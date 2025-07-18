class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.integer :tmdb_id, null: false
      t.string :title, null: false
      t.integer :runtime
      t.string :poster_url

      t.timestamps
    end
  end
end
