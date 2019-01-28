# Bonus calculations for PlayBusiness users
## Description:
Technical test. Development of an app that calculates bonus for system users based on dynamic rules.
## Technologies:
* Ruby 2.5.3p105
* Rails 5.2.2
* Postgres 10.6
* Gems:
    * Devise 5.1
    * simplecov 0.16.0
    * rspec-rails 3.8
    * Factory_bot_rails 5.0.0.r2 (opcional)
## Execution
The app automatically executes through this command
```
rails server
```
## Service:
`bonus_calculation` service solves the requirement by receiving the user `ID` and returning a hash with `lower_limit`, `upper_limit` and `bonus` values. Additionally, there’s a proposal for an alternative to the requirement through a function in the database engine which allows solving the need by decreasing the data load through the net. Following this, there’s a description for the logic of this algorithm, which applies to the service, as well as to the proposal in the database engine.
1. Calculation of the number of valid investments for the user. If the number of valid investments is 0, there’s no bonus.
2. Calculation of the investment average and standard deviation.
3. Attainment of the interval to which the coefficient of variation belongs (obtained from the division of standard deviation by the investment average) and the interval to which the investment average corresponds.
4. If there’s no interval for the coefficient of variation (for example, when the coefficient of variation is less than 0.14 or the standard deviation equals 0), the standard deviation is reassigned with the predefined values on the table for a single investment ([first table](https://docs.google.com/spreadsheets/d/1xGovhmmAhFAbkWAhlaULOZk5QNJoEceSsS4BAal_S2U/edit)) and the interval of the coefficient of variation is reassigned to [0.3,1.3)
5. Attainment of values for bonus from the investments interval and the interval of the coefficients of variation.
6. Calculation of bonus from the bonus values and standard deviation.
### bonus_calculation:
The logic developed in this service is solved mainly using scopes. The result is built by operating the values through an additional method in the same controller (`ApplicationController`)
#### Scopes:
##### Investment:
* `valid_user_investments`: investments where the difference between amount and wallet_amount is greater than 3000
* `valid_investments`: investments where the difference between amount and wallet_amount is greater tan 3000 for the user whose id is the value received as parameter.
* `amount_difference_summary`: sum of the difference of amount and wallet_amount from the investments table.
* `amount_pow_difference_summary`: sum of the difference of amount, wallet_amount and the average of squared investments received as parameter.
#### InvestmentInterval:
* `get_intervals`: it obtains the investments intervals that have the value received as parameter in a closed set or which value is less than the maximum value or greater than the minimum value.
#### CvInterval:
* `get_intervals`: it obtains the intervals of the coefficients of variation that have the (x > min y x <= max) value received as parameter in a closed set from the left and open from the right, or which value is less than the maximum value or greater than the minimum value.

### bonus_calculation_alternative:
The `bonus_calculation` function developed on postgres is used in the controller (`ApplicationController`). Please note that the alternative is built with the purpose of decreasing execution costs.

## Data model
The relational model that describes the solution to the problem can be found on this [link](https://drive.google.com/file/d/1hKTG_8SAtIJOQH_FTPUcIFsgNN2c1ulm/preview). Each of the tables, their atributes and relations are described next.
#### USERS:
- **Description:** app users.
- **Attributes:**
  - ID: auto incremental primary key.
  - EMAIL: user email. Representative character only.
#### INVESTMENTS:
- **Description:** investments made by the app users.
- **Attributes:**
  - ID: auto incremental primary key.
  - AMOUNT: amount of the total investment by a user on a startup.
  - WALLET_AMOUNT: amount of the virtual investment by a user on a startup.
  - USER_ID: identifier of the user who owns that investment.
#### INVESTMENT_INTERVALS:
- **Description:** investments interval in which the investments average of a user is grouped according to the corresponding plan. Each plan indicates the grouping of the investment intervals with disjoint values amongst them.
- **Attributed:**
  - ID: auto incremental primary key
  - MIN: minimum value of the interval to which the investments average of a user could belong.
  - MAX: maximum value of the interval to which the investments average of a user could belong.
  - COLLECTION: identifier of the grouping that identifies an investments interval within a plan.
#### CV_INTERVALS:
- **Description:** interval of coefficients of variation in which the CV is grouped (coefficient of variation), calculated from a user investments. Each interval is defined by a closed set on the minimum value and open on the maximum value ([min,max)).
- **Attributes:**
  - ID: auto incremental primary key
  - MIN: mínimum value to which the CV calculated by the user could belong.
  - MAX: maximum value to which the CV calculated by the user could belong.
#### CV_INVESTMENT_INTERVALS:
- **Description:** information crossing between CV_INTERVALS and INVESTMENT_INTERVALS tables with the objective of grouping the investments intervals that belong to a CV interval (coefficient of variation).
- **Attributes:**
  - ID: auto incremental primary key.
  - CV_INTERVAL_ID: key that references the ID of CV_INTERVALS table.
  - INVESTMENT_INTERVAL_ID: key that references the ID of INVESTMENT_INTERVALS table.
#### BONUS:
- **Description:** base values for the calculation of users’ bonus
- **Attributes:**
  - ID: auto incremental primary key
  - STD: standard deviation
  - PERCENT: bonus percentage
  - CV_INVESTMENT_INTERVAL_ID: key that references the ID of CV_INVESTMENT_INTERVALS table to indicate the investments and coefficients of variation intervals groupings to which the bonus belongs.
#### UNIT_BONUS:
- **Description:** values defined for a single valid investment or for coefficients of variation less than 0.14 (CV < 0.14)
- **Attributes:**
  - STDV: demographic standard deviation
  - INVESTMENT_INTERVAL_ID: key that references the ID of INVESTMENT_INTERVALS table to indicate the investments interval to which the standard deviation belongs.

### Relations:
#### UNIT_BONUS -> INVESTMENT_INTERVALS
Allows UNIT_BONUS to reuse the intervals to which the STDV belong.
#### CV_INVESTMENT_INTERVALS -> INVESTMENT_INTERVALS Y CV_INVESTMENT_INTERVALS -> CV_INTERVALS
Allows the N:M relation between CV_INVESTMENT_INTERVALS and CV_INTERVALS tables.
#### BONUS -> CV_INVESTMENT_INTERVALS
Allows to capture the bonus data which simultaneously belong to an investments interval and to a coefficients of variation.
#### INVESTMENT -> USERS
Links the investments to the users that execute them.

#### Test(s)
The requested tests were integrated with `RSpec` in an iterative manner through the comparison of the response array with the expected array. Additionally, a users’ manufacturer is provided with its respective investments with the help of `FactoryBot` in order to pass test users’ making the corresponding changes.
