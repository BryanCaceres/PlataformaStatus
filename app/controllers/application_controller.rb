class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?, :current_admin, :admin_signed_in?, :get_current_identity_name, :get_current_identity_email, :get_current_logout_redirect

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

  def failure
    flash[:error] = "Error en el inicio de sesión."
    redirect_login_identity
  end

  def redirect_login_identity
    session[:type_admin].present? ? (redirect_to admin_otps_verify_path) : (redirect_to otps_verify_path)
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
    if decoded_session_token(user_session_token).nil?
      close_user_session 
      return false
    end

    return true
  end

  def current_user
    data_token = decoded_session_token(user_session_token)
    return false if data_token.nil?
    get_user(data_token["sub"])
  end

  def close_user_session
    warden.logout
    delete_session_token(:token_user)
  end

  def authenticate_admin!
    unless admin_signed_in?
      close_admin_session
      flash[:error] = "Para acceder debe iniciar sesión."
      redirect_to admin_login_path
    end
  end

  def admin_signed_in?
    if decoded_session_token(admin_session_token).nil?
      close_admin_session 
      return false
    end

    return true
  end

  def current_admin
    data_token = decoded_session_token(admin_session_token)
    return false if data_token.nil?
    get_admin(data_token["sub"]) 
  end

  def close_admin_session
    warden.logout
    delete_session_token(:token_admin)
  end

  def get_current_identity_name
    current_user ? current_user.name : current_admin.name
  end
  
  def get_current_identity_email
    current_user ? current_user.email : current_admin.email 
  end

  def get_current_logout_redirect
    current_user ? logout_path : admin_logout_path
  end  

  def get_ip
    request.headers["CF-Connecting-IP"].present? ? request.headers["CF-Connecting-IP"] : request.remote_ip
  end

  private

  def user_session_token
    session[:token_user]
  end

  def admin_session_token
    session[:token_admin]
  end
  
  def decoded_session_token(token)
    Jwt.decode(token)
  end

  def delete_session_token(token)
    session.delete(token)
  end

  def get_user(id)
    @current_user ||= User.find_by(id: id)
  end

  def get_admin(id)
    @current_admin ||= Admin.find_by(id: id)
  end
end
