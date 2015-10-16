require 'rails_helper'

RSpec.feature 'Applications awaiting payment are displayed on dashboard', type: :feature do
  enable_payment

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :user, office: office }

  let(:application1) { create :application_full_remission, office: office }
  let!(:payment1) { create :payment, application: application1 }
  let(:application2) { create :application_full_remission, office: office }
  let!(:payment2) { create :payment, application: application2 }
  let(:other_application) { create :application_full_remission }
  let!(:other_payment) { create :payment, application: other_application }

  before do
    login_as user
  end

  scenario 'User is presented the list of applications awaiting payment only for their office' do
    visit root_path

    within '.waiting-for-payment' do
      expect(page).to have_content(application1.reference)
      expect(page).to have_content(application2.reference)
      expect(page).not_to have_content(other_application.reference)
    end
  end
end
