class CreateInvestmentIntervals < ActiveRecord::Migration[5.2]
  def change
    create_table :investment_intervals do |t|
      t.float :min
      t.float :max
      t.decimal :group

      t.timestamps
    end
  end
end
