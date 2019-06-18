class ApplicationController < ActionController::Base

  #The parent class for all controller class in the application.
  #Has some methods for default validations of query parameters and also handles authentication

  include ApiConstants

  rescue_from ActionController::UnpermittedParameters, with: :invalid_field_handler

  before_action :authorize_request
  before_action :validate_query_params, only: [:index,:show]
  before_action :load_objects, only: :index
  before_action :load_object, only: :show
  
  def index
      render_blueprinter(@items,:api_v1,root.pluralize)
  end

  def show
    if @item.present?
      render_blueprinter(@item,:api_v1_detail,root)
    else
      log_and_render_error(API_ERROR_MAPPINGS[:RESOURCE_NOT_FOUND])
    end
  end

private
  #handle authorization
  def authorize_request
    header = request.headers['Authorization'] || params[:auth] #params[:auth] is added for testing apis from browser.
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @decoded.key?(:user_id) && User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: API_ERROR_MAPPINGS[:UNAUTHORIZED]
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: API_ERROR_MAPPINGS[:UNAUTHORIZED]
    end
  end

  def not_found
    render json: { error: 'not_found' }
  end

  def log_and_render_error(error_code,error_body=nil)
    log_error(error_code,error_body)
    if error_body.present?
      render json: {error: error_body}, status: error_code
    else
      head error_code
    end
  end

  def log_error(error_code,error_body)
    Rails.logger.info("Error in processing api #{request.path}.")
    Rails.logger.info("Error Code #{error_code}")
    Rails.logger.info("Error message #{error_body}")
  end

  #This method raises Unpermitted params exception which is caught and rescued by invalid_field_handler method
  def validate_query_params(additional_params = nil)
    params.permit(*ApiConstants::DEFAULT_INDEX_PARAMS, *additional_params)
  end

  def invalid_field_handler(exception) # called if extra fields are present in params.
    Rails.logger.error("API Unpermitted Parameters. Params : #{params.inspect} Exception: #{exception.class}  Exception Message: #{exception.message}")
    invalid_fields = exception.params
    errors = Hash[invalid_fields.map { |v| [v, :unpermitted_param] }]
    log_and_render_error(API_ERROR_MAPPINGS[:BAD_REQUEST],errors)
  end

  #paginate records based on the given limit and offset values
  def paginate_items(items)
    paginated_items = items.paginate(paginate_options)
    next_page_exists = paginated_items.length > @limit || paginated_items.next_page
    add_link_header(offset: (offset + 1)) if next_page_exists
    paginated_items[0..(@limit - 1)] # get paginated_collection of length 'limit'
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
      @limit = limit # user given/defualt offset number
      options[:per_page] =  @limit
      options[:page] = offset + 1
      options
  end

  def offset
    (params[:offset] || ApiConstants::DEFAULT_PAGINATE_OPTIONS[:offset]).to_i
  end

  def limit
    (params[:limit] || ApiConstants::DEFAULT_PAGINATE_OPTIONS[:limit]).to_i
  end

  def render_blueprinter(items = nil,view=api_v1,_root)
    render json: blueprint.render(items,view: view,root: _root || root), status: API_ERROR_MAPPINGS[:OK]
  end

  def show?
    @show ||= current_action?('show')
  end

  def index?
    @index ||= current_action?('index')
  end

  def current_action?(action)
    action_name.to_s == action
  end


end
