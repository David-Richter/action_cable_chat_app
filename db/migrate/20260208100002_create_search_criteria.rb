class CreateSearchCriteria < ActiveRecord::Migration[7.1]
  def change
    create_table :search_criteria do |t|
      t.references :user, foreign_key: true, null: false

      # Price range
      t.decimal :min_price, precision: 10, scale: 2
      t.decimal :max_price, precision: 10, scale: 2
      t.decimal :max_total_rent, precision: 10, scale: 2

      # Size
      t.decimal :min_living_space, precision: 8, scale: 2
      t.decimal :max_living_space, precision: 8, scale: 2
      t.integer :min_rooms
      t.integer :max_rooms

      # Location preferences (comma-separated districts)
      t.text :preferred_districts
      t.text :excluded_districts

      # Features
      t.boolean :require_balcony, default: false
      t.boolean :require_elevator, default: false
      t.boolean :require_parking, default: false
      t.boolean :require_garden, default: false
      t.boolean :pets_needed, default: false
      t.boolean :accept_wbs, default: true

      # Preferences
      t.string  :offer_type, default: 'rent'
      t.integer :max_floor
      t.integer :min_construction_year
      t.decimal :min_score_threshold, precision: 5, scale: 2, default: 60.0

      t.boolean :notifications_enabled, default: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
