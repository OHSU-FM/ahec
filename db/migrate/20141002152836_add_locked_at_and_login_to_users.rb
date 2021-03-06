class AddLockedAtAndLoginToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :username, :string
    add_index :users, :username, unique: true
    add_column :users, :locked_at ,:datetime
    add_column :users, :use_ldap, :boolean
  end
end
