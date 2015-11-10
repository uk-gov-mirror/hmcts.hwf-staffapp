# coding: utf-8
require 'rails_helper'

RSpec.feature 'Evidence check flow', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let(:application) { create :application_full_remission, user: user }
  let(:outcome) { nil }
  let(:amount) { nil }
  let(:evidence) { create :evidence_check, application: application, outcome: outcome, amount_to_pay: amount }

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
      expect(page).to have_content 'Is the evidence ready to process?'
    end
  end

  context 'when on "Evidence accuracy" page' do
    before { visit evidence_accuracy_path(id: evidence.id) }

    context 'when the page is submitted without anything filled in' do
      before { click_button 'Next' }

      it 're-renders the page' do
        expect(page).to have_content 'Is the evidence ready to process?'
      end
    end

    it 'displays the title of the page' do
      expect(page).to have_content 'Evidence'
    end

    it 'displays the form label' do
      expect(page).to have_content 'Is the evidence ready to process?'
    end

    scenario 'confirming the evidence is correct redirects to the income page' do
      choose 'evidence_correct_true'
      click_button 'Next'
      expect(page).to have_content 'Total monthly income from evidence'
    end

    scenario 'rejecting the evidence redirects to the summary page' do
      choose 'evidence_correct_false'
      expect(page).to have_content 'Describe the problem with the evidence'
      click_button 'Next'
      expect(page).to have_content 'Check details'
    end
  end

  context 'when on "Income" page' do
    before { visit evidence_income_path(id: evidence.id) }

    it 'fill in the income form takes me to the next page' do
      expect(page).to have_content 'Total monthly income from evidence'
      fill_in 'evidence_income', with: 500
      click_button 'Next'
    end
  end

  context 'when on "Income result" page' do
    before { visit evidence_result_path(id: evidence.id) }

    it 'displays the title of the page' do
      expect(page).to have_content('Income')
    end

    it 'displays a result block' do
      expect(page).to have_xpath('//div[contains(@class,"callout")]/h3[@class="bold"]')
    end

    context 'when the evidence check returns none' do
      let(:outcome) { 'none' }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-none")]/h3[@class="bold"]', text: '✗ The applicant must pay the full fee') }

      it 'clicking the Next button redirects to the summary page' do
        click_link_or_button 'Next'
        expect(page).to have_content('Check details')
      end
    end

    context 'when the evidence check returns [part]' do
      let(:outcome) { 'part' }
      let(:amount) { 45 }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-part")]/h3[@class="bold"]', text: 'The applicant must pay £45 towards the fee') }

      it 'clicking the Next button redirects to the summary page' do
        click_link_or_button 'Next'
        expect(page).to have_content('Check details')
      end
    end

    context 'when the evidence check returns full' do
      let(:outcome) { 'full' }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-full")]/h3[@class="bold"]', text: '✓ The applicant doesn’t have to pay the fee') }

      it 'clicking the Next button redirects to the summary page' do
        click_link_or_button 'Next'
        expect(page).to have_content('Check details')
      end
    end
  end

  context 'when on "summary" page' do
    before { visit evidence_summary_path(id: evidence.id) }

    context 'for an unsuccessful outcome' do
      let(:evidence) { create :evidence_check_incorrect }
      let(:expected_fields) do
        {
          'Correct' => 'No',
          'Reason' => evidence.incorrect_reason
        }
      end

      it 'renders correct outcome' do
        page_expectation('The applicant must pay the full fee', expected_fields)
      end
    end

    context 'for a part remission outcome' do
      let(:evidence) { create :evidence_check_part_outcome }
      let(:expected_fields) do
        {
          'Correct' => 'Yes',
          'Income' => "£#{evidence.income}"
        }
      end

      it 'renders correct outcome' do
        page_expectation("The applicant must pay £#{evidence.amount_to_pay} towards the fee", expected_fields)
      end

      context 'clicking the Next button' do
        before { click_link_or_button 'Complete processing' }
        it 'creates a payment record' do
          expect(evidence.application.payment?).to be true
        end
      end
    end

    context 'for a full remission outcome' do
      let(:evidence) { create :evidence_check_full_outcome }
      let(:expected_fields) do
        {
          'Correct' => 'Yes',
          'Income' => "£#{evidence.income}"
        }
      end

      it 'renders correct outcome' do
        page_expectation('The applicant doesn’t have to pay the fee', expected_fields)
      end
    end

    it 'clicking the Next button redirects to the confirmation page' do
      click_link_or_button 'Complete processing'
      expect(page).to have_content('Processing complete')
    end

    def page_expectation(outcome, fields = {})
      expect(page).to have_content(outcome)
      fields.each do |title, value|
        expect(page).to have_content("#{title}#{value}")
      end
      expect(page).to have_link('Change application evidence', href: evidence_accuracy_path(evidence))
    end
  end

  context 'when on "Evidence confirmation" page' do
    before { visit evidence_confirmation_path(id: evidence.id) }

    it { expect(page).to have_content 'Processing complete' }

    context 'when the remission is' do
      context 'full' do
        let(:outcome) { 'full' }

        it { expect(page).to have_no_content(/(not\ correct\|part-fee)/) }
      end

      context 'part' do
        let(:outcome) { 'part' }

        it { expect(page).to have_content 'part-fee' }

        it { expect(page).to have_content(evidence.application.full_name) }

        it { expect(page).to have_content(user.name) }

        it { expect(page).to have_content(evidence.amount_to_pay) }

        it { expect(page).to have_content(evidence.expires_at.strftime('%-d %B %Y')) }
      end

      context 'rejected' do
        let(:outcome) { 'none' }

        it { expect(page).to have_content 'not correct' }

        it { expect(page).to have_content(evidence.application.full_name) }

        it { expect(page).to have_content(user.name) }
      end
    end
  end
end