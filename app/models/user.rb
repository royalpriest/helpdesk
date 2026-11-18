# A staff member who answers tickets.
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :saved_views, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :nullify

  # The link in an invitation email. It stops working once the agent sets a password.
  generates_token_for :invitation, expires_in: 7.days do
    password_salt&.last(10)
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true

  scope :active, -> { where(deactivated_at: nil) }
  scope :admins, -> { active.where(admin: true) }
  scope :alphabetical, -> { order(:name, :email_address) }

  # Creates an agent with a random password and emails them a link to choose their own.
  def self.invite!(name:, email_address:)
    create!(name: name, email_address: email_address, password: SecureRandom.base58(32)).tap do |user|
      AgentMailer.invitation(user).deliver_later
    end
  end

  def display_name
    name.presence || email_address
  end

  def active?
    deactivated_at.nil?
  end

  # Signs the agent out everywhere and takes them off their open tickets.
  def deactivate!
    transaction do
      update!(deactivated_at: Time.current)
      sessions.destroy_all
      assigned_tickets.not_closed.update_all(assignee_id: nil)
    end
  end

  # The team always needs at least one admin who can manage agents.
  def last_admin?
    admin? && User.admins.where.not(id: id).none?
  end

  def reactivate!
    update!(deactivated_at: nil)
  end
end
