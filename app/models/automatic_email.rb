# Recognises email that was sent by a machine rather than a person:
# out-of-office replies, bounces and bulk or mailing-list mail.
module AutomaticEmail
  SYSTEM_SENDERS = /\A(mailer-daemon|postmaster)@/i
  BULK_PRECEDENCE = %w[bulk junk list auto_reply].freeze

  def self.automatic?(mail)
    auto_submitted?(mail) ||
      BULK_PRECEDENCE.include?(header(mail, "Precedence").downcase) ||
      header(mail, "X-Autoreply").present? ||
      header(mail, "X-Autorespond").present? ||
      delivery_report?(mail) ||
      Array(mail.from).any? { |address| address.match?(SYSTEM_SENDERS) }
  end

  # RFC 3834: anything other than "no" means the message was sent automatically.
  def self.auto_submitted?(mail)
    value = header(mail, "Auto-Submitted").downcase
    value.present? && value != "no"
  end

  def self.delivery_report?(mail)
    mail.mime_type == "multipart/report" || mail.content_type.to_s.include?("report-type=delivery-status")
  end

  def self.header(mail, name)
    mail[name]&.value.to_s.strip
  end
  private_class_method :header
end
