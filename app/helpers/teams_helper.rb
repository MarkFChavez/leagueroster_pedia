module TeamsHelper
  def team_logo_config(team_short_name)
    configs = {
      'T1' => {
        shape: 'pentagon',
        clip_path: 'polygon(50% 0%, 100% 38%, 82% 100%, 18% 100%, 0% 38%)',
        gradient_from: 'from-red-600/20',
        gradient_to: 'to-red-900/10',
        border_color: 'border-red-500/30',
        text_color: 'text-red-400',
        hover_border: 'group-hover:border-red-400/50',
        hover_shadow: 'group-hover:shadow-[0_0_20px_rgba(239,68,68,0.4)]'
      },
      'G2' => {
        shape: 'hexagon',
        clip_path: 'polygon(25% 0%, 75% 0%, 100% 50%, 75% 100%, 25% 100%, 0% 50%)',
        gradient_from: 'from-blue-600/20',
        gradient_to: 'to-blue-900/10',
        border_color: 'border-blue-500/30',
        text_color: 'text-blue-400',
        hover_border: 'group-hover:border-blue-400/50',
        hover_shadow: 'group-hover:shadow-[0_0_20px_rgba(59,130,246,0.4)]'
      },
      'HLE' => {
        shape: 'diamond',
        clip_path: 'polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%)',
        gradient_from: 'from-orange-600/20',
        gradient_to: 'to-orange-900/10',
        border_color: 'border-orange-500/30',
        text_color: 'text-orange-400',
        hover_border: 'group-hover:border-orange-400/50',
        hover_shadow: 'group-hover:shadow-[0_0_20px_rgba(249,115,22,0.4)]'
      },
      'GENG' => {
        shape: 'octagon',
        clip_path: 'polygon(30% 0%, 70% 0%, 100% 30%, 100% 70%, 70% 100%, 30% 100%, 0% 70%, 0% 30%)',
        gradient_from: 'from-yellow-600/20',
        gradient_to: 'to-yellow-900/10',
        border_color: 'border-yellow-500/30',
        text_color: 'text-yellow-400',
        hover_border: 'group-hover:border-yellow-400/50',
        hover_shadow: 'group-hover:shadow-[0_0_20px_rgba(234,179,8,0.4)]'
      },
      'DK' => {
        shape: 'triangle',
        clip_path: 'polygon(50% 0%, 0% 100%, 100% 100%)',
        gradient_from: 'from-indigo-600/20',
        gradient_to: 'to-indigo-900/10',
        border_color: 'border-indigo-500/30',
        text_color: 'text-indigo-400',
        hover_border: 'group-hover:border-indigo-400/50',
        hover_shadow: 'group-hover:shadow-[0_0_20px_rgba(99,102,241,0.4)]'
      }
    }

    # Return config for the team or default circle config
    configs[team_short_name.upcase] || {
      shape: 'circle',
      clip_path: nil,
      gradient_from: 'from-lol-gold/20',
      gradient_to: 'to-transparent',
      border_color: 'border-lol-gold/30',
      text_color: 'text-lol-gold',
      hover_border: 'group-hover:border-lol-gold/50',
      hover_shadow: 'group-hover:shadow-glow'
    }
  end
end
