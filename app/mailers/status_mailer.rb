class StatusMailer < ApplicationMailer

    def send_notification(email, deal_ops_survey_ids, errors, cc = [])
      @errors = errors
      @deal_ops_survey_ids = deal_ops_survey_ids
  
      mail(from: "Sistema Status <hola@efy.global>" ,
          to: email,
          subject: "Estado Actualización Conteo de Respuestas")
    end
  
end