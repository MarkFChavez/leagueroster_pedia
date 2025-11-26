# Team Badge Helper - Quick Reference

## Basic Usage

```erb
<!-- Hexagon badge (primary) -->
<%= team_hexagon_badge(team, size: 'small') %>
<%= team_hexagon_badge(team, size: 'large') %>

<!-- Shield badge (alternative) -->
<%= team_shield_badge(team, size: 'small') %>
<%= team_shield_badge(team, size: 'large') %>

<!-- Geometric badge (alternative) -->
<%= team_geometric_badge(team, size: 'small') %>
<%= team_geometric_badge(team, size: 'large') %>
```

## Size Reference

| Size | Dimensions | Tailwind Classes | Use Case |
|------|-----------|------------------|----------|
| `'small'` | 64x64px | `w-14 h-14` to `w-16 h-16` | Index cards, lists |
| `'medium'` | 80x80px | `w-20 h-20` | Default, general purpose |
| `'large'` | 128x128px | `w-24 h-24` to `w-32 h-32` | Detail pages, headers |

## Region Colors

| Region | Color | Hex Code |
|--------|-------|----------|
| LCK | Red | `#E74C3C` |
| LPL | Orange | `#F39C12` |
| LEC | Blue | `#3498DB` |
| LCS | Purple | `#9B59B6` |
| PCS | Green | `#2ECC71` |
| VCS | Dark Orange | `#E67E22` |
| CBLOL | Teal | `#1ABC9C` |
| LJL | Pink | `#E91E63` |
| LLA | Deep Orange | `#FF5722` |
| **Unknown** | Gold | `#C4A15B` |

## With Image Fallback

```erb
<% if team.logo_url.present? %>
  <div class="w-16 h-16 flex items-center justify-center">
    <img src="<%= team.logo_url %>"
         alt="<%= team.name %>"
         onerror="this.parentElement.replaceWith(document.createElement('div'));
                  this.parentElement.parentElement.insertAdjacentHTML('beforeend',
                  '<%= j team_hexagon_badge(team, size: 'small').gsub("'", "\\'") %>')">
  </div>
<% else %>
  <%= team_hexagon_badge(team, size: 'small') %>
<% end %>
```

## Initials Logic

The helper automatically extracts initials:

| Team Name | Short Name | Result |
|-----------|------------|--------|
| Team T1 | T1 | `T1` |
| G2 Esports | G2 | `G2` |
| FunPlus Phoenix | FPX | `FPX` |
| Team SoloMid | - | `TSM` |
| CLG | - | `CLG` |

**Rules:**
1. If `team.short_name` exists, use first 3 chars
2. If multiple words, take first letter of each (max 3)
3. If single word, take first 3 characters

## Styling Tips

### Custom Wrapper Styles

```erb
<!-- Add custom container -->
<div class="flex-shrink-0 group-hover:scale-110 transition-transform">
  <%= team_hexagon_badge(team, size: 'large') %>
</div>
```

### In Card Layouts

```erb
<div class="flex items-center gap-4">
  <%= team_hexagon_badge(team, size: 'small') %>
  <div>
    <h3><%= team.name %></h3>
    <p><%= team.region %></p>
  </div>
</div>
```

## Common Patterns

### Team Grid

```erb
<div class="grid grid-cols-3 gap-4">
  <% teams.each do |team| %>
    <div class="text-center">
      <%= team_hexagon_badge(team, size: 'large') %>
      <p class="mt-2"><%= team.short_name %></p>
    </div>
  <% end %>
</div>
```

### Team Dropdown

```erb
<select>
  <% teams.each do |team| %>
    <option value="<%= team.id %>">
      <%= team.short_name %> (<%= team.region %>)
    </option>
  <% end %>
</select>
```

### Empty State

```erb
<% if teams.empty? %>
  <div class="text-center">
    <%= team_hexagon_badge(OpenStruct.new(name: 'No Teams', region: 'UNKNOWN'), size: 'large') %>
    <p>No teams available</p>
  </div>
<% end %>
```

## Troubleshooting

### Badge Not Showing
- Ensure helper is loaded: check `app/helpers/team_logo_helper.rb` exists
- Verify team has name: `team.name.present?`
- Check view includes helper module

### Wrong Colors
- Verify `team.region` matches region codes (uppercase)
- Unknown regions default to gold
- Check spelling: "LCK" not "lck"

### Initials Too Long
- Helper automatically limits to 3 characters
- Override by setting `team.short_name`

### Performance Issues
- Badges are lightweight (~800 bytes)
- No N+1 queries (all data on team object)
- Consider caching for large lists

## Advanced Customization

### Custom Colors

Edit `REGION_COLORS` in `app/helpers/team_logo_helper.rb`:

```ruby
REGION_COLORS = {
  'CUSTOM' => {
    primary: '#FF0000',
    secondary: '#CC0000',
    glow: 'rgba(255, 0, 0, 0.6)'
  }
}
```

### Custom Patterns

Add to `geometric_pattern` method:

```ruby
patterns = [
  # Your custom SVG here
  '<circle cx="50" cy="50" r="30" stroke="white" fill="none"/>'
]
```

### Custom Size

```erb
<!-- Inline override (not recommended) -->
<div class="w-32 h-32">
  <%= team_hexagon_badge(team, size: 'large') %>
</div>
```

## Demo Partial

To see all three badge styles:

```erb
<%= render 'teams/badge_alternatives', team: @team %>
```

This shows hexagon, shield, and geometric badges side-by-side.

## Testing

```ruby
# In Rails console
team = Team.first
helper.team_hexagon_badge(team, size: 'small')
# => "<div class='...'><svg>...</svg></div>"
```

## Files Reference

- **Helper:** `app/helpers/team_logo_helper.rb`
- **Views:** `app/views/teams/index.html.erb`, `show.html.erb`
- **Demo:** `app/views/teams/_badge_alternatives.html.erb`
- **Docs:** `/TEAM_LOGO_BADGES.md`, `/DESIGN_EXPLANATION.md`
