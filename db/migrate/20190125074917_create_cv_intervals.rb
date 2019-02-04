class CreateCvIntervals < ActiveRecord::Migration[5.2]
  def change
    create_table :cv_intervals do |t|
      t.float :min
      t.float :max

      t.timestamps
    end
  end
end
