Before('@api') do |_scenario|
  use_rack_test = ENV.fetch('USE_RACK_TEST', 'false') == 'true'
  Capybara.current_driver = use_rack_test ? :rack_test : :server_only
end