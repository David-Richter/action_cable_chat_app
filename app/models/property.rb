class Property < ApplicationRecord
  has_one :property_score, dependent: :destroy

  validates :external_id, presence: true, uniqueness: { scope: :source }
  validates :source, presence: true
  validates :title, presence: true
  validates :offer_type, inclusion: { in: %w[rent buy] }

  scope :recommended, -> { where(recommended: true).order(overall_score: :desc) }
  scope :active, -> { where(archived: false) }
  scope :recent, -> { order(listed_at: :desc) }
  scope :top_scored, -> { order(overall_score: :desc) }
  scope :by_district, ->(district) { where(district: district) }
  scope :rent, -> { where(offer_type: 'rent') }
  scope :buy, -> { where(offer_type: 'buy') }

  scope :in_price_range, ->(min, max) {
    scope = all
    scope = scope.where('price >= ?', min) if min.present?
    scope = scope.where('price <= ?', max) if max.present?
    scope
  }

  scope :in_size_range, ->(min, max) {
    scope = all
    scope = scope.where('living_space >= ?', min) if min.present?
    scope = scope.where('living_space <= ?', max) if max.present?
    scope
  }

  scope :with_min_rooms, ->(min) { where('rooms >= ?', min) if min.present? }

  BERLIN_DISTRICTS = [
    'Mitte', 'Friedrichshain-Kreuzberg', 'Pankow', 'Charlottenburg-Wilmersdorf',
    'Spandau', 'Steglitz-Zehlendorf', 'Tempelhof-Schöneberg', 'Neukölln',
    'Treptow-Köpenick', 'Marzahn-Hellersdorf', 'Lichtenberg', 'Reinickendorf'
  ].freeze

  POPULAR_NEIGHBORHOODS = {
    'Mitte' => ['Mitte', 'Tiergarten', 'Wedding'],
    'Friedrichshain-Kreuzberg' => ['Friedrichshain', 'Kreuzberg'],
    'Pankow' => ['Prenzlauer Berg', 'Pankow', 'Weißensee'],
    'Charlottenburg-Wilmersdorf' => ['Charlottenburg', 'Wilmersdorf'],
    'Neukölln' => ['Neukölln', 'Britz', 'Rudow'],
    'Tempelhof-Schöneberg' => ['Schöneberg', 'Tempelhof', 'Friedenau'],
    'Steglitz-Zehlendorf' => ['Steglitz', 'Zehlendorf', 'Dahlem'],
    'Treptow-Köpenick' => ['Alt-Treptow', 'Köpenick', 'Oberschöneweide'],
    'Lichtenberg' => ['Lichtenberg', 'Rummelsburg', 'Karlshorst'],
    'Reinickendorf' => ['Reinickendorf', 'Tegel', 'Hermsdorf'],
    'Spandau' => ['Spandau', 'Haselhorst', 'Siemensstadt'],
    'Marzahn-Hellersdorf' => ['Marzahn', 'Hellersdorf', 'Biesdorf']
  }.freeze

  def score_label
    return 'Hervorragend' if overall_score >= 85
    return 'Sehr gut' if overall_score >= 70
    return 'Gut' if overall_score >= 55
    return 'Akzeptabel' if overall_score >= 40
    'Unterdurchschnittlich'
  end

  def score_color
    return '#2ecc71' if overall_score >= 85
    return '#27ae60' if overall_score >= 70
    return '#f39c12' if overall_score >= 55
    return '#e67e22' if overall_score >= 40
    '#e74c3c'
  end

  def warm_rent
    total_rent.presence || (price.to_f + additional_costs.to_f + heating_costs.to_f)
  end

  def price_display
    if offer_type == 'rent'
      "#{price&.round(0)} EUR/Monat"
    else
      "#{price&.round(0)} EUR"
    end
  end

  def features_list
    features = []
    features << 'Balkon' if balcony
    features << 'Garten' if garden
    features << 'Aufzug' if elevator
    features << 'Keller' if cellar
    features << 'Stellplatz' if parking
    features << 'Möbliert' if furnished
    features << 'Haustiere erlaubt' if pets_allowed
    features
  end
end
