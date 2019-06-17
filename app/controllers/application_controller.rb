class ApplicationController < ActionController::Base

  include ApiConstants

  rescue_from ActionController::UnpermittedParameters, with: :invalid_field_handler

  before_action :authorize_request
  before_action :validate_index_params, only: :index
  before_action :load_objects, only: :index
  before_action :load_object, only: :show
  
  def index
    if @items.present?
      render_blueprinter(@items,:api_v1,root.pluralize)
    else
      log_and_render_error(API_ERROR_MAPPINGS[:NO_CONTENT]) 
    end
  end

  def show
    if @item.present?
      render_blueprinter(@item,:api_v1_detail,root)
    else
      log_and_render_error(API_ERROR_MAPPINGS[:RESOURCE_NOT_FOUND])
    end
  end

private

  def authorize_request
    header = request.headers['Authorization'] || params[:auth]
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def not_found
    render json: { error: 'not_found' }
  end

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

  def paginate_items(items)
    paginated_items = items.paginate(paginate_options)
    next_page_exists = paginated_items.length > @per_page || paginated_items.next_page
    add_link_header(page: (page + 1)) if next_page_exists
    paginated_items[0..(@per_page - 1)] # get paginated_collection of length 'per_page'
  end

  # Add link header if next page exists.
  def add_link_header(query_parameters)
    response.headers['Link'] = construct_link_header(query_parameters)
  end

  # Construct link header for paginated collection
  def construct_link_header(updated_query_parameters)
    query_string = '?'

    # Construct query string with updated_query_parameters.
    request.query_parameters.merge(updated_query_parameters).each { |x, y| query_string += "#{x}=#{y}&" }
    url = url_for(only_path: false) + query_string.chop # concatenate url & chopped query string
    "<#{url}>; rel=\"next\""
  end

  def paginate_options
      options = {}
      @per_page = per_page # user given/defualt page number
      options[:per_page] =  @per_page
      options[:page] = page
      options
  end

  def page
    (params[:page] || ApiConstants::DEFAULT_PAGINATE_OPTIONS[:page]).to_i
  end

  def per_page
    (params[:per_page] || ApiConstants::DEFAULT_PAGINATE_OPTIONS[:per_page]).to_i
  end

  def render_blueprinter(items = nil,view=api_v1,_root)
    render json: blueprint.render(items,view: view,root: _root || root), status: API_ERROR_MAPPINGS[:OK]
  end

end
