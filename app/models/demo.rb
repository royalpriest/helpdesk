# The public demo (DEMO_MODE=true) lets anyone sign in with a well-known password,
# so it wipes everything visitors did and loads the demo data again every night.
module Demo
  KEEP_TABLES = %w[schema_migrations ar_internal_metadata].freeze

  def self.enabled?
    Rails.configuration.x.demo_mode
  end

  def self.reset!
    connection = ActiveRecord::Base.connection
    connection.disable_referential_integrity do
      (connection.tables - KEEP_TABLES).each { |table| connection.execute("DELETE FROM #{connection.quote_table_name(table)}") }
      connection.execute("DELETE FROM ticket_search")
    end
    Rails.application.load_seed
  end
end
