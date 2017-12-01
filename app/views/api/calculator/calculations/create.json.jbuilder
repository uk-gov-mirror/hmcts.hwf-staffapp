json.calculation do
  json.inputs @calculation.inputs
  json.result do
    json.should_get_help @calculation.help_available?
    json.should_not_get_help @calculation.help_not_available?
    json.messages do
      json.array! @calculation.failure_reasons do |key|
        json.key key
        json.parameters @calculation.inputs
      end
    end
  end
  json.fields_required do
    json.array! @calculation.fields_required
  end
  json.fields @fields
end