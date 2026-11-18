class AddRatingToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :rating, :string
    add_column :tickets, :rating_comment, :text
    add_column :tickets, :rated_at, :datetime
    add_index :tickets, :rated_at
  end
end
