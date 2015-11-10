module Views
  class ApplicationResult

    def initialize(application)
      @application = application
    end

    def result
      %w[full part none].include?(outcome) ? outcome : 'error'
    end

    def amount_to_pay
      if evidence_or_application.amount_to_pay.present?
        "£#{evidence_or_application.amount_to_pay.round}"
      end
    end

    def savings
      format_locale(@application.savings_investment_valid?.to_s)
    end

    def income
      format_locale(%w[full part].include?(result).to_s)
    end

    private

    def outcome
      case evidence_or_application
      when EvidenceCheck
        evidence_or_application.outcome
      when Application
        evidence_or_application.application_outcome
      end
    end

    def evidence_or_application
      @application.evidence_check || @application
    end

    def format_locale(suffix)
      prefix = 'activemodel.attributes.applikation/forms/summary'
      I18n.t(suffix, scope: prefix)
    end
  end
end