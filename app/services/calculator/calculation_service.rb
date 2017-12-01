module Calculator
  # The primary interface for the calculator
  #
  #
  class CalculationService
    FIELDS = [:marital_status, :fee, :date_of_birth, :total_savings, :benefits_received, :number_of_children, :total_income]
    attr_reader :failure_reasons, :inputs

    def initialize(inputs, calculators:)
      self.inputs = inputs.freeze
      self.failed = false
      self.help_available = false
      self.failure_reasons = []
      self.calculators = calculators
    end

    def self.call(inputs, calculators: [DisposableCalculationService])
      new(inputs, calculators: calculators).call
    end

    def call
      catch(:abort) do
        calculators.each do |calculator|
          result = calculator.call(inputs)
          if result.help_not_available?
            add_failure(result.failure_reasons)
            throw(:abort)
          end
          if result.help_available?
            add_success
          end
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