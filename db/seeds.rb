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
user = User.create!(name: "test", email: "test@example.com", password: "password")

puts "Creating movies..."
movie = Movie.create!(
  # add movie-specific fields here
  api_id: "1234567",
  countries: "USA",
  languages: "English",
  runtime: 120
)

medium1 = Medium.create!(
  title: "The Matrix",
  description: "A computer hacker learns about the true nature of reality.",
  release_date: Date.new(1999, 3, 31),
  year: "1999",
  poster_url: "https://example.com/matrix.jpg",
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

movie2 = Movie.create!(countries: ["USA"], languages: ["English"], runtime: 136, directors: ["James Gunn"], writers: ["James Gunn", "Dan Abnett", "Andy Lanning"], actors: ["Chris Pratt", "Zoe Saldaña", "Dave Bautista"])

medium3 = Medium.create!(title: "Guardians of the Galaxy Vol. 2", genres: ["Action", "Adventure", "Comedy"], description: "The Guardians struggle to keep together as a team while dealing with their personal family issues, notably Star-Lord's encounter with his father, the ambitious celestial being Ego.
", release_date: "05 May 2017", year: 2017, poster_url: "https://m.media-amazon.com/images/M/MV5BNWE5MGI3MDctMmU5Ni00YzI2LWEzMTQtZGIyZDA5MzQzNDBhXkEyXkFqcGc@._V1_SX300.jpg", sub_media: movie2)



puts "Creating reviews..."
Review.create!(content: "Good movie!", rating: 5, user: user, medium: medium1)
Review.create!(content: "Great book!", rating: 4, user: user, medium: medium2)

puts "Finished! Created #{Review.count} reviews."
