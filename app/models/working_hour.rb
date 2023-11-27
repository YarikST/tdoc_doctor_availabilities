class WorkingHour < ApplicationRecord
  belongs_to :doctor

  validates :start_at, :end_at, :wday, presence: true
end