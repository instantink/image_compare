# frozen_string_literal: true

begin
  require "pry-byebug"
rescue LoadError => _e
  nil
end

require "image_compare"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |file| require file }

RSpec.configure do |config|
  config.mock_with :rspec

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed
end

def image_path(name)
  "#{File.dirname(__FILE__)}/fixtures/#{name}.png"
end
