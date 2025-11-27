class TeamSource < ApplicationRecord
  validates :short_name, presence: true, uniqueness: true
  validates :long_name, presence: true
end
