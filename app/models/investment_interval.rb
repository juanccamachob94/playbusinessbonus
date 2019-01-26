class InvestmentInterval < ApplicationRecord
  scope :get_interval, -> average, group {where("? between min and max",average).where(group:group).first}
end
