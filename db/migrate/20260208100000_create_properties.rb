class CreateProperties < ActiveRecord::Migration[7.1]
  def change
    create_table :properties do |t|
      t.string  :external_id, null: false
      t.string  :source, null: false
      t.string  :title, null: false
      t.text    :description
      t.string  :property_type
      t.string  :offer_type, default: 'rent'

      # Pricing
      t.decimal :price, precision: 10, scale: 2
      t.decimal :price_per_sqm, precision: 10, scale: 2
      t.decimal :additional_costs, precision: 10, scale: 2
      t.decimal :heating_costs, precision: 10, scale: 2
      t.decimal :total_rent, precision: 10, scale: 2
      t.decimal :deposit, precision: 10, scale: 2

      # Size & Layout
      t.decimal :living_space, precision: 8, scale: 2
      t.integer :rooms
      t.integer :floor
      t.integer :total_floors

      # Location
      t.string  :district
      t.string  :neighborhood
      t.string  :address
      t.string  :zip_code
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7

      # Features
      t.boolean :balcony, default: false
      t.boolean :garden, default: false
      t.boolean :elevator, default: false
      t.boolean :cellar, default: false
      t.boolean :parking, default: false
      t.boolean :furnished, default: false
      t.boolean :pets_allowed, default: false
      t.string  :energy_rating
      t.integer :construction_year
      t.string  :heating_type
      t.string  :condition

      # Availability
      t.date    :available_from
      t.boolean :wbs_required, default: false

      # Metadata
      t.string  :url
      t.string  :image_url
      t.string  :contact_name
      t.string  :contact_phone

      # Scoring
      t.decimal :overall_score, precision: 5, scale: 2, default: 0
      t.boolean :recommended, default: false
      t.boolean :archived, default: false

      t.datetime :listed_at
      t.timestamps
    end

    add_index :properties, [:external_id, :source], unique: true
    add_index :properties, :district
    add_index :properties, :overall_score
    add_index :properties, :recommended
    add_index :properties, :price
    add_index :properties, :living_space
    add_index :properties, :rooms
  end
end
