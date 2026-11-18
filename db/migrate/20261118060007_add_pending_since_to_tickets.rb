class AddPendingSinceToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :pending_since, :datetime
    add_index :tickets, :pending_since
  end
end
