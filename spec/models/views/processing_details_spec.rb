# coding: utf-8
require 'rails_helper'

RSpec.describe Views::ProcessingDetails do
  let(:application) { build_stubbed(:application) }
  let(:record) { double(application: application) }

  subject(:view) { described_class.new(record) }

  it { is_expected.to delegate_method(:reference).to(:application) }

  describe '#expires' do
    let(:expires_at) { 2.days.from_now }
    let(:record) { double(application: application, expires_at: expires_at) }

    subject { view.expires }

    it 'returns just date' do
      is_expected.to be_a(Date)
    end

    it 'returns the correct date from the record\'s expires_at' do
      is_expected.to eq(expires_at.to_date)
    end
  end

  describe '#processed_by' do
    subject { view.processed_by }

    it 'returns the name of the user who created the application' do
      is_expected.to eql(application.user.name)
    end
  end

  describe '#applicant' do
    subject { view.applicant }

    it 'returns the full name of the applicant' do
      is_expected.to eql(application.full_name)
    end
  end
end