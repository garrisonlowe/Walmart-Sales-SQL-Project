-- Question 1: Analyze Payment Methods
-- What are the different payment methods used by customers? And how many items were purchased using each payment method?


-- Types of Payment Methods
SELECT 
    DISTINCT payment_method
FROM walmart_sales;

-- Count of Items Purchased by each Payment Method
SELECT 
    payment_method, 
    COUNT(*) AS items_purchased
FROM walmart_sales
GROUP BY 1;

