
-- Question 6: Determine the most common payment method for each branch.
-- What is the most frequently used payment method in each branch?


SELECT
    branch,
    payment_method
FROM (
    SELECT
        branch,
        payment_method,
        COUNT(*) as count,
        RANK() OVER(PARTITION BY branch ORDER BY count(*) DESC) as rank
    FROM walmart_sales
    GROUP BY 1, 2

) a 
WHERE rank = 1
ORDER BY 1