module ApiConstants
  
  API_ERROR_MAPPINGS = {
    BAD_REQUEST: 400,
    RESOURCE_NOT_FOUND: 404,
    OK: 200,
    NO_CONTENT: 204,
    UNAUTHORIZED: 401
  }

  DEFAULT_PAGINATE_OPTIONS = {
    per_page: 30,
    max_per_page: 100,
    page: 1
  }

  DEFAULT_PARAMS = %w(controller action auth id)

  PAGINATE_PARAMS = %w(page per_page)

  DEFAULT_INDEX_PARAMS = DEFAULT_PARAMS | PAGINATE_PARAMS 

end