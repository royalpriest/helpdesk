# A saved answer agents can insert into a reply.
class CannedReply < ApplicationRecord
  validates :title, :body, presence: true

  scope :alphabetical, -> { order(:title) }

  PLACEHOLDERS = %w[customer_name agent_name ticket_reference].freeze

  # Fills in {{customer_name}}, {{agent_name}} and {{ticket_reference}}.
  # Unknown placeholders are left as they are so typos are easy to spot.
  def render_for(ticket:, agent:)
    values = {
      "customer_name" => ticket.customer.display_name,
      "agent_name" => agent.display_name,
      "ticket_reference" => ticket.reference
    }
    body.gsub(/\{\{\s*(\w+)\s*\}\}/) { values.fetch($1, $&) }
  end
end
