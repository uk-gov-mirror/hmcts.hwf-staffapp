class BenefitCheckRunner
  def initialize(application)
    @application = application
  end

  def can_run?
    applicant.last_name.present? &&
      applicant.date_of_birth.present? &&
      applicant.ni_number.present? &&
      benefit_check_date.present?
  end

  def run
    if can_run? && should_run?
      BenefitCheckService.new(benefit_check)

      @application.update(application_type: 'benefit', application_outcome: benefit_check.outcome)
    end
  end

  private

  def applicant
    @application.applicant
  end

  def detail
    @application.detail
  end

  def should_run?
    previous_check.nil? || !same_as_before? || was_error?
  end

  def was_error?
    !%w[Yes No].include?(previous_check.dwp_result)
  end

  def same_as_before?
    applicant_same? && (previous_check.date_to_check == benefit_check_date)
  end

  def applicant_same?
    %i[last_name date_of_birth ni_number].all? do |field|
      previous_check.send(field) == applicant.send(field)
    end
  end

  def previous_check
    @previous_check ||= @application.last_benefit_check
  end

  def benefit_check
    @benefit_check ||= BenefitCheck.create(
      application: @application,
      last_name: applicant.last_name,
      date_of_birth: applicant.date_of_birth,
      ni_number: applicant.ni_number,
      date_to_check: benefit_check_date,
      our_api_token: generate_api_token,
      parameter_hash: build_hash
    )
  end

  def benefit_check_date
    if detail.date_fee_paid.present?
      detail.date_fee_paid
    elsif detail.date_received.present?
      detail.date_received
    end
  end

  def build_hash
    Base64.encode64 [applicant.last_name,
                     applicant.date_of_birth,
                     applicant.ni_number,
                     benefit_check_date].to_s
  end

  def generate_api_token
    short_name = @application.user.name.gsub(' ', '').downcase.truncate(27)
    "#{short_name}@#{@application.created_at.strftime('%y%m%d%H%M%S')}.#{@application.id}"
  end
end