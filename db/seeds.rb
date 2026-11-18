# Creates a demo agent, a customer and a couple of tickets so you can
# click around right after `bin/setup`.
# Demo data has a well-known password, so it's never loaded in production.
if Rails.env.production?
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

  if customer.tickets.none?
    ticket = customer.tickets.create!(subject: "Can't log in")
    ticket.add_customer_message!(body: "Hi, I keep getting 'invalid password' even after resetting it.")

    other = customer.tickets.create!(subject: "Invoice question", assignee: agent)
    other.add_customer_message!(body: "Could you resend last month's invoice?")
  end

  puts "Sign in as agent@example.com / password"
end
