# A label agents put on tickets, like "billing" or "bug".
class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tickets, through: :taggings

  normalizes :name, with: ->(name) { name.to_s.strip.downcase.gsub(/\s+/, "-") }

  validates :name, presence: true, uniqueness: true, length: { maximum: 40 }

  scope :alphabetical, -> { order(:name) }
  scope :in_use, -> { where(id: Tagging.select(:tag_id)) }

  def to_param
    name
  end
end
