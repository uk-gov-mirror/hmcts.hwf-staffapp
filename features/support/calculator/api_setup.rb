Before('@api') do |scenario|
  use_rack_test = ENV.fetch('USE_RACK_TEST', 'false') == 'true'
  if use_rack_test
    Capybara.current_driver = :rack_test
  else
    Capybara.current_driver = :server_only
  end
end