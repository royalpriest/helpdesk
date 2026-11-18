# A conversation with a customer.
class Ticket < ApplicationRecord
  STATUSES = %w[open pending closed].freeze

  belongs_to :customer
  belongs_to :assignee, class_name: "User", optional: true
  has_many :messages, -> { order(:created_at) }, dependent: :destroy, inverse_of: :ticket

  has_secure_token :portal_token

  enum :status, STATUSES.index_by(&:itself), default: "open", validate: true

  validates :subject, presence: true

  scope :unassigned, -> { where(assignee_id: nil) }
  scope :assigned_to, ->(user) { where(assignee: user) }
  scope :recent_first, -> { order(updated_at: :desc) }

  # The tag that ties an email thread back to this ticket, e.g. "[#42]".
  def reference
    "[##{id}]"
  end

  # Pulls a ticket id out of a subject like "Re: [#42] Can't log in".
  def self.id_from_subject(subject)
    subject.to_s[/\[#(\d+)\]/, 1]&.to_i
  end

  # Records a customer's message and reopens the ticket if it was closed.
  def add_customer_message!(body:, email_message_id: nil)
    transaction do
      messages.create!(body: body, email_message_id: email_message_id)
      update!(status: "open") unless open?
      touch
    end
  end

  # Records an agent's reply and emails it to the customer.
  def add_agent_reply!(user:, body:)
    message = transaction do
      update!(status: "pending") if open?
      touch
      messages.create!(user: user, body: body)
    end
    TicketMailer.reply(message).deliver_later
    message
  end
end
