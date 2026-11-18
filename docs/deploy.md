# Deploying Helpdesk

This guide runs Helpdesk on a single Linux server (Ubuntu 24.04 or newer) with:

- **Puma** serving the app, with Solid Queue running inside it for background jobs
- **SQLite** for the database (it lives in `storage/`, so back that folder up)
- **Caddy** in front for HTTPS
- **Postmark** for inbound and outbound email (other providers work too, see the end)

A $5–10/month VPS is plenty for a small team.

## 1. Prepare the server

Point a DNS record such as `help.example.com` at your server, then on the server:

```sh
sudo apt update
sudo apt install -y git build-essential libyaml-dev libsqlite3-dev libvips caddy

# Install Ruby 3.3 with mise (any Ruby version manager is fine)
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
mise use --global ruby@3.3
```

## 2. Get the code

```sh
sudo mkdir -p /srv/helpdesk && sudo chown $USER /srv/helpdesk
git clone https://github.com/royalpriest/helpdesk.git /srv/helpdesk
cd /srv/helpdesk
bundle config set --local deployment true
bundle config set --local without "development test"
bundle install
```

## 3. Configure it

Create `/srv/helpdesk/.env` (it is git-ignored) and fill in your values:

```sh
RAILS_ENV=production
SECRET_KEY_BASE=          # run: bin/rails secret
APP_HOST=help.example.com
SUPPORT_EMAIL=support@example.com
SOLID_QUEUE_IN_PUMA=1

# Outgoing mail (Postmark's SMTP server; username and password are both your server token)
SMTP_ADDRESS=smtp.postmarkapp.com
SMTP_USERNAME=your-postmark-server-token
SMTP_PASSWORD=your-postmark-server-token

# Incoming mail
ACTION_MAILBOX_INGRESS=postmark
RAILS_INBOUND_EMAIL_PASSWORD=   # run: bin/rails secret

# Optional
AUTO_CLOSE_AFTER_DAYS=7
```

Then set up the database and assets:

```sh
set -a; source .env; set +a
bin/rails db:prepare
bin/rails assets:precompile
```

Create your first agent (demo data is never loaded in production):

```sh
bin/rails runner 'User.create!(name: "Your Name", email_address: "you@example.com", password: "a-long-password")'
```

## 4. Run it with systemd

Create `/etc/systemd/system/helpdesk.service`, replacing `deploy` with your user name:

```ini
[Unit]
Description=Helpdesk
After=network.target

[Service]
User=deploy
WorkingDirectory=/srv/helpdesk
EnvironmentFile=/srv/helpdesk/.env
ExecStart=/home/deploy/.local/bin/mise exec -- bin/rails server -b 127.0.0.1 -p 3000
Restart=always

[Install]
WantedBy=multi-user.target
```

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now helpdesk
```

## 5. Put Caddy in front

Replace `/etc/caddy/Caddyfile` with:

```
help.example.com {
  reverse_proxy 127.0.0.1:3000
}
```

```sh
sudo systemctl reload caddy
```

Caddy gets an HTTPS certificate for you. Open `https://help.example.com` and sign in.

## 6. Receive email

In Postmark:

1. Open your server's **Default Inbound Stream** and set the webhook URL to
   `https://actionmailbox:YOUR_RAILS_INBOUND_EMAIL_PASSWORD@help.example.com/rails/action_mailbox/postmark/inbound_emails`
2. Tick **Include raw email content in JSON payload**.
3. Forward your `SUPPORT_EMAIL` address to the inbound address Postmark shows you (or use Postmark's
   inbound domain forwarding).
4. In **Sender Signatures**, verify your `SUPPORT_EMAIL` so replies can be sent from it.

Send a test email to your support address. It should appear as a ticket within a few seconds.

## Run with Docker instead

If you'd rather not install Ruby on the server, use the Docker image. It runs Puma with Solid Queue
inside it, and keeps the databases and attachments in a volume.

```sh
docker run -d --name helpdesk --restart unless-stopped \
  -p 127.0.0.1:3000:3000 \
  -v helpdesk-storage:/rails/storage \
  -e SECRET_KEY_BASE=$(openssl rand -hex 64) \
  -e APP_HOST=help.example.com \
  -e SUPPORT_EMAIL=support@example.com \
  -e SMTP_ADDRESS=smtp.postmarkapp.com \
  -e SMTP_USERNAME=your-postmark-server-token \
  -e SMTP_PASSWORD=your-postmark-server-token \
  -e ACTION_MAILBOX_INGRESS=postmark \
  -e RAILS_INBOUND_EMAIL_PASSWORD=choose-a-long-random-string \
  ghcr.io/royalpriest/helpdesk:latest
```

Keep the same `SECRET_KEY_BASE` between restarts (put the variables in a file and use
`--env-file`), or everyone gets signed out. Create the first agent with:

```sh
docker exec -it helpdesk bin/rails runner 'User.create!(name: "Your Name", email_address: "you@example.com", password: "a-long-password", admin: true)'
```

Then set up Caddy (step 5) and inbound email (step 6) as above. To update, pull the new image
and recreate the container; migrations run automatically on start.

To try it on your own computer without HTTPS, add `-e FORCE_SSL=false -e ASSUME_SSL=false`, publish
the port with `-p 3000:3000` and open http://localhost:3000. You can also build the image yourself
with `docker build -t helpdesk .`.

## Updating

```sh
cd /srv/helpdesk
git pull
bundle install
set -a; source .env; set +a
bin/rails db:migrate
bin/rails assets:precompile
sudo systemctl restart helpdesk
```

## Backups

Everything lives in `/srv/helpdesk/storage/`: the SQLite databases and uploaded attachments. Copy it
somewhere safe on a schedule, for example with `sqlite3 storage/production.sqlite3 ".backup ..."` or
[Litestream](https://litestream.io).

## Other mail providers

Action Mailbox also supports Mailgun, Mandrill, SendGrid and a plain SMTP relay (for Postfix or
Exim). Set `ACTION_MAILBOX_INGRESS` to `mailgun`, `mandrill`, `sendgrid` or `relay` and follow the
[Action Mailbox guide](https://guides.rubyonrails.org/action_mailbox_basics.html#configuration) for
that provider's webhook URL. Use the provider's SMTP details for `SMTP_*`.
