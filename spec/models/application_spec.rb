require 'rails_helper'
require 'support/calculator_test_data'

RSpec.describe Application, type: :model do

  let(:user)  { create :user }
  let(:application) { described_class.create(user_id: user.id) }

  before do
    stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
    {
      birth_date: (Time.zone.today - 18.years).strftime('%Y%m%d'),
      entitlement_check_date: (Time.zone.today - 1.month).strftime('%Y%m%d'),
      id: "#{user.name.gsub(' ', '').downcase.truncate(27)}@#{application.created_at.strftime('%y%m%d%H%M%S')}.#{application.id}",
      ni_number: 'AB123456A',
      surname: 'TEST'
    }).to_return(status: 200, body: '', headers: {})

    application.date_of_birth = Time.zone.today - 18.years
    application.date_received = Time.zone.today - 1.month
    application.ni_number = 'AB123456A'
  end

  describe 'income calculation' do
    it 'includes can_calculate?' do
      expect(application).to respond_to :can_calculate?
    end

    it 'includes calculate' do
      expect(application).to respond_to :calculate
    end

    context 'can_calculate?' do
      context 'when required fields are complete' do
        before do
          application.dependents = true
          application.fee = 300
          application.married = true
          application.income = 1000
          application.children = 1
          application.valid?
        end

        before { application.valid? }
        it 'returns true' do
          expect(application.can_calculate?).to eq true
        end
      end
      context 'when required fields are missing' do
        before do
          application.fee = nil
          application.married = true
          application.income = 1000
          application.children = 1
          application.valid?
        end

        it 'returns false' do
          expect(application.can_calculate?).to eq false
        end
      end
    end
  end

  describe 'auto running calculator' do
    context 'without required fields' do
      before do
        application.dependents = true
        application.fee = nil
        application.married = true
        application.income = 1000
        application.children = 1
      end

      it 'does not update remission type' do
        expect { application.save } .to_not change { application.application_type }
      end

      it 'does not update amount_to_pay' do
        expect { application.save } .to_not change { application.amount_to_pay }
      end
    end

    context 'with required fields' do
      before do
        application.dependents = true
        application.fee = 300
        application.married = true
        application.income = 1000
        application.children = 1
      end

      it 'updates remission type' do
        expect { application.save } .to change { application.application_type }
      end

      it 'updates amount_to_pay' do
        expect { application.save } .to change { application.amount_to_pay }
      end
    end
  end

  describe 'calculator' do
    CalculatorTestData.seed_data.each do |src|
      it "scenario \##{src[:id]} passes" do
        application.update(
          fee: src[:fee],
          married: src[:married_status],
          dependents: src[:children].to_i > 0,
          children: src[:children],
          income: src[:income]
        )
        expect(application.application_type).to eq 'income'
        expect(application.application_outcome).to eq src[:type]
        expect(application.amount_to_pay).to eq src[:they_pay].to_i
      end
    end
  end

  describe 'auto running benefit checks' do
    context 'when saved without required fields' do
      it 'does not run a benefit check' do
        expect { application.save } .to_not change { application.benefit_checks.count }
      end
    end

    context 'when the final item required is saved' do
      before { application.last_name = 'TEST' }
      it 'runs a benefit check ' do
        expect { application.save } .to change { application.benefit_checks.count }.by 1
      end

      it 'sets application_type to benefit' do
        application.save
        expect(application.application_type).to eq 'benefit'
      end

      context 'when other fields are changed' do
        before do
          application.last_name = 'TEST'
          application.save
          application.fee = 300
        end

        it 'does not perform another benefit check' do
          expect { application.save } .to_not change { application.benefit_checks.count }
        end
      end

      context 'when date_fee_paid is updated' do
        before do
          stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
          {
            birth_date: (Time.zone.today - 18.years).strftime('%Y%m%d'),
            entitlement_check_date: (Time.zone.today - 2.weeks).strftime('%Y%m%d'),
            id: "#{user.name.gsub(' ', '').downcase.truncate(27)}@#{application.created_at.strftime('%y%m%d%H%M%S')}.#{application.id}",
            ni_number: 'AB123456A',
            surname: 'TEST'
          }).to_return(status: 200, body: '', headers: {})

          application.last_name = 'TEST'
          application.save
          application.date_fee_paid = Time.zone.today - 2.weeks
        end

        it 'runs a benefit check' do
          expect { application.save } .to change { application.benefit_checks.count }.by 1
        end

        it 'sets the new benefit check date' do
          application.save
          expect(application.last_benefit_check.date_to_check).to eq Time.zone.today - 2.weeks
        end
      end

      context 'when a benefit check field is changed' do
        before do
          stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
          {
            birth_date: (Time.zone.today - 18.years).strftime('%Y%m%d'),
            entitlement_check_date: (Time.zone.today - 1.month).strftime('%Y%m%d'),
            id: "#{user.name.gsub(' ', '').downcase.truncate(27)}@#{application.created_at.strftime('%y%m%d%H%M%S')}.#{application.id}",
            ni_number: 'AB123456A',
            surname: 'NEW NAME'
          }).to_return(status: 200, body: '', headers: {})

          application.last_name = 'TEST'
          application.save
          application.last_name = 'New name'
        end

        it 'runs a benefit check' do
          expect { application.save } .to change { application.benefit_checks.count }.by 1
        end
      end
    end
  end
end