class CreateBonus < ActiveRecord::Migration[5.2]
  def change
    create_table :bonus do |t|
      t.float :std
      t.float :percent
      t.references :cv_investment_interval, foreign_key: true

      t.timestamps
    end
  end
end
