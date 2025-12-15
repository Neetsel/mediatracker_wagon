import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="like-icon"
export default class extends Controller {
  static targets = ["hideable", "show"]

  call(event) {
    event.preventDefault()
    // if (this.hideableTarget.classList.contains("d-none")) {
    //   this.hideableTarget.classList.remove("d-none")
    //   this.showTarget.classList.add("d-none")
    // } else {
    //   this.hideableTarget.classList.add("d-none")
    //   this.showTarget.classList.remove("d-none")
    // }
  }
}
