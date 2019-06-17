class HomeController < ActionController::Base

  def index
    render plain: "Hello. Welcome to Bankify", status: 200
  end

end