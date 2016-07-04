# coding: utf-8
module Views
  class ProcessedData

    def initialize(application)
      @application = application
    end

    def application_processed
      build_return_hash @application
    end

    def application_deleted
      if application_deleted?
        build_delete_hash
      end
    end

    def evidence_check_processed
      build_return_hash(evidence_check) if evidence_check_valid?
    end

    def part_payment_processed
      build_return_hash(part_payment) if part_payment_valid?
    end

    private

    def application_deleted?
      @application.deleted_by.present?
    end

    def evidence_check_valid?
      evidence_check && evidence_check.completed_at
    end

    def evidence_check
      @application.evidence_check
    end

    def part_payment_valid?
      part_payment && part_payment.completed_at
    end

    def part_payment
      @application.part_payment
    end

    def build_return_hash(object)
      {
        on: prepare_date(object.completed_at),
        by: prepare_name(object.completed_by),
        text: prepare_reason(object)
      }
    end

    def build_delete_hash
      {
        on: prepare_date(@application.deleted_at),
        by: prepare_name(@application.deleted_by),
        text: "Reason for deletion: \"#{@application.deleted_reason}\""
      }
    end

    def prepare_name(user)
      user.name if user
    end

    def prepare_date(date)
      date.strftime(Date::DATE_FORMATS[:gov_uk_long]) if date
    end

    def prepare_reason(object)
      if object.is_a?(Application)
        text = object.detail.emergency_reason
        prefix = 'Reason for emergency'
      else
        text = object.incorrect_reason
        prefix = 'Reason not processed'
      end
      "#{prefix}: \"#{text}\"" if text
    end
  end
end