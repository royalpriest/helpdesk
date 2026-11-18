# Creates a demo agent, a customer and a couple of tickets so you can
# click around right after `bin/setup`.
# Demo data has a well-known password, so it's never loaded in production
# unless this is the public demo (DEMO_MODE=true).
if Rails.env.production? && ENV["DEMO_MODE"] != "true"
  puts "Skipping demo data in production. Create your first agent with bin/rails console."
else
  agent = User.find_or_create_by!(email_address: "agent@example.com") do |u|
    u.name = "Demo Agent"
    u.admin = true
    u.password = "password"
  end

  customer = Customer.find_or_create_by!(email_address: "customer@example.com") { |c| c.name = "Casey Customer" }

  CannedReply.find_or_create_by!(title: "Password reset") do |r|
    r.body = "You can reset your password from the sign in page by clicking \"Forgot password?\"."
  end
  CannedReply.find_or_create_by!(title: "Thanks, closing") do |r|
    r.body = "Glad that's sorted, {{customer_name}}! I'll close this ticket, but just reply if anything else comes up."
  end

  teammate = User.find_or_create_by!(email_address: "sam@example.com") do |u|
    u.name = "Sam Rivera"
    u.password = SecureRandom.hex(16)
  end

  support = Inbox.default
  billing = Inbox.find_or_create_by!(email_address: "billing@example.com") { |i| i.name = "Billing" }

  if customer.tickets.none?
    ticket = customer.tickets.create!(subject: "Can't log in", inbox: support)
    ticket.add_customer_message!(body: "Hi, I keep getting 'invalid password' even after resetting it.")
    ticket.add_tag("login")

    other = customer.tickets.create!(subject: "Invoice question", assignee: agent, inbox: billing)
    other.add_customer_message!(body: "Could you resend last month's invoice? I can't find it in my email.")
    other.add_internal_note!(user: agent, body: "Their invoice bounced last month, so check the billing address first.")
    other.add_agent_reply!(user: agent, body: "Hi Casey, I've just resent it. It should arrive within a few minutes.")
    other.add_tag("billing")

    jordan = Customer.find_or_create_by!(email_address: "jordan@example.com") { |c| c.name = "Jordan Lee" }
    export = jordan.tickets.create!(subject: "Export to CSV?", assignee: teammate, inbox: support)
    export.add_customer_message!(body: "Is there a way to export all our tickets to a spreadsheet?")
    export.add_tag("feature-request")

    done = jordan.tickets.create!(subject: "Change my email address", assignee: agent, inbox: support)
    done.add_customer_message!(body: "Please change my login email to jordan.lee@example.com.")
    done.add_agent_reply!(user: agent, body: "Done! You can sign in with the new address now.")
    done.update!(status: "closed")
    done.rate!("good", comment: "Super quick, thanks!")

    # Spread the demo tickets out in time, so the inbox shows realistic waiting times.
    ticket.update_columns(waiting_since: 5.hours.ago, updated_at: 5.hours.ago)
    ticket.messages.update_all(created_at: 5.hours.ago)
    export.update_columns(waiting_since: 50.minutes.ago, updated_at: 50.minutes.ago)
    export.messages.update_all(created_at: 50.minutes.ago)
    other.messages.order(:id).each_with_index { |message, i| message.update_columns(created_at: (3.hours - (i * 20).minutes).ago) }
    other.update_columns(updated_at: 2.hours.ago)
    done.messages.update_all(created_at: 1.day.ago)
    done.update_columns(updated_at: 1.day.ago)
  end

  puts "Sign in as agent@example.com / password"
end
