# Closes tickets that have been waiting on the customer for too long.
# Runs hourly from config/recurring.yml.
class CloseStalePendingTicketsJob < ApplicationJob
  queue_as :default

  def perform(days: Rails.configuration.x.auto_close_after_days)
    return if days <= 0

    Ticket.pending_before(days.days.ago).find_each do |ticket|
      ticket.update!(status: "closed")
    end
  end
end
