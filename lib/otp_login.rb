class OtpLogin

  def self.set_password(identity)
    # Crear contraseña
    temporal_password = SecureRandom.hex(3)
    
    # Actualizar contraseña usuario
    identity.password = temporal_password
    identity.password_confirmation = temporal_password
    identity.settings["login_date"] = Time.zone.now.to_i
    identity.settings["password_active"] = true

    # Devuelve error si no se pudo actualizar la información
    return { :error => true, :message => "Hubo un problema al generar la contraseña" } unless identity.save 

    # Envía contraseña por email
    identity.send_otp_email(temporal_password)

    # Envía contraseña por sms (Proxima implementacion)
    # identity.send_otp_sms(temporal_password)

    # Devuelve mensaje de éxito
    return { :error => false, :message => "Si el usuario existe se le enviará su contraseña por email" }
  end

end