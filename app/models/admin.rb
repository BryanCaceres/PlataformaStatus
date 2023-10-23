class Admin < ApplicationRecord
    validates :name, :email, presence: true
    validates_uniqueness_of :email

    has_secure_password

    def send_otp_email(password)
        GeneralMailer.send_password(self.email, password).deliver_later
    end
    
    def send_otp_sms(password)
    account_sid = 'YOUR_TWILIO_ACCOUNT_SID'
    auth_token = 'YOUR_TWILIO_AUTH_TOKEN'
    client = Twilio::REST::Client.new(account_sid, auth_token)

    from = 'whatsapp:+1234567890' # Número de Twilio para WhatsApp Business
    to = "+5692345678" # Número de teléfono del usuario

    client.messages.create(
        from: from,
        to: to,
        body: "Tu código OTP es: #{password}"
    )
    end
end
