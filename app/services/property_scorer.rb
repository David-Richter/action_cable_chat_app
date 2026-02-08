class PropertyScorer
  # Weights for scoring categories (must sum to 1.0)
  WEIGHTS = {
    price: 0.30,
    location: 0.25,
    size: 0.20,
    features: 0.15,
    value: 0.10
  }.freeze

  # Berlin average rent per sqm (Mietspiegel reference)
  BERLIN_AVG_RENT_SQM = 12.50

  # Desirable districts ranked by popularity/demand
  DISTRICT_RANKINGS = {
    'Friedrichshain-Kreuzberg' => 95,
    'Mitte' => 92,
    'Pankow' => 88,
    'Charlottenburg-Wilmersdorf' => 85,
    'Tempelhof-Schöneberg' => 80,
    'Neukölln' => 75,
    'Steglitz-Zehlendorf' => 72,
    'Treptow-Köpenick' => 68,
    'Lichtenberg' => 62,
    'Reinickendorf' => 58,
    'Spandau' => 55,
    'Marzahn-Hellersdorf' => 50
  }.freeze

  def initialize(property, criteria = nil)
    @property = property
    @criteria = criteria
  end

  def self.score(property, criteria = nil)
    new(property, criteria).calculate
  end

  def calculate
    scores = {
      price_score: score_price,
      location_score: score_location,
      size_score: score_size,
      features_score: score_features,
      value_score: score_value
    }

    overall = scores.sum { |key, val|
      weight_key = key.to_s.sub('_score', '').to_sym
      val * WEIGHTS[weight_key]
    }.round(2)

    scores[:overall_score] = overall
    scores[:price_notes] = price_analysis
    scores[:location_notes] = location_analysis
    scores[:size_notes] = size_analysis
    scores[:features_notes] = features_analysis
    scores[:summary] = generate_summary(overall, scores)

    scores
  end

  private

  def score_price
    return 50.0 unless @property.price_per_sqm.present?

    sqm_price = @property.price_per_sqm.to_f
    avg = district_average_rent

    # Lower price = better score
    ratio = sqm_price / avg
    score = if ratio <= 0.7
              95.0 # Exceptional deal
            elsif ratio <= 0.85
              85.0 # Very good
            elsif ratio <= 1.0
              70.0 # Fair price
            elsif ratio <= 1.15
              55.0 # Slightly above average
            elsif ratio <= 1.3
              40.0 # Above average
            else
              25.0 # Expensive
            end

    # Bonus for low total rent
    if @property.warm_rent < 800
      score = [score + 10, 100].min
    elsif @property.warm_rent < 1200
      score = [score + 5, 100].min
    end

    score.round(2)
  end

  def score_location
    base = DISTRICT_RANKINGS[@property.district] || 60.0

    # Adjust for popular neighborhoods
    popular = %w[Prenzlauer\ Berg Kreuzberg Friedrichshain Charlottenburg Schöneberg Mitte]
    base += 5 if popular.include?(@property.neighborhood)

    [base.to_f, 100].min.round(2)
  end

  def score_size
    return 50.0 unless @property.living_space.present? && @property.rooms.present?

    space = @property.living_space.to_f
    rooms = @property.rooms

    # Score based on space per room
    space_per_room = space / rooms
    score = if space_per_room >= 25
              90.0
            elsif space_per_room >= 20
              75.0
            elsif space_per_room >= 16
              60.0
            elsif space_per_room >= 12
              45.0
            else
              30.0
            end

    # Bonus for overall size
    score += 5 if space >= 80
    score += 5 if space >= 100

    # Match criteria if present
    if @criteria
      score += 10 if @criteria.min_rooms.present? && rooms >= @criteria.min_rooms
      score += 5 if @criteria.min_living_space.present? && space >= @criteria.min_living_space
    end

    [score, 100].min.round(2)
  end

  def score_features
    score = 40.0 # Base score

    score += 10 if @property.balcony
    score += 8  if @property.elevator
    score += 7  if @property.cellar
    score += 8  if @property.garden
    score += 5  if @property.parking
    score += 3  if @property.pets_allowed

    # Condition bonus
    case @property.condition
    when 'Erstbezug' then score += 15
    when 'Neuwertig' then score += 10
    when 'Gepflegt' then score += 5
    end

    # Energy efficiency
    case @property.energy_rating
    when 'A+', 'A' then score += 10
    when 'B' then score += 7
    when 'C' then score += 4
    end

    # Construction year bonus
    if @property.construction_year
      score += 5 if @property.construction_year >= 2010
      score += 5 if @property.construction_year.between?(1890, 1930) # Altbau charm
    end

    # Penalty for WBS requirement (limits accessibility)
    score -= 10 if @property.wbs_required

    [score, 100].min.round(2)
  end

  def score_value
    return 50.0 unless @property.price_per_sqm.present? && @property.living_space.present?

    price_score = score_price
    location_score = score_location
    size_score = score_size

    # Value = quality relative to price
    quality_avg = (location_score + size_score) / 2.0
    value = if price_score > quality_avg
              # Price is better than quality suggests -> good value
              [quality_avg + (price_score - quality_avg) * 0.5, 100].min
            else
              # Quality exceeds what price suggests
              quality_avg - (quality_avg - price_score) * 0.3
            end

    value.round(2)
  end

  def district_average_rent
    PropertyFetcher::DISTRICT_RENT_AVERAGES[@property.district] || BERLIN_AVG_RENT_SQM
  end

  def price_analysis
    return "Keine Preisdaten verfügbar" unless @property.price_per_sqm.present?

    avg = district_average_rent
    sqm = @property.price_per_sqm.to_f
    diff_pct = ((sqm - avg) / avg * 100).round(1)

    if diff_pct < -15
      "Deutlich unter dem Durchschnitt für #{@property.district} (#{diff_pct}%). Sehr gutes Angebot!"
    elsif diff_pct < 0
      "Unter dem Durchschnitt für #{@property.district} (#{diff_pct}%). Fairer Preis."
    elsif diff_pct < 15
      "Leicht über dem Durchschnitt für #{@property.district} (+#{diff_pct}%)."
    else
      "Deutlich über dem Durchschnitt für #{@property.district} (+#{diff_pct}%). Teuer."
    end
  end

  def location_analysis
    ranking = DISTRICT_RANKINGS[@property.district]
    if ranking && ranking >= 80
      "#{@property.neighborhood} in #{@property.district} ist eine sehr gefragte Lage."
    elsif ranking && ranking >= 60
      "#{@property.neighborhood} in #{@property.district} ist eine solide Wohngegend."
    else
      "#{@property.neighborhood} in #{@property.district} ist eine günstigere Lage am Stadtrand."
    end
  end

  def size_analysis
    return "Keine Größendaten verfügbar" unless @property.living_space.present?

    space = @property.living_space.to_f
    rooms = @property.rooms.to_i
    spr = rooms > 0 ? (space / rooms).round(1) : 0

    "#{space.round(1)}m² für #{rooms} Zimmer (#{spr}m²/Zimmer). " +
      if spr >= 25
        "Sehr großzügiger Schnitt."
      elsif spr >= 18
        "Guter Schnitt."
      else
        "Eher kompakt geschnitten."
      end
  end

  def features_analysis
    features = @property.features_list
    if features.length >= 4
      "Umfangreiche Ausstattung: #{features.join(', ')}."
    elsif features.length >= 2
      "Gute Grundausstattung: #{features.join(', ')}."
    elsif features.length == 1
      "Basisausstattung: #{features.join(', ')}."
    else
      "Keine besonderen Ausstattungsmerkmale angegeben."
    end
  end

  def generate_summary(overall, scores)
    parts = []

    if overall >= 80
      parts << "Hervorragendes Angebot!"
    elsif overall >= 65
      parts << "Gutes Angebot mit Potenzial."
    elsif overall >= 50
      parts << "Durchschnittliches Angebot."
    else
      parts << "Unterdurchschnittliches Angebot."
    end

    # Highlight strengths
    best = [:price_score, :location_score, :size_score, :features_score].max_by { |k| scores[k] }
    labels = { price_score: 'Preis', location_score: 'Lage', size_score: 'Größe', features_score: 'Ausstattung' }
    parts << "Stärke: #{labels[best]}." if scores[best] >= 70

    # Highlight weaknesses
    worst = [:price_score, :location_score, :size_score, :features_score].min_by { |k| scores[k] }
    parts << "Schwäche: #{labels[worst]}." if scores[worst] < 50

    parts.join(' ')
  end
end
