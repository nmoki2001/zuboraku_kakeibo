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

ActiveRecord::Schema[7.2].define(version: 2025_12_05_220857) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_classifications", force: :cascade do |t|
    t.bigint "entry_id", null: false
    t.integer "method", null: false
    t.bigint "predicted_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_ai_classifications_on_entry_id"
    t.index ["predicted_category_id"], name: "index_ai_classifications_on_predicted_category_id"
  end

  create_table "analyses", force: :cascade do |t|
    t.text "good_points", null: false
    t.text "improvements", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_analyses_on_created_at"
  end

  create_table "analysis_requests", force: :cascade do |t|
    t.datetime "used_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["used_at"], name: "index_analysis_requests_on_used_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "kind", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name"
  end

  create_table "entries", force: :cascade do |t|
    t.date "occurred_on", null: false
    t.string "description", null: false
    t.integer "amount", null: false
    t.integer "direction", null: false
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "anon_user_id"
    t.index ["anon_user_id"], name: "index_entries_on_anon_user_id"
    t.index ["category_id"], name: "index_entries_on_category_id"
    t.index ["occurred_on"], name: "index_entries_on_occurred_on"
  end

  add_foreign_key "ai_classifications", "categories", column: "predicted_category_id"
  add_foreign_key "ai_classifications", "entries"
  add_foreign_key "entries", "categories"
end
