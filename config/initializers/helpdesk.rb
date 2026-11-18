# The address customers write to. Incoming mail to it becomes tickets,
# and replies are sent from it.
Rails.application.config.x.support_email = ENV.fetch("SUPPORT_EMAIL", "support@example.com")

# Tickets waiting on the customer ("pending") are closed after this many days
# without a reply. A later reply from the customer reopens them.
Rails.application.config.x.auto_close_after_days = ENV.fetch("AUTO_CLOSE_AFTER_DAYS", 7).to_i
