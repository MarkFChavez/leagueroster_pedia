class Team < ApplicationRecord
  belongs_to :team_source
  has_many :players, dependent: :destroy
end
