require 'rails_helper'

RSpec.describe Applications::ProcessController, type: :controller do
  include Devise::TestHelpers

  let(:user)          { create :user }
  let(:application) { build_stubbed(:application) }

  let(:personal_information_form) { double }
  let(:application_details_form) { double }
  let(:benefit_form) { double }
  let(:benefit_check_runner) { double(run: nil) }
  let(:income_form) { double }
  let(:income_calculation_runner) { double(run: nil) }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Applikation::Forms::PersonalInformation).to receive(:new).with(application.applicant).and_return(personal_information_form)
    allow(Applikation::Forms::ApplicationDetail).to receive(:new).with(application.detail).and_return(application_details_form)
    allow(Applikation::Forms::Benefit).to receive(:new).with(application).and_return(benefit_form)
    allow(BenefitCheckRunner).to receive(:new).with(application).and_return(benefit_check_runner)
    allow(Applikation::Forms::Income).to receive(:new).with(application).and_return(income_form)
    allow(IncomeCalculationRunner).to receive(:new).with(application).and_return(income_calculation_runner)
  end

  describe 'GET #personal_information' do
    before do
      get :personal_information, application_id: application.id
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:personal_information)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(personal_information_form)
      end
    end
  end

  describe 'PUT #personal_information_save' do
    let(:expected_params) { { last_name: 'Name', date_of_birth: '20/01/2980', married: false } }

    before do
      allow(personal_information_form).to receive(:update_attributes).with(expected_params)
      allow(personal_information_form).to receive(:save).and_return(form_save)

      put :personal_information_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to application_details' do
        expect(response).to redirect_to(application_application_details_path(application))
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:personal_information)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(personal_information_form)
      end
    end
  end

  describe 'GET #application_details' do
    before do
      get :application_details, application_id: application.id
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:application_details)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_details_form)
      end

      it 'assigns user\'s jurisdictions' do
        expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
      end
    end
  end

  describe 'PUT #application_details_save' do
    let(:expected_params) { { fee: '300' } }

    before do
      allow(application_details_form).to receive(:update_attributes).with(expected_params)
      allow(application_details_form).to receive(:save).and_return(form_save)
      # FIXME: this should be removed asap (both test and code)
      allow(application).to receive(:update)

      put :application_details_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to savings_investments in the old BuildController' do
        expect(response).to redirect_to(application_build_path(application_id: application.id, id: :savings_investments))
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:application_details)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_details_form)
      end

      it 'assigns user\'s jurisdictions' do
        expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
      end
    end
  end

  describe 'GET #benefits' do
    before do
      allow(application).to receive(:savings_investment_valid?).and_return(savings_valid)

      get :benefits, application_id: application.id
    end

    context 'when application failed savings and investments' do
      let(:savings_valid) { false }

      it 'redirects to the summary' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when savings and investments passed' do
      let(:savings_valid) { true }

      it 'returns 200 response' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:benefits)
      end

      it 'assigns the benefits form' do
        expect(assigns(:form)).to eql(benefit_form)
      end
    end
  end

  describe 'PUT #benefits_save' do
    let(:expected_params) { { benefits: false } }

    before do
      expect(benefit_form).to receive(:update_attributes).with(expected_params)
      expect(benefit_form).to receive(:save).and_return(form_save)

      put :benefits_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'runs the benefit check on the application' do
        expect(benefit_check_runner).to have_received(:run)
      end

      it 'redirects to the benefits result page' do
        expect(response).to redirect_to(application_benefits_result_path(application))
      end
    end

    context 'when the form can\'t be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:benefits)
      end

      it 'assigns the benefits form' do
        expect(assigns(:form)).to eql(benefit_form)
      end
    end
  end

  describe 'GET #benefits_result' do
    let(:application) { build_stubbed(:application, benefits: benefits) }

    before do
      get :benefits_result, application_id: application.id
    end

    context 'when the applicant is on benefits' do
      let(:benefits) { true }

      it 'renders 200 response' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:benefits_result)
      end

      it 'assigns application' do
        expect(assigns(:application)).to eql(application)
      end
    end

    context 'when the applicant is not on benefits' do
      let(:benefits) { false }

      it 'redirects to the income page' do
        expect(response).to redirect_to(application_build_path(application_id: application.id, id: :income))
      end
    end
  end

  describe 'GET #income' do
    let(:application) { build_stubbed(:application, benefits: benefits) }

    before do
      get :income, application_id: application.id
    end

    context 'when application is on benefits' do
      let(:benefits) { true }

      it 'redirects to the summary' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when application is not on benefits' do
      let(:benefits) { false }

      it 'returns 200 response' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:income)
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(income_form)
      end
    end
  end

  describe 'PUT #income_save' do
    let(:evidence_check_service) { double(decide!: true) }
    let(:payment_builder) { double(decide!: true) }

    let(:expected_params) { { dependents: false } }

    before do
      expect(income_form).to receive(:update_attributes).with(expected_params)
      expect(income_form).to receive(:save).and_return(form_save)

      allow(EvidenceCheckSelector).to receive(:new).with(application, Integer).and_return(evidence_check_service)
      allow(PaymentBuilder).to receive(:new).with(application, Integer).and_return(payment_builder)

      put :income_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'runs the income calculation on the application' do
        expect(income_calculation_runner).to have_received(:run)
      end

      it 'makes decision on evidence check' do
        expect(evidence_check_service).to have_received(:decide!)
      end

      it 'builds payment if needed' do
        expect(payment_builder).to have_received(:decide!)
      end

      it 'redirects to the income result page' do
        expect(response).to redirect_to(application_build_path(application_id: application.id, id: :income_result))
      end
    end

    context 'when the form can\'t be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:income)
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(income_form)
      end
    end
  end

  describe 'GET #income_result' do
    let(:application) { build_stubbed(:application, application_type: type) }

    before do
      get :income_result, application_id: application.id
    end

    context 'when the application is income based' do
      let(:type) { 'income' }

      it 'renders 200 response' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:income_result)
      end

      it 'assigns application' do
        expect(assigns(:application)).to eql(application)
      end
    end

    context 'when the application is not income based' do
      let(:type) { 'benefits' }

      it 'redirects to the summary page' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end
  end

  describe 'GET #summary' do
    before do
      get :summary, application_id: application.id
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:summary)
      end
    end
  end

  context 'GET #confirmation' do
    before { get :confirmation, application_id: application.id }

    it 'displays the confirmation view' do
      expect(response).to render_template :confirmation
    end
  end
end