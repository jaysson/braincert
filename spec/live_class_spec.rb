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
  describe 'setting times' do
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
  describe 'serializing' do
    before :each do
      @c = Braincert::LiveClass.new(:title => 'x',
        :start_time_with_zone => Time.utc(2015,8,3,15,0).in_time_zone('Edinburgh'),
        :duration => 3600)
    end
    specify 'single class meeting' do
      expect(@c.to_json).to eq "{\"title\":\"x\",\"timezone\":\"28\",\"start_time\":\"04:00PM\",\"end_time\":\"05:00PM\",\"date\":\"2015-08-03\",\"seat_attendees\":25,\"record\":1,\"format\":\"json\"}"
    end
    specify 'recurring meetings' do
      @c.is_recurring = 1
      @c.repeat = Braincert::REPEAT_WEEKLY
      @c.end_classes_count = 3
      expect(@c.to_json).to eq "{\"title\":\"x\",\"timezone\":\"28\",\"start_time\":\"04:00PM\",\"end_time\":\"05:00PM\",\"date\":\"2015-08-03\",\"seat_attendees\":25,\"record\":1,\"format\":\"json\",\"is_recurring\":1,\"repeat\":4,\"end_classes_count\":3}"
    end
    describe 'recovers timezone info' do
      subject do
        attrs = JSON.parse(IO.read 'spec/fixtures/get_class_by_id.json').first
        Braincert::LiveClass.new(Braincert::LiveClass.from_attributes(attrs))
      end
      # has timezone 38 (Chihuahua, La Paz, Mazatlan), but loses timezone name info; can we recover it?
      its(:start_time) { should eq "05:15PM" }
      raise 'how to check timezone??'
      its(:duration) { should eq 15.minutes }
    end
  end
  describe 'CRUD' do
    it 'creates' do
      @c = Braincert::LiveClass.new(@valid_attributes)
      expect(@c).to receive(:do_request).with('schedule',
        hash_including("title" => "Test class"))
      @c.save
    end
    it 'creates with recurring' do
      @c = Braincert::LiveClass.new(@valid_attributes)
      @c.is_recurring = 1
      @c.repeat = Braincert::REPEAT_WEEKLY
      @c.end_classes_count = 3
      expect(@c).to receive(:do_request).with('schedule',
        hash_including("end_classes_count" => 3, "repeat" => 4, "is_recurring" => 1))
      @c.save
    end
  end
end
      
