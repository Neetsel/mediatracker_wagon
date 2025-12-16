import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mediumType", "buttons"]

  connect() {
    this.step = 1
  }

  submit(event) {
    if (this.step === 1) {
      event.preventDefault()
      this.buttonsTarget.classList.remove("d-none")
      this.step = 2
    }
  }

  choose(event) {
    this.mediumTypeTarget.value = event.currentTarget.dataset.medium
    this.element.querySelector("form").requestSubmit()
  }
}
