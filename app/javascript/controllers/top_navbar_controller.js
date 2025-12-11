import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    console.log("Le JS est connecté")


    this.close()
  }

  toggle() {
    console.log("Le toggle fonctionne")

    this.panelTarget.classList.toggle("open")
  }

  open() {
    this.panelTarget.classList.add("open")
  }

  close() {
    this.panelTarget.classList.remove("open")
  }
}
