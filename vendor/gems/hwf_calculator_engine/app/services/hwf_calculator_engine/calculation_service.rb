module HwfCalculatorEngine
  # The primary interface for the calculator
  #
  #
  class CalculationService
    # @TODO This is now defined in the form object - can anything be shared here ?
    FIELDS = [:marital_status, :fee, :date_of_birth, :total_savings, :benefits_received, :number_of_children, :total_income]
    FIELDS_AFFECTING_LIKELYHOOD = [:date_of_birth, :total_savings, :benefits_received, :total_income]
    attr_reader :failure_reasons, :inputs

    def initialize(inputs, calculators:)
      self.inputs = inputs.freeze
      self.failed = false
      self.help_available = false
      self.failure_reasons = []
      self.calculators = calculators
    end

    def self.call(inputs, calculators: [TotalSavingsSubCalculationService])
      new(inputs, calculators: calculators).call
    end

    def call
      # @TODO Decide what to do here and remove this comment
      # There are 2 catch blocks here which at present has little value
      # but, I am planning ahead a little in that invalid inputs might
      # want to add something to this instance in terms of messages etc..
      # but unsure right now.
      catch(:abort) do
        calculators.each do |calculator|
          my_result = catch(:invalid_inputs) do
            result = calculator.call(inputs)
            if result.help_not_available?
              add_failure(result.failure_reasons)
              throw(:abort)
            end
            if result.help_available?
              add_success
            end
            result
          end
          throw :abort, self unless my_result.valid?
        end
      end
      self
    end

    def help_not_available?
      failed
    end

    def help_available?
      help_available
    end

    def fields_required
      FIELDS - inputs.keys
    end

    def required_fields_affecting_likelyhood
      FIELDS_AFFECTING_LIKELYHOOD - inputs.keys
    end

    private

    def add_failure(reasons)
      self.failed = true
      failure_reasons.concat reasons
    end

    def add_success
      self.help_available = true
    end

    attr_accessor :failed, :calculators, :help_available
    attr_writer :failure_reasons, :inputs
  end
end