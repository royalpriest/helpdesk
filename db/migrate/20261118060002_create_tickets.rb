class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :assignee, foreign_key: { to_table: :users }
      t.string :subject, null: false
      t.string :status, null: false, default: "open"
      t.string :portal_token, null: false

      t.timestamps
    end
    add_index :tickets, :status
    add_index :tickets, :portal_token, unique: true
  end
end
