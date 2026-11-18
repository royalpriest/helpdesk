module Portal
  class TicketsController < BaseController
    before_action :set_ticket

    def show
      @messages = @ticket.messages.includes(:user, attachments_attachments: :blob)
    end
  end
end
