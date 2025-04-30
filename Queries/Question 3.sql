-- Question 3: Determine the busiest day for each branch.
-- What is the busiest day of the week for each branch based on the transaction volume?

WITH cte AS (
    SELECT
        branch,
        to_char(to_date(date, 'DD/MM/YYYY'), 'Day') as day_name,
        COUNT(*) as total_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
    FROM walmart_sales
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC
)
SELECT 
    branch,
    day_name,
    total_transactions
FROM cte
WHERE rank = 1
;