require 'spec_helper'
require 'active_support/core_ext/time/zones'

describe Braincert::LiveClass do
  describe 'new' do
    subject { Braincert::LiveClass.new }
    it { should_not be_valid }
  end
  describe 'setting timezone' do
    before :each do
      @c = Braincert::LiveClass.new 
    end
    it 'sets time and timezone' do
      @t = Time.utc(2015,8,3,18,15,0)
      cases = [
        'Hawaii', '08:15AM', '2015-08-03', '32'
      ]
      cases.each_slice(4) do |c|
        @c.set_start_time_and_zone(@t.in_time_zone(c[0]))
        expect(@c.start_time).to eq c[1]
        expect(@c.date).to eq c[2]
        expect(@c.timezone).to eq c[3]
      end
    end
  end
end
      
