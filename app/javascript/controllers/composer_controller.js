import { Controller } from "@hotwired/stimulus"

// Switches the message box between a reply to the customer and an internal note.
export default class extends Controller {
  static targets = ["tab", "body", "reply", "note", "hint"]
  static values = { replyPlaceholder: String, notePlaceholder: String, replyHint: String, noteHint: String }

  connect() {
    this.show("reply")
  }

  switch(event) {
    this.show(event.currentTarget.dataset.mode)
    this.bodyTarget.focus()
  }

  show(mode) {
    const note = mode === "note"
    this.element.classList.toggle("is-note", note)
    this.tabTargets.forEach((tab) => tab.setAttribute("aria-selected", String(tab.dataset.mode === mode)))
    this.replyTargets.forEach((el) => (el.hidden = note))
    this.noteTargets.forEach((el) => (el.hidden = !note))
    this.bodyTarget.placeholder = note ? this.notePlaceholderValue : this.replyPlaceholderValue
    this.hintTarget.textContent = note ? this.noteHintValue : this.replyHintValue
  }
}
