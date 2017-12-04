module Forms
  module Calculator
    class Calculation < ::FormObject
      PERMITTED_ATTRIBUTES = {
          date_of_birth: Date
      }
      def self.permitted_attributes
        PERMITTED_ATTRIBUTES
      end
      define_attributes

    end
  end
end