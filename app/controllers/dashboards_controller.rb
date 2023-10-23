class DashboardsController < ApplicationController
  before_action :authenticate_user!, except: [:initialize]
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
    @status_watcher_surveys = []
    current_user.status_watcher_accesses.each do |swa|
      deals_ops_info = get_deal_ops_by_client(swa.client_id)
      next if deals_ops_info.empty?
      client = swa.client
      surveys = get_surveys(deals_ops_info, swa.product_id)
      next if surveys.empty?
      @status_watcher_surveys << { 'client' => client, 'surveys' => surveys }
    end
  end

  def get_deal_ops_by_client(id)
    DealOpsInfo.joins(deal: :client).where(clients: { id: id }).where(is_active: true)
  end

  def get_surveys(deals_ops_info, product_id)
    deals_ops_info.flat_map do |deal_ops|
      deal_ops.surveys_informations.where(product_id: product_id, is_active: true)
    end
  end
end
