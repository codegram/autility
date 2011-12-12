gem 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'mocha'
require 'vcr'
require_relative '../lib/utilities'

VCR.config do |c|
  c.cassette_library_dir = "test/fixtures/cassettes"
  c.stub_with :webmock
  c.default_cassette_options = { :record => :new_episodes }
end
