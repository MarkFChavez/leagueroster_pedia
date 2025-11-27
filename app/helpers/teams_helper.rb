module TeamsHelper
  def team_logo_config(team)
    # Get region-based colors
    region = team.region || 'Unknown'
    region_colors = region_color_config(region)

    # Map region colors to logo format
    color_map = {
      'LCK' => { base: 'red', rgba: '239,68,68' },
      'LPL' => { base: 'yellow', rgba: '234,179,8' },
      'LEC' => { base: 'blue', rgba: '59,130,246' },
      'LCS' => { base: 'purple', rgba: '168,85,247' },
      'PCS' => { base: 'green', rgba: '34,197,94' },
      'VCS' => { base: 'teal', rgba: '20,184,166' },
      'CBLOL' => { base: 'orange', rgba: '249,115,22' },
      'LLA' => { base: 'pink', rgba: '236,72,153' }
    }

    color_info = color_map[region] || { base: 'gray', rgba: '156,163,175' }
    base_color = color_info[:base]

    # Return consistent circle config with region-based colors
    {
      shape: 'circle',
      clip_path: nil,
      gradient_from: "from-#{base_color}-600/20",
      gradient_to: "to-#{base_color}-900/10",
      border_color: "border-#{base_color}-500/30",
      text_color: "text-#{base_color}-400",
      hover_border: "group-hover:border-#{base_color}-400/50",
      hover_shadow: "group-hover:shadow-[0_0_20px_rgba(#{color_info[:rgba]},0.4)]"
    }
  end

  def region_color_config(region)
    configs = {
      'LCK' => {
        border: 'border-red-500/30',
        badge_bg: 'bg-red-500/10',
        badge_border: 'border-red-500/30',
        badge_text: 'text-red-400',
        hover_border: 'hover:border-red-500/50'
      },
      'LPL' => {
        border: 'border-yellow-500/30',
        badge_bg: 'bg-yellow-500/10',
        badge_border: 'border-yellow-500/30',
        badge_text: 'text-yellow-400',
        hover_border: 'hover:border-yellow-500/50'
      },
      'LEC' => {
        border: 'border-blue-500/30',
        badge_bg: 'bg-blue-500/10',
        badge_border: 'border-blue-500/30',
        badge_text: 'text-blue-400',
        hover_border: 'hover:border-blue-500/50'
      },
      'LCS' => {
        border: 'border-purple-500/30',
        badge_bg: 'bg-purple-500/10',
        badge_border: 'border-purple-500/30',
        badge_text: 'text-purple-400',
        hover_border: 'hover:border-purple-500/50'
      },
      'PCS' => {
        border: 'border-green-500/30',
        badge_bg: 'bg-green-500/10',
        badge_border: 'border-green-500/30',
        badge_text: 'text-green-400',
        hover_border: 'hover:border-green-500/50'
      },
      'VCS' => {
        border: 'border-teal-500/30',
        badge_bg: 'bg-teal-500/10',
        badge_border: 'border-teal-500/30',
        badge_text: 'text-teal-400',
        hover_border: 'hover:border-teal-500/50'
      },
      'CBLOL' => {
        border: 'border-orange-500/30',
        badge_bg: 'bg-orange-500/10',
        badge_border: 'border-orange-500/30',
        badge_text: 'text-orange-400',
        hover_border: 'hover:border-orange-500/50'
      },
      'LLA' => {
        border: 'border-pink-500/30',
        badge_bg: 'bg-pink-500/10',
        badge_border: 'border-pink-500/30',
        badge_text: 'text-pink-400',
        hover_border: 'hover:border-pink-500/50'
      }
    }

    # Return config for the region or default gray config
    configs[region] || {
      border: 'border-gray-700/30',
      badge_bg: 'bg-gray-700/10',
      badge_border: 'border-gray-700/30',
      badge_text: 'text-gray-400',
      hover_border: 'hover:border-gray-700/50'
    }
  end
end
