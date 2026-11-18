ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Fixtures skip model callbacks, so fill the full-text search index by hand.
    setup { Ticket.rebuild_search_index }

    # Add more helper methods to be used by all tests here...
  end
end
