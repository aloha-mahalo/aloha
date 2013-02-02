require 'rubygems'
require 'spork'
require 'timecop'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require 'rspec/autorun'

  RSpec.configure do |config|
    config.mock_with :rspec
  end
end

Spork.each_run do
end
