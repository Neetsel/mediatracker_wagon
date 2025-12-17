import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="next-up-icon"
export default class extends Controller {
  static targets = ["icon", "button", "text"]

  static values = {
    titleMovie: String,
    idMovie: String,
    titleBook: String,
    idBook: String,
    coverBook: String,
    authorBook: String,
    titleGame: String,
    idGame: String,
    coverGame: String,
    developer: String,
    publisher: String,
    platforms: String,
    storyDuration: String,
    extrasDuration: String,
    completionistDuration: String,
    mediumType: String,
    year: String,
    settings: String,
    location: String,
    disabled: {type: Boolean, default: false},
    addText: { type: String, default: "add to your next up" },
    removeText: {type: String, default: "Remove from your next up"}
  }

  connect() {
    let title = "";
    const settings = this.settingsValue;
    const year = this.yearValue;
    if (this.titleMovieValue) {
      title = this.titleMovieValue;
    }
    else if (this.titleBookValue) {
      title = this.titleBookValue;
    } else {
      title = this.titleGameValue;
    }

    if (this.locationValue == "card") {
      this.buttonTarget.classList.add("btn-icon");
    } else {
      this.buttonTarget.classList.add("btn-cta","btn-cta-show");
    }

    fetch(`/media/check_settings?name=${encodeURIComponent(title)}&year=${encodeURIComponent(year)}&settings=${encodeURIComponent(settings)}`)
      .then(response => response.json())
      .then(data => {
        if (data.favorite) {
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

  toggleNextUp() {

    if (!this.disabledValue) {

      this.disabledValue = true;
      let title = "";
      let id = "";
      let cover = "";
      let author = "";
      let developers = "";
      let publishers = "";
      let platforms = "";
      let storyDuration = "";
      let extrasDuration = "";
      let completionistDuration = "";
      const mediumType = this.mediumTypeValue;
      const year = this.yearValue;
      const settings = this.settingsValue;

      if (this.titleMovieValue) {
        title = this.titleMovieValue;
        id = this.idMovieValue
      }
      else if (this.titleBookValue) {
        title = this.titleBookValue;
        id = this.idBookValue;
        id = id.replace("/works/", "");
        cover = this.coverBookValue;
        author = this.authorBookValue;
      } else {
        title = this.titleGameValue;
        id = this.idGameValue;
        cover = this.coverGameValue;
        developers = this.developerValue.replace("[", "").replace("]", "");
        publishers = this.publisherValue.replace("[", "").replace("]", "");
        platforms = this.platformsValue.replace("[", "").replace("]", "");
        storyDuration = this.storyDurationValue;
        extrasDuration = this.extrasDurationValue;
        completionistDuration = this.completionistDurationValue;
      }

      fetch(`/media/toggle_settings?id=${encodeURIComponent(id)}&name=${encodeURIComponent(title)}&cover=${encodeURIComponent(cover)}&author=${encodeURIComponent(author)}&medium_type=${encodeURIComponent(mediumType)}&year=${encodeURIComponent(year)}&settings=${encodeURIComponent(settings)}&developers=${encodeURIComponent(developers)}&publishers=${encodeURIComponent(publishers)}&platforms=${encodeURIComponent(platforms)}&story_duration=${encodeURIComponent(storyDuration)}&extras_duration=${encodeURIComponent(extrasDuration)}&completionist_duration=${encodeURIComponent(completionistDuration)}`)
        .then(response => response.json())
        .then(data => {
          this.iconTarget.classList.toggle("fa-regular");
          this.iconTarget.classList.toggle("fa-solid");

          if (this.locationValue == "show") {
            this.buttonTarget.classList.toggle("btn-favorites");
            this.textTarget.innerText === this.addTextValue ? this.textTarget.innerText = this.removeTextValue : this.textTarget.innerText = this.addTextValue;
          }

          setTimeout(() => {
            this.disabledValue = false;
          }, 300);
        });
    }
  }
}
