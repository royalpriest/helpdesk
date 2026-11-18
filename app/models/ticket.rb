# A conversation with a customer.
class Ticket < ApplicationRecord
  STATUSES = %w[open pending closed].freeze
  RATINGS = %w[good bad].freeze

  belongs_to :customer
  belongs_to :assignee, class_name: "User", optional: true
  has_many :messages, -> { order(:created_at) }, dependent: :destroy, inverse_of: :ticket

  has_secure_token :portal_token

  # Pages showing this ticket, and the inbox, refresh themselves when it changes.
  broadcasts_refreshes
  broadcasts_refreshes_to ->(_ticket) { :tickets }

  enum :status, STATUSES.index_by(&:itself), default: "open", validate: true

  validates :subject, presence: true
  validates :rating, inclusion: { in: RATINGS }, allow_nil: true

  before_save :track_pending_since, if: :status_changed?

  scope :unassigned, -> { where(assignee_id: nil) }
  scope :assigned_to, ->(user) { where(assignee: user) }
  scope :recent_first, -> { order(updated_at: :desc) }
  scope :not_closed, -> { where.not(status: "closed") }
  scope :pending_before, ->(time) { pending.where(pending_since: ...time) }

  # Matches the subject, any message body, or the customer's email or name.
  def self.search(query)
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query.strip)}%"
    ids = left_joins(:messages).joins(:customer).where(
      "tickets.subject LIKE :q OR messages.body LIKE :q OR customers.email_address LIKE :q OR customers.name LIKE :q",
      q: pattern
    ).select(:id)
    where(id: ids)
  end

  scope :rated_since, ->(time) { where(rated_at: time..) }

  # Share of "good" ratings, as a whole percentage, or nil with no ratings.
  def self.satisfaction_score(since: 30.days.ago)
    rated = rated_since(since)
    total = rated.count
    (rated.where(rating: "good").count * 100.0 / total).round if total.positive?
  end

  def rate!(rating, comment: nil)
    update!(rating: rating, rating_comment: comment.presence, rated_at: Time.current)
  end

  def awaiting_rating?
    closed? && rated_at.nil?
  end

  # The inbox filters: "mine", "unassigned", "open" or "all".
  def self.for_filter(filter, user)
    case filter
    when "mine" then assigned_to(user).not_closed
    when "unassigned" then unassigned.not_closed
    when "open" then not_closed
    else all
    end
  end

  # The tag that ties an email thread back to this ticket, e.g. "[#42]".
  def reference
    "[##{id}]"
  end

  # Pulls a ticket id out of a subject like "Re: [#42] Can't log in".
  def self.id_from_subject(subject)
    subject.to_s[/\[#(\d+)\]/, 1]&.to_i
  end

  # Records a customer's message and reopens the ticket if it was closed.
  def add_customer_message!(body:, email_message_id: nil, attachments: [])
    transaction do
      messages.create!(body: body, email_message_id: email_message_id, attachments: attachments)
      update!(status: "open") unless open?
      touch
    end
  end

  # Records a note only agents can see. It isn't emailed and doesn't change the status.
  def add_internal_note!(user:, body:)
    transaction do
      touch
      messages.create!(user: user, body: body, internal: true)
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

  private
    def track_pending_since
      self.pending_since = pending? ? Time.current : nil
    end
end
