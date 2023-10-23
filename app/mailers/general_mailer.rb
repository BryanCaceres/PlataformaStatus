class GeneralMailer < ApplicationMailer

  def send_password(email, password)
    @password = password

    mail(from: "Estudios FirstJob <efy@firstjob.cl>",
        to: email,
        subject: "Tu Contraseña de un solo uso para estudios FirstJob (EFY, BIE)")
  end

end
