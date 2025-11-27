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

ActiveRecord::Schema[8.0].define(version: 2025_11_27_065945) do
  create_table "players", force: :cascade do |t|
    t.integer "team_id", null: false
    t.string "ign"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "team_sources", force: :cascade do |t|
    t.string "short_name"
    t.string "long_name"
    t.string "external_team_url"
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["short_name"], name: "index_team_sources_on_short_name", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.integer "team_source_id", null: false
    t.string "org_location"
    t.string "region"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_source_id"], name: "index_teams_on_team_source_id"
  end

  add_foreign_key "players", "teams"
  add_foreign_key "teams", "team_sources"
end
