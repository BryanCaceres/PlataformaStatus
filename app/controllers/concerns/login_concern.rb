module LoginConcern
	extend ActiveSupport::Concern

  def set_otp_password(identity)
    OtpLogin.set_password(identity)
  end

  def set_type_session(type)
    session["type_#{type}".to_sym] = true
  end

  def set_otp_cookie(identity, type)
    session["#{type}_otp".to_sym] = identity.email
  end

  def set_session_ip(ip, type)
    session["#{type}_ip".to_sym] = ip
  end

  def delete_session_otp(type)
    session.delete("#{type}_otp".to_sym)
  end


end