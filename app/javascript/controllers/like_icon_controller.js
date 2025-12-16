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
    settings: String
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

    fetch(`check_settings?name=${title}&year=${year}&settings=${settings}`)
      .then(response => response.json())
      .then(data => {
        if (data) {
          this.iconTarget.classList.remove("fa-regular");
          this.iconTarget.classList.add("fa-solid");
        } else {
          this.iconTarget.classList.remove("fa-solid");
          this.iconTarget.classList.add("fa-regular");
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
      id = this.idBookValue;
      id = id.replace("/works/", "");
      cover = this.coverBookValue;
      author = this.authorBookValue;
    } else {
      title = this.titleGameValue;
      id = this.idGameValue;
      cover = this.coverGameValue;
      developers = this.developerValue;
      publishers = this.publisherValue;
      platforms = this.platformsValue;
      storyDuration = this.storyDurationValue;
      extrasDuration = this.extrasDurationValue;
      completionistDuration = this.completionistDurationValue;
    }

    fetch(`/media/toggle_settings?id=${id}&name=${title}&cover=${cover}&author=${author}&medium_type=${mediumType}&year=${year}&settings=${settings}&developers=${developers}&publishers=${publishers}&platforms=${platforms}&story_duration=${storyDuration}&extras_duration=${extrasDuration}&completionist_duration=${completionistDuration}`)
      .then(response => response.json())
      .then(data => {
        this.iconTarget.classList.toggle("fa-regular");
        this.iconTarget.classList.toggle("fa-solid");
      });

  }
}
