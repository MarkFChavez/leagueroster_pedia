import { Controller } from "@hotwired/stimulus"

// Search/filter controller for team and player search
export default class extends Controller {
  static targets = ["input", "card", "resultCount", "clearButton"]

  connect() {
    console.log("Search controller connected!")
    this.updateResultCount()
  }

  // Filter teams as user types
  filter(event) {
    const query = this.inputTarget.value.toLowerCase().trim()

    // Show/hide clear button
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.classList.toggle('hidden', query === '')
    }

    if (query === '') {
      // Show all cards if search is empty
      this.showAllCards()
      this.updateResultCount()
      return
    }

    let visibleCount = 0

    this.cardTargets.forEach(card => {
      if (this.matchesQuery(card, query)) {
        card.classList.remove('hidden')
        visibleCount++
      } else {
        card.classList.add('hidden')
      }
    })

    this.updateResultCount(visibleCount)
  }

  // Check if a team card matches the search query
  matchesQuery(card, query) {
    // Find the actual team card element inside the wrapper
    const teamCardElement = card.querySelector('.js-open-modal')
    if (!teamCardElement) return false

    // Get team data from card attributes
    const teamName = (teamCardElement.dataset.teamName || '').toLowerCase()
    const teamLongName = (teamCardElement.dataset.teamLongName || '').toLowerCase()
    const region = (teamCardElement.dataset.teamRegion || '').toLowerCase()

    // Check team names and region
    if (teamName.includes(query) ||
        teamLongName.includes(query) ||
        region.includes(query)) {
      return true
    }

    // Check player IGNs from roster data
    try {
      const roster = JSON.parse(teamCardElement.dataset.teamRoster || '[]')
      const playerMatch = roster.some(player => {
        const ign = (player.ign || '').toLowerCase()
        const name = (player.name || '').toLowerCase()
        return ign.includes(query) || name.includes(query)
      })

      if (playerMatch) {
        return true
      }
    } catch (e) {
      console.warn('Error parsing roster data:', e)
    }

    return false
  }

  // Show all cards (reset filter)
  showAllCards() {
    this.cardTargets.forEach(card => {
      card.classList.remove('hidden')
    })
  }

  // Clear search input and show all
  clear() {
    this.inputTarget.value = ''
    this.showAllCards()
    this.updateResultCount()

    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.classList.add('hidden')
    }

    // Focus back on input
    this.inputTarget.focus()
  }

  // Update result counter
  updateResultCount(count = null) {
    if (!this.hasResultCountTarget) return

    const visibleCount = count !== null ? count : this.cardTargets.filter(card => !card.classList.contains('hidden')).length
    const total = this.cardTargets.length

    if (visibleCount === total) {
      this.resultCountTarget.textContent = `Showing all ${total} teams`
    } else {
      this.resultCountTarget.textContent = `Found ${visibleCount} of ${total} teams`
    }
  }
}
