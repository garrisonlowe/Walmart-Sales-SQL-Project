
-- Question 7: Analyze sales shifts throughout the day
-- How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?


SELECT 
    branch,
    COUNT(*) as transactions,
    CASE 
        WHEN EXTRACT(HOUR from (time::time)) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR from (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as time_of_day
FROM walmart_sales
GROUP BY 1, 3
ORDER BY 1, 3