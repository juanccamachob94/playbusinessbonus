class ChangeColumnInvestmentIntervalFromDecimalToInteger < ActiveRecord::Migration[5.2]
  def change
    remove_column :investment_intervals, :group, :decimal
    add_column :investment_intervals, :group, :integer
  end
end
