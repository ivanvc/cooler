dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift(File.join(dir, '..', 'lib'))
$LOAD_PATH.unshift(dir)

require 'cooler'

Dir[File.join(dir, 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rr
  config.order = 'random'
end
