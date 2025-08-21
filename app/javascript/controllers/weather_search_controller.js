import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "results"]

  search(event) {
    event.preventDefault()
    
    this.showLoading()
    
    const form = this.element.closest('form')
    if (form) {
      setTimeout(() => {
        form.requestSubmit()
      }, 150) // This is fiddly. Could be longer, or could be shorter, but at least for how I type, it works.
    }
  }

  showLoading() {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = `
        <div class="text-center py-8">
          <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
          <p class="mt-4 text-gray-400">Fetching weather data...</p>
        </div>
      `
    }
    
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true
      this.buttonTarget.classList.add('opacity-50', 'cursor-not-allowed')
      
      setTimeout(() => {
        this.buttonTarget.disabled = false
        this.buttonTarget.classList.remove('opacity-50', 'cursor-not-allowed')
      }, 2000)
    }
  }
}
