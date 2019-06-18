module ApiConstants
  
  API_ERROR_MAPPINGS = {
    BAD_REQUEST: 400,
    RESOURCE_NOT_FOUND: 404,
    OK: 200,
    NO_CONTENT: 204,
    UNAUTHORIZED: 401
  }

  DEFAULT_PAGINATE_OPTIONS = {
    limit: 30,
    max_limit: 100,
    offset: 0
  }

  DEFAULT_PARAMS = %w(controller action auth id)

  PAGINATE_PARAMS = %w(offset limit)

  DEFAULT_INDEX_PARAMS = DEFAULT_PARAMS | PAGINATE_PARAMS 

end