class ApplicationController < ActionController::Base
  def calculate_user
    user_id = params[:user_id]

    quantity = Investment.valid_investments(user_id).count
    if quantity == 0
      return render json: {data:[]}
    end
    average = Investment.valid_investments(user_id).amount_difference_summary / quantity
    standard_desviation = Math.sqrt(Investment.valid_investments(user_id).amount_pow_difference_summary(average)/quantity)
    cv_interval = CvInterval.get_intervals(standard_desviation/average).first
    investment_interval = InvestmentInterval.get_intervals(average,1).first

    if cv_interval.nil? || standard_desviation/average < 0.14
      standard_desviation = UnitBonu.find_by(investment_interval:investment_interval).stdv
      cv_interval = CvInterval.get_intervals(0.31).first
    end

    bonus = Bonu.where(cv_investment_interval:CvInvestmentInterval.find_by(cv_interval:cv_interval,investment_interval:investment_interval)).order("std")
    render json: {data:build_result(standard_desviation,bonus)}
  end

  def build_result standard_desviation,bonus
    result = []
    bonus.each_with_index do |value,i|
      result[i] = {lower_limit: value.std * standard_desviation,bonus:"#{value.percent}%"}
    end
    (1..(result.length - 1)).each do |i|
      result[i - 1][:upper_limit] ="$#{result[i][:lower_limit] - 0.01}"
      result[i][:lower_limit] = "$#{result[i][:lower_limit]}"
    end
    result[0][:lower_limit] = "$#{result[0][:lower_limit]}"
    result
  end
end
