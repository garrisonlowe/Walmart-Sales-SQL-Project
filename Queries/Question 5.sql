
-- Question 5: Calculate Total Profit by Category
-- What is the total profit for each category, ranked from highest to lowest?

SELECT 
    category,
    SUM(profit_margin * total_price) as profit
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
