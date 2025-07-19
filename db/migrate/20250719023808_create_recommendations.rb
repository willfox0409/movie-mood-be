class CreateRecommendations < ActiveRecord::Migration[7.1]
  def change
    create_table :recommendations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.string :mood
      t.string :genre
      t.string :decade
      t.string :runtime
      t.integer :tmdb_id
      t.datetime :recommended_at
      t.text :openai_prompt
      t.text :openai_response

      t.timestamps
    end
  end
end
