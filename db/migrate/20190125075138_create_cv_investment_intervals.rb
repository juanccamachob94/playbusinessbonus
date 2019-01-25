class CreateCvInvestmentIntervals < ActiveRecord::Migration[5.2]
  def change
    create_table :cv_investment_intervals do |t|
      t.references :cv_interval, foreign_key: true
      t.references :investment_interval, foreign_key: true

      t.timestamps
    end
  end
end
