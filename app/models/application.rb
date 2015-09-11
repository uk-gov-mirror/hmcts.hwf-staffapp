class Application < ActiveRecord::Base # rubocop:disable ClassLength

  include IncomeCalculator
  belongs_to :user
  belongs_to :jurisdiction
  has_many :benefit_checks

  MAX_AGE = 120
  MIN_AGE = 16

  after_save :run_auto_checks

  # Step 1 - Personal detail validation
  with_options if: proc { active_or_status_is? 'personal_information' } do
    validates :last_name, presence: true
    validates :married, inclusion: { in: [true, false] }
    validates :last_name, length: { minimum: 2 }, allow_blank: true
    validates :date_of_birth, date: true
    validate :dob_age_valid?
  end

  validates :ni_number, format: {
    with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
  }, allow_blank: true
  # End step 1 validation

  # Step 2 - Application details validation
  with_options if: proc { active_or_status_is? 'application_details' } do
    validates :fee, :jurisdiction_id, presence: true
    validates :fee, numericality: { allow_blank: true }
    validates :date_received, date: {
      after: proc { Time.zone.today - 3.months },
      before: proc { Time.zone.today + 1.day }
    }
    with_options if: :probate? do
      validates :deceased_name, presence: true
      validates :date_of_death, date: {
        before: proc { Time.zone.today + 1.day }
      }

    end
    with_options if: :refund? do
      validates :date_fee_paid, date: {
        after: proc { Time.zone.today - 3.months },
        before: proc { Time.zone.today + 1.day }
      }
    end
  end
  # End step 2 validation

  # Step 3 - Savings and investments validation
  with_options if: proc { active_or_status_is? 'savings_investments' } do
    validates :threshold_exceeded, inclusion: { in: [true, false] }
    validates :over_61, inclusion: { in: [true, false] }, if: :threshold_exceeded
    validates :high_threshold_exceeded, inclusion: { in: [true, false] }, if: :over_61
  end
  # End step 3 validation

  # Step 4 - Benefits
  with_options if: proc { active_or_status_is? 'benefits' } do
    validates :benefits, inclusion: { in: [true, false] }, if: :benefits_required?
  end
  # End step 4 validation

  # Step 5 - Income
  with_options if: proc { active_or_status_is? 'income' } do
    validates :dependents, inclusion: { in: [true, false] }, if: :income_required?
    validates :income, numericality: true, if: :income_required?
    validates :children, numericality: true, if: :income_children_required?
    validate :children_numbers, if: :income_required?
  end
  # End step 5 validation

  def ni_number=(val)
    if val.nil?
      self[:ni_number] = nil
    else
      self[:ni_number] = val.upcase if val.present?
    end
  end

  def children=(val)
    self[:children] = dependents? ? val : 0
  end

  def ni_number_display
    unless self[:ni_number].nil?
      self[:ni_number].gsub(/(.{2})/, '\1 ')
    end
  end

  def fee=(val)
    super
    if known_over_61?
      self.threshold = 16000
    else
      self.threshold = val.to_i <= 1000 ? 3000 : 4000
    end
  end

  def threshold_exceeded=(val)
    super
    self.over_61 = nil unless threshold_exceeded?
    if threshold_exceeded? && !over_61
      self.application_type = 'none'
      self.application_outcome = 'none'
      self.dependents = nil
    end
  end

  def high_threshold_exceeded=(val)
    super
    if high_threshold_exceeded?
      self.application_type = 'none'
      self.application_outcome = 'none'
      self.dependents = nil
    else
      self.application_type = nil
      self.application_outcome = nil
    end
  end

  def savings_investment_valid?
    result = false
    if threshold_exceeded == false ||
       (threshold_exceeded && (over_61 && high_threshold_exceeded == false))
      result = true
    end
    result
  end

  def benefits=(val)
    super
    self.application_type = benefits? ? 'benefit' : 'income'
  end

  def full_name
    [title, first_name, last_name].join(' ')
  end

  def known_over_61?
    applicant_age >= 61
  end

  def applicant_age
    now = Time.zone.now.utc.to_date
    now.year - date_of_birth.year - (date_of_birth.to_date.change(year: now.year) > now ? 1 : 0)
  end

  def can_check_benefits?
    [
      last_name.present?,
      date_of_birth.present?,
      ni_number.present?,
      (date_received.present? || date_fee_paid.present?)
    ].all?
  end

  def last_benefit_check
    benefit_checks.order(:id).last
  end

  private

  def income_required?
    active_or_status_is?('income') & !benefits? && savings_investment_valid?
  end

  def income_children_required?
    income_required? && dependents?
  end

  def benefits_required?
    active_or_status_is?('benefits') && :savings_investment_valid?
  end

  def run_auto_checks
    run_benefit_check
    calculate if can_calculate?
  end

  def children_numbers
    errors.add(
      :children,
      I18n.t('activerecord.errors.models.application.attributes.children.not_a_number')
    ) if dependents? && no_children?
  end

  def no_children?
    children_present? && children == 0
  end

  def children_present?
    children.present?
  end

  def run_benefit_check # rubocop:disable MethodLength
    if can_check_benefits? && new_benefit_check_needed?
      BenefitCheckService.new(
        benefit_checks.create(
          last_name: last_name,
          date_of_birth: date_of_birth,
          ni_number: ni_number,
          date_to_check: benefit_check_date,
          our_api_token: generate_api_token,
          parameter_hash: build_hash
        )
      )
      update(
        application_type: 'benefit',
        application_outcome: outcome_from_dwp_result
      )
    end
  end

  def outcome_from_dwp_result
    case last_benefit_check.dwp_result
    when 'Yes'
      'full'
    when 'No'
      'none'
    end
  end

  def benefit_check_date
    if date_fee_paid.present?
      date_fee_paid
    elsif date_received.present?
      date_received
    end
  end

  def new_benefit_check_needed?
    last_benefit_check.nil? || last_benefit_check.parameter_hash != build_hash
  end

  def build_hash
    Base64.encode64([last_name, date_of_birth, ni_number, benefit_check_date].to_s)
  end

  def generate_api_token
    user = User.find(user_id)
    short_name = user.name.gsub(' ', '').downcase.truncate(27)
    "#{short_name}@#{created_at.strftime('%y%m%d%H%M%S')}.#{id}"
  end

  def active?
    status == 'active'
  end

  def active_or_status_is?(status_name)
    active? || status.to_s.include?(status_name)
  end

  def dob_age_valid?
    errors.add(:date_of_birth, "can't contain non numbers") if date_of_birth =~ /a-zA-Z/
    validate_dob_maximum unless date_of_birth.blank?
    validate_dob_minimum unless date_of_birth.blank?
  end

  def validate_dob_maximum
    if date_of_birth < Time.zone.today - MAX_AGE.years
      errors.add(
        :date_of_birth,
        I18n.t('activerecord.attributes.dwp_check.dob_too_old', max_age: MAX_AGE)
      )
    end
  end

  def validate_dob_minimum
    if date_of_birth > Time.zone.today - MIN_AGE.years
      errors.add(
        :date_of_birth,
        I18n.t('activerecord.attributes.dwp_check.dob_too_young', min_age: MIN_AGE)
      )
    end
  end
end