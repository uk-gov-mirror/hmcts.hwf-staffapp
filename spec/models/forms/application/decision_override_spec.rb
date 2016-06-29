require 'rails_helper'

RSpec.describe Forms::Application::DecisionOverride do
  params_list = %i[value reason created_by_id]

  let(:override) { build_stubbed :decision_override }
  let(:user) { create :staff }

  subject(:form) { described_class.new(override) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  context 'validation' do
    before { form.update_attributes(params) }
    subject { form.valid? }

    context 'user_id' do
      let(:user_id) { nil }
      let(:params) { { value: 1, reason: nil, created_by_id: user_id } }

      context 'not set' do
        it { is_expected.to be false }
      end

      context 'set with a checkbox value' do
        let(:user_id) { user.id }

        it { is_expected.to be true }
      end

    end

    context 'with attribute "value"' do
      let(:reason) { nil }
      let(:option) { nil }
      let(:params) { { value: option, reason: reason, created_by_id: user.id } }

      context 'not set' do
        it { is_expected.to be false }
      end

      context 'set with a checkbox value' do
        let(:option) { 1 }

        it { is_expected.to be true }
      end

      context 'set with "other" value' do
        let(:option) { 'other' }

        it { is_expected.to be false }

        context 'with attribute "reason"' do

          context 'not set' do
            it { is_expected.to be false }
          end

          context 'set' do
            let(:reason) { 'Some reason' }

            it { is_expected.to be true }
          end
        end
      end
    end
  end

  describe '#save' do
    let(:override) { create :decision_override }

    before do
      form.update_attributes(params)
    end

    subject { form.save }

    context 'for an invalid form' do
      let(:params) { { value: nil, reason: nil, created_by_id: user.id } }
      it { is_expected.to be false }
    end

    context 'for a valid form when a value is chosen' do
      let(:params) { { value: 1, reason: nil, created_by_id: user.id } }

      it { is_expected.to be true }

      before { subject && override.reload }

      it 'updates the reason from the option label' do
        expect(override.reason).to eql "You've received paper evidence that the applicant is receiving benefits"
      end
    end

    context 'for a valid form when user inputs a reason' do
      let(:params) { { value: 'other', reason: 'foo reason bar', created_by_id: user.id } }

      it { is_expected.to be true }

      before { subject && override.reload }

      it 'updates the correct field on evidence check and creates reason record with explanation' do
        expect(override.reason).to eql 'foo reason bar'
      end
    end
  end

end
