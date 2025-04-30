# Walmart Sales Data Analysis Project

This SQL project analyzes Walmart's sales data to derive meaningful business insights.

## Project Overview

An analysis of Walmart's sales data using SQL to uncover patterns, trends, and key performance indicators that can drive business decisions.

### Project Description

This project utilizes SQL to analyze Walmart's sales data, focusing on:

- Revenue trends across branches and categories.
- Identifying best-selling product categories.
- Sales performance by time, city, and payment method.
- Analyzing peak sales periods and customer buying patterns.
- Profit margin analysis by branch and category.

### Dataset Description

```sql
CREATE TABLE IF NOT EXISTS public.walmart_sales
(
    invoice_id bigint,
    branch text COLLATE pg_catalog."default",
    city text COLLATE pg_catalog."default",
    category text COLLATE pg_catalog."default",
    unit_price double precision,
    quantity double precision,
    date text COLLATE pg_catalog."default",
    "time" text COLLATE pg_catalog."default",
    payment_method text COLLATE pg_catalog."default",
    rating double precision,
    profit_margin double precision,
    total_price double precision
)
```

**Sample of Dataset:**

| invoice_id | branch | city | category | unit_price | quantity | date | time | payment_method | rating | profit_margin | total_price |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | WALM003 | San Antonio | Health and beauty | 74.69 | 7 | 05/01/19 | 13:08:00 | E-wallet | 9.1 | 0.48 | 522.83 |
| 2 | WALM048 | Harlingen | Electronic accessories | 15.28 | 5 | 08/03/19 | 10:29:00 | Cash | 9.6 | 0.48 | 76.4 |
| 3 | WALM067 | Haltom City | Home and lifestyle | 46.33 | 7 | 03/03/19 | 13:23:00 | Credit card | 7.4 | 0.33 | 324.31 |
| 4 | WALM064 | Bedford | Health and beauty | 58.22 | 8 | 27/01/19 | 20:33:00 | E-wallet | 8.4 | 0.33 | 465.76 |
| 5 | WALM013 | Irving | Sports and travel | 86.31 | 7 | 08/02/19 | 10:37:00 | E-wallet | 5.3 | 0.48 | 604.17 |

### SQL Skills Demonstrated

- Aggregations and Grouping
- Window Functions
- Common Table Expressions (CTEs)
- Joins and Subqueries
- Data Cleaning and Transformation

## Data Ingestion

**Python Requirements**

```python
import pandas as pd
import numpy as np
import kaggle as kaggle
import psycopg2
from sqlalchemy import create_engine
import _mysql_connector
```

**Kaggle API call to retrieve dataset**

```python
kaggle.api.authenticate()
# Load the dataset from Kaggle
dataset_path = kaggle.api.dataset_download_files('najir0123/walmart-10k-sales-datasets', path='.', unzip=True)

```

## Data Cleaning

We’ll start by checking for duplicate records.

```python
# Checking for duplicated rows
df.duplicated().sum()

# Dropping the duplicated records
df.drop_duplicates(inplace=True)
```

We can now check for null values per column.

```python
df.isnull().sum()
```

| Column | Null Count |
| --- | --- |
| invoice_id | 0 |
| Branch | 0 |
| City | 0 |
| category | 0 |
| unit_price | 31 |
| quantity | 31 |
| date | 0 |
| time | 0 |
| payment_method | 0 |
| rating | 0 |
| profit_margin | 0 |

We can now drop these rows as they are useless to us.

```python
df.dropna(inplace=True)
```

Next, we want to remove the ‘$’ symbol from the `unit_price` column.

```python
# Remove the '$' sign and convert 'unit_price' to float
df['unit_price'] = df['unit_price'].str.replace('$','').astype(float)
```

Changing Ewallet to E-Wallet for better readability.

```python
# Changing 'Ewallet' to 'E-wallet'
df['payment_method'] = df['payment_method'].str.replace('Ewallet', 'E-wallet')
df['payment_method'].unique().tolist()
```

Next, let’s create a `total_price` column using the `unit_price` and the `quantity`

```python
df['Total_Price'] = (df['unit_price'] * df['quantity']).round(2)
df.head()
```

Now, we can change the column names to be all lowercase to avoid future issues with PostgreSQL.

```python
df.columns = df.columns.str.lower()
df.head()
```

Lastly, let’s export the clean data as a csv file.

```python
df.to_csv('walmart_sales_cleaned.csv', index=False)
```

### Loading data into PostgreSQL

For this, we will utilize `SQLAlchemy` and `create_engine` libraries in a `Try/Except` block.

```python
try:
    # Create a connection string
    conn_string = f"postgresql://{user}:{password}@{host}:{port}/{database}"
    
    # Create a SQLAlchemy engine
    engine = create_engine(conn_string)
    
    # Load the DataFrame into the PostgreSQL database
    df.to_sql('walmart_sales', engine, if_exists='replace', index=False)
    
    print("Data loaded successfully into PostgreSQL database.")
except Exception as e:
    print("Error loading data into PostgreSQL database:", e)
```

## Data Analysis

For this portion of the project we are going to be answering 10 business questions using SQL in our PostgreSQL database, each question is roughly increasing difficulty.

**Business Questions**

1. What are the different payment methods used by customers? And how many items were purchased using each payment method?
2. Which categories have the highest average rating in each branch?
3. What is the busiest day of the week for each branch based on the transaction volume?
4. What are the minimum, average, and maximum ratings for each category in each city?
5. What is the total profit for each category, ranked from highest to lowest?
6. What is the most frequently used payment method in each branch?
7. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
8. Which branches experiences the largest decrease in revenue compared to the previous year?

### Question 1

What are the different payment methods used by customers? And how many items were purchased using each payment method?

```sql
-- Types of Payment Methods
SELECT 
    DISTINCT payment_method
FROM walmart_sales;
```

|  | Payment Method |
| --- | --- |
| 1 | Credit card |
| 2 | E-wallet |
| 3 | Cash |

```sql
SELECT
	payment_method,
	COUNT(*) AS items_purchased
FROM walmart_sales
GROUP BY 1;
```

| Payment Method | Items Purchased |
| --- | --- |
| Credit card | 4256 |
| E-wallet | 3881 |
| Cash | 1832 |

### Question 2

Which categories have the highest average rating in each branch?

```sql
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
```

| Branch | Category | Average Rating |
| --- | --- | --- |
| WALM001 | Electronic accessories | 7.45 |
| WALM002 | Food and beverages | 8.25 |
| WALM003 | Sports and travel | 7.50 |
| WALM004 | Food and beverages | 9.30 |
| WALM005 | Health and beauty | 8.37 |

### Question 3

What is the busiest day of the week for each branch based on the transaction volume?

```sql
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
```

| Branch | Day | Transactions |
| --- | --- | --- |
| WALM001 | Thursday | 16 |
| WALM002 | Thursday | 15 |
| WALM003 | Tuesday | 33 |
| WALM004 | Sunday | 14 |
| WALM005 | Wednesday | 19 |

### Question 4

What are the minimum, average, and maximum ratings for each category in each city?

```sql
SELECT
    city,
    category,
    AVG(rating) as avg_rating,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating
FROM walmart_sales
GROUP BY 1, 2
ORDER BY 1, 2 DESC
```

| City | Category | Average Rating | Min Rating | Max Rating |
| --- | --- | --- | --- | --- |
| Abilene | Home and lifestyle | 6.10 | 4 | 9 |
| Abilene | Health and beauty | 9.70 | 9.7 | 9.7 |
| Abilene | Food and beverages | 6.95 | 6 | 8.9 |
| Abilene | Fashion accessories | 6.24 | 4 | 9 |
| Abilene | Electronic accessories | 7.97 | 7.1 | 8.8 |

### Question 5

What is the total profit for each category, ranked from highest to lowest?

```sql
SELECT 
    category,
    SUM(profit_margin * total_price) as profit
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC

```

| Category | Profit ($) |
| --- | --- |
| Fashion accessories | 192,314.89 |
| Home and lifestyle | 192,213.64 |
| Electronic accessories | 30,772.49 |
| Food and beverages | 21,552.86 |
| Sports and travel | 20,613.81 |
| Health and beauty | 18,671.73 |

### Question 6

What is the most frequently used payment method in each branch?

```sql
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
```

| Branch | Payment Method |
| --- | --- |
| WALM001 | E-wallet |
| WALM002 | E-wallet |
| WALM003 | Credit card |
| WALM004 | E-wallet |
| WALM005 | E-wallet |

### Question 7

How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

```sql
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
```

| Branch | Transactions | Time of Day |
| --- | --- | --- |
| WALM001 | 36 | Afternoon |
| WALM001 | 30 | Evening |
| WALM001 | 8 | Morning |
| WALM002 | 29 | Afternoon |
| WALM002 | 21 | Evening |
| WALM002 | 15 | Morning |
| WALM003 | 95 | Afternoon |
| WALM003 | 41 | Evening |

### Question 8

Which branches experiences the largest decrease in revenue compared to the previous year?

```sql
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
```

| Branch | Year | Revenue | Previous Revenue | Decrease (%) | Rank |
| --- | --- | --- | --- | --- | --- |
| WALM001 | 20 | 1814 | 3671.68 | -50.59% | 1 |
| WALM001 | 22 | 1488 | 1789 | -16.83% | 2 |
| WALM001 | 23 | 1463 | 1488 | -1.68% | 3 |
| WALM001 | 21 | 1789 | 1814 | -1.38% | 4 |
| WALM002 | 20 | 937 | 2161.12 | -56.64% | 1 |
| WALM002 | 22 | 1169 | 1895 | -38.31% | 2 |
| WALM003 | 20 | 4822 | 6773.56 | -28.81% | 1 |
| WALM003 | 21 | 4178 | 4822 | -13.36% | 2 |
| WALM004 | 23 | 958 | 1337 | -28.35% | 1 |
| WALM004 | 22 | 1337 | 1571 | -14.89% | 2 |

### Question 9

Calculate monthly total revenue for each branch.

```sql
WITH cte AS (
    SELECT 
        branch,
        EXTRACT(MONTH FROM TO_DATE(date, 'DD/MM/YYYY')) as month,
        EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YYYY')) as year,
        SUM(total_price) as total_revenue
    FROM walmart_sales
    GROUP BY 1, 3, 2
    ORDER BY 1, 3, 2
), cte2 as (
    SELECT
        *,
        lag(total_revenue) OVER(PARTITION BY branch, year ORDER BY month) as previous_month_rev,
        CASE 
            WHEN lag(total_revenue) OVER(PARTITION BY branch, year ORDER BY month) IS NULL THEN NULL
            ELSE ((total_revenue - lag(total_revenue) OVER(PARTITION BY branch, year ORDER BY month)) / lag(total_revenue) OVER(PARTITION BY branch, year ORDER BY month)) * 100.0
        END as difference
    FROM cte
    ORDER BY branch, year, month
)
SELECT 
    branch,
    month,
    year,
    ROUND(CAST(total_revenue AS numeric), 2) as total_revenue,
    CONCAT(ROUND(CAST(difference AS numeric), 1), '%') as MTM_growth_rate
FROM cte2
```

| Branch | Month | Year | Revenue | Growth |
| --- | --- | --- | --- | --- |
| WALM001 | 1 | 19 | 1476.68 | - |
| WALM001 | 3 | 19 | 2195.00 | 48.6% |
| WALM001 | 1 | 20 | 30.00 | -98.6% |
| WALM001 | 2 | 20 | 82.00 | 173.3% |
| WALM001 | 4 | 20 | 54.00 | -34.1% |
| WALM001 | 5 | 20 | 149.00 | 175.9% |
| WALM001 | 6 | 20 | 68.00 | -54.4% |
| WALM001 | 8 | 20 | 102.00 | 50.0% |
| WALM001 | 9 | 20 | 433.00 | 324.5% |
| WALM001 | 10 | 20 | 84.00 | -80.6% |
| WALM001 | 12 | 20 | 812.00 | 866.7% |
| WALM001 | 2 | 21 | 189.00 | -76.7% |
| WALM001 | 3 | 21 | 26.00 | -86.2% |
| WALM001 | 4 | 21 | 49.00 | 88.5% |
| WALM001 | 5 | 21 | 72.00 | 46.9% |
| WALM001 | 7 | 21 | 27.00 | -62.5% |
| WALM001 | 8 | 21 | 261.00 | 866.7% |
| WALM001 | 9 | 21 | 313.00 | 19.9% |
| WALM001 | 10 | 21 | 257.00 | -17.9% |
| WALM001 | 11 | 21 | 197.00 | -23.3% |