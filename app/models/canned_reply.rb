# A saved answer agents can insert into a reply.
class CannedReply < ApplicationRecord
  validates :title, :body, presence: true

  scope :alphabetical, -> { order(:title) }
end
