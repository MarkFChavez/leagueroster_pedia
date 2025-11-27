class TeamSource < ApplicationRecord
  has_many :teams, dependent: :destroy

  validates :short_name, presence: true, uniqueness: true
  validates :long_name, presence: true
end
