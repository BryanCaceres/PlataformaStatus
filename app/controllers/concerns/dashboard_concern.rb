module DashboardConcern
  extend ActiveSupport::Concern
  
  def get_client_options(ids = [])
    clients = Client.select("clients.id, clients.name || ' | ' || countries.iso as label").joins(:country).left_joins(:client_general_results, :client_historical_results).where("client_general_results.is_active = true OR client_historical_results.is_active = true").order('label')

    clients = clients.where(id: ids) unless ids.empty?

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

  def get_historical_results
    client_historical_result = @client&.client_historical_results&.where(client_historical_results: { is_active: true })&.select(:results)&.first

    efy_historical = client_historical_result&.results&.dig('efy')

    @efy_historical_general = efy_historical.select { |entry| entry['type'] == 'general' } unless efy_historical.nil?
    @efy_historical_tech = efy_historical.select { |entry| entry['type'] == 'tech' } unless efy_historical.nil?
    @efy_historical_fem = efy_historical.select { |entry| entry['type'] == 'femenino' } unless efy_historical.nil?
  end

  def get_active_study_by_key_name(key_name)
    Study.find_by(key_name: key_name, is_active: true)
  end
end