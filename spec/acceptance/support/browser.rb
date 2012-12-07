#
# Allow tests to run in Chrome browser
#
if ENV['BROWSER'] == 'chrome'
  Capybara.register_driver :selenium do |app|
    driver = Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
end

require 'capybara/rspec'
require 'capybara-screenshot/rspec'
#
# Default timeout for extended for AJAX based application
#
Capybara.default_wait_time = 20
