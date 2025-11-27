module PlayerImageHelper
  # Generic user silhouette placeholder SVG as base64 data URI
  SILHOUETTE_SVG = <<~SVG.squish
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
    </svg>
  SVG

  SILHOUETTE_DATA_URI = "data:image/svg+xml;base64,#{Base64.strict_encode64(SILHOUETTE_SVG)}".freeze

  SIZE_CLASSES = {
    'small' => 'w-8 h-8',      # 32px
    'medium' => 'w-12 h-12',   # 48px
    'large' => 'w-16 h-16'     # 64px
  }.freeze

  # Renders a player image with fallback to silhouette placeholder
  #
  # @param player [Player] The player object
  # @param size [String] Size variant: 'small', 'medium', or 'large' (default: 'small')
  # @param css_class [String] Additional CSS classes
  # @return [String] HTML img tag with onerror fallback
  #
  # Example:
  #   <%= player_image_tag(@player, size: 'medium') %>
  #   <%= player_image_tag(player, size: 'large', css_class: 'mr-4') %>
  def player_image_tag(player, size: 'small', css_class: nil)
    size_class = SIZE_CLASSES[size] || SIZE_CLASSES['small']

    # Build CSS classes
    classes = [
      size_class,
      'rounded-full',
      'object-cover',
      'bg-gray-700',
      'border-2',
      'border-gray-600',
      css_class
    ].compact.join(' ')

    if player.image_url.present?
      # Use external image URL with fallback to silhouette
      image_tag(
        player.image_url,
        alt: player.ign,
        class: classes,
        onerror: "this.onerror=null; this.src='#{SILHOUETTE_DATA_URI}';"
      )
    else
      # Use silhouette placeholder directly
      image_tag(
        SILHOUETTE_DATA_URI,
        alt: player.ign,
        class: classes
      )
    end
  end

  # Returns inline SVG silhouette for use in other contexts
  #
  # @param size [String] Size variant
  # @param css_class [String] Additional CSS classes
  # @return [String] HTML with inline SVG
  def player_silhouette_svg(size: 'small', css_class: nil)
    size_class = SIZE_CLASSES[size] || SIZE_CLASSES['small']

    classes = [
      size_class,
      'rounded-full',
      'bg-gray-700',
      'border-2',
      'border-gray-600',
      'text-gray-400',
      'p-2',
      css_class
    ].compact.join(' ')

    content_tag(:div, class: classes) do
      SILHOUETTE_SVG.html_safe
    end
  end
end
