class AddAreaCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :area_code, :string
  end
end
