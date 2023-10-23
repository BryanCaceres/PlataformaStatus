require 'strategies/otp_auth'

Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :otp_auth
  manager.failure_app = AuthController.action(:failure)
end