class InvestmentInterval < ApplicationRecord
  scope :get_intervals, -> average, group {where("(? between min and max) or (min is null and ? < max) or (min < ? and max is null)",average,average,average).where(group:group)}
end
