-- Question 2: Identify Highest Rated Categories in each branch.
-- Which categories have the highest average rating in each branch?

WITH cte AS (
    SELECT
        branch,
        category,
        AVG(rating) AS average_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart_sales
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC
)
SELECT
    branch,
    category,
    average_rating
FROM cte
WHERE rank = 1
ORDER BY 1
;