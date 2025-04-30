-- Question 8: Identify Branches with Highest Revenue Decline Year-Over-Year
-- Which branches experiences the largest decrease in revenue compared to the previous year?

-- All branches and all years with decrease in revenue from previous year, not including 2019 (year 0)
WITH cte AS (
    SELECT
        branch,
        EXTRACT (YEAR FROM to_date(date, 'DD/MM/YYYY')) as year,
        SUM(total_price) as revenue
    FROM walmart_sales
    GROUP BY 1, 2
),
main_cte AS (
    SELECT 
        * ,
        LAG(revenue, 1) OVER(PARTITION BY branch ORDER BY branch, year) as previous,
        ((revenue - (LAG(revenue, 1) OVER(PARTITION BY branch ORDER BY branch, year))) / 
        (LAG(revenue, 1) OVER(PARTITION BY branch ORDER BY branch, year))) * 100.0 as rev_diff
    FROM cte
    ORDER BY branch, year
),
second_cte AS (
    SELECT
        branch,
        year,
        revenue,
        previous,
        rev_diff,
        RANK() OVER(PARTITION BY branch ORDER BY rev_diff) as rank
    FROM main_cte
    WHERE year IN ('20', '21', '22', '23')
    ORDER BY 1, 5
)
SELECT *
FROM second_cte
WHERE rev_diff < 0