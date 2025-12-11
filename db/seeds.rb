# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Clearing existing data..."
Review.destroy_all
Movie.destroy_all
Book.destroy_all
Game.destroy_all
User.destroy_all

puts "Creating users..."
user = User.create!(user_name: "test", email: "test@example.com", password: "password")

puts "Creating movies..."
movie = Movie.create!(
  # add movie-specific fields here
  api_id: "1234567",
  countries: "USA",
  languages: "English",
  runtime: 136
)

medium1 = Medium.create!(
  title: "The Matrix",
  description: "A computer hacker learns about the true nature of reality.",
  release_date: Date.new(1999, 3, 31),
  year: "1999",
  poster_url: "https://m.media-amazon.com/images/M/MV5BN2NmN2VhMTQtMDNiOS00NDlhLTliMjgtODE2ZTY0ODQyNDRhXkEyXkFqcGc@._V1_SX300.jpg",
  sub_media: movie
)

movie3 = Movie.create!(
  # add movie-specific fields here
  api_id: "1234567",
  countries: "USA",
  languages: "English",
  runtime: 120
)

medium3 = Medium.create!(
  title: "Guardians of the Galaxy Vol. 2",
  description: "The Guardians struggle to keep together as a team while dealing with their personal family issues, notably Star-Lord's encounter with his father, the ambitious celestial being Ego..",
  release_date: Date.new(2017, 5, 5),
  year: "2017",
  poster_url: "https://m.media-amazon.com/images/M/MV5BNWE5MGI3MDctMmU5Ni00YzI2LWEzMTQtZGIyZDA5MzQzNDBhXkEyXkFqcGc@._V1_SX300.jpg",
  sub_media: movie
)

movie4 = Movie.create!(
  # add movie-specific fields here
  api_id: "1234567",
  countries: "USA",
  languages: "English",
  runtime: 128
)

medium4 = Medium.create!(
  title: "La La Land",
  description: "When Sebastian, a pianist, and Mia, an actress, follow their passion and achieve success in their respective fields, they find themselves torn between their love for each other and their careers.",
  release_date: Date.new(2016, 12, 25),
  year: "2016",
  poster_url: "https://m.media-amazon.com/images/M/MV5BMzUzNDM2NzM2MV5BMl5BanBnXkFtZTgwNTM3NTg4OTE@._V1_SX300.jpg",
  sub_media: movie
)

movie5 = Movie.create!(
  # add movie-specific fields here
  api_id: "1234567",
  countries: "USA",
  languages: "English",
  runtime: 121
)

medium5 = Medium.create!(
  title: "Star Wars: Episode IV - A New Hope",
  description: "Luke Skywalker joins forces with a Jedi Knight, a cocky pilot, a Wookiee and two droids to save the galaxy from the Empire's world-destroying battle station, while also attempting to rescue Princess Leia from the mysterious Darth ...",
  release_date: Date.new(1977, 5, 25),
  year: "1977",
  poster_url: "https://m.media-amazon.com/images/M/MV5BOGUwMDk0Y2MtNjBlNi00NmRiLTk2MWYtMGMyMDlhYmI4ZDBjXkEyXkFqcGc@._V1_SX300.jpg",
  sub_media: movie
)

puts "Creating books..."
book = Book.create!(
  # add book-specific fields here
  isbn: "1400078776",
  publisher: "Vintage International",
  amount_pages: 288
)

medium2 = Medium.create!(
  title: "Never Let Me Go",
  description: "Ishiguro explores what it means to have a soul and how art distinguishes man from other life forms. But above all, Never Let Me Go is a study of friendship and the bonds we form which make or break while we come of age.",
  release_date: Date.new(2006, 1, 1),
  year: "2006",
  poster_url: "https://covers.openlibrary.org/b/id/13160732-L.jpg",
  sub_media: book
)

puts "Creating reviews..."
Review.create!(content: "Good movie!", rating: 5, user: user, medium: medium1)
Review.create!(content: "Great book!", rating: 4, user: user, medium: medium2)
Review.create!(content: "Interesting!", rating: 4, user: user, medium: medium3)
Review.create!(content: "The best!", rating: 5, user: user, medium: medium4)
Review.create!(content: "Interesting!", rating: 4, user: user, medium: medium5)

puts "Finished! Created #{Review.count} reviews."
