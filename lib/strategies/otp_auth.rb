Warden::Strategies.add(:otp_auth) do
  def valid?
    params['otp'].present?
  end

  def authenticate!
    # Obtiene el usuario por email
    identity = get_admin_by_email(session[:user_otp])

    # Si no existe el usuario o no está activo devuelve error
    return fail! "Datos de acceso incorrectos" unless identity

    # Si se agotó el tiempo de duración del código devuelve error
    return fail! "Se acabó el tiempo de validez del código. Por favor vuelve a solicitarlo." if identity.settings["login_date"].present? && (Time.zone.now.to_i > (Time.zone.at(identity.settings["login_date"]) + ENV["OTP_TIMEOUT"].to_i).to_i)

    # Si la contraseña es incorrecta devuelve error
    return fail! "Datos de acceso incorrectos" unless check_identity(identity, params['otp']['password']) && identity.settings["password_active"]

    # Genera el token de acceso y lo asocia en session[:token_user]
    set_session_token(identity)

    # Elimina la ip de session[:user_ip]
    delete_session_ip

    # Elimina el usuario de session[:user_otp]
    delete_session_otp

    # Devuelve success! al estar todo correcto
    return success! identity
  end

  private

  def get_admin_by_email(email)
    Admin.find_by(email: email, is_active: true)
  end

  def check_identity(identity, password)
    identity.try(:authenticate, password)
  end

  def session_ip
    session[:user_ip]
  end

  def set_session_token(identity)
    session[:token_user] = generate_access_token(identity)
  end

  def generate_access_token(identity)
    Jwt.encode({ sub: identity.id, ip_address: session_ip })
  end

  def delete_session_ip
    session.delete(:user_ip)
  end

  def delete_session_otp
    session.delete(:user_otp)
  end
end