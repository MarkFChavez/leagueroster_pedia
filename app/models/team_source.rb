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

    # Extract and sync player roster
    sync_players(doc, team)

    # Update last synced timestamp
    update(last_synced_at: Time.current)
  end

  private

  def sync_players(doc, team)
    # Find the roster table
    roster_table = doc.at_css("table.wikitable.team-members")
    return unless roster_table

    # Delete existing players (as requested: delete removed players)
    team.players.destroy_all

    # Extract player rows from tbody
    roster_table.css("tbody tr").each do |row|
      player_data = extract_player_data(row)
      next unless player_data

      team.players.create(player_data)
    end
  end

  def extract_player_data(row)
    cells = row.css("td")
    return nil if cells.size < 7

    # Extract data from specific column indices
    # Column 2: Player (IGN)
    # Column 3: Name (Real name)
    # Column 4: Role
    # Column 5: Contract Ends
    # Column 6: Date Joined

    ign = cells[2]&.text&.strip
    name = cells[3]&.text&.strip
    role = cells[4]&.text&.strip
    contract_ends = parse_date(cells[5])
    date_joined = parse_date(cells[6])

    # Clean up role (remove "Laner" suffix, etc.)
    role = clean_role(role) if role

    {
      ign: ign,
      name: name,
      role: role,
      contract_ends: contract_ends,
      date_joined: date_joined
    }
  end

  def parse_date(cell)
    return nil unless cell

    # Try data-sort-value attribute first (timestamp or date string)
    if cell['data-sort-value']
      date_value = cell['data-sort-value']

      # Check if it's a Unix timestamp (all digits)
      if date_value.match?(/^\d+$/)
        begin
          return Time.at(date_value.to_i).to_date
        rescue
          # Fall through to text parsing
        end
      end

      # Try parsing as date string
      begin
        return Date.parse(date_value)
      rescue ArgumentError
        # Fall through to text parsing
      end
    end

    # Fall back to parsing cell text directly
    cell_text = cell.text.strip

    # Look for ISO date format (YYYY-MM-DD) in the text
    if cell_text.match?(/\d{4}-\d{2}-\d{2}/)
      date_match = cell_text.match(/(\d{4}-\d{2}-\d{2})/)
      begin
        return Date.parse(date_match[1])
      rescue ArgumentError
        nil
      end
    end

    nil
  end

  def clean_role(role)
    # Normalize role names
    role.gsub(/\s*Laner?\s*$/i, '').strip
  end

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
