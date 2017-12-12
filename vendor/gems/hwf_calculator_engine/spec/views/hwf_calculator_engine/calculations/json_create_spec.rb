require 'rails_helper'
module HwfCalculatorEngine
  RSpec.describe 'hwf_calculator_engine/calculations/create.json.jbuilder', type: :view do
    let(:inputs) { { 'marital_status' => 'single' } }
    let(:fields_required) { [:fee, :total_income] }
    let(:fields) { {} }
    before do
      assign :calculation, calculation
      assign :fields, fields
      render
    end

    context 'calculation top level object' do
      let(:calculation) { instance_double(CalculationService, help_not_available?: false, help_available?: false, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: []) }

      it 'is present' do
        json = JSON.parse(rendered)
        expect(json).to include_json(calculation: an_instance_of(Hash))
      end

      it 'is the only top level object' do
        json = JSON.parse(rendered)
        expect(json.keys).to eql(['calculation'])
      end
    end

    context 'calculation.result object' do
      let(:calculation) { instance_double(CalculationService, help_not_available?: false, help_available?: false, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: []) }

      context 'is present' do
        it 'has a calculation.result object' do
          json = JSON.parse(rendered)
          expect(json['calculation']).to include_json(result: an_instance_of(Hash))
        end
      end
    end

    context 'calculation.result.should_get_help' do
      context 'when calculation.help_available is false' do
        let(:calculation) { instance_double(CalculationService, help_not_available?: false, help_available?: false, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: []) }

        it 'is false' do
          json = JSON.parse(rendered)
          expect(json.dig('calculation', 'result')).to include_json(should_get_help: false)
        end
      end

      context 'when calculation.help_available is true' do

        let(:calculation) { instance_double(CalculationService, help_not_available?: false, help_available?: true, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: []) }
        it 'is true' do
          json = JSON.parse(rendered)
          expect(json.dig('calculation', 'result')).to include_json(should_get_help: true)
        end
      end
    end

    context 'calculation.result.should_not_get_help' do
      context 'when calculation.help_not_available? is false' do
        let(:calculation) { instance_double(CalculationService, help_not_available?: false, help_available?: false, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: []) }

        it 'is false' do
          json = JSON.parse(rendered)
          expect(json.dig('calculation', 'result')).to include_json(should_not_get_help: false)
        end
      end

      context 'when calculation.help_not_available? is true' do
        let(:calculation) { instance_double(CalculationService, help_not_available?: true, help_available?: false, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: []) }

        it 'is true' do
          json = JSON.parse(rendered)
          expect(json.dig('calculation', 'result')).to include_json(should_not_get_help: true)
        end
      end
    end

    context 'calculation.result.messages' do
      context 'when calculation.help_not_available? is false and messages are empty' do
        let(:calculation) { instance_double(CalculationService, help_not_available?: false, help_available?: false, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: []) }

        it 'is an empty array' do
          json = JSON.parse(rendered)
          expect(json.dig('calculation', 'result')).to include_json(messages: [])
        end
      end

      context 'when calculation.help_not_available? is true and messages are present' do
        let(:calculation) { instance_double(CalculationService, help_not_available?: true, help_available?: false, inputs: inputs, messages: [{ key: :any_reason, source: :any }, { key: :any_other_reason, source: :any }], fields_required: fields_required, required_fields_affecting_likelyhood: []) }

        it 'is a 2 element array' do
          json = JSON.parse(rendered)
          expect(json.dig('calculation', 'result', 'messages').length).to be 2
        end

        it 'contains the key and parameters for both messages' do
          json = JSON.parse(rendered)
          matcher1 = a_hash_including('key' => 'any_reason', 'parameters' => inputs, 'source' => 'any')
          matcher2 = a_hash_including('key' => 'any_other_reason', 'parameters' => inputs, 'source' => 'any')
          expect(json.dig('calculation', 'result', 'messages')).to contain_exactly matcher1, matcher2
        end
      end
    end

    context 'calculation.fields_required JSON array' do
      let(:calculation) { instance_double(CalculationService, help_not_available?: false, help_available?: false, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: []) }

      it 'is an array' do
        json = JSON.parse(rendered)
        expect(json.dig('calculation')).to include_json(fields_required: an_instance_of(Array))
      end

      it 'matches the fields_required provided' do
        json = JSON.parse(rendered)
        expect(json.dig('calculation', 'fields_required')).to eql fields_required.map(&:to_s)
      end
    end

    context 'calculation.required_fields_affecting_likelyhood JSON array' do
      let(:calculation) { instance_double(CalculationService, help_not_available?: false, help_available?: false, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: ['field1', 'field2']) }

      it 'is an array' do
        json = JSON.parse(rendered)
        expect(json.dig('calculation')).to include_json(required_fields_affecting_likelyhood: an_instance_of(Array))
      end

      it 'matches the fields_required provided' do
        json = JSON.parse(rendered)
        expect(json.dig('calculation', 'required_fields_affecting_likelyhood')).to eql ['field1', 'field2']
      end
    end

    context 'calculation.fields JSON object' do
      let(:calculation) { instance_double(CalculationService, help_not_available?: false, help_available?: false, inputs: inputs, messages: [], fields_required: fields_required, required_fields_affecting_likelyhood: []) }

      context 'with example fields' do
        let(:fields) do
          {
              "example_field_1" => {
                  "type" => "string"
              },
              "example_field_2" => {
                  "type" => "integer"
              }
          }
        end
        it 'has a calculation.fields object' do
          json = JSON.parse(rendered)
          expect(json.dig('calculation')).to include_json(fields: an_instance_of(Hash))
        end
        it 'has a calculation.fields object matching the examples provided' do
          json = JSON.parse(rendered)
          expect(json.dig('calculation', 'fields')).to include_json(fields)
        end
      end
    end
  end
end
