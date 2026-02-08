class PropertyScreener
  def initialize(user = nil)
    @user = user
    @criteria = user&.search_criteria
  end

  def self.run(user = nil)
    new(user).screen
  end

  def screen
    listings = PropertyFetcher.fetch_all
    imported = import_listings(listings)
    scored = score_properties(imported)
    recommendations = identify_recommendations(scored)
    notify_user(recommendations) if @user && @criteria&.notifications_enabled
    { imported: imported.size, scored: scored.size, recommended: recommendations.size }
  end

  def screen_existing
    properties = Property.active
    properties = filter_by_criteria(properties) if @criteria
    scored = score_properties(properties.to_a)
    identify_recommendations(scored)
    scored
  end

  private

  def import_listings(listings)
    imported = []

    listings.each do |data|
      property = Property.find_or_initialize_by(
        external_id: data[:external_id],
        source: data[:source]
      )

      property.assign_attributes(data)

      if property.new_record? || property.changed?
        property.save!
        imported << property
      end
    end

    imported
  end

  def score_properties(properties)
    properties.each do |property|
      scores = PropertyScorer.score(property, @criteria)

      property_score = property.property_score || property.build_property_score
      property_score.update!(scores)

      property.update!(
        overall_score: scores[:overall_score],
        recommended: scores[:overall_score] >= recommendation_threshold
      )
    end

    properties
  end

  def filter_by_criteria(properties)
    return properties unless @criteria

    scope = properties
    scope = scope.where(offer_type: @criteria.offer_type)
    scope = scope.in_price_range(@criteria.min_price, @criteria.max_price)
    scope = scope.in_size_range(@criteria.min_living_space, @criteria.max_living_space)
    scope = scope.with_min_rooms(@criteria.min_rooms)

    if @criteria.preferred_districts_list.any?
      scope = scope.where(district: @criteria.preferred_districts_list)
    end

    if @criteria.excluded_districts_list.any?
      scope = scope.where.not(district: @criteria.excluded_districts_list)
    end

    scope
  end

  def identify_recommendations(properties)
    threshold = recommendation_threshold

    properties.select do |p|
      meets_threshold = p.overall_score >= threshold
      matches_criteria = @criteria ? @criteria.matches?(p) : true

      is_recommended = meets_threshold && matches_criteria
      p.update!(recommended: is_recommended) if p.recommended != is_recommended
      is_recommended
    end
  end

  def recommendation_threshold
    @criteria&.min_score_threshold || 60.0
  end

  def notify_user(recommendations)
    return if recommendations.empty?

    ActionCable.server.broadcast(
      "property_channel_user_#{@user.id}",
      {
        type: 'new_recommendations',
        count: recommendations.size,
        top_property: format_property_notification(recommendations.max_by(&:overall_score))
      }
    )
  end

  def format_property_notification(property)
    {
      id: property.id,
      title: property.title,
      score: property.overall_score,
      price: property.price_display,
      district: property.district,
      rooms: property.rooms,
      living_space: property.living_space.to_f.round(1)
    }
  end
end
