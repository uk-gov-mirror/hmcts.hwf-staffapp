require 'rails_helper'

RSpec.feature 'List processed applications', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as(user)
  end

  let!(:application1) { create :application_full_remission, :processed_state, office: user.office }
  let!(:application2) { create :application_part_remission, :processed_state, office: user.office }
  let!(:application3) { create :application_part_remission }

  scenario 'User lists all processed applications' do
    visit '/'

    expect(page).to have_content('Processed applications')

    within '.completed-applications' do
      click_link 'Processed applications'
    end

    expect(page.current_path).to eql('/processed_applications')

    within 'table.processed-applications tbody' do
      expect(page).to have_content(application1.applicant.full_name)
      expect(page).to have_content(application2.applicant.full_name)
    end
  end

  scenario 'User displays detail of one processed application' do
    visit '/processed_applications'

    click_link application1.reference

    expect(page.current_path).to eql("/processed_applications/#{application1.id}")

    expect(page).to have_content('Processed application')
    expect(page).to have_content("Full name#{application1.applicant.full_name}")
  end
end
