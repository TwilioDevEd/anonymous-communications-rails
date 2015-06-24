class CreateVacationProperties < ActiveRecord::Migration
  def change
    create_table :vacation_properties do |t|
      t.belongs_to :user, index:true
      t.string :description
      t.string :image_url

      t.timestamps null: false
    end
  end
end
