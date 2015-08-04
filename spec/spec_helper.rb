require 'its'
require 'debugger'
require 'webmock'
# require 'active_support/core_ext/time/zones'
# require 'active_support/core_ext/time/calculations'
# require 'active_support/core_ext/numeric/time'
require 'active_support/all'

Dir[File.join(File.dirname(__FILE__), '..', 'lib', '*.rb')].each { |f|  load f }

RSpec.configure do |config|
  config.before(:suite) { WebMock.enable! }
  config.after(:suite)  { WebMock.disable! }
end
