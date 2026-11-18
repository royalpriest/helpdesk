# An address customers write to, like support@ or billing@. Each ticket belongs
# to the inbox its first email was sent to, and replies go out from that address.
class Inbox < ApplicationRecord
  has_many :tickets, dependent: :restrict_with_error

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :alphabetical, -> { order(:name) }

  # The inbox for SUPPORT_EMAIL, used when incoming mail matches no other inbox.
  def self.default
    support_email = Rails.configuration.x.support_email.strip.downcase
    find_by(email_address: support_email) || order(:id).first || create!(name: "Support", email_address: support_email)
  end

  # Picks the inbox matching any of the given addresses, or the default one.
  def self.for_addresses(addresses)
    normalized = Array(addresses).compact.map { |address| address.to_s.strip.downcase }
    find_by(email_address: normalized) || default
  end

  # "Billing <billing@example.com>"
  def from_address
    ActionMailer::Base.email_address_with_name(email_address, name)
  end

  def domain
    email_address.split("@").last
  end
end
