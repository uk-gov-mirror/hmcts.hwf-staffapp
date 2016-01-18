require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:subject_user) { build_stubbed(:user) }

  subject(:policy) { described_class.new(user, subject_user) }

  def dup_user(user)
    # HACK: how to achieve the same stubbed object in 2 different instances
    user.dup.tap do |new_user|
      new_user.id = user.id
    end
  end

  context 'for staff' do
    let(:user) { build_stubbed(:staff) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:list_deleted) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:restore) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }

    context 'when the subject_user is the staff themselves' do
      let(:subject_user) { dup_user(user) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:edit_password) }
      it { is_expected.to permit_action(:update_password) }

      context 'when the role is staff' do
        before do
          subject_user.role  = 'user'
        end

        it { is_expected.to permit_action(:update) }
      end

      context 'when trying to set a role to manager' do
        before do
          subject_user.role  = 'manager'
        end

        it { is_expected.not_to permit_action(:update) }
      end

      context 'when trying to set a role to admin' do
        before do
          subject_user.role  = 'admin'
        end

        it { is_expected.not_to permit_action(:update) }
      end
    end

    context 'when the subject_user is not the staff themselves' do
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:edit_password) }
      it { is_expected.not_to permit_action(:update_password) }
    end
  end

  context 'for manager' do
    let(:office) { build_stubbed(:office) }
    let(:user) { build_stubbed(:manager, office: office) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.not_to permit_action(:list_deleted) }
    it { is_expected.not_to permit_action(:restore) }

    context 'when the subject_user belongs to the same office as the manager' do
      let(:subject_user) { build_stubbed(:user, office: office) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }

      context 'when the subject_user is the manager themselves' do
        let(:subject_user) { dup_user(user) }

        it { is_expected.not_to permit_action(:destroy) }
        it { is_expected.to permit_action(:edit_password) }
        it { is_expected.to permit_action(:update_password) }

        context 'when trying to set a role to admin' do
          before do
            subject_user.role = :admin
          end

          it { is_expected.not_to permit_action(:update) }
        end
      end

      context 'when the subject_user is not the manager themselves' do
        it { is_expected.to permit_action(:destroy) }
        it { is_expected.not_to permit_action(:edit_password) }
        it { is_expected.not_to permit_action(:update_password) }

        context 'when role set to manager' do
          let(:subject_user) { build_stubbed(:user, office: office, role: 'manager') }

          it { is_expected.to permit_action(:create) }
          it { is_expected.to permit_action(:update) }
        end

        context 'when role set to admin' do
          let(:subject_user) { build_stubbed(:user, office: office, role: 'admin') }

          it { is_expected.not_to permit_action(:create) }
          it { is_expected.not_to permit_action(:update) }
        end
      end
    end

    context 'when the subject_user does not belong to the same office as the manager' do
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:destroy) }

      context 'when the manager tries to increase permissions to admin' do
        before do
          subject_user.role = 'admin'
        end

        it { is_expected.not_to permit_action(:update) }
      end

      context 'when the manager tries to increase permissions to manager' do
        before do
          subject_user.role = 'manager'
        end

        it { is_expected.not_to permit_action(:update) }
      end
    end
  end

  context 'for admin' do
    let(:user) { build_stubbed(:admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:list_deleted) }
    it { is_expected.to permit_action(:restore) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }

    context 'when the subject_user is the admin themselves' do
      let(:subject_user) { dup_user(user) }

      it { is_expected.not_to permit_action(:destroy) }
      it { is_expected.to permit_action(:edit_password) }
      it { is_expected.to permit_action(:update_password) }
    end

    context 'when the subject_user is not the admin themselves' do
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.not_to permit_action(:edit_password) }
      it { is_expected.not_to permit_action(:update_password) }
    end
  end

  describe described_class::Scope do
    describe '#resolve' do
      let(:office) { create :office }
      let(:other_office) { create :office }

      let!(:user1) { create :user, office: office }
      let!(:user2) { create :manager, office: office }
      let!(:user3) { create :admin, office: office }

      let!(:user4) { create :user, office: other_office }
      let!(:user5) { create :manager, office: other_office }
      let!(:user6) { create :admin, office: other_office }

      subject(:resolve) { described_class.new(user, User).resolve }

      context 'for staff' do
        let(:user) { create(:staff, office: office) }

        it { is_expected.to be_empty }
      end

      context 'for manager' do
        let(:user) { create(:manager, office: office) }

        it 'returns only users and managers from the same office' do
          is_expected.to match_array([user, user1, user2])
        end
      end

      context 'for admin' do
        let(:user) { create(:admin, office: office) }

        it 'returns all users' do
          is_expected.to match_array([user, user1, user2, user3, user4, user5, user6])
        end
      end
    end
  end
end