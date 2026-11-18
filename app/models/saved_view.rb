# An agent's saved combination of inbox filter, tag and search.
class SavedView < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 40 }
  validates :filter, inclusion: { in: TicketsController::FILTERS }

  scope :alphabetical, -> { order(:name) }

  def params
    { filter: filter, tag: tag.presence, q: query.presence }.compact
  end
end
