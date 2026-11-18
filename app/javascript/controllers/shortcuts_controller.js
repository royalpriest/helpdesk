import { Controller } from "@hotwired/stimulus"

// Keyboard shortcuts for agents:
//   ⌘K / Ctrl+K  search tickets
//   /            pick a canned reply (when not typing)
//   ⌘↵ / Ctrl+↵  send the message you're writing
export default class extends Controller {
  static targets = ["search"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
  }

  onKeydown(event) {
    const typing = event.target.closest("input, textarea, select, [contenteditable]")
    const mod = event.metaKey || event.ctrlKey

    if (mod && event.key.toLowerCase() === "k" && this.hasSearchTarget) {
      event.preventDefault()
      this.searchTarget.focus()
      this.searchTarget.select()
    } else if (mod && event.key === "Enter" && event.target.matches("textarea")) {
      const submit = event.target.form?.querySelector("[data-composer-target~=primary]:not([hidden])")
      if (submit) {
        event.preventDefault()
        event.target.form.requestSubmit(submit)
      }
    } else if (event.key === "/" && !typing && !mod) {
      const picker = document.getElementById("canned_reply")
      if (picker) {
        event.preventDefault()
        picker.focus()
        picker.showPicker?.()
      }
    }
  }
}
