CREATE OR REPLACE FUNCTION bonus_calculation(idUsuario integer)
RETURNS TABLE(LOWER_LIMIT FLOAT, UPPER_LIMIT FLOAT, BONUS FLOAT) AS
$$
DECLARE
  valid_number_of_investments  INTEGER;
  average                FLOAT;
  standard_deviation    FLOAT;
  cv_interval            RECORD;
  cv                     FLOAT;
  investment_interval    RECORD;
BEGIN
  -- Number of investments from user with id = user_id
  SELECT COUNT(*) INTO valid_number_of_investments FROM USERS U, INVESTMENTS I WHERE U.ID = I.USER_ID AND U.ID = idUsuario AND I.AMOUNT - I.WALLET_AMOUNT > 3000;
   --In case the user doesn't have any investments
   IF valid_number_of_investments = 0 THEN
    return QUERY SELECT NULL::FLOAT, NULL::FLOAT, NULL::FLOAT;
   END IF;
   --average calculated with the sumatory of (amount-wallet_amount) and the number of valid_number_of_investments
   SELECT AVG(I.AMOUNT - I.WALLET_AMOUNT) INTO average FROM USERS U, INVESTMENTS I WHERE U.ID = I.USER_ID AND U.ID = idUsuario AND I.AMOUNT - I.WALLET_AMOUNT > 3000;
   --standard_deviation sqrt(sum[(xi - average)^2]/valid_number_of_investments) xi = each value (amount - wallet_amount)
   SELECT SQRT(SUM(POW(I.AMOUNT - I.WALLET_AMOUNT - (SELECT AVG(I.AMOUNT - I.WALLET_AMOUNT) FROM USERS U, INVESTMENTS I WHERE U.ID = I.USER_ID AND U.ID = idUsuario AND I.AMOUNT - I.WALLET_AMOUNT > 3000),2))/valid_number_of_investments) INTO standard_deviation FROM USERS U, INVESTMENTS I WHERE U.ID = I.USER_ID AND U.ID = idUsuario AND I.AMOUNT - I.WALLET_AMOUNT > 3000;
   --Look for cv on cv_interval taking into account cv = standard_deviation/average
   cv := standard_deviation/average;
   SELECT * INTO cv_interval FROM CV_INTERVALS CI WHERE (cv > MIN AND cv <= MAX) OR(cv > MIN AND MAX IS NULL) OR (MIN IS NULL AND cv <= MAX) LIMIT 1;
   -- Search investment_interval for average. 1 for 1st collection of intervals
   SELECT * INTO investment_interval FROM INVESTMENT_INTERVALS WHERE ((average BETWEEN MIN AND MAX) OR (MIN IS NULL AND average < MAX) OR (MIN < average AND MAX IS NULL)) AND COLLECTION = 1 LIMIT 1;
   -- If there's not a cv_interval for the calculated cv (standard_deviation/average). For example cv < 0.14
   IF CV_INTERVAL IS NULL THEN
    -- recalculate standard_deviation with other options
    SELECT stdv INTO standard_deviation FROM UNIT_BONUS WHERE INVESTMENT_INTERVAL_ID = investment_interval.id;
    -- recalculate cv_interval with a value less than 1.3 and greater than 0.3, for example, 0.31
    cv := 0.31;
    SELECT * INTO cv_interval FROM CV_INTERVALS CI WHERE (cv > MIN AND cv <= MAX) OR(cv > MIN AND MAX IS NULL) OR (MIN IS NULL AND cv <= MAX) LIMIT 1;
   END IF;
   -- select deviation values with percentages that correspond to cv_interval and investment_interval with std order and uilding a result with standard_deviation in order to function
   RETURN QUERY SELECT CAST(TO_CHAR(B.STD * standard_deviation::FLOAT,'FM999999990.00') AS FLOAT) LOWER_LIMIT,CAST(TO_CHAR(((SELECT MIN(B2.STD) FROM BONUS B2 WHERE B2.CV_INVESTMENT_INTERVAL_ID = (SELECT ID FROM CV_INVESTMENT_INTERVALS WHERE CV_INTERVAL_ID = cv_interval.id AND INVESTMENT_INTERVAL_ID = investment_interval.id) AND B2.STD > B.STD) * standard_deviation - 0.01)::FLOAT,'FM999999990.00') AS FLOAT) UPPER_LIMIT, B.PERCENT BONUS FROM BONUS B WHERE B.cv_investment_interval_id = (SELECT ID FROM CV_INVESTMENT_INTERVALS WHERE CV_INTERVAL_ID = cv_interval.id AND INVESTMENT_INTERVAL_ID = investment_interval.id) ORDER BY B.STD;
END
$$
LANGUAGE plpgsql;
