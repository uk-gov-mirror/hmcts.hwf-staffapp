module HwfCalculatorEngine
  module Forms
    class Calculation < FormObject
      UNDEFINED = :undefined
      PERMITTED_ATTRIBUTES = {
          marital_status: String,
          date_of_birth: Date,
          fee: Float,
          total_savings: Float
      }
      def self.permitted_attributes
        PERMITTED_ATTRIBUTES
      end
      define_attributes

      def initialize(*args)
        PERMITTED_ATTRIBUTES.keys.each do |attr|
          instance_variable_set("@#{attr}", UNDEFINED)
        end
        super
      end

      def to_h
        super.reject {|k,v| v == UNDEFINED}
      end

    end
  end
end
