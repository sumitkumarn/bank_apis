class BranchesController < ApplicationController

include CacheHelper

private
  def load_objects
    validate_input_data
    @items = Branch.joins(:bank).where(
        banks: {name: params[:bank_name].upcase}, branches: {city: params[:city].upcase}
      ) # Rails handles SQL injection when Active Record methods are used. So, no sanitization is done explicitly
    @items = paginate_items(@items)
  end

  def load_object
    params[:ifsc] = params[:id].upcase if params[:id].present?
    @item = Branch.find_by_ifsc(params[:ifsc]) # No need to sanitize for sql injection. 
  end

  #whitelist query params for show and index end points 
  def validate_query_params
    if index?
      super(BranchConstants::INDEX_QUERY_PARAMS)  
    end
    if show?
      super(BranchConstants::SHOW_QUERY_PARAMS)
    end
  end

  #check if the values given in the query params are valid resources or not. If not, raise 400 with appropriate message.
  def validate_input_data
    errors = {}
    BranchConstants::INDEX_QUERY_PARAMS.each do |query_param|
      if send("#{query_param}_from_cache").exclude?(params[query_param].try(:upcase))
        errors[query_param] = "No #{query_param} found with the given value '#{params[query_param]}'"
      end
    end
    log_and_render_error(API_ERROR_MAPPINGS[:BAD_REQUEST_ERROR],errors) if errors.any?
  end

  #methods invoked from render_blueprinter method of application_controller 
  def blueprint
    'BranchBlueprint'.constantize
  end

  def root
    'branch'.freeze
  end

end
