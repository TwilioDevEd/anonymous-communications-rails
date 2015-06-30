class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.string :name
      t.string :phone_number
      t.integer :status, default: 0
      t.text :message
      t.belongs_to :vacation_property, index:true

      t.timestamps null: false
    end
  end
end
