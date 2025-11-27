class Team < ApplicationRecord
  belongs_to :team_source
  has_many :players, dependent: :destroy

  validates :org_location, presence: true
  validates :region, presence: true
end
