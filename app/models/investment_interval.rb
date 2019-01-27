class InvestmentInterval < ApplicationRecord
  scope :get_intervals, -> average, collection {where("(? between min and max) or (min is null and ? < max) or (min < ? and max is null)",average,average,average).where(collection:collection)}
end
