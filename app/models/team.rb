class Team < ApplicationRecord
  has_many :players, dependent: :destroy

  validates :name, presence: true
  validates :region, presence: true
end
