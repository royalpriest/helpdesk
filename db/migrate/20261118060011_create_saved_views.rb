class CreateSavedViews < ActiveRecord::Migration[8.1]
  def change
    create_table :saved_views do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :filter, null: false, default: "open"
      t.string :tag
      t.string :query
      t.timestamps
    end
  end
end
