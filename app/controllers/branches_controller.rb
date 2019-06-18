class BranchesController < ApplicationController

include CacheHelper

private
  def load_objects
    validate_input_data
    @items = Branch.joins(:bank).where(
        banks: {name: params[:bank_name].try(:upcase)}, branches: {city: params[:city].try(:upcase)}
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

  #checks if required params are passed in the URL
  def check_missing_params
    missing_param_errors = {}
    missing_keys = BranchConstants::INDEX_QUERY_PARAMS - params.keys
    missing_keys.each do |missing_key|
      missing_param_errors[missing_key] = 'Missing in URL Query Param.'
    end
    missing_param_errors
  end

  #check if the values given in the query params are valid resources or not. If not, raise 400 with appropriate message.
  def validate_input_data
    errors = {}
    missing_param_errors = check_missing_params
    if missing_param_errors.blank?
      BranchConstants::INDEX_QUERY_PARAMS.each do |query_param|
        if send("#{query_param}_from_cache").exclude?(params[query_param].try(:upcase))
          errors[query_param] = "No #{query_param} found with the given value '#{params[query_param]}'"
        end
      end
      log_and_render_error(API_ERROR_MAPPINGS[:BAD_REQUEST],errors) if errors.any?
    else
      log_and_render_error(API_ERROR_MAPPINGS[:BAD_REQUEST],missing_param_errors)
    end
  end

  #methods invoked from render_blueprinter method of application_controller 
  def blueprint
    'BranchBlueprint'.constantize
  end

  def root
    'branch'.freeze
  end

end
