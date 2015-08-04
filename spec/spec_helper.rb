require 'its'
require 'debugger'
require 'webmock'
require 'active_support/all'
require 'simplecov'
SimpleCov.start

Dir[File.join(File.dirname(__FILE__), '..', 'lib', '*.rb')].each { |f|  load f }

RSpec.configure do |config|
  config.before(:suite) { WebMock.enable!  }
  config.after(:suite)  { WebMock.disable! }
end
