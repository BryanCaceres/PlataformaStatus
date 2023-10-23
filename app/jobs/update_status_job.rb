require 'sidekiq-scheduler'

class UpdateStatusJob
  include Sidekiq::Worker

  @@DEFAULT_TIME_ZONE = 'America/Santiago'

  def perform
    if FeatureFlagService.is_active?('response_update_jobs')
      current_date = DateTime.now # Está en la zona horaria indicada en config.time_zone
      current_year = current_date.year
      
      country_aplicaction_details = get_applying_countries(current_year)
      if country_aplicaction_details.empty?
        put_message("No se encontraron paises aplicando")
        return
      end

      deal_ops_survey_ids = get_deal_ops_surveys_ids_to_update(country_aplicaction_details, current_date)

      if deal_ops_survey_ids.empty?
        put_message("NO EXISTEN ENCUESTAS PARA ACTUALIZAR")
        return
      end

      errors = []
      deal_ops_survey_ids_updated = []
      api = Api.new(ENV["SIDKIQ_TOKEN"], ENV["API_CRM_DOMAIN"])

      deal_ops_survey_ids.each do |deal_ops_survey_id|
        response = get_response_count(api, deal_ops_survey_id)
        if response.dig("msg") == nil && ![200, 201].include?(response.dig("statusCode"))
          errors << "Error al actualizar deal_ops_survey id => #{deal_ops_survey_id} | statusCode #{response.dig("statusCode")} | detalle #{response.dig("message")}"
          next
        end

        deal_ops_survey_ids_updated << deal_ops_survey_id
      end

      put_message("PROCESO DE ACTUALIZACIÓN FINALIZADO")
      put_message("ERRORES ===> #{ errors.join(" , ") }") if errors.size > 0

      StatusMailer.send_notification(ENV['DEFAULT_NOTIFICATION_RECEIVER'], deal_ops_survey_ids_updated, errors).deliver_later if deal_ops_survey_ids_updated.present? || errors.present?
    else
      put_message("LA ACTUALIZACIÓN DIARIA ESTA DESACTIVADA")
    end
  end
  
  private

  def get_applying_countries(year)
    CountryApplicationDetail.where(is_active: true, year: year)
  end

  def get_deal_ops_surveys_ids_to_update(country_aplicaction_details, current_date)
    surveys_to_update = get_surveys_to_update(country_aplicaction_details, current_date)

    if surveys_to_update.empty?
      put_message("NO SE ENCONTRARON ENCUESTAS PARA ACTUALIZAR A ESTA HORA")
      return []
    end
    
    surveys_id_to_update = surveys_to_update&.pluck(:id)
    return get_deal_ops_survey_ids_by_surveys_to_update(surveys_id_to_update)
  end

  def get_surveys_to_update(country_aplicaction_details, current_date)
    surveys_to_update = []
    country_aplicaction_details.each do |country_applying|
      surveys_to_update_now = get_surveys_to_update_now(country_applying, current_date)
      
      next if surveys_to_update_now.empty?
      
      surveys_to_update.push(*surveys_to_update_now)
    end

    return surveys_to_update
  end

  def get_surveys_to_update_now(country_applying, current_date)
    time_zone = country_applying.country&.time_zone || @@DEFAULT_TIME_ZONE
    tz_current_date = time_zone == @@DEFAULT_TIME_ZONE ? current_date : current_date.in_time_zone(time_zone)
    current_hour_str = tz_current_date.strftime("%H:%M")

    surveys = get_surveys_by_country_product_year(country_applying.country_id, country_applying.product_id, country_applying.year)
    return [] if surveys.empty?

    surveys_to_update_now = filter_surveys_by_current_time(surveys, current_hour_str)      
    return [] if surveys_to_update_now.empty?

    return surveys_to_update_now
  end 
  
  def get_surveys_by_country_product_year(country_id, product_id, year)
    SurveysInformation.joins(:client).where(is_active: true, is_archived: false, product_id: product_id, year: year).where(client: { country_id: country_id })
  end

  def filter_surveys_by_current_time(surveys, current_hour_str)
    surveys.select { |survey| survey.update_hours.include?(current_hour_str) } 
  end

  def get_deal_ops_survey_ids_by_surveys_to_update(surveys_id_to_update)
    DealOpsSurvey.where(survey_information_id: surveys_id_to_update)&.pluck(:id)
  end

  def get_response_count(api, deal_ops_survey_id, update_n_collectors = false)
    api.send("post", "survey-information/count", { dealOpsSurveyId: deal_ops_survey_id, updateNumberOfCollector: update_n_collectors }.to_json)
  end

  def put_message(message)
    puts "#########################################"
    puts message
    puts "#########################################"
  end

end
