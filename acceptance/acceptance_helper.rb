require File.expand_path("../../spec/spec_helper.rb", __FILE__)

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configuration.before(:each, :type => :request) do
  PaperTrail.enabled = true
end
