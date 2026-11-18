class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.text :body, null: false
      t.string :email_message_id

      t.timestamps
    end
    add_index :messages, :email_message_id, unique: true
  end
end
