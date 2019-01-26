class CvInterval < ApplicationRecord
  has_many :cv_investment_intervals
  has_many :investment_intervals, through: :cv_investment_intervals
  scope :get_intervals, -> cv {where("(? > min and ? <= max) or (? > min and max is null) or (min is null and ? <= max)",cv,cv,cv,cv)}
end
