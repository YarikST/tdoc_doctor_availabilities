class CreateWorkingHours < ActiveRecord::Migration[7.0]
  def change
    create_table :working_hours do |t|
      t.belongs_to :doctor

      t.datetime :start_at
      t.datetime :end_at
      t.integer  :wday

      t.timestamps
    end
  end
end
