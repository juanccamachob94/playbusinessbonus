class ApplicationController < ActionController::Base
  def calculate_user
    user_id = params[:user_id]
    quantity = Investment.valid_investments(user_id).count
    average = Investment.valid_investments(user_id).amount_difference_summary / quantity
    standard_desviation = Math.sqrt(Investment.valid_investments(user_id).amount_pow_difference_summary(average)/quantity)
    bonus = Bonu.where(cv_investment_interval:CvInvestmentInterval.find_by(cv_interval:CvInterval.get_interval(standard_desviation/average),investment_interval:InvestmentInterval.get_interval(average,1)))
    result = []
    bonus.each_with_index do |value,i|
      result[i] = {lower_limit: value.std * standard_desviation,bonus:value.percent}
    end
    (1..(result.length - 1)).each do |i|
      result[i - 1][:upper_limit] = result[i][:lower_limit] - 0.01
    end
    render json: {data:result}
  end
end
