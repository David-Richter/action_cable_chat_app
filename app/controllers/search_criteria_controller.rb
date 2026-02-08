class SearchCriteriaController < ApplicationController
  before_action :logged_in_user

  def edit
    @criteria = current_user.search_criteria || current_user.build_search_criteria
  end

  def update
    @criteria = current_user.search_criteria || current_user.build_search_criteria
    if @criteria.update(criteria_params)
      redirect_to dashboard_properties_path, notice: 'Suchkriterien gespeichert!'
    else
      render :edit
    end
  end

  private

  def criteria_params
    params.require(:search_criteria).permit(
      :min_price, :max_price, :max_total_rent,
      :min_living_space, :max_living_space,
      :min_rooms, :max_rooms,
      :preferred_districts, :excluded_districts,
      :require_balcony, :require_elevator, :require_parking,
      :require_garden, :pets_needed, :accept_wbs,
      :offer_type, :max_floor, :min_construction_year,
      :min_score_threshold, :notifications_enabled, :active
    )
  end
end
