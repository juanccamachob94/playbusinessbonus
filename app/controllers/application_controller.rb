class ApplicationController < ActionController::Base

  def bonus_calculation user_id
    # Number of investments of user with id = user_id
    number_valid_of_investments = Investment.valid_investments(user_id).count
    # In case of user doesn't have investments
    if number_valid_of_investments == 0
      return render json: {data:[]}
    end
    # average calculated with the sumatory of (amount-wallet_amount) and the number valid of investments
    average = Investment.valid_investments(user_id).amount_difference_summary / number_valid_of_investments
    # standard_desviation sqrt(sum[(xi - average)^2]/number_valid_of_investments) xi = each value (amount - wallet_amount)
    standard_desviation = Math.sqrt(Investment.valid_investments(user_id).amount_pow_difference_summary(average)/number_valid_of_investments)
    # Search cv_inverval for cv = standard_desviation/average
    cv_interval = CvInterval.get_intervals(standard_desviation/average).first
    # Search investment_interval for average. 1 for 1st collection of intervals
    investment_interval = InvestmentInterval.get_intervals(average,1).first
    #If cv_interval not exist by cv (standard_desviation/average). A case is for cv < 0.14
    if cv_interval.nil?
      #recalculate standard_desviation with another options
      standard_desviation = UnitBonu.find_by(investment_interval:investment_interval).stdv
      #recalculate cv_interval with a value less than 1.3 and greater than 0.3, 0.31 for example
      cv_interval = CvInterval.get_intervals(0.31).first
    end
    #select desviation values with percentages that correspond to cv_interval and investment_interval with std order
    bonus = Bonu.where(cv_investment_interval:CvInvestmentInterval.find_by(cv_interval:cv_interval,investment_interval:investment_interval)).order("std")
    #building a result with standard_desviation for operate
    build_result(standard_desviation,bonus)
  end

  #calculate bonus for user with him/her id [postgres implementation]
  def bonus_calculation_alternative
    #call a postgres function with the user_id as parameter
    render json: {data:User.find_by_sql(['SELECT * FROM bonus_calculation(?)',params[:user_id]])}
  end

  private
    #build a result with the standard_desviation operation and defining a upper_limit
    def build_result standard_desviation,bonus
      result = []
      #build a result with values multiplied with standard_desviation and assign a percent
      bonus.each_with_index do |value,i|
        result[i] = {lower_limit: (value.std * standard_desviation).round(2),bonus:value.percent}
      end
      #A second loop for assign upper_limit with lower_limit - 0.01
      (1..(result.length - 1)).each do |i|
        result[i - 1][:upper_limit] = result[i][:lower_limit] - 0.01
      end
      result
    end
end
