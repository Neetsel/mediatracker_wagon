import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="like-icon"
export default class extends Controller {
  static targets = ["icon"]

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
    location: String
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

    fetch(`check_settings?name=${encodeURIComponent(title)}&year=${encodeURIComponent(year)}&settings=${encodeURIComponent(settings)}`)
      .then(response => response.json())
      .then(data => {
        if (data.favorite) {
          if ( this.locationValue == "card") {
            this.iconTarget.classList.remove("fa-regular");
            this.iconTarget.classList.add("fa-solid");
          } else {

          }
        } else {
          if ( this.locationValue == "card") {
            this.iconTarget.classList.remove("fa-solid");
            this.iconTarget.classList.add("fa-regular");
          } else {

          }
        }
      });
  }

  toggleLike() {

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
      id = this.idBookValue.replace("/works/", "");
      cover = this.coverBookValue;
      author = this.authorBookValue;
    } else {
      title = this.titleGameValue;
      id = this.idGameValue;
      cover = this.coverGameValue;
      developers = this.developerValue.replace("[","").replace("]","");
      publishers = this.publisherValue.replace("[","").replace("]","");
      platforms = this.platformsValue.replace("[","").replace("]","");
      storyDuration = this.storyDurationValue;
      extrasDuration = this.extrasDurationValue;
      completionistDuration = this.completionistDurationValue;
    }

    fetch(`/media/toggle_settings?id=${encodeURIComponent(id)}&name=${encodeURIComponent(title)}&cover=${encodeURIComponent(cover)}&author=${encodeURIComponent(author)}&medium_type=${encodeURIComponent(mediumType)}&year=${encodeURIComponent(year)}&settings=${encodeURIComponent(settings)}&developers=${encodeURIComponent(developers)}&publishers=${encodeURIComponent(publishers)}&platforms=${encodeURIComponent(platforms)}&story_duration=${encodeURIComponent(storyDuration)}&extras_duration=${encodeURIComponent(extrasDuration)}&completionist_duration=${encodeURIComponent(completionistDuration)}`)
      .then(response => response.json())
      .then(data => {
        if (this.locationValue == "card") {
          this.iconTarget.classList.toggle("fa-regular");
          this.iconTarget.classList.toggle("fa-solid");
        } else {

        }
      });

  }
}
