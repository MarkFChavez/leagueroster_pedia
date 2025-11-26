module TeamLogoHelper
  # Region color schemes for visual distinction
  REGION_COLORS = {
    'KR' => { primary: '#E74C3C', secondary: '#C0392B', glow: 'rgba(231, 76, 60, 0.6)' },        # Red - Korea
    'CN' => { primary: '#F39C12', secondary: '#D68910', glow: 'rgba(243, 156, 18, 0.6)' },       # Orange - China
    'EMEA' => { primary: '#3498DB', secondary: '#2874A6', glow: 'rgba(52, 152, 219, 0.6)' },     # Blue - Europe/Middle East/Africa
    'NA' => { primary: '#9B59B6', secondary: '#7D3C98', glow: 'rgba(155, 89, 182, 0.6)' },       # Purple - North America
    'PCS' => { primary: '#2ECC71', secondary: '#28B463', glow: 'rgba(46, 204, 113, 0.6)' },      # Green - Pacific
    'VCS' => { primary: '#E67E22', secondary: '#CA6F1E', glow: 'rgba(230, 126, 34, 0.6)' },      # Dark Orange - Vietnam
    'CBLOL' => { primary: '#1ABC9C', secondary: '#16A085', glow: 'rgba(26, 188, 156, 0.6)' },    # Teal - Brazil
    'LJL' => { primary: '#E91E63', secondary: '#C2185B', glow: 'rgba(233, 30, 99, 0.6)' },       # Pink - Japan
    'LLA' => { primary: '#FF5722', secondary: '#E64A19', glow: 'rgba(255, 87, 34, 0.6)' },       # Deep Orange - Latin America
  }.freeze

  # Fallback gold color for unknown regions
  DEFAULT_COLORS = {
    primary: '#C4A15B',
    secondary: '#A88745',
    glow: 'rgba(196, 161, 91, 0.6)'
  }.freeze

  # Get the primary color for a team's region (for brutalist design)
  def team_region_color(team)
    region_key = team.region&.upcase
    colors = REGION_COLORS.fetch(region_key, DEFAULT_COLORS)
    colors[:primary]
  end

  # Generate a hexagonal team badge with initials
  def team_hexagon_badge(team, size: 'medium')
    colors = REGION_COLORS.fetch(team.region&.upcase, DEFAULT_COLORS)
    initials = extract_initials(team)

    # Size configurations
    size_config = case size
    when 'small'
      { container: 'w-14 h-14 sm:w-16 sm:h-16', font: 'text-lg sm:text-xl', svg: 64 }
    when 'large'
      { container: 'w-24 h-24 sm:w-28 sm:h-28 lg:w-32 lg:h-32', font: 'text-3xl sm:text-4xl', svg: 128 }
    else # medium
      { container: 'w-20 h-20', font: 'text-2xl', svg: 80 }
    end

    content_tag(:div,
      class: "#{size_config[:container]} relative flex items-center justify-center group-hover:scale-110 transition-transform duration-300",
      data: { team_badge: team.id }
    ) do
      # SVG hexagon background
      hexagon_svg = <<~SVG.html_safe
        <svg viewBox="0 0 100 100" class="absolute inset-0 w-full h-full" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="grad-#{team.id}" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" style="stop-color:#{colors[:primary]};stop-opacity:1" />
              <stop offset="100%" style="stop-color:#{colors[:secondary]};stop-opacity:1" />
            </linearGradient>
            <filter id="glow-#{team.id}" x="-50%" y="-50%" width="200%" height="200%">
              <feGaussianBlur in="SourceGraphic" stdDeviation="3" />
            </filter>
          </defs>
          <!-- Outer glow hexagon -->
          <polygon points="50,5 90,27.5 90,72.5 50,95 10,72.5 10,27.5"
                   fill="url(#grad-#{team.id})"
                   filter="url(#glow-#{team.id})"
                   opacity="0.4" />
          <!-- Main hexagon -->
          <polygon points="50,8 87,28 87,70 50,92 13,70 13,28"
                   fill="url(#grad-#{team.id})"
                   stroke="#{colors[:primary]}"
                   stroke-width="2" />
          <!-- Inner border -->
          <polygon points="50,15 80,32 80,68 50,85 20,68 20,32"
                   fill="none"
                   stroke="rgba(255,255,255,0.2)"
                   stroke-width="1" />
        </svg>
      SVG

      initials_html = content_tag(:div,
        initials,
        class: "relative z-10 font-black #{size_config[:font]} text-white uppercase tracking-tight drop-shadow-[0_2px_8px_rgba(0,0,0,0.9)] select-none"
      )

      hexagon_svg + initials_html
    end
  end

  # Generate a shield-style badge with region theming
  def team_shield_badge(team, size: 'medium')
    colors = REGION_COLORS.fetch(team.region&.upcase, DEFAULT_COLORS)
    initials = extract_initials(team)

    size_config = case size
    when 'small'
      { container: 'w-14 h-14 sm:w-16 sm:h-16', font: 'text-base sm:text-lg', padding: 'p-2' }
    when 'large'
      { container: 'w-24 h-24 sm:w-28 sm:h-28 lg:w-32 lg:h-32', font: 'text-2xl sm:text-3xl', padding: 'p-4' }
    else
      { container: 'w-20 h-20', font: 'text-xl', padding: 'p-3' }
    end

    content_tag(:div,
      class: "#{size_config[:container]} relative overflow-hidden rounded-lg group-hover:scale-110 transition-all duration-300",
      style: "background: linear-gradient(135deg, #{colors[:primary]} 0%, #{colors[:secondary]} 100%); box-shadow: 0 0 20px #{colors[:glow]}, inset 0 1px 0 rgba(255,255,255,0.2);"
    ) do
      # Geometric pattern overlay
      pattern_html = content_tag(:div, '',
        class: "absolute inset-0 opacity-10",
        style: "background-image: repeating-linear-gradient(45deg, transparent, transparent 10px, rgba(255,255,255,0.1) 10px, rgba(255,255,255,0.1) 20px);"
      )

      # Region label
      region_badge = if team.region.present?
        content_tag(:div,
          team.region.upcase,
          class: "absolute top-1 right-1 text-[8px] font-bold bg-black/40 text-white px-1 py-0.5 rounded backdrop-blur-sm"
        )
      else
        ''.html_safe
      end

      # Team initials
      initials_html = content_tag(:div,
        class: "relative z-10 flex items-center justify-center h-full"
      ) do
        content_tag(:span,
          initials,
          class: "font-black #{size_config[:font]} text-white uppercase tracking-tight drop-shadow-[0_2px_8px_rgba(0,0,0,0.9)] select-none"
        )
      end

      pattern_html + region_badge + initials_html
    end
  end

  # Generate a circular badge with dynamic geometric pattern
  def team_geometric_badge(team, size: 'medium')
    colors = REGION_COLORS.fetch(team.region&.upcase, DEFAULT_COLORS)
    initials = extract_initials(team)

    # Create a deterministic pattern based on team name
    pattern_seed = team.name.bytes.sum % 4

    size_config = case size
    when 'small'
      { container: 'w-14 h-14 sm:w-16 sm:h-16', font: 'text-lg sm:text-xl' }
    when 'large'
      { container: 'w-24 h-24 sm:w-28 sm:h-28 lg:w-32 lg:h-32', font: 'text-3xl sm:text-4xl' }
    else
      { container: 'w-20 h-20', font: 'text-2xl' }
    end

    content_tag(:div,
      class: "#{size_config[:container]} relative flex items-center justify-center rounded-full overflow-hidden group-hover:scale-110 transition-all duration-300 border-2",
      style: "background: linear-gradient(135deg, #{colors[:primary]} 0%, #{colors[:secondary]} 100%); border-color: #{colors[:primary]}; box-shadow: 0 0 20px #{colors[:glow]};"
    ) do
      # Dynamic geometric pattern based on team
      pattern_svg = <<~SVG.html_safe
        <svg viewBox="0 0 100 100" class="absolute inset-0 w-full h-full opacity-20" xmlns="http://www.w3.org/2000/svg">
          #{geometric_pattern(pattern_seed)}
        </svg>
      SVG

      initials_html = content_tag(:div,
        initials,
        class: "relative z-10 font-black #{size_config[:font]} text-white uppercase tracking-tight drop-shadow-[0_2px_8px_rgba(0,0,0,0.9)] select-none"
      )

      pattern_svg + initials_html
    end
  end

  private

  def extract_initials(team)
    if team.short_name.present?
      # Use short_name if available (e.g., "T1", "G2")
      team.short_name.upcase.first(3)
    else
      # Extract initials from team name
      words = team.name.split(/\s+/)
      if words.length == 1
        # Single word: take first 2-3 characters
        team.name.upcase.first(3)
      else
        # Multiple words: take first letter of each word (max 3)
        words.first(3).map { |w| w[0] }.join.upcase
      end
    end
  end

  def geometric_pattern(seed)
    patterns = [
      # Pattern 0: Diagonal lines
      '<line x1="0" y1="0" x2="100" y2="100" stroke="white" stroke-width="2"/>
       <line x1="100" y1="0" x2="0" y2="100" stroke="white" stroke-width="2"/>',

      # Pattern 1: Concentric circles
      '<circle cx="50" cy="50" r="40" fill="none" stroke="white" stroke-width="2"/>
       <circle cx="50" cy="50" r="25" fill="none" stroke="white" stroke-width="2"/>',

      # Pattern 2: Grid
      '<line x1="33" y1="0" x2="33" y2="100" stroke="white" stroke-width="1"/>
       <line x1="67" y1="0" x2="67" y2="100" stroke="white" stroke-width="1"/>
       <line x1="0" y1="33" x2="100" y2="33" stroke="white" stroke-width="1"/>
       <line x1="0" y1="67" x2="100" y2="67" stroke="white" stroke-width="1"/>',

      # Pattern 3: Triangular
      '<polygon points="50,10 90,90 10,90" fill="none" stroke="white" stroke-width="2"/>
       <polygon points="50,30 70,70 30,70" fill="none" stroke="white" stroke-width="2"/>'
    ]

    patterns[seed] || patterns[0]
  end
end
