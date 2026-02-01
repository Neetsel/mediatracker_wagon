import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collection-icon"
export default class extends Controller {
  static targets = ["icon", "button", "text"]

  static values = {
    id: String,
    settings: String,
    location: String,
    disabled: {type: Boolean, default: false},
    addText: { type: String, default: "add to your collection" },
    removeText: {type: String, default: "Remove from your collection"}
  }

  connect() {
    const id = this.idValue;
    const settings = this.settingsValue;

    if (this.locationValue == "card") {
      this.buttonTarget.classList.add("btn-icon");
    } else {
      this.buttonTarget.classList.add("btn-cta","btn-cta-show");
    }

    fetch(`/media/${encodeURIComponent(id)}/check_settings?settings=${encodeURIComponent(settings)}`)
      .then(response => response.json())
      .then(data => {
        if (data.medium) {
          this.checkCollection(data.medium);
        } else {
          this.iconTarget.classList.remove("fa-solid");
          this.iconTarget.classList.add("fa-regular");
          this.buttonTarget.classList.remove("btn-hidden");
        }
      });
  }

  checkCollection(medium) {
    fetch(`/collections/check_collection?id=${medium.id}`)
      .then(response => response.json())
      .then(data => {
        if (data) {
          this.iconTarget.classList.remove("fa-regular");
          this.iconTarget.classList.add("fa-solid");
          if ( this.locationValue == "show") {
            this.buttonTarget.classList.add("btn-favorites");
            this.textTarget.innerText = this.removeTextValue;
          }
        } else {
          this.iconTarget.classList.remove("fa-solid");
          this.iconTarget.classList.add("fa-regular");
        }
        this.buttonTarget.classList.remove("btn-hidden");
      });
  }

  toggleCollection() {
    if (!this.disabledValue) {

      this.disabledValue = true;
      const id = this.idValue;
      const settings = this.settingsValue;

      fetch(`/media/${encodeURIComponent(id)}/toggle_settings?settings=${encodeURIComponent(settings)}`)
        .then(response => response.json())
        .then(data => {
          console.log(data)
          this.changeCollection(data)
          this.iconTarget.classList.toggle("fa-regular");
          this.iconTarget.classList.toggle("fa-solid");

          if (this.locationValue == "show") {
            this.buttonTarget.classList.toggle("btn-favorites");
            this.buttonTarget.classList.contains("btn-favorites") ? this.textTarget.innerText = this.removeTextValue : this.textTarget.innerText = this.addTextValue;
          }
        });
    }
  }

  changeCollection(medium) {
    fetch(`/collections/toggle_collection?id=${medium.id}`)
      .then(response => response.json())
      .then(data => {
        setTimeout(() => {
          this.disabledValue = false;
        }, 300);
      });
  }
}
