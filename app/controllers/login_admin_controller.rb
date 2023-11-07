class LoginAdminController < ApplicationController
  before_action :authenticate_admin!, only: [:logout]
  before_action :check_access, only: [:signin, :verify]
  before_action :check_access_verify, only: [:verify]
  before_action :check_recaptcha, only: [:create]

  include LoginConcern

  def initialize
    super
    # Include the main layout bootstrap file
    require_relative "../views/#{Rails.configuration.settings.KT_THEME_LAYOUT_DIR}/_bootstrap/auth"

    # Initialize the main layout bootstrap class
    KTBootstrapAuth.new.init(helpers)
  end

  def signin
    helpers.addJavascriptFile('custom/authentication/sign-in/general-admin.js')

    # Elimina la session[:admin_otp] al cargar la vista de inicio de sesión, esto obliga a que deba solicitar una nueva contraseña al momento de volver a esa vista.
    delete_session_otp("admin")

    # Guarda la ip del usuario en session[:user_ip]
    set_session_ip(get_ip, "admin")

    render "pages/auth/signin_admin"
  end

  def create
    # Valida que el correo electronico este presente
    redirect_login("El correo electronico es obligatorio.") and return unless params[:otp][:email].present?
    
    # Obtiene el usuario por email
    identity = get_admin_by_email(params[:otp][:email].strip)
    
    # Valida que el usuario exista
    redirect_login("Error en el inicio de sesión.") and return unless identity.present?

    # Crea la contraseña y envia el correo electronico
    set_password = set_otp_password(identity)

    # Valida que la contraseña se haya creado correctamente
    redirect_login("Error en el inicio de sesión.") and return if set_password[:error]

    # Crea la cookie con el usuario, esto para validar el acceso a la vista de verificación
    set_otp_cookie(identity, "admin")
    
    # Redirecciona a la vista de verificación
    redirect_to admin_otps_verify_path
  end 

  def verify
    helpers.addJavascriptFile('custom/authentication/sign-in/general-admin-otp.js')

    render "pages/auth/verify_admin"
  end

  def confirm
    # Si no viene el password redirecciona a la vista de verificación
    redirect_otp("Debe ingresar la contraseña.") and return unless params[:otp][:password].present?

    # Crea la session con el tipo de usuario que es admin o user
    set_type_session("admin")
    
    # Autentica el usuario
    warden.authenticate!(:admin_auth)

    # Desactiva la contraseña del usuario
    cancel_password(current_admin)

    # Elimina la session[:admin_otp] al cargar la vista de inicio de sesión, esto obliga a que deba solicitar una nueva contraseña al momento de volver a esa vista.
    delete_session_otp("admin")
    
    # Redirecciona a la vista de inicio
    redirect_root
  end

  def logout
    close_user_session
    redirect_login
  end

  def check_recaptcha
    success = verify_recaptcha(action: 'login_recaptcha', minimum_score: 0.7, secret_key: ENV['RECAPTCHA_SECRET_KEY_V3'])
    checkbox_success = verify_recaptcha(message: 'Error in passing CAPTCHA.') unless success
    if !success && !checkbox_success
        flash[:error] = 'No se ha podido validar su intento de iniciar sesión, asegurese de marcar la casilla, "No soy un robot"'
        flash[:show_checkbox_recaptcha] = true
        redirect_to admin_login_path and return
    end
  end

  private

  def check_access
    redirect_root if session[:token_admin].present?
  end

  def check_access_verify
    redirect_login unless session[:admin_otp].present?
  end
  
  def get_admin_by_email(email)
    Admin.find_by(email: email, is_active: true)
  end

  def cancel_password(identity)
    identity.settings["password_active"] = false
    identity.save
  end

  def redirect_login(message = nil)
    flash[:error] = message if message.present?
    redirect_to admin_login_path
  end

  def redirect_otp(message = nil)
    flash[:error] = message if message.present?
    redirect_to admin_otps_verify_path
  end

  def redirect_root
    redirect_to root_path
  end
end
