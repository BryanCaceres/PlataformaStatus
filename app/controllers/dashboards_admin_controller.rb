class DashboardsAdminController < ApplicationController
  before_action :authenticate_admin!, except: [:initialize]
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
    @client_options = get_client_options 
    
    client_id = params[:client_id] ? params[:client_id] : @client_options&.first&.second 

    @client = get_client_by_id(client_id)
    
    get_study_information # Establece variables de instancia para la información base de los estudios
    
    get_general_information # Establece las variables de instacia para la información de los rankings generales del cliente

    get_historical_results
  end

end
