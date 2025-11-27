import { Controller } from "@hotwired/stimulus"

// Team roster modal controller
export default class extends Controller {
  static targets = [
    "content",
    "teamName",
    "teamLongName",
    "teamInitials",
    "teamRegion",
    "rosterList",
    "viewFullLink"
  ]

  connect() {
    console.log("Modal controller connected!")
    // Listen for ESC key to close modal
    this.escapeHandler = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.escapeHandler)

    // Listen for modal open button clicks
    this.clickHandler = this.handleButtonClick.bind(this)
    document.addEventListener("click", this.clickHandler)
  }

  handleButtonClick(event) {
    const button = event.target.closest('.js-open-modal')
    if (button) {
      this.open({ preventDefault: () => {}, currentTarget: button })
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.escapeHandler)
    document.removeEventListener("click", this.clickHandler)
  }

  // Open modal with team data
  open(event) {
    console.log("Modal open triggered!", event)
    event.preventDefault()
    const button = event.currentTarget

    // Get team data from button attributes
    const teamId = button.dataset.teamId
    const teamName = button.dataset.teamName
    const teamLongName = button.dataset.teamLongName
    const teamRegion = button.dataset.teamRegion

    // Get roster data (passed as JSON string)
    const roster = JSON.parse(button.dataset.teamRoster || '[]')

    // Update modal content
    this.teamNameTarget.textContent = teamName
    this.teamLongNameTarget.textContent = teamLongName
    this.teamInitialsTarget.textContent = teamName
    this.teamRegionTarget.textContent = teamRegion || 'N/A'
    this.viewFullLinkTarget.href = `/teams/${teamId}`

    // Render roster
    this.renderRoster(roster)

    // Show modal
    this.element.classList.remove('hidden')

    // Lock body scroll
    document.body.style.overflow = 'hidden'

    // Focus trap
    this.contentTarget.focus()
  }

  // Close modal
  close(event) {
    if (event) {
      event.preventDefault()
    }

    this.element.classList.add('hidden')
    document.body.style.overflow = ''
  }

  // Handle ESC key
  handleEscape(event) {
    if (event.key === "Escape" && !this.element.classList.contains('hidden')) {
      this.close()
    }
  }

  // Helper: Check if contract is expired
  isContractExpired(contractEnds) {
    if (!contractEnds) return false
    const today = new Date()
    const contractDate = new Date(contractEnds)
    return contractDate < today
  }

  // Helper: Format date as "MMM YYYY"
  formatDateMonthYear(dateString) {
    if (!dateString) return ''
    const date = new Date(dateString)
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    return `${months[date.getMonth()]} ${date.getFullYear()}`
  }

  // Render roster list
  renderRoster(roster) {
    if (!roster || roster.length === 0) {
      this.rosterListTarget.innerHTML = `
        <p class="text-gray-500 text-center py-8">No roster information available</p>
      `
      return
    }

    // Role color mapping
    const roleColors = {
      'Top': { bg: 'bg-role-top/10', border: 'border-role-top/30', badge: 'bg-role-top/20 border-role-top/50 text-role-top-light' },
      'Jungle': { bg: 'bg-role-jungle/10', border: 'border-role-jungle/30', badge: 'bg-role-jungle/20 border-role-jungle/50 text-role-jungle-light' },
      'Mid': { bg: 'bg-role-mid/10', border: 'border-role-mid/30', badge: 'bg-role-mid/20 border-role-mid/50 text-role-mid-light' },
      'ADC': { bg: 'bg-role-adc/10', border: 'border-role-adc/30', badge: 'bg-role-adc/20 border-role-adc/50 text-role-adc-light' },
      'Support': { bg: 'bg-role-support/10', border: 'border-role-support/30', badge: 'bg-role-support/20 border-role-support/50 text-role-support-light' }
    }

    const rosterHTML = roster.map(player => {
      const colors = roleColors[player.role] || {
        bg: 'bg-gray-800/30',
        border: 'border-gray-700/30',
        badge: 'bg-gray-700/20 border-gray-600/50 text-gray-300'
      }

      const nameHTML = player.name ? `<p class="text-xs text-gray-500">${player.name}</p>` : ''

      // Generate contract HTML
      let contractHTML = ''
      if (player.contract_ends) {
        if (this.isContractExpired(player.contract_ends)) {
          contractHTML = `
            <div class="mt-2 pt-2 border-t border-gray-700/30">
              <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-bold
                           bg-red-500/20 border border-red-500 text-red-400 mb-1">
                CONTRACT ENDED
              </span>
              <span class="block text-gray-600 text-xs">Ended ${this.formatDateMonthYear(player.contract_ends)}</span>
            </div>
          `
        } else {
          contractHTML = `
            <div class="mt-2 pt-2 border-t border-gray-700/30 text-xs">
              <span class="block text-gray-600">Contract Until</span>
              <span class="font-medium text-gray-400">${this.formatDateMonthYear(player.contract_ends)}</span>
            </div>
          `
        }
      }

      return `
        <div class="${colors.bg} border-l-4 ${colors.border} rounded-lg p-3">
          <div class="flex items-center justify-between mb-2">
            <div class="flex-1 min-w-0">
              <h5 class="font-bold text-gray-100 truncate">${player.ign}</h5>
              ${nameHTML}
            </div>
            <span class="inline-flex items-center px-2 py-1 rounded-full ${colors.badge} border text-xs font-semibold ml-3">
              ${player.role || 'N/A'}
            </span>
          </div>
          ${contractHTML}
        </div>
      `
    }).join('')

    this.rosterListTarget.innerHTML = rosterHTML
  }
}
