require 'spec_helper'

describe 'request' do
  include BraincertRequestHelpers # sets a mocked sitename in STUB_SITE
  before do
    Braincert.api_key = 'apiXYZ'
  end
  describe 'creating' do
    before(:each) do
      @c = Braincert::LiveClass.new(
        :title => 'Test class',
        :start_time_with_zone => 1.day.from_now.midnight.in_time_zone("Pacific Time (US & Canada)"),
        :duration => 3600
        )
      expect(@c).to be_valid
    end
    specify 'successfully' do
      WebMock.stub_request(:post, regexp_for('schedule')).to_return fixture('success_add_class')
      @c.save
      expect(@c.id).to eq 6598
    end
    specify 'when course already persisted' do
      expect(@c.save).not_to be_nil
      expect(@c.save).to be_nil
      expect(@c.errors[:connection].first).to match /cannot be updated/i
    end
    specify 'with HTTP errors' do
      WebMock.stub_request(:post, regexp_for('schedule')).to_raise Errno::ECONNRESET
      expect(@c.save).to be_nil
      expect(@c.errors[:connection].first).to match /Connection reset/
    end
    specify 'with HTTP errors using save!' do
      WebMock.stub_request(:post, regexp_for('schedule')).to_raise Errno::ECONNRESET
      expect { @c.save! }.to raise_error(Braincert::LiveClass::SaveError)
    end
    specify 'with invalid API key' do
      WebMock.stub_request(:post, regexp_for('schedule')).to_return fixture('error_invalid_api_key')
      expect(@c.save).to be_nil
      expect(@c.errors[:connection].first).to match /invalid API key/i
    end
    specify 'transaction successful but request fails' do
      WebMock.stub_request(:post, regexp_for('schedule')).to_return fixture('error_too_many_seats')
      expect(@c.save).to be_nil
      expect(@c.errors[:connection].first).to match /Please enter less than 2 Seat Attendees/i
    end
  end
end
