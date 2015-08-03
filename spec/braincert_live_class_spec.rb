require 'spec_helper'
describe Braincert::LiveClass do
  describe 'new' do
    subject { Braincert::LiveClass.new }
    it { should_not be_valid }
  end
  describe 'setting timezone' do
    before :each do
      @c = Braincert::LiveClass.new 
    end
    it 'sets timezone' do
      @c.timezone = 'Hawaii'
      expect(@c.timezone).to eq('32')
    end
  end
end
      
