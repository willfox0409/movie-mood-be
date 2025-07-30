class RenameMovieTitleToRecommendedTitleInRecommendations < ActiveRecord::Migration[7.1]
  def change
    rename_column :recommendations, :movie_title, :recommended_title
  end
end
