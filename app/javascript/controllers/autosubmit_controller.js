import { Controller } from "@hotwired/stimulus"

// Submits the form as soon as one of its fields changes, so filters and
// ticket details apply without an extra "Update" click.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
