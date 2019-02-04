class ChangeColumnInvestmentIntervalFromGroupToCollection < ActiveRecord::Migration[5.2]
  def change
    remove_column :investment_intervals, :group, :integer
    add_column :investment_intervals, :collection, :integer
  end
end
