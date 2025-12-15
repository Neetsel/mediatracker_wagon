import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="like-icon"
export default class extends Controller {

  reset() {
    this.buttonTarget.removeAttribute("disabled");
    this.buttonTarget.innerText = this.originalTextValue;
    this.linkTarget.classList.add("d-none");
  }

  like() {
    this.buttonTarget.setAttribute('disabled', '')
    this.buttonTarget.innerText = this.textValue
    this.linkTarget.classList.remove('d-none')
  }
}
