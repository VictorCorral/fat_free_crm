#
# Drives the browser in 'headless' mode if required.
# Useful for CI and travis tests
#

if ENV['HEADLESS'] == 'true' or ENV["CI"] == "true"
  require 'headless'
  headless = Headless.new(:dimensions => "1600x1200x24")
  headless.start
  HEADLESS_DISPLAY = ":#{headless.display}"
  at_exit do
    headless.destroy
  end
  puts "Running in Headless mode. Display #{HEADLESS_DISPLAY}"
end
