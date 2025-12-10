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

ActiveRecord::Schema[7.1].define(version: 2025_12_10_105008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "isbn"
    t.string "publisher"
    t.integer "amount_pages"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authors", default: [], array: true
    t.string "work_id"
    t.string "book_id"
  end

  create_table "chats", force: :cascade do |t|
    t.string "title"
    t.bigint "user_id", null: false
    t.bigint "medium_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medium_id"], name: "index_chats_on_medium_id"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "collections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "medium_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medium_id"], name: "index_collections_on_medium_id"
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "api_id"
    t.string "publisher"
    t.integer "main_story_duration"
    t.integer "main_extras_duration"
    t.string "completionist_duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "developers", default: [], array: true
    t.string "platforms", default: [], array: true
  end

  create_table "media", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.date "release_date"
    t.string "year"
    t.string "poster_url"
    t.string "sub_media_type"
    t.bigint "sub_media_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "genres", default: [], array: true
    t.index ["sub_media_type", "sub_media_id"], name: "index_media_on_sub_media"
  end

  create_table "media_consumptions", force: :cascade do |t|
    t.string "status"
    t.date "consumption_date"
    t.bigint "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_media_consumptions_on_collection_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "role"
    t.string "content"
    t.bigint "chat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "api_id"
    t.string "countries"
    t.string "languages"
    t.integer "runtime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "directors", default: [], array: true
    t.string "writers", default: [], array: true
    t.string "actors", default: [], array: true
  end

  create_table "reviews", force: :cascade do |t|
    t.string "content"
    t.integer "rating"
    t.bigint "medium_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medium_id"], name: "index_reviews_on_medium_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chats", "media"
  add_foreign_key "chats", "users"
  add_foreign_key "collections", "media"
  add_foreign_key "collections", "users"
  add_foreign_key "media_consumptions", "collections"
  add_foreign_key "messages", "chats"
  add_foreign_key "reviews", "media"
  add_foreign_key "reviews", "users"
end
