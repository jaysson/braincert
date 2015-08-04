require 'spec_helper'

module BraincertRequestHelpers 
  def regexp_for(action)
    Regexp.new "\\A#{@site}/#{action}\\?"
  end
  def fixture(file)
    {:status => 200, :body => IO.read("spec/fixtures/#{file}.json")}
  end
end

describe 'request' do
  include BraincertRequestHelpers
  before do
    @site = 'http://example.com'
    Braincert::Request.api_key = 'apiXYZ'
    Braincert::Request.site = @site
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
