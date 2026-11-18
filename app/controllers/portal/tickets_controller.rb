module Portal
  class TicketsController < BaseController
    before_action :set_ticket

    def show
      @messages = @ticket.messages.includes(:user)
    end
  end
end
