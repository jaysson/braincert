require 'spec_helper'

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
    it 'is not valid' do
      expect(Braincert::LiveClass.new).to_not be_valid
    end
    it 'is valid with valid attributes' do
      expect(Braincert::LiveClass.new(@valid_attributes)).to be_valid
    end
  end
  describe 'setting time with zone' do
    subject do
      c = Braincert::LiveClass.new(:title => 'Test')
      c.start_time_with_zone = Time.utc(2015,8,3,18,15,0).in_time_zone('Hawaii')
      c.duration = 3600         # seconds
      c
    end
    its(:start_time) { should eq '08:15AM' }
    its(:end_time)   { should eq '09:15AM' }
    its(:date) { should eq '2015-08-03' }
    its(:timezone) { should eq '32' }
    it { should be_valid }
  end
end
      
