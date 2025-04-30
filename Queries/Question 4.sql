-- Question 4: Analyze Category Ratings by City
-- What are the minimum, average, and maximum ratings for each category in each city?

SELECT
    city,
    category,
    AVG(rating) as avg_rating,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating
FROM walmart_sales
GROUP BY 1, 2
ORDER BY 1, 2 DESC