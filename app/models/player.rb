class Player < ApplicationRecord
  belongs_to :team

  validates :ign, presence: true
  validates :role, presence: true
end
