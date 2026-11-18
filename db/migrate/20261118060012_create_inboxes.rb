class CreateInboxes < ActiveRecord::Migration[8.1]
  def up
    create_table :inboxes do |t|
      t.string :name, null: false
      t.string :email_address, null: false
      t.timestamps
    end
    add_index :inboxes, :email_address, unique: true

    add_reference :tickets, :inbox, foreign_key: true

    # Existing tickets move into a default inbox for the current support address.
    email = ENV.fetch("SUPPORT_EMAIL", "support@example.com").strip.downcase
    execute <<~SQL
      INSERT INTO inboxes (name, email_address, created_at, updated_at)
      VALUES ('Support', #{connection.quote(email)}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
    execute "UPDATE tickets SET inbox_id = (SELECT id FROM inboxes LIMIT 1)"

    change_column_null :tickets, :inbox_id, false
  end

  def down
    remove_reference :tickets, :inbox, foreign_key: true
    drop_table :inboxes
  end
end
