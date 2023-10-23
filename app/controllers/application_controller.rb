class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?

  # Main initialization
  def initialize
    initThemeMode
    initThemeDirection
    initLayout
  end

  # Init theme mode option from settings
  def initThemeMode
    helpers.setModeSwitch(Rails.configuration.settings.KT_THEME_MODE_SWITCH_ENABLED)
    helpers.setModeDefault(Rails.configuration.settings.KT_THEME_MODE_DEFAULT)
  end

  # Init theme direction option (RTL or LTR) from settings
  # Init RTL html attributes by checking if RTL is enabled.
  # This function is being called for the html tag
  def initThemeDirection
    helpers.setDirection(Rails.configuration.settings.KT_THEME_DIRECTION)

    if helpers.isRtlDirection
      helpers.addHtmlAttribute('html', 'direction', 'rtl')
      helpers.addHtmlAttribute('html', 'dir', 'rtl')
      helpers.addHtmlAttribute('html', 'style', 'direction: rtl')
    end
  end

  # Init layout html attributes and classes
  def initLayout
    helpers.addHtmlAttribute('body', 'id', 'kt_app_body')
    helpers.addHtmlAttribute('body', 'data-kt-name', helpers.getName())
  end

  def warden
    request.env['warden']
  end

  def health
    render json: {
      :error => false,
      :message => "Success"
    }, status: 200
  end

  def authenticate_user!
    unless user_signed_in?
      close_user_session
      flash[:error] = "Para acceder debe iniciar sesión."
      redirect_to login_path
    end
  end

  def user_signed_in?
    if decoded_session_token.nil?
      close_user_session 
      return false
    end

    return true
  end

  def current_user
    data_token = decoded_session_token
    return false if data_token.nil?
    get_admin(data_token["sub"])
  end

  def close_user_session
    warden.logout
    delete_session_token
  end

  private

  def session_token
    session[:token_user]
  end

  def decoded_session_token
    Jwt.decode(session_token)
  end

  def get_admin(id)
    @current_user ||= Admin.find_by(id: id)
  end

  def get_user(id)
    @current_user ||= User.find_by(id: id)
  end

  def delete_session_token
    session.delete(:token_user)
  end
end
