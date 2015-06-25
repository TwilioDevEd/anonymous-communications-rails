class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.string :name
      t.string :phone_number
      t.integer :status
      t.text :message
      t.belongs_to :vacation_property, index:true
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
