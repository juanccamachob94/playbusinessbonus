class ChangeColumnUnitBonuFromStringToFloat < ActiveRecord::Migration[5.2]
  def change
    remove_column :unit_bonus, :stdv_float, :string
    add_column :unit_bonus, :stdv, :float
  end
end
