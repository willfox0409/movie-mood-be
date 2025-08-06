class CreateSavedMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :saved_movies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.string :title, null: false

      t.timestamps
    end
  end
end
