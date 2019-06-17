require 'pagy'
require 'pagy/extras/countless'
require 'pagy/extras/array'
require 'pagy/extras/overflow' #added to handle overflow page issue
class ApplicationController < ActionController::Base

  include ApiConstants

  protect_from_forgery with: :exception
  rescue_from ActionController::UnpermittedParameters, with: :invalid_field_handler

  before_action :validate_index_params, only: [:index]


  def log_and_render_error(error_code,error_body=nil)
    log_error(error_code,error_body)
    if error_body.present?
      render json: error_body, status: error_code
    else
      head error_code
    end
  end

  def log_error(error_code,error_body)
    Rails.logger.info("Error in processing api #{request.path}.")
    Rails.logger.info("Error Code #{error_code}")
    Rails.logger.info("Error message #{error_body}")
  end

  def validate_index_params(additional_params)
    params.permit(*ApiConstants::DEFAULT_INDEX_PARAMS, *additional_params)
  end

  def invalid_field_handler(exception) # called if extra fields are present in params.
    Rails.logger.error("API Unpermitted Parameters. Params : #{params.inspect} Exception: #{exception.class}  Exception Message: #{exception.message}")
    invalid_fields = exception.params
    errors = Hash[invalid_fields.map { |v| [v, :invalid_field] }]
    log_and_render_error(API_ERROR_MAPPINGS[:BAD_REQUEST],errors)
  end

  # will take scoper as one argument.
  def load_objects(items = scoper)
    @items = paginate_items(items)
  end

  def paginate_items(items)
    is_array = !items.respond_to?(:scoped) # check if it is array or AR
    paginated_items = items.paginate(paginate_options(is_array))

    # next page exists if scoper is array & next_page is not nil or
    # next page exists if scoper is AR & collection length > per_page
    next_page_exists = paginated_items.length > @per_page || paginated_items.next_page && is_array
    add_link_header(page: (page + 1)) if next_page_exists
    paginated_items[0..(@per_page - 1)] # get paginated_collection of length 'per_page'
  end

  # Add link header if next page exists.
  def add_link_header(query_parameters)
    response.headers['Link'] = construct_link_header(query_parameters)
  end

  def add_total_entries(total_items)
    response.headers['X-Search-Results-Count'] = total_items.to_s
  end
  # Construct link header for paginated collection
  def construct_link_header(updated_query_parameters)
    query_string = '?'

    # Construct query string with updated_query_parameters.
    request.query_parameters.merge(updated_query_parameters).each { |x, y| query_string += "#{x}=#{y}&" }
    url = url_for(only_path: false) + query_string.chop # concatenate url & chopped query string
    "<#{url}>; rel=\"next\""
  end

  def paginate_options(is_array = false)
      options = {}
      @per_page = per_page # user given/defualt page number
      options[:per_page] =  is_array ? @per_page : @per_page + 1 # + 1 to find next link unless scoper is array
      options[:offset] = @per_page * (page - 1) unless is_array # assign offset unless scoper is array
      options[:page] = page
      options[:total_entries] = options[:page] * options[:per_page] unless is_array # To prevent paginate from firing count query unless scoper is array
      options
  end

  def page
    (params[:page] || ApiConstants::DEFAULT_PAGINATE_OPTIONS[:page]).to_i
  end

  def per_page
    (params[:per_page] || ApiConstants::DEFAULT_PAGINATE_OPTIONS[:per_page]).to_i
  end

end
