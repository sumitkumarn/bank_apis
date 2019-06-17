class BranchesController < ApplicationController

  def index
    @items = Branch.joins(:bank).where(banks: {name: params[:bank_name]},branches: {city: params[:city]})
    render json: paginate_items(@items), status: 200
  end

  private

  def validate_index_params
    super(BranchConstants::QUERY_PARAMS)
  end

end
