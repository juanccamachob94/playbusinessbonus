class CreateUnitBonus < ActiveRecord::Migration[5.2]
  def change
    create_table :unit_bonus do |t|
      t.string :stdv_float
      t.references :investment_interval, foreign_key: true

      t.timestamps
    end
  end
end
