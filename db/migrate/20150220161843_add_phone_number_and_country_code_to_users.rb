class AddPhoneNumberAndCountryCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_number, :string
    add_column :users, :country_code, :string
  end
end
