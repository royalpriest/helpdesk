module Portal
  class TicketsController < BaseController
    before_action :set_ticket

    def show
      @messages = @ticket.messages.visible_to_customer.includes(:user, attachments_attachments: :blob)
    end
  end
end
