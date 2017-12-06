module HwfCalculatorEngine
  module Forms
    class Calculation < ::FormObject
      PERMITTED_ATTRIBUTES = {
          date_of_birth: Date,
          fee: Float,
          total_savings: Float
      }
      def self.permitted_attributes
        PERMITTED_ATTRIBUTES
      end
      define_attributes

    end
  end
end
