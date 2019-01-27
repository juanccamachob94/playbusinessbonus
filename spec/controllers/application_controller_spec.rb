require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe "#bonus_calculation" do
    expected_values =
    {
      1 => [{lower_limit: 3061.86,bonus: 20.0,upper_limit: 6123.71},{lower_limit: 6123.72,bonus: 30.0,upper_limit: 30618.61},{lower_limit: 30618.62,bonus: 35}],
      2 => [{lower_limit: 9633,bonus: 20.0,upper_limit: 19265.99},{lower_limit: 19266,bonus: 30.0,upper_limit: 77063.99},{lower_limit: 77064,bonus: 35}],
      3 => [{lower_limit: 19500,bonus: 25.0,upper_limit: 58499.99},{lower_limit: 58500,bonus: 30.0,upper_limit: 175499.99},{lower_limit: 175500,bonus: 40}],
      4 => [{lower_limit: 9633,bonus: 20.0,upper_limit: 19265.99},{lower_limit: 19266,bonus: 30.0,upper_limit: 77063.99},{lower_limit: 77064,bonus: 35}],
      5 => [{lower_limit: 463.05,bonus: 30.0,upper_limit: 926.09},{lower_limit: 926.1,bonus: 35.0,upper_limit: 4630.49},{lower_limit: 4630.5,bonus: 40}]
    }
    expected_values.each do |val, expected|
      it "Should to calculate a bonus for user" do
        app = ApplicationController.new
        expect(app.bonus_calculation(val)).to match_array(expected)
      end
    end
  end
end
