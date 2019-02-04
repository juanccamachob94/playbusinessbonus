class ApplicationController < ActionController::Base

  def bonus_calculation user_id
    # Number of investments from user with id = user_id
    valid_number_of_investments = Investment.valid_investments(user_id).count
    # In case the user doesn't have any investments
    if valid_number_of_investments == 0
      return render json: {data:[]}
    end
    # average calculated with the sumatory of (amount-wallet_amount) and the number of valid_number_of_investments
    average = Investment.valid_investments(user_id).amount_difference_summary / valid_number_of_investments
    # standard_deviation sqrt(sum[(xi - average)^2]/valid_number_of_investments) xi = each value (amount - wallet_amount)
    standard_deviation = Math.sqrt(Investment.valid_investments(user_id).amount_pow_difference_summary(average)/valid_number_of_investments)
    # Look for cv on cv_interval taking into account cv = standard_deviation/average
    cv_interval = CvInterval.get_intervals(standard_deviation/average).first
    # Search investment_interval for average. 1 for 1st collection of intervals
    investment_interval = InvestmentInterval.get_intervals(average,1).first
    #If there's not a cv_interval for the calculated cv (standard_deviation/average). For example cv < 0.14
    if cv_interval.nil?
      #recalculate standard_deviation with other options
      standard_deviation = UnitBonu.find_by(investment_interval:investment_interval).stdv
      #recalculate cv_interval with a value less than 1.3 and greater than 0.3, for example, 0.31
      cv_interval = CvInterval.get_intervals(0.31).first
    end
    #select deviation values with percentages that correspond to cv_interval and investment_interval with std order
    bonus = Bonu.where(cv_investment_interval:CvInvestmentInterval.find_by(cv_interval:cv_interval,investment_interval:investment_interval)).order("std")
    #building a result with standard_deviation in order to function
    build_result(standard_deviation,bonus)
  end

  #calculate bonus for user with its id [postgres implementation]
  def bonus_calculation_alternative id_user
    #call a postgres function with the user_id as parameter
    x = JSON.parse User.find_by_sql(['SELECT * FROM bonus_calculation(?)',id_user]).to_json
    res = []
    x.each_with_index do |mihash,i|
      res[i] = mihash.select {|k, v| !v.nil? }
    end
    res
  end

  private
    #build a result with the standard_deviation operation and defining an upper_limit
    def build_result standard_deviation,bonus
      result = []
      #build a result with values multiplied by standard_deviation and assign a percentage
      bonus.each_with_index do |value,i|
        result[i] = {lower_limit: (value.std * standard_deviation).round(2),bonus:value.percent}
      end
      #A second loop to assign an upper_limit with a lower_limit of - 0.01
      (1..(result.length - 1)).each do |i|
        result[i - 1][:upper_limit] = result[i][:lower_limit] - 0.01
      end
      result
    end
end
