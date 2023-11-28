class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor

  validates :start_at, :end_at, :wday, :disease, presence: true
end