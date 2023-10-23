require 'jwt'

class Jwt
  def self.encode(payload)
    JWT.encode payload, ENV["JWT_SECRET"], ENV["JWT_ALGORITHM"]
  end

  def self.decode(token)
    begin
      decoded = JWT.decode token, ENV["JWT_SECRET"], true, { algorithm: ENV["JWT_ALGORITHM"] }
      return decoded[0]
    rescue => e
      puts e.inspect
      return nil
    end
  end
end