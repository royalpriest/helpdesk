# Someone who writes in for help. Customers don't have passwords;
# they reach their tickets through the private portal link in each email.
class Customer < ApplicationRecord
  has_many :tickets, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true

  def display_name
    name.presence || email_address
  end
end
