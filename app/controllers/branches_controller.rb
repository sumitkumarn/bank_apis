class BranchesController < ApplicationController

private
  def load_objects
    @items = Branch.joins(:bank).where(banks: {name: params[:bank_name]},branches: {city: params[:city]})
    @items = paginate_items(@items)
  end

  def load_object
    params[:ifsc] = params[:id] if params[:id].present?
    @item = Branch.find_by_ifsc(params[:ifsc])
  end

  def validate_index_params
    super(BranchConstants::QUERY_PARAMS)
  end

  def blueprint
    'BranchBlueprint'.constantize
  end

  def root
    'branch'.freeze
  end

end
