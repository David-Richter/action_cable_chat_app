class SearchCriteria < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :min_score_threshold, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :offer_type, inclusion: { in: %w[rent buy] }

  def preferred_districts_list
    return [] if preferred_districts.blank?
    preferred_districts.split(',').map(&:strip)
  end

  def preferred_districts_list=(list)
    self.preferred_districts = Array(list).reject(&:blank?).join(', ')
  end

  def excluded_districts_list
    return [] if excluded_districts.blank?
    excluded_districts.split(',').map(&:strip)
  end

  def excluded_districts_list=(list)
    self.excluded_districts = Array(list).reject(&:blank?).join(', ')
  end

  def matches?(property)
    return false if property.offer_type != offer_type
    return false if min_price.present? && property.price.to_f < min_price
    return false if max_price.present? && property.price.to_f > max_price
    return false if max_total_rent.present? && property.warm_rent > max_total_rent
    return false if min_living_space.present? && property.living_space.to_f < min_living_space
    return false if max_living_space.present? && property.living_space.to_f > max_living_space
    return false if min_rooms.present? && property.rooms.to_i < min_rooms
    return false if max_rooms.present? && property.rooms.to_i > max_rooms
    return false if require_balcony && !property.balcony
    return false if require_elevator && !property.elevator
    return false if require_parking && !property.parking
    return false if require_garden && !property.garden
    return false if pets_needed && !property.pets_allowed
    return false if !accept_wbs && property.wbs_required
    return false if preferred_districts_list.any? && !preferred_districts_list.include?(property.district)
    return false if excluded_districts_list.include?(property.district)
    true
  end
end
