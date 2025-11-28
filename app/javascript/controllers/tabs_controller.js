import { Controller } from "@hotwired/stimulus"

// Simple tab switching controller
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { activeTab: { type: String, default: "active" } }

  connect() {
    this.showTab(this.activeTabValue)
  }

  switch(event) {
    const tabId = event.currentTarget.dataset.tabId
    this.showTab(tabId)
  }

  showTab(tabId) {
    this.activeTabValue = tabId

    // Update tab buttons
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabId === tabId
      tab.classList.toggle("border-lol-gold", isActive)
      tab.classList.toggle("text-lol-gold", isActive)
      tab.classList.toggle("border-transparent", !isActive)
      tab.classList.toggle("text-gray-400", !isActive)
    })

    // Update panels
    this.panelTargets.forEach(panel => {
      panel.classList.toggle("hidden", panel.dataset.tabId !== tabId)
    })
  }
}
