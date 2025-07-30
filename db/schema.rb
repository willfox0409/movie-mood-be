# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_07_30_223207) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "movies", force: :cascade do |t|
    t.integer "tmdb_id", null: false
    t.string "title", null: false
    t.integer "runtime"
    t.string "poster_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
  end

  create_table "offers", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.bigint "provider_id", null: false
    t.string "offer_type", null: false
    t.decimal "price", precision: 8, scale: 2
    t.string "url"
    t.boolean "available", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_offers_on_available"
    t.index ["movie_id", "provider_id", "offer_type"], name: "index_offers_on_movie_provider_type", unique: true
    t.index ["movie_id"], name: "index_offers_on_movie_id"
    t.index ["offer_type"], name: "index_offers_on_offer_type"
    t.index ["provider_id"], name: "index_offers_on_provider_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name", null: false
    t.integer "justwatch_id", null: false
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["justwatch_id"], name: "index_providers_on_justwatch_id", unique: true
    t.index ["name"], name: "index_providers_on_name"
  end

  create_table "recommendations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.string "mood"
    t.string "genre"
    t.string "decade"
    t.string "runtime"
    t.integer "tmdb_id"
    t.datetime "recommended_at"
    t.text "openai_prompt"
    t.text "openai_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recommended_title"
    t.index ["movie_id"], name: "index_recommendations_on_movie_id"
    t.index ["user_id"], name: "index_recommendations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "offers", "movies"
  add_foreign_key "offers", "providers"
  add_foreign_key "recommendations", "movies"
  add_foreign_key "recommendations", "users"
end
