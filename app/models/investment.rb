class Investment < ApplicationRecord
  belongs_to :user
  scope :valid_investments, -> user_id {where(user_id:user_id).where("amount - wallet_amount > 3000")}
  scope :amount_difference_summary, -> {sum("amount - wallet_amount")}
  scope :amount_pow_difference_summary, -> average {sum("pow(amount - wallet_amount - #{average},2)")}
end
