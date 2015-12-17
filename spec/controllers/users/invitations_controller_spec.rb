# coding: utf-8
require 'rails_helper'

RSpec.describe Users::InvitationsController, type: :controller do

  include Devise::TestHelpers

  let(:office) { create :office }
  let(:admin_user) { create :admin_user, office: office }
  let(:manager_user) { create :manager, office: office }
  let(:user) { build :user }

  let(:invitation) do
    {
      name: user.name,
      email: user.email,
      office_id: office.id
    }
  end

  let(:manager_invitation) { invitation.merge!(role: 'manager') }
  let(:admin_invitation) { invitation.merge(role: 'admin') }

  let(:invited_user) { User.where(email: user.email).first }

  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  context 'Manager user' do
    describe 'POST #create' do

      before { sign_in manager_user }

      it 'does allow you to invite managers as a manager' do
        post :create, user: manager_invitation

        expect(invited_user['email']).to eq user.email
        expect(invited_user['invited_by_id']).to eq manager_user.id
      end

      it 'does not allow you to invite admins as a manager' do
        expect {
          post :create, user: admin_invitation
        }.to raise_error 'Unprivileged invitation error: Non-admin user is inviting an admin.'
      end
    end

    context 'Admin user' do
      describe 'POST #create' do

        before { sign_in admin_user }

        it 'does allow you to invite managers as an admin' do
          post :create, user: manager_invitation

          expect(invited_user['email']).to eq user.email
          expect(invited_user['invited_by_id']).to eq admin_user.id
        end

        it 'does allow admins to invite admins' do
          post :create, user: admin_invitation

          expect(invited_user['email']).to eq user.email
          expect(invited_user['invited_by_id']).to eq admin_user.id
        end
      end
    end
  end
end