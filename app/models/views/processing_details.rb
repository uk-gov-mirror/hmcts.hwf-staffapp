module Views
  class ProcessingDetails
    attr_reader :application, :evidence_or_part_payment

    delegate :reference, to: :application

    def initialize(calling_object)
      if calling_object.is_a?(Application)
        @application = calling_object
      else
        @evidence_or_part_payment = calling_object
        @application = calling_object.application
      end
    end

    def expires
      @evidence_or_part_payment.expires_at.to_date unless @evidence_or_part_payment.nil?
    end

    def processed_by
      @application.completed_by.name if @application.completed_by.present?
    end

    def processed_on
      if @application.completed_at.present?
        @application.completed_at.strftime(Date::DATE_FORMATS[:gov_uk_long])
      end
    end

    def applicant
      @application.full_name
    end

    def deleted_reason
      @application.deleted_reason if @application.deleted?
    end

    def deleted_on
      if @application.deleted?
        @application.deleted_at.strftime(Date::DATE_FORMATS[:gov_uk_long])
      end
    end

    def deleted_by
      if @application.deleted?
        @application.deleted_by.name
      end
    end
  end
end
