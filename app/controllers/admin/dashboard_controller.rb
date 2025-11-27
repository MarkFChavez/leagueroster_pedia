module Admin
  class DashboardController < BaseController
    def index
      add_breadcrumb "Admin", admin_root_path
    end
  end
end
