require 'rspec'
require 'pry'
require 'fakeweb'

RSpec.configure do |rspec|
  rspec.run_all_when_everything_filtered = true
  rspec.treat_symbols_as_metadata_keys_with_true_values = true
  rspec.filter_run_including :focus
  rspec.order = 'rand'
  rspec.color = true

  rspec.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  rspec.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end
end

FakeWeb.allow_net_connect = false
