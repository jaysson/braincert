require 'spec_helper'

include BraincertRequestHelpers

describe 'API method wrapper' do
  before :each do
    @c = Braincert::LiveClass.new(:title => 'Test class',
      :start_time_with_zone => Time.utc(2015,8,3,15,0).in_time_zone('Edinburgh'),
      :duration => 3600)
  end
  describe 'serializing' do
    specify 'single class meeting' do
      expect(@c.to_json).to be_json_eql('{"title":"Test class","timezone":"28","start_time":"04:00PM","end_time":"05:00PM","date":"2015-08-03","seat_attendees":2,"record":1,"format":"json"}')
    end
    specify 'recurring meetings' do
      @c.is_recurring = 1
      @c.repeat = Braincert::REPEAT_WEEKLY
      @c.end_classes_count = 3
      expect(@c.to_json).to be_json_eql('{"title":"Test class","timezone":"28","start_time":"04:00PM","end_time":"05:00PM","date":"2015-08-03","seat_attendees":2,"record":1,"format":"json","is_recurring":1,"repeat":4,"end_classes_count":3}')
    end
    describe 'recovers timezone info' do
      subject do
        attrs = JSON.parse(IO.read 'spec/fixtures/get_class_by_id.json').first
        Braincert::LiveClass.new(Braincert::LiveClass.from_attributes(attrs))
      end
      # has timezone 38 (Chihuahua, La Paz, Mazatlan), but loses timezone name info; can we recover it?
      its(:start_time) { should eq "05:15PM" }
      its(:duration) { should eq 15.minutes }
      it 'preserves timezone' do ; pending 'How to check timezone?' ; end
    end
  end
  describe '#save' do
    it 'succeeds' do
      expect(@c).to receive(:do_request).with('schedule',
        hash_including("title" => "Test class"))
      @c.save
    end
    it 'succeeds with recurring' do
      @c.is_recurring = 1
      @c.repeat = Braincert::REPEAT_WEEKLY
      @c.end_classes_count = 3
      expect(@c).to receive(:do_request).with('schedule',
        hash_including("end_classes_count" => 3, "repeat" => 4, "is_recurring" => 1))
      @c.save
    end
  end
  describe '.find' do
    describe 'existing' do
      subject do
        WebMock.stub_request(:post, regexp_for('getclass')).to_return fixture('get_class_by_id')
        c = Braincert::LiveClass.find(6622)
      end
      its(:id) { should == 6622 }
      its(:title) { should == "Test class" }
      its(:seat_attendees) { should == 2 }
    end
    describe 'with nonexistent id' do
      before(:each) do
        WebMock.stub_request(:post, regexp_for('getclass')).to_return fixture('get_class_with_bad_id')
      end
    end
  end
end
