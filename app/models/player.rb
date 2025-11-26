class Player < ApplicationRecord
  belongs_to :team

  scope :ordered_by_role, lambda {
    order(
      Arel.sql(
        "CASE
          WHEN LOWER(role) IN ('top', 'top laner', 'toplane') THEN 1
          WHEN LOWER(role) IN ('jungle', 'jungler') THEN 2
          WHEN LOWER(role) IN ('mid', 'mid laner', 'midlane', 'middle') THEN 3
          WHEN LOWER(role) IN ('adc', 'ad carry', 'bot', 'bottom', 'bot laner') THEN 4
          WHEN LOWER(role) IN ('support', 'sup') THEN 5
          ELSE 6
        END, role"
      )
    )
  }
end
