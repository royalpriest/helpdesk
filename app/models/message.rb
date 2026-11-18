# One message on a ticket. A message with a user was written by an agent;
# a message without one came from the customer.
class Message < ApplicationRecord
  belongs_to :ticket, inverse_of: :messages
  belongs_to :user, optional: true

  validates :body, presence: true

  def from_agent?
    user_id.present?
  end

  def author_name
    from_agent? ? user.display_name : ticket.customer.display_name
  end
end
