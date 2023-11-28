class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.belongs_to :doctor
      t.belongs_to :patient

      t.string :disease

      t.datetime :start_at
      t.datetime :end_at
      t.integer  :wday

      t.timestamps
    end
  end
end
