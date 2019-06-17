class JsonWebToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  #returns the JWT token for given payload and expiry time. Default expiry time is 5 days.
  def self.encode(payload, exp = 5.days.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  #returns a hash with user_id and expiry of the token in UNIX epoch
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  end
end