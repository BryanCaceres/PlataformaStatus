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
    return
  end
end
