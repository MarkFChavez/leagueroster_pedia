import { Controller } from "@hotwired/stimulus"

// Search/filter controller for team and player search
export default class extends Controller {
  static targets = [
    "input", "card", "resultCount", "clearButton",
    "activeFilter", "activeFilterText", "regionButton",
    "preview", "previewResults", "previewEmpty", "previewFooter"
  ]

  connect() {
    console.log("Search controller connected!")
    this.activeRegion = null
    this.updateResultCount()

    // Debounce timer
    this.debounceTimer = null

    // Close preview on click outside
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener('click', this.boundClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.boundClickOutside)
    if (this.debounceTimer) clearTimeout(this.debounceTimer)
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hidePreview()
    }
  }

  // Filter teams as user types (debounced)
  filter(event) {
    const query = this.inputTarget.value.toLowerCase().trim()

    // Show/hide clear button immediately
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.classList.toggle('hidden', query === '')
    }

    // Clear any pending debounce
    if (this.debounceTimer) clearTimeout(this.debounceTimer)

    if (query === '') {
      // Show all cards immediately when cleared
      this.showAllCards()
      this.updateResultCount()
      this.hidePreview()
      return
    }

    // Debounce the actual filtering for performance
    this.debounceTimer = setTimeout(() => {
      this.performFilter(query)
    }, 150)
  }

  // Perform the actual filtering logic
  performFilter(query) {
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
    // Find the actual team card element inside the wrapper (now an <a> tag)
    const teamCardElement = card.querySelector('a[data-team-id]')
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

    // Check player names (IGN and real names)
    try {
      const players = JSON.parse(teamCardElement.dataset.teamPlayers || '[]')
      const playerMatch = players.some(name =>
        (name || '').toLowerCase().includes(query)
      )
      if (playerMatch) return true
    } catch (e) {
      console.warn('Error parsing player data:', e)
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

    // Highlight the selected region button
    this.regionButtonTargets.forEach(button => {
      if (button.dataset.region === region) {
        button.classList.add('ring-2', 'ring-lol-gold', 'bg-lol-gold/10', 'scale-[1.02]')
      } else {
        button.classList.remove('ring-2', 'ring-lol-gold', 'bg-lol-gold/10', 'scale-[1.02]')
      }
    })

    // Show active filter indicator
    if (this.hasActiveFilterTarget && this.hasActiveFilterTextTarget) {
      this.activeFilterTarget.classList.remove('hidden')
      this.activeFilterTextTarget.textContent = region
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

    // Remove highlight from all region buttons
    this.regionButtonTargets.forEach(button => {
      button.classList.remove('ring-2', 'ring-lol-gold', 'bg-lol-gold/10', 'scale-[1.02]')
    })
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
        const teamCard = card.querySelector('a[data-team-id]')
        const name = teamCard.dataset.teamLongName
        const shortName = teamCard.dataset.teamName
        const region = teamCard.dataset.teamRegion
        const href = teamCard.getAttribute('href')
        return `
          <a href="${href}"
             class="block w-full flex items-center gap-3 p-3 rounded-lg hover:bg-gray-700/50 transition-colors text-left">
            <div class="w-10 h-10 rounded-full bg-gray-700/50 flex items-center justify-center text-sm font-bold text-lol-gold">
              ${shortName}
            </div>
            <div class="flex-1 min-w-0">
              <div class="font-medium text-white truncate">${name}</div>
              <div class="text-xs text-gray-400">${region}</div>
            </div>
          </a>
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

  // Handle clicking a preview result (now handled by direct links)
  selectPreviewResult(event) {
    this.hidePreview()
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
