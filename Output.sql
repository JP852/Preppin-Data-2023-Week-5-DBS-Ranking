
-- Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
-- Change transaction date to the just be the month of the transaction
-- Total up the transaction values so you have one row for each bank and month combination
-- Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
-- Without losing all of the other data fields, find:
--     - The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
--     - The average transaction value per rank, call this field 'Avg Transaction Value per Rank'


WITH CTE AS(
  
SELECT
    SUM(VALUE) AS SUM_OF_VALUE
    ,IFF(LENGTH(transaction_code) = 15,LEFT(transaction_code,3),LEFT(transaction_code,2)) AS BANK
    ,MONTHNAME(DATE(transaction_date,'dd/MM/yyyy hh24:mi:ss')) as MONTH
    ,RANK() OVER(PARTITION BY MONTHNAME(DATE(transaction_date,'dd/MM/yyyy hh24:mi:ss')) ORDER BY SUM(value) DESC)  AS RANK
      FROM PD2023_WK01
        GROUP BY BANK,MONTH)
    ,AVG_RANK AS(
SELECT 
    BANK
    ,AVG(RANK) AS AVG_RANK_ACROSS_ALL_MONTHS
      FROM CTE 
        GROUP BY BANK)
    ,AVG_RANK_VALUE AS(
SELECT 
    RANK
    ,AVG(SUM_OF_VALUE) AS Avg_Transaction_per_Rank
      FROM CTE
        GROUP BY RANK)
SELECT 
    C.* 
    ,AVG_RANK_ACROSS_ALL_MONTHS AS AVG_RANK_PER_BANK
    ,Avg_Transaction_per_Rank AS Avg_Transaction_value_per_Rank
      FROM CTE AS C
        INNER JOIN AVG_RANK AS AR
        ON C.BANK = AR.BANK
        INNER JOIN AVG_RANK_VALUE AS AVR
        ON AVR.RANK = C.RANK
