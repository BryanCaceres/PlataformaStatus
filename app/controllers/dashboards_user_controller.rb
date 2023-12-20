class DashboardsUserController < ApplicationController
  before_action :authenticate_user!, except: [:initialize]
  before_action :handle_index, only: [:index]
  
  include DashboardConcern
  
  def initialize
    super
    # Include the main layout bootstrap file
    require_relative "../views/#{Rails.configuration.settings.KT_THEME_LAYOUT_DIR}/_bootstrap/default"

    # Initialize the main layout bootstrap class
    KTBootstrapDefault.new.init(helpers)
  end

  def index
    # Include vendors and javascript files for dashboard widgets
    helpers.addVendors(%w[amcharts amcharts-maps amcharts-stock])
    render "pages/dashboards/index"
  end

  private

  def handle_index
    user_accesses = handle_user_accesses
    
    @client_options = get_client_options(user_accesses)

    client_id = params[:client_id] ? params[:client_id] : @client_options&.first&.second 

    @client = get_client_by_id(client_id)
    
    get_study_information # Establece variables de instancia para la información base de los estudios
    
    get_general_information # Establece las variables de instacia para la información de los rankings generales del cliente
 
    get_historical_results
  end

  def handle_user_accesses
    user_accesses = get_user_access_client_ids(current_user.id)
    if user_accesses.empty?
      logout("No se encontró su información asociada. Intene nuevamente más tarde. Si el problema persiste pongase en contacto con soporte")
    end

    return user_accesses
  end

  def get_user_access_client_ids(id)
    UserAccess.where(user_id: id).pluck(:client_id)
  end

end
