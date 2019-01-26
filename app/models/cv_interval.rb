class CvInterval < ApplicationRecord
  has_many :cv_investment_intervals
  has_many :investment_intervals, through: :cv_investment_intervals
  scope :get_interval, -> cv {find_by("? > min and ? <= max",cv,cv)}
end
