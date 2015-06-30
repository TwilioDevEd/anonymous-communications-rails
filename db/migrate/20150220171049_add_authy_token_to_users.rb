class AddAuthyTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authy_id, :string
    add_column :users, :verified, :boolean, default: false
  end
end
