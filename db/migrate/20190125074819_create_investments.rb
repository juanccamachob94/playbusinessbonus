class CreateInvestments < ActiveRecord::Migration[5.2]
  def change
    create_table :investments do |t|
      t.references :user, foreign_key: true
      t.float :amount
      t.float :wallet_amount

      t.timestamps
    end
  end
end
