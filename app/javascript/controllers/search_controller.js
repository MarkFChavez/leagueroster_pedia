import { Controller } from "@hotwired/stimulus"

// Search/filter controller for team and player search
export default class extends Controller {
  static targets = [
    "input", "card", "resultCount", "clearButton",
    "activeFilter", "activeFilterText",
    "preview", "previewResults", "previewEmpty", "previewFooter"
  ]

  connect() {
    console.log("Search controller connected!")
    this.activeRegion = null
    this.updateResultCount()

    // Close preview on click outside
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener('click', this.boundClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.boundClickOutside)
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hidePreview()
    }
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
      this.hidePreview()
      return
    }

    let visibleCount = 0
    const matchingCards = []

    this.cardTargets.forEach(card => {
      if (this.matchesQuery(card, query)) {
        card.classList.remove('hidden')
        visibleCount++
        matchingCards.push(card)
      } else {
        card.classList.add('hidden')
      }
    })

    this.updateResultCount(visibleCount)
    this.updatePreview(matchingCards, query)
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
    this.hidePreview()

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

  // Filter by region (called from region card clicks)
  filterByRegion(event) {
    const region = event.currentTarget.dataset.region
    this.activeRegion = region

    // Clear search input when filtering by region
    if (this.hasInputTarget) {
      this.inputTarget.value = ''
    }
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.classList.add('hidden')
    }

    let visibleCount = 0

    this.cardTargets.forEach(card => {
      const cardRegion = card.dataset.region
      if (cardRegion === region) {
        card.classList.remove('hidden')
        visibleCount++
      } else {
        card.classList.add('hidden')
      }
    })

    // Show active filter indicator
    if (this.hasActiveFilterTarget && this.hasActiveFilterTextTarget) {
      this.activeFilterTarget.classList.remove('hidden')
      this.activeFilterTextTarget.textContent = `Filtering by ${region}`
    }

    this.updateResultCount(visibleCount)

    // Scroll to teams section
    const teamsSection = document.querySelector('[data-search-target="card"]')
    if (teamsSection) {
      teamsSection.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
  }

  // Clear region filter
  clearRegionFilter() {
    this.activeRegion = null
    this.showAllCards()
    this.updateResultCount()

    // Hide active filter indicator
    if (this.hasActiveFilterTarget) {
      this.activeFilterTarget.classList.add('hidden')
    }
  }

  // Show preview dropdown with matching results
  updatePreview(matchingCards, query) {
    if (!this.hasPreviewTarget) return

    if (matchingCards.length === 0) {
      this.previewResultsTarget.innerHTML = ''
      this.previewEmptyTarget.classList.remove('hidden')
      this.previewFooterTarget.classList.add('hidden')
    } else {
      this.previewEmptyTarget.classList.add('hidden')
      this.previewFooterTarget.classList.toggle('hidden', matchingCards.length <= 5)

      // Show first 5 results
      const resultsHtml = matchingCards.slice(0, 5).map(card => {
        const teamCard = card.querySelector('.js-open-modal')
        const name = teamCard.dataset.teamLongName
        const shortName = teamCard.dataset.teamName
        const region = teamCard.dataset.teamRegion
        return `
          <button type="button"
                  data-action="click->search#selectPreviewResult"
                  data-team-id="${teamCard.dataset.teamId}"
                  class="w-full flex items-center gap-3 p-3 rounded-lg hover:bg-gray-700/50 transition-colors text-left">
            <div class="w-10 h-10 rounded-full bg-gray-700/50 flex items-center justify-center text-sm font-bold text-lol-gold">
              ${shortName}
            </div>
            <div class="flex-1 min-w-0">
              <div class="font-medium text-white truncate">${name}</div>
              <div class="text-xs text-gray-400">${region}</div>
            </div>
          </button>
        `
      }).join('')

      this.previewResultsTarget.innerHTML = resultsHtml
    }

    this.previewTarget.classList.remove('hidden')
  }

  // Hide preview dropdown
  hidePreview() {
    if (this.hasPreviewTarget) {
      this.previewTarget.classList.add('hidden')
    }
  }

  // Handle clicking a preview result
  selectPreviewResult(event) {
    const teamId = event.currentTarget.dataset.teamId
    this.hidePreview()

    // Find and click the actual card to open modal
    const card = this.cardTargets.find(c => {
      const teamCard = c.querySelector('.js-open-modal')
      return teamCard && teamCard.dataset.teamId === teamId
    })

    if (card) {
      const teamCard = card.querySelector('.js-open-modal')
      if (teamCard) teamCard.click()
    }
  }

  // Scroll to full results section
  scrollToResults() {
    this.hidePreview()
    const resultsSection = document.querySelector('[data-search-target="card"]')
    if (resultsSection) {
      resultsSection.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
  }
}
