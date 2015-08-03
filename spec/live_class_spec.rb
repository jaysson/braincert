require 'spec_helper'
require 'active_support/core_ext/time/zones'
require 'webmock'

describe Braincert::LiveClass do
  before(:all) do
    @valid_attributes = {
      :title => 'Test class',
      :start_time => '08:15AM',
      :end_time => '09:15AM',
      :date => '2015-08-03',
      :timezone => '32'         # Hawaii
    }
  end
  
  describe 'when created' do
    it 'is not valid' do ; Braincert::LiveClass.new.should_not be_valid ; end
    it 'is valid with valid attributes' do ; Braincert::LiveClass.new(@valid_attributes).should be_valid ; end
  end
  describe 'setting timezone' do
    subject do
      c = Braincert::LiveClass.new
      c.start_time_with_zone = Time.utc(2015,8,3,18,15,0).in_time_zone('Hawaii')
      c
    end
    its(:start_time) { should eq '08:15AM' }
    its(:date) { should eq '2015-08-03' }
    its(:timezone) { should eq '32' }
  end
  describe 'CRUD' do
    before(:all) do
      BrainCert::Request.api_key = 'apiXYZ'
      BrainCert::Request.site = 'http://example.com'
      WebMock.enable!
      WebMock.stub_request(:post, %r{http://example.com/.*}).to_return do |req|
        debugger
      end
    end
    after(:all) do
      WebMock.disable!
    end
    describe 'create' do
      before(:each) do
        @c = Braincert::LiveClass.new(@valid_attributes)
      end
    end
  end
end
      
