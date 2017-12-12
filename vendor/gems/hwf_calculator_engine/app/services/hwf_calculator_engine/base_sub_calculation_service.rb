module HwfCalculatorEngine
  class BaseSubCalculationService
    attr_reader :messages
    def self.call(inputs)
      new(inputs).call
    end

    def initialize(inputs)
      self.inputs = inputs
      self.messages = []
    end

    def call
      raise 'Not Implemented'
    end

    def help_not_available?
      raise 'Not Implemented'
    end

    def help_available?
      raise 'Not Implemented'
    end

    def valid?
      raise 'Not Implemented'
    end

    private

    attr_accessor :inputs
    attr_writer :messages
  end
end