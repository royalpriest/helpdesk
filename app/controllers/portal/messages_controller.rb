module Portal
  class MessagesController < BaseController
    before_action :set_ticket

    def create
      body = params.expect(message: [ :body ])[:body]

      if body.blank?
        redirect_to portal_ticket_path(@ticket.portal_token), alert: "Message can't be blank."
      else
        @ticket.add_customer_message!(body: body)
        redirect_to portal_ticket_path(@ticket.portal_token), notice: "Message sent."
      end
    end
  end
end
