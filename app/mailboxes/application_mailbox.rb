class ApplicationMailbox < ActionMailbox::Base
  # Every email sent to the support address goes to the shared inbox.
  routing all: :support
end
