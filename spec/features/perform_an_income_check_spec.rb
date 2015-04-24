require 'rails_helper'

RSpec.feature 'Undertake an income calculation', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user)          { FactoryGirl.create :user }

  before do
    WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi'])
    Capybara.current_driver = :webkit
  end

  after { Capybara.use_default_driver }

  context 'as user' do
    before(:each) do
      login_as user
      visit calculator_income_path
    end
    after(:each) { page.driver.reset! }
    context 'with valid data' do
      before(:each) do
        fill_in 'fee', with: '410'
        fill_in 'children', with: '2'
        fill_in 'income', with: '2000'
        choose 'couple-no'

        click_button 'Check'

      end
      scenario 'shows a successful result', js: true do
        expect(page).to have_xpath('//div[@class="panel callout"]', visible: true)
        expect(page).to have_xpath('//small[@class="error hide"]', count: 0)
      end
      scenario 'calculates correct values', js: true do
        expect(page).to have_xpath('//span[@id="fee-remit"]', text: '£200')
        expect(page).to have_xpath('//span[@id="fee-payable"]', text: '£210')
      end

    end
    context 'with invalid data' do
      scenario 'displays error', js: true do

        click_button 'Check'

        expect(page).to have_xpath('//div[@class="panel callout"]', visible: false)
        expect(page).to have_xpath('//small[@class="error"]', count: 3)
      end
    end
  end
end