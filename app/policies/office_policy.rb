class OfficePolicy < BasePolicy
  def index?
    not_staff?
  end

  def show?
    not_staff? || (staff? && same_office?)
  end

  def new?
    admin?
  end

  def create?
    admin?
  end

  def edit?
    admin? || (manager? && same_office?)
  end

  def update?
    admin? || (manager? && same_office?)
  end

  private

  def same_office?
    @record == @user.office
  end
end
