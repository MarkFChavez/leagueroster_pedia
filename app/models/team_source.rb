class TeamSource < ApplicationRecord
  has_many :teams, dependent: :destroy

  validates :short_name, presence: true, uniqueness: true
  validates :long_name, presence: true

  def sync
    return unless external_team_url.present?

    response = HTTParty.get(external_team_url)
    return unless response.success?

    doc = Nokogiri::HTML(response.body)

    # Find the infobox table with team information (note: capital I in InfoboxTeam)
    infobox = doc.at_css("table.InfoboxTeam")
    return unless infobox

    # Extract org_location and region from the infobox
    org_location = extract_infobox_value(infobox, "Org Location")
    region = extract_infobox_value(infobox, "Region")

    # Create or update the team record
    team = teams.first_or_initialize
    team.update(
      org_location: org_location,
      region: region
    )

    # Update last synced timestamp
    update(last_synced_at: Time.current)
  end

  private

  def extract_infobox_value(infobox, label)
    # Find the td cell with the matching label text
    label_cell = infobox.css("td").find { |td| td.text.strip == label }
    return nil unless label_cell

    # Get the parent row and find the next td sibling (the value cell)
    row = label_cell.parent
    cells = row.css("td")

    # The value is typically in the second td
    return nil if cells.size < 2

    value_cell = cells[1]

    # Try to get short code from div.region-icon first (for Region field)
    region_icon = value_cell.at_css('div.region-icon')
    return region_icon.text.strip if region_icon

    # Fall back to markup-object-name (for Org Location and other fields)
    markup_name = value_cell.at_css('span.markup-object-name')
    return markup_name.text.strip if markup_name

    # Final fallback to all text
    value_cell.text.strip
  end
end
