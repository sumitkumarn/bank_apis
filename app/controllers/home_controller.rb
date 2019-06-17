class HomeController < ActionController::Base

  def index
    Rails.logger.info "Environment information #{ENV}"
  end

end