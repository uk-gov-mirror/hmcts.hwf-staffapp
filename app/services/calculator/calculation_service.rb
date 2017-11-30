module Calculator
  # The primary interface for the calculator
  #
  #
  class CalculationService
    attr_reader :failure_reasons

    def initialize(inputs, calculators:)
      self.inputs = inputs
      self.failed = false
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
          if result.failure?
            add_failure(result.failure_reasons)
            throw(:abort)
          end
        end
      end
      self
    end

    def failure?
      failed
    end

    private

    def add_failure(reasons)
      self.failed = true
      failure_reasons.concat reasons
    end

    attr_accessor :inputs, :failed, :calculators
    attr_writer :failure_reasons
  end
end