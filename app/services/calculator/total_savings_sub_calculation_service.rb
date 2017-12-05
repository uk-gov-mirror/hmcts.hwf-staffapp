module Calculator
  class TotalSavingsSubCalculationService < BaseSubCalculationService
    FEE_TABLE = [
        { age: 1..61, fee: 1..1000, total_savings: 3000 }.freeze,
        { age: 1..61, fee: 1001..1335, total_savings: 4000 }.freeze,
        { age: 1..61, fee: 1336..1665, total_savings: 5000 }.freeze,
        { age: 1..61, fee: 1666..2000, total_savings: 6000 }.freeze,
        { age: 1..61, fee: 2001..2330, total_savings: 7000 }.freeze,
        { age: 1..61, fee: 2331..4000, total_savings: 8000 }.freeze,
        { age: 1..61, fee: 4001..5000, total_savings: 10000 }.freeze,
        { age: 1..61, fee: 5001..6000, total_savings: 12000 }.freeze,
        { age: 1..61, fee: 6001..7000, total_savings: 14000 }.freeze,
        { age: 1..61, fee: 7001..Float::INFINITY, total_savings: 16000 }.freeze,
        { age: 61..200, fee: 1..Float::INFINITY, total_savings: 16000 }.freeze
    ].freeze

    def call
      throw :invalid_inputs, self unless valid?
      process_inputs
    end

    def help_available?
      help_available
    end

    def help_not_available?
      help_not_available
    end
    
    def valid?
      inputs[:date_of_birth].is_a?(Date) &&
          inputs[:fee].is_a?(Numeric) &&
          inputs[:total_savings].is_a?(Numeric)
    end

    private

    def process_inputs
      dob = inputs[:date_of_birth]
      this_years_birthday = dob.dup.tap { |d| d.change year: Date.today.year }
      age = Date.today.year - dob.year
      if Date.today < this_years_birthday
        age -= 1
      end
      fee_band = FEE_TABLE.find do |f|
        f[:age].cover?(age) && f[:fee].cover?(inputs[:fee])
      end
      raise "Fee band not found for date_of_birth: #{dob} and fee: #{inputs[:fee]}" if fee_band.nil?
      if inputs[:total_savings] < fee_band[:total_savings]
        mark_as_help_available
      else
        mark_as_help_not_available
      end
      self
    end

    def mark_as_help_available
      self.help_available = true
      self.help_not_available = false
    end

    def mark_as_help_not_available
      self.help_not_available = true
      self.help_available = false
    end

    attr_accessor :help_available, :help_not_available
  end
end