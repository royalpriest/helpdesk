class ApplicationMailer < ActionMailer::Base
  default from: -> { Rails.configuration.x.support_email }
  layout "mailer"
end
