class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :email_address, null: false
      t.string :name, null: false, default: ""

      t.timestamps
    end
    add_index :customers, :email_address, unique: true
  end
end
