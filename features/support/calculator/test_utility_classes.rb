module Test
  module Calculator
    # A utility class for providing a normalised interface to the response back from the
    # calculator, allowing the low level detail of what belongs where to be defined in
    # this class only and not spread all over the test suite.
    class Response
      attr_reader :messages, :likelyhood, :previous_answers, :fields_required
      def self.parse(response)
        json = JSON.parse(response)
        messages = json.dig('calculation', 'result', 'messages').map { |msg| Message.from_json(msg) }
        likelyhood = chance_of_getting_help(json)
        previous_answers = json.dig('calculation', 'inputs')
        fields_required = json.dig('calculation', 'fields_required')
        new messages: messages,
            likelyhood: likelyhood,
            previous_answers: previous_answers,
            fields_required: fields_required
      end

      def initialize(messages:, likelyhood:, previous_answers:, fields_required:)
        self.messages = messages
        self.likelyhood = likelyhood
        self.previous_answers = previous_answers
        self.fields_required = fields_required
      end

      def next_field
        fields_required.first
      end

      private

      def self.chance_of_getting_help(json)
        result = json.dig('calculation', 'result')
        if result['should_get_help']
          'likely'
        elsif result ['should_not_get_help']
          'unlikely'
        else
          'unknown'
        end
      end

      attr_writer :messages, :likelyhood, :previous_answers, :fields_required
    end

    class Message
      attr_reader :key, :parameters

      def self.from_json(json)
        new(key: json['key'], parameters: json['parameters'])
      end

      def initialize(key:, parameters:)
        self.key = key
        self.parameters = parameters
      end

      private

      attr_writer :key, :parameters
    end
  end
end