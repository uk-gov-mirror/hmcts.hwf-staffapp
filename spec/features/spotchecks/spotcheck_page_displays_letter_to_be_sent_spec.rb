require 'rails_helper'

RSpec.feature 'Spotcheck page displays letter to be sent', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as user
  end

  let(:application) { create :application_full_remission }
  let(:spotcheck) { create :spotcheck, application: application }

  context 'when the Spotcheck feature is enabled' do
    enable_spotcheck

    scenario 'User navigates to the spot check page, which has all required details' do
      visit spotcheck_path(spotcheck)

      within '.spotcheck-letter' do
        expect(page).to have_content(application.reference)
        expect(page).to have_content(application.full_name)
        expect(page).to have_content(user.name)
        expect(page).to have_content(spotcheck.expires_at.to_date)
      end
    end
  end

  context 'when the Spotcheck feature is disabled' do
    disable_spotcheck

    scenario 'User can not navigate to the spot check page' do
      visit spotcheck_path(spotcheck)

      expect(page.status_code).to be 404
    end
  end
end