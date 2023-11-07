require 'strategies/admin_auth'
require 'strategies/user_auth'

Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :admin_auth, :user_auth
  manager.failure_app = ApplicationController.action(:failure)
end