Rails.application.configure do
  # Configure Mission Control Jobs to use the same auth as admin panel
  MissionControl::Jobs.http_basic_auth_user = ENV["ADMIN_USERNAME"]
  MissionControl::Jobs.http_basic_auth_password = ENV["ADMIN_PASSWORD"]
end
