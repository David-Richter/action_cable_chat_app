class PropertyScore < ApplicationRecord
  belongs_to :property

  validates :property, presence: true

  def score_breakdown
    {
      'Preis' => { score: price_score, notes: price_notes, weight: '30%' },
      'Lage' => { score: location_score, notes: location_notes, weight: '25%' },
      'Größe' => { score: size_score, notes: size_notes, weight: '20%' },
      'Ausstattung' => { score: features_score, notes: features_notes, weight: '15%' },
      'Preis-Leistung' => { score: value_score, notes: nil, weight: '10%' }
    }
  end
end
