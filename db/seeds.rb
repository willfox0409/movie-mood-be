# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# USERS

User.create!(
  username: 'moviebuff101',
  email: 'buff@example.com',
  password: 'tarantino123'
)

User.create!(
  username: 'cinephile',
  email: 'cine@example.com',
  password: 'popcorn!'
)

# MOVIES

Movie.create!(
  tmdb_id: 923,
  title: "No Country For Old Men",
  runtime: 122,
  poster_url: "https://cdn.displate.com/artwork/857x1200/2024-11-03/ca0bbfbb-9420-4d9e-ab44-064383ce0793.jpg",
  description: "A relentless killer hunts stolen drug money across the desolate Texas borderlands, while an aging sheriff struggles to make sense of the violence unraveling before him."
)

Movie.create!(
  tmdb_id: 550,
  title: "Fight Club",
  runtime: 139,
  poster_url: "https://media.posterlounge.com/img/products/680000/676414/676414_poster.jpg",
  description: "An insomniac office worker and a charismatic soap salesman start an underground fight club that spirals into a chaotic rebellion against consumer culture and identity itself."
)

Movie.create!(
  tmdb_id: 10874,
  title: "Paris, Texas",
  runtime: 145,
  poster_url: "https://image.tmdb.org/t/p/w500/4xCly5XbTz6LJi5rWkRlyuGLHfM.jpg",
  description: "A drifter emerges from the desert with no memory, slowly reconnecting with the family he abandoned years before in this haunting and poetic American odyssey."
)

Movie.create!(
  tmdb_id: 12106,
  title: "The Great Outdoors",
  runtime: 91,
  poster_url: "https://image.tmdb.org/t/p/w500/6IC9fgzrKigSi0T1VsDyzVgYf2x.jpg",
  description: "A Chicago man's peaceful vacation in the woods turns chaotic when his obnoxious brother-in-law shows up with his family in tow, bringing wild mishaps and laughs."
)
