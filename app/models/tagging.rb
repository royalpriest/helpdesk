class Tagging < ApplicationRecord
  belongs_to :ticket, touch: true
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :ticket_id }
end
