class Reservation < ActiveRecord::Base
  validates :name, presence: true
  validates :phone_number, presence: true

  enum status: [ :pending, :confirmed, :rejected ]

  belongs_to :vacation_property
end
