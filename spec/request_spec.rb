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
    @valid_attributes = {
      :title => 'Test class',
      :start_time_with_zone => 1.day.from_now.midnight.in_time_zone("Pacific Time (US & Canada)"),
      :duration => 3600
    }
  end
  specify 'to create class successfully' do
    WebMock.stub_request(:post, regexp_for('schedule')).to_return fixture('success_add_class')
    c = Braincert::LiveClass.new(@valid_attributes)
    expect(c).to be_valid
    c.save
    expect(c.class_id).to eq 6598
  end
end
