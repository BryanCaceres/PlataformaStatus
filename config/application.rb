require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Keenthemes
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = ENV['AVAILABLE_LOCALE'].split(",").map(&:to_sym)
    config.i18n.default_locale = ENV['DEFAULT_LOCALE'].to_sym
    config.time_zone = 'Santiago'
    config.active_record.default_timezone = :local

    config.action_mailer.delivery_method = :smtp

    config.action_mailer.smtp_settings = {
      :user_name => ENV['SMTP_USER_NAME'],
      :password => ENV['SMTP_PASSWORD'],
      :address => ENV['SMTP_ADDRESS'],
      :domain => ENV['SMTP_DOMAIN'],
      :port => ENV['SMTP_PORT'],
      :authentication => ENV['SMTP_AUTHENTICATION']
    }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Custom configuration for Keenthemes application
    config.settings = config_for(:settings)

    config.autoload_paths += %W(#{config.root}/lib)

    # Sets the exceptions application invoked by the ShowException middleware when an exception happens.
    config.exceptions_app = self.routes
  end
end
