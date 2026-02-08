class PropertiesController < ApplicationController
  before_action :logged_in_user
  before_action :set_property, only: [:show]

  def index
    @properties = Property.active.top_scored

    # Apply filters
    @properties = @properties.by_district(params[:district]) if params[:district].present?
    @properties = @properties.where('rooms >= ?', params[:min_rooms]) if params[:min_rooms].present?
    @properties = @properties.where('price <= ?', params[:max_price]) if params[:max_price].present?
    @properties = @properties.where('living_space >= ?', params[:min_space]) if params[:min_space].present?

    case params[:sort]
    when 'price_asc' then @properties = @properties.reorder(price: :asc)
    when 'price_desc' then @properties = @properties.reorder(price: :desc)
    when 'size_desc' then @properties = @properties.reorder(living_space: :desc)
    when 'newest' then @properties = @properties.reorder(listed_at: :desc)
    when 'score' then @properties = @properties.reorder(overall_score: :desc)
    end

    @recommended_count = Property.active.recommended.count
    @total_count = Property.active.count
    @avg_score = Property.active.average(:overall_score)&.round(1) || 0
  end

  def show
    @score = @property.property_score
  end

  def recommended
    @properties = Property.active.recommended.limit(20)
  end

  def screen
    result = PropertyScreener.run(current_user)
    redirect_to properties_path, notice: "Screening abgeschlossen: #{result[:imported]} neue Angebote importiert, #{result[:recommended]} empfohlen."
  end

  def dashboard
    @total = Property.active.count
    @recommended = Property.active.recommended
    @top_properties = Property.active.top_scored.limit(5)
    @by_district = Property.active.group(:district).average(:price_per_sqm).sort_by { |_, v| v || 0 }
    @district_counts = Property.active.group(:district).count
    @avg_score = Property.active.average(:overall_score)&.round(1) || 0
    @avg_price = Property.active.average(:price)&.round(0) || 0
    @avg_size = Property.active.average(:living_space)&.round(1) || 0
    @criteria = current_user.search_criteria
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end
end
