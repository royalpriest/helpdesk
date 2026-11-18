# The address customers write to. Incoming mail to it becomes tickets,
# and replies are sent from it.
Rails.application.config.x.support_email = ENV.fetch("SUPPORT_EMAIL", "support@example.com")
