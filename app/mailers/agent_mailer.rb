class AgentMailer < ApplicationMailer
  def invitation(user)
    @user = user
    mail subject: "You've been invited to the helpdesk", to: user.email_address
  end

  def assigned(ticket, assigned_by:)
    @ticket = ticket
    @assigned_by = assigned_by
    mail subject: "#{assigned_by.display_name} assigned you #{ticket.reference} #{ticket.subject}",
         to: ticket.assignee.email_address
  end
end
