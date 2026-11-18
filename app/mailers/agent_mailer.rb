class AgentMailer < ApplicationMailer
  def invitation(user)
    @user = user
    mail subject: "You've been invited to the helpdesk", to: user.email_address
  end
end
