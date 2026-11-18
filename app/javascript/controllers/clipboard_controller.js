import { Controller } from "@hotwired/stimulus"

// Copies a value to the clipboard and confirms it on the button.
export default class extends Controller {
  static targets = ["label"]
  static values = { text: String }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.textValue)
      this.flash("Copied")
    } catch {
      this.flash("Copy failed. Select the link instead.")
    }
  }

  flash(message) {
    const original = this.labelTarget.textContent
    this.labelTarget.textContent = message
    clearTimeout(this.timer)
    this.timer = setTimeout(() => (this.labelTarget.textContent = original), 2000)
  }
}
