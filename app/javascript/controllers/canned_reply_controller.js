import { Controller } from "@hotwired/stimulus"

// Drops the chosen canned reply into the reply box at the cursor.
export default class extends Controller {
  static targets = ["body"]

  insert(event) {
    const text = event.target.value
    if (!text) return

    const box = this.bodyTarget
    const start = box.selectionStart ?? box.value.length
    const end = box.selectionEnd ?? box.value.length
    box.value = box.value.slice(0, start) + text + box.value.slice(end)
    box.focus()
    event.target.value = ""
  }
}
