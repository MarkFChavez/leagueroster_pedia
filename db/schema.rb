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

ActiveRecord::Schema[8.0].define(version: 2025_11_27_040804) do
  create_table "players", force: :cascade do |t|
    t.string "ign"
    t.string "real_name"
    t.string "country"
    t.string "nationality"
    t.integer "age"
    t.date "birthdate"
    t.string "role"
    t.integer "team_id", null: false
    t.date "date_joined"
    t.boolean "is_current"
    t.text "previous_teams"
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ign"], name: "index_players_on_ign"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.string "region"
    t.string "logo_url"
    t.string "website"
    t.boolean "is_disbanded"
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "players", "teams"
end
