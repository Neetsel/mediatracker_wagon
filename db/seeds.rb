# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning database ..."
Movie.destroy_all
Medium.destroy_all

puts "Creating movies"

movie = Movie.create!(countries: ["USA"], languages: ["English"], runtime: 136, directors: ["James Gunn"], writers: ["James Gunn", "Dan Abnett", "Andy Lanning"], actors: ["Chris Pratt", "Zoe Saldaña", "Dave Bautista"])

media = Medium.create!(title: "Guardians of the Galaxy Vol. 2", genres: ["Action", "Adventure", "Comedy"], description: "The Guardians struggle to keep together as a team while dealing with their personal family issues, notably Star-Lord's encounter with his father, the ambitious celestial being Ego.
", release_date: "05 May 2017", year: 2017, poster_url: "https://m.media-amazon.com/images/M/MV5BNWE5MGI3MDctMmU5Ni00YzI2LWEzMTQtZGIyZDA5MzQzNDBhXkEyXkFqcGc@._V1_SX300.jpg", sub_media: movie)


puts "Finished ! Created #{Movie.count} movies"
puts "#{movie}"
puts "#{media}"
