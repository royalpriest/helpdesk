# When the customer started waiting on the team, so the inbox can show the
# longest-waiting tickets first. Cleared when an agent replies.
class AddWaitingSinceToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :waiting_since, :datetime
    add_index :tickets, :waiting_since

    reversible do |dir|
      dir.up do
        execute "UPDATE tickets SET waiting_since = updated_at WHERE status = 'open'"
      end
    end
  end
end
