class DashboardsAdminController < ApplicationController
  before_action :authenticate_admin!, except: [:initialize]
  before_action :handle_index, only: [:index]
  
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
  end

  def get_client_options
    clients = Client.select("clients.id, clients.name || ' | ' || countries.iso as label").joins(:country).left_joins(:client_general_results, :client_historical_results).where("client_general_results.is_active = true OR client_historical_results.is_active = true").order('label')

    clients.empty? ? [] : clients.order('label ASC').map { |option| [option.label, option.id] }
  end

  def get_client_by_id(id)
    Client.find_by(id: id)
  end

  def get_study_information
    @efy = get_active_study_by_key_name('efy')
    @bie = get_active_study_by_key_name('bie')
    @tom = get_active_study_by_key_name('tom')
  end

  def get_general_information
    client_general_result = @client&.client_general_results&.where(client_general_results: { is_active: true })&.select(:results)&.first

    @efy_general = client_general_result&.results&.dig('efy')
    @bie_general = client_general_result&.results&.dig('bie')
    @tom_general = client_general_result&.results&.dig('tom')
  end

  def get_active_study_by_key_name(key_name)
    Study.find_by(key_name: key_name, is_active: true)
  end

end