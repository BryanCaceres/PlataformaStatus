require 'sidekiq-scheduler'

class UpdateCountryStatusJob
  include Sidekiq::Worker

  @@APPLICATION_STATUSES = { 'normal' => 1, 'critical' => 2 }
  @@DAYS_BEFORE_CRITICAL_PERIOD = { 'country' => 14, 'survey' => 7 }

  def perform
    if FeatureFlagService.is_active?('response_update_jobs')
      current_date = DateTime.now
      current_year = current_date.year

      country_aplicaction_details = get_applying_countries(current_year)
      if country_aplicaction_details.empty?
        put_message("No se encontraron paises aplicando")
        return
      end

      put_message("ACTUALIZACIÓN DE country_aplicaction_details INICIADA")

      update_country_application_statuses(country_aplicaction_details, current_date)
      
      put_message("ACTUALIZACIÓN DE country_aplicaction_details FINALIZADA")

      active_surveys = get_active_surveys
      if active_surveys.empty?
        put_message("No se encontraron encuestas activas")
        return
      end

      put_message("ACTUALIZACIÓN DE active_surveys INICIADA")
      
      update_survey_application_statuses(active_surveys, current_date)
      
      put_message("ACTUALIZACIÓN DE active_surveys FINALIZADA")
    else
      put_message("EL MANEJO DE ESTADOS PAISES Y ENCUESTAS ESTA DESACTIVADA")
    end
  end
  
  private
  
  def get_applying_countries(year)
    CountryApplicationDetail.where(is_active: true, year: year)
  end

  def update_country_application_statuses(country_aplicaction_details, current_date)
    country_aplicaction_details.each do |country_applying|
      end_date = country_applying.end_date
      critical_period = end_date - @@DAYS_BEFORE_CRITICAL_PERIOD['country']
      set_country_application_status(country_applying, end_date, critical_period, current_date)
    end
  end

  def set_country_application_status(country_applying, end_date, critical_period, current_date)
    current_application_status = country_applying.study_application_status_id

    return country_applying.update(is_active: false) if current_date > end_date

    return country_applying.update(study_application_status_id: @@APPLICATION_STATUSES['critical']) if current_date >= critical_period

    return country_applying.update(study_application_status_id: @@APPLICATION_STATUSES['normal']) if current_application_status != @@APPLICATION_STATUSES['normal']

    return country_applying
  end

  def update_survey_application_statuses(active_surveys, current_date)
    active_surveys.each do |survey|
      application_start = survey.application_start
      application_end = survey.application_end
      critical_period = application_end - @@DAYS_BEFORE_CRITICAL_PERIOD['survey']
      set_survey_application_status(survey, application_end, critical_period, current_date)
    end
  end

  def get_active_surveys
    SurveysInformation.where(is_active: true, is_archived: false)
  end

  def set_survey_application_status(survey, application_end, critical_period, current_date)
    # Verificación de desactivación por haber alcanzado muestra minima o estar fuera de plazo
    return survey.update(is_active: false) if survey.reached_minimum_sample? || current_date > application_end

    country_id = survey&.client&.country_id
    return if country_id.nil?

    country_aplication_detail = get_country_aplication_detail_by_survey_information(country_id, survey.product_id, survey.year)
    return if country_aplication_detail.nil?

    # Se verifica desactivación según país
    return survey.update(is_active: false) unless country_aplication_detail.is_active

    # Se cambia el estado en base al que tiene el país
    return survey.update(study_application_status_id: @@APPLICATION_STATUSES['critical']) if country_aplication_detail.study_application_status_id == @@APPLICATION_STATUSES['critical']

    current_survey_status = survey&.study_application_status_id
    return if current_survey_status.nil?

    # Cambio de estado por estar en el periodo critico
    return survey.update(study_application_status_id: @@APPLICATION_STATUSES['critical']) if current_date >= critical_period

    return survey.update(study_application_status_id: @@APPLICATION_STATUSES['normal']) if current_survey_status != @@APPLICATION_STATUSES['normal']

    return survey
  end

  def get_country_aplication_detail_by_survey_information(country_id, product_id, year)
    CountryApplicationDetail.select(:id, :study_application_status_id, :is_active).where(country_id: country_id, product_id: product_id, year: year).first
  end

  def put_message(message)
    puts "#########################################"
    puts message
    puts "#########################################"
  end

end
