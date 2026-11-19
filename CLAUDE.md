# Notes for Claude

## Commits and pull requests
- Do not add `Co-Authored-By: Claude`, `Claude-Session:` or any other Claude attribution lines to commit messages.
- Do not add "Generated with Claude Code" or similar footers to pull request descriptions or comments.
- Do not put "claude" in branch names (no `claude/...` prefix). Use a short descriptive name such as `fix/codespaces-sign-in` or `docs/changelog`.

## Project
- Rails 8 app with SQLite, Solid Queue, Solid Cable, Hotwire and importmaps. No Node build step.
- Incoming email: `app/mailboxes/support_mailbox.rb`. Ticket rules live in `app/models/ticket.rb`.
- Before opening a pull request, run `bin/rails test`, `bin/rubocop` and `bin/brakeman --no-pager`.
- One pull request per issue where practical, with `Closes #N` in the description.
