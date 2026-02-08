class CreatePropertyScores < ActiveRecord::Migration[7.1]
  def change
    create_table :property_scores do |t|
      t.references :property, foreign_key: true, null: false

      t.decimal :price_score, precision: 5, scale: 2, default: 0
      t.decimal :location_score, precision: 5, scale: 2, default: 0
      t.decimal :size_score, precision: 5, scale: 2, default: 0
      t.decimal :features_score, precision: 5, scale: 2, default: 0
      t.decimal :value_score, precision: 5, scale: 2, default: 0
      t.decimal :overall_score, precision: 5, scale: 2, default: 0

      t.text :price_notes
      t.text :location_notes
      t.text :size_notes
      t.text :features_notes
      t.text :summary

      t.timestamps
    end

    add_index :property_scores, :overall_score
  end
end
