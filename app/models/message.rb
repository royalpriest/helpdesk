# One message on a ticket. A message with a user was written by an agent;
# a message without one came from the customer.
class Message < ApplicationRecord
  belongs_to :ticket, inverse_of: :messages
  belongs_to :user, optional: true
  has_many_attached :attachments

  validates :body, presence: true

  after_create_commit -> { ticket.reload.update_search_index }

  # Internal notes are for agents only: never emailed, never shown in the portal.
  scope :visible_to_customer, -> { where(internal: false) }

  def from_agent?
    user_id.present?
  end

  def author_name
    from_agent? ? user.display_name : ticket.customer.display_name
  end
end
