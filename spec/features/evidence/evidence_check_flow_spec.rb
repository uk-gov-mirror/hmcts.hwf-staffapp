require 'rails_helper'

RSpec.feature 'Evidence check flow', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let(:application) { create :application_full_remission, user: user }
  let!(:evidence) { create :evidence_check, application_id: application.id }

  before { login_as user }

  context 'when on "Evidence show" page' do
    before { visit evidence_show_path(id: evidence.id) }
    headings = ['Waiting for evidence',
                'Process evidence',
                'Processing details',
                'Personal details',
                'Application details',
                'Assessment']

    headings.each do |heading_title|
      it "has a heading titled #{heading_title}" do
        expect(page).to have_content heading_title
      end
    end

    scenario 'when clicked on "Next", goes to the next page' do
      click_link 'Next'
      expect(page).to have_content 'Is the evidence correct?'
    end
  end

  context 'when on "Evidence accuracy" page' do
    before { visit evidence_accuracy_path(id: evidence.id) }

    context 'when the page is submitted without anything filled in' do
      before { click_button 'Next' }

      it 're-renders the page' do
        expect(page).to have_content 'Is the evidence correct?'
      end
    end

    it 'displays the title of the page' do
      expect(page).to have_content 'Evidence'
    end

    it 'displays the form label' do
      expect(page).to have_content 'Is the evidence correct?'
    end

    scenario 'fill in the form takes me to the income page' do
      choose 'evidence_correct_false'
      expect(page).to have_content 'What is incorrect about the evidence?'
      click_button 'Next'
      expect(page).to have_content 'Total monthly income from evidence'
    end
  end

  context 'when on "Income" page' do
    before { visit evidence_income_path(id: evidence.id) }

    it 'displays the input label' do
      expect(page).to have_content 'Total monthly income from evidence'
    end
  end
end
