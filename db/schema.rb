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

ActiveRecord::Schema[7.1].define(version: 2026_02_08_100002) do
  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "source", null: false
    t.string "title", null: false
    t.text "description"
    t.string "property_type"
    t.string "offer_type", default: "rent"
    t.decimal "price", precision: 10, scale: 2
    t.decimal "price_per_sqm", precision: 10, scale: 2
    t.decimal "additional_costs", precision: 10, scale: 2
    t.decimal "heating_costs", precision: 10, scale: 2
    t.decimal "total_rent", precision: 10, scale: 2
    t.decimal "deposit", precision: 10, scale: 2
    t.decimal "living_space", precision: 8, scale: 2
    t.integer "rooms"
    t.integer "floor"
    t.integer "total_floors"
    t.string "district"
    t.string "neighborhood"
    t.string "address"
    t.string "zip_code"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.boolean "balcony", default: false
    t.boolean "garden", default: false
    t.boolean "elevator", default: false
    t.boolean "cellar", default: false
    t.boolean "parking", default: false
    t.boolean "furnished", default: false
    t.boolean "pets_allowed", default: false
    t.string "energy_rating"
    t.integer "construction_year"
    t.string "heating_type"
    t.string "condition"
    t.date "available_from"
    t.boolean "wbs_required", default: false
    t.string "url"
    t.string "image_url"
    t.string "contact_name"
    t.string "contact_phone"
    t.decimal "overall_score", precision: 5, scale: 2, default: "0.0"
    t.boolean "recommended", default: false
    t.boolean "archived", default: false
    t.datetime "listed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district"], name: "index_properties_on_district"
    t.index ["external_id", "source"], name: "index_properties_on_external_id_and_source", unique: true
    t.index ["living_space"], name: "index_properties_on_living_space"
    t.index ["overall_score"], name: "index_properties_on_overall_score"
    t.index ["price"], name: "index_properties_on_price"
    t.index ["recommended"], name: "index_properties_on_recommended"
    t.index ["rooms"], name: "index_properties_on_rooms"
  end

  create_table "property_scores", force: :cascade do |t|
    t.integer "property_id", null: false
    t.decimal "price_score", precision: 5, scale: 2, default: "0.0"
    t.decimal "location_score", precision: 5, scale: 2, default: "0.0"
    t.decimal "size_score", precision: 5, scale: 2, default: "0.0"
    t.decimal "features_score", precision: 5, scale: 2, default: "0.0"
    t.decimal "value_score", precision: 5, scale: 2, default: "0.0"
    t.decimal "overall_score", precision: 5, scale: 2, default: "0.0"
    t.text "price_notes"
    t.text "location_notes"
    t.text "size_notes"
    t.text "features_notes"
    t.text "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["overall_score"], name: "index_property_scores_on_overall_score"
    t.index ["property_id"], name: "index_property_scores_on_property_id"
  end

  create_table "search_criteria", force: :cascade do |t|
    t.integer "user_id", null: false
    t.decimal "min_price", precision: 10, scale: 2
    t.decimal "max_price", precision: 10, scale: 2
    t.decimal "max_total_rent", precision: 10, scale: 2
    t.decimal "min_living_space", precision: 8, scale: 2
    t.decimal "max_living_space", precision: 8, scale: 2
    t.integer "min_rooms"
    t.integer "max_rooms"
    t.text "preferred_districts"
    t.text "excluded_districts"
    t.boolean "require_balcony", default: false
    t.boolean "require_elevator", default: false
    t.boolean "require_parking", default: false
    t.boolean "require_garden", default: false
    t.boolean "pets_needed", default: false
    t.boolean "accept_wbs", default: true
    t.string "offer_type", default: "rent"
    t.integer "max_floor"
    t.integer "min_construction_year"
    t.decimal "min_score_threshold", precision: 5, scale: 2, default: "60.0"
    t.boolean "notifications_enabled", default: true
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_search_criteria_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "messages", "users"
  add_foreign_key "property_scores", "properties"
  add_foreign_key "search_criteria", "users"
end
