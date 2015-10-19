module Views
  class ApplicationOverview
    attr_reader :application

    APPLICATION_ATTRS = %i[date_of_birth full_name ni_number
                           date_received form_name amount_to_pay]

    delegate(*APPLICATION_ATTRS, to: :application)

    def initialize(application)
      @application = application
    end

    def status
      @application.married? ? 'Married' : 'Single'
    end

    def jurisdiction
      @application.jurisdiction.name
    end

    def fee
      "£#{@application.fee.round}"
    end

    def number_of_children
      @application.children
    end

    def total_monthly_income
      "£#{@application.income.round}"
    end

    def income
      format_locale(@application.application_outcome)
    end

    def savings
      format_locale(@application.savings_investment_valid?.to_s)
    end

    def result
      @application.application_outcome
    end

    private

    def format_locale(suffix)
      prefix = 'activemodel.attributes.applikation/forms/summary'
      I18n.t(suffix, scope: prefix)
    end
  end
end
