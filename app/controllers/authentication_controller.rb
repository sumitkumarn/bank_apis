class AuthenticationController < ApplicationController
  before_action :authorize_request, except: :login

  # POST /auth/login
  #If login is success, then jwt token is sent as response along with expiry in epoch
  #In case of login failure, unauthorized response is sent back.
  def login
    @user = User.find_by_email(params[:email])
    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 5.days.to_i
      render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                     username: @user.username }, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  private
  #whitelist login params
  def login_params
    params.permit(:email, :password)
  end
end