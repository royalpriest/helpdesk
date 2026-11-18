class CreateCannedReplies < ActiveRecord::Migration[8.1]
  def change
    create_table :canned_replies do |t|
      t.string :title, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
