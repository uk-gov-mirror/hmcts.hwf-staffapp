module Calculator
  class BaseSubCalculationService
    def self.call(inputs)
      new(inputs).call
    end

    def initialize(inputs)
      self.inputs = inputs
    end

    def call
      raise 'Not Implemented'
    end

    def failure?
      raise 'Not Implemented'
    end

    def failure_reasons
      raise 'Not Implemented'
    end

    private

    attr_accessor :inputs
  end
end