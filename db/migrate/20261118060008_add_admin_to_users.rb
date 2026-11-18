class AddAdminToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin, :boolean, null: false, default: false

    # Existing installs: make the earliest agent an admin so someone can still manage the team.
    reversible do |dir|
      dir.up do
        execute "UPDATE users SET admin = 1 WHERE id = (SELECT MIN(id) FROM users)"
      end
    end
  end
end
