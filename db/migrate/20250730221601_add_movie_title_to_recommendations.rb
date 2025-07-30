class AddMovieTitleToRecommendations < ActiveRecord::Migration[7.1]
  def change
    add_column :recommendations, :movie_title, :string
  end
end
