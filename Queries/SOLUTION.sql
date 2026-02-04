-- Comprehensive SQL analytics project using the Zomato dataset to analyze customer behavior, revenue trends,
-- restaurant performance, rider efficiency, churn, and operational insights with CTEs and window functions.


-- Question 1:
-- Determine the top three most frequently ordered dishes by the customer Indrajit Gara over the last 12 months, based on total order frequency.
SELECT customer_name,
       dishes,
       Total_orders
       FROM
(SELECT c.customer_id,
       c.customer_name,
       o.order_item dishes,
       Count(*) Total_orders,
       DENSE_RANK() OVER(ORDER BY Count(*)) as Ranks
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL 1 YEAR 
      AND
      c.customer_name = "Indrajit Gara"
GROUP BY 1,2,3
ORDER BY 4 DESC) as t
WHERE Ranks <= 3
limit 3;

-- Insight:
-- The customer Indrajit Gara shows a clear preference for a small set of dishes, with multiple items having the same highest order frequency.
-- This indicates consistent repeat ordering behavior, suggesting strong customer loyalty toward specific menu items.

-- Business Use Case:
-- Restaurants can bundle these top dishes or offer personalized discounts to increase retention.
-- These dishes can be prioritized in inventory planning and recommendation systems to optimize sales.


-- Question 2:
-- Popular Time Slots
-- Question: Analyze order volume distribution across 2-hour time slots to identify peak ordering periods on the Zomato platform.

SELECT 
	  FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 as Start_Time,
      FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 + 2 as End_Time,
      COUNT(*) as Total_Order
FROM orders
GROUP BY 1,2
ORDER BY 3 DESC;

-- Insight:
-- Order volume peaks during the 14:00–16:00 and 20:00–22:00 time slots, indicating strong demand during lunch and late-evening hours on the Zomato platform.
-- Business Impact for Zomato:
-- These peak windows can be leveraged for dynamic pricing, flash offers, and restaurant promotions.
-- Zomato can optimize delivery partner allocation and ETA predictions during high-demand periods to improve customer experience.


-- Question 3:
-- Evaluate the Average Order Value (AOV) of customers on the Zomato platform who have placed more than 20 orders,
-- and rank these high-frequency customers based on their AOV.

SELECT 
	   C.customer_name,
       ROUND(avg(o.total_amount),2) aov
FROM orders o
JOIN customers c
on o.customer_id = c.customer_id
GROUP BY 1
HAVING COUNT(order_id) > 20
ORDER BY 2 DESC;

-- Insight:
-- Customers with more than 20 orders demonstrate consistently higher Average Order Value,
-- indicating that repeat customers contribute disproportionately to overall revenue on Zomato.

-- Business Impact for Zomato:
-- Such users can be tagged as High-Value Customers (HVCs).
-- Zomato can design personalized recommendations, premium memberships (Zomato Gold), and upsell strategies to further increase Customer Lifetime Value (CLV).
-- Reinforces the strategy that customer retention drives sustainable revenue growth more effectively than one-time acquisition.


-- Question 4:
-- Identify high-value customers on the Zomato platform who have spent more than ₹5,000 on food orders, and rank them based on their total lifetime spend.

SELECT 
    c.customer_name,
    c.customer_id,
    ROUND(SUM(o.total_amount),0) AS total_amount
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_name,
    c.customer_id
HAVING SUM(o.total_amount) > 5000
ORDER BY total_amount DESC
LIMIT 5;

-- Insight:
-- A small group of customers contributes significantly to total revenue, with each spending over ₹5,000 on food orders.
-- This highlights the presence of high-value users who drive disproportionate revenue on the Zomato platform.
-- Business Impact for Zomato:
-- These users can be tagged as VIP / Power Users
-- Ideal targets for Zomato Gold, exclusive coupons, and priority delivery
-- Helps Zomato focus on CLV (Customer Lifetime Value) rather than only order volume


-- Question 5:
-- Identify restaurants on the Zomato platform with orders that were placed but not delivered,
-- and analyze the volume of non-delivered orders at the restaurant level.

SELECT 
    r.restaurant_name,
    COUNT(o.order_id) AS cnt_not_delivered_orders
FROM
    orders o
        LEFT JOIN
    restaurants r ON o.restaurant_id = r.restaurant_id
        LEFT JOIN
    deliveries d ON o.order_id = d.order_id
WHERE
    d.delivery_id IS NULL
GROUP BY 1
ORDER BY 2 DESC;

-- Insight:
-- Certain restaurants show a significantly higher number of non-delivered orders, indicating potential operational bottlenecks,
-- delivery partner shortages, or restaurant-level inefficiencies.

-- Business Impact for Zomato:
-- These restaurants can be flagged for operational audits.
-- Zomato can optimize delivery partner allocation, ETA accuracy, and restaurant onboarding quality checks.
-- Reducing non-delivered orders directly improves customer trust, platform ratings, and repeat usage.


-- Question 6:
--  Rank restaurants on the Zomato platform by their total revenue generated over the past year,
-- and identify the top-revenue-generating restaurant within each city.

SELECT 
    city,
    restaurant_id,
    restaurant_name,
    Total_Rev
FROM (
    SELECT
        r.city,
        r.restaurant_id,
        r.restaurant_name,
        ROUND(SUM(o.total_amount), 0) AS Total_Rev,
        RANK() OVER (
            PARTITION BY r.city 
            ORDER BY ROUND(SUM(o.total_amount), 0) DESC
        ) AS Ranks
    FROM orders o
    JOIN restaurants r 
        ON o.restaurant_id = r.restaurant_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL 1 YEAR
    GROUP BY r.city, r.restaurant_id, r.restaurant_name
) Restaurant_Revenue_Ranking
WHERE Ranks = 1
ORDER BY city;

-- 📊 Business Insight (Revenue & City Performance)

-- Insight:
-- Each city has a distinct top-revenue-generating restaurant,
-- indicating that revenue leadership is highly localized rather than dominated by a single national player.

-- Business Impact for Zomato:
-- Zomato can feature top-earning restaurants in each city for promotions and visibility boosts
-- Helps identify city-wise flagship partners
-- Useful for commission optimization, premium placement, and partnership strategy


-- Question 7:
-- Identify the most popular dish in each city on the Zomato platform based on total order volume, to understand regional food preferences.

SELECT city, order_item, Total_Orders
FROM (
    SELECT 
        r.city,
        o.order_item,
        COUNT(o.order_id) AS Total_Orders,
        RANK() OVER (
            PARTITION BY r.city 
            ORDER BY COUNT(o.order_id) DESC
        ) AS Rank_by_city
    FROM restaurants r
    JOIN orders o 
        ON r.restaurant_id = o.restaurant_id
    GROUP BY r.city, o.order_item
) ranked_data
WHERE Rank_by_city = 1
ORDER BY city;

-- 📊 Business Insight (City-Level Demand Analytics)

-- Insight:
-- Food preferences vary significantly across cities, with different dishes dominating order volumes in different regions.
-- This highlights strong regional taste patterns among Zomato users.

-- Business Impact for Zomato:
-- Enables city-specific menu recommendations and personalized home screens
-- Helps Zomato run localized marketing campaigns (e.g., “Mumbai loves Idli Sambar”)
-- Assists restaurant partners in menu optimization based on city demand


-- Question 8:
-- Identify customers on the Zomato platform who were active in 2024 but have not placed any orders in 2025, to analyze potential customer churn.
 
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2024
  AND NOT EXISTS (
        SELECT 1
        FROM orders o2
        WHERE o2.customer_id = o.customer_id
          AND EXTRACT(YEAR FROM o2.order_date) = 2025
  )
ORDER BY 1;

-- 📊 Business Insight (Churn & Retention Focused)

-- Insight:
-- A significant set of customers who were previously active did not return in the following year,
-- indicating potential churn driven by experience, pricing sensitivity, or competitive alternatives.

-- Business Impact for Zomato:
-- These users can be targeted with win-back campaigns, personalized offers, or reactivation notifications.
-- Helps Zomato quantify year-over-year retention gaps and prioritize retention strategies over acquisition.
-- Inputs directly into CLV and cohort analysis.


-- Question 9:
-- Analyze and compare year-over-year order cancellation rates for restaurants on the Zomato platform to identify operational performance trends

WITH cancellation_data_25 AS (
    SELECT
        o.restaurant_id,
        r.restaurant_name,
        COUNT(o.order_id) AS total_orders,
        SUM(
            CASE
                WHEN d.delivery_id IS NULL THEN 1
                ELSE 0
            END
        ) AS cancelled_orders
    FROM orders o
    LEFT JOIN deliveries d
        ON o.order_id = d.order_id
    LEFT JOIN restaurants r
        ON o.restaurant_id = r.restaurant_id
    WHERE YEAR(o.order_date) = 2025
    GROUP BY
        o.restaurant_id,
        r.restaurant_name
),
Last_Year_Data AS (
    SELECT
        restaurant_id,
        restaurant_name,
        total_orders,
        cancelled_orders,
        ROUND((cancelled_orders / NULLIF(total_orders, 0)) * 100, 2) AS cancellation_rate_2025
    FROM cancellation_data_25
),
cancellation_data_26 AS (
    SELECT
        o.restaurant_id,
        r.restaurant_name,
        COUNT(o.order_id) AS total_orders,
        SUM(
            CASE
                WHEN d.delivery_id IS NULL THEN 1
                ELSE 0
            END
        ) AS cancelled_orders
    FROM orders o
    LEFT JOIN deliveries d
        ON o.order_id = d.order_id
    LEFT JOIN restaurants r
        ON o.restaurant_id = r.restaurant_id
    WHERE YEAR(o.order_date) = 2026
    GROUP BY
        o.restaurant_id,
        r.restaurant_name
),
Current_Year_Data AS (
    SELECT
        restaurant_id,
        restaurant_name,
        total_orders,
        cancelled_orders,
        ROUND((cancelled_orders / NULLIF(total_orders, 0)) * 100, 2) AS cancellation_rate_2026
    FROM cancellation_data_26
)
SELECT
    l.restaurant_id,
    l.restaurant_name,
    l.cancellation_rate_2025,
    c.cancellation_rate_2026,
    ROUND(
        c.cancellation_rate_2026 - l.cancellation_rate_2025,
        2
    ) AS rate_difference
FROM Last_Year_Data l
LEFT JOIN Current_Year_Data c
    ON l.restaurant_id = c.restaurant_id;

-- 📊 Business Insight (Operations & Quality Control)

-- Insight:
-- Cancellation rates vary significantly across restaurants year-over-year, with some showing clear improvement while others experience an increase.
-- This highlights inconsistent operational reliability at the restaurant level.

-- Business Impact for Zomato:
-- Restaurants with rising cancellation rates can be flagged for operational audits or delivery partner realignment.
-- Restaurants with improving trends can be rewarded with higher platform visibility.
-- Cancellation rate trends directly impact customer trust, ratings, and retention.


-- Question 10:
-- Calculate the average delivery time for each delivery partner (rider) on the Zomato platform to evaluate rider performance and delivery efficiency.

SELECT
    r.rider_id,
    r.rider_name,
    SEC_TO_TIME(
        AVG(
            TIMESTAMPDIFF(
                SECOND,
                CONCAT(o.order_date, ' ', o.order_time),
                CONCAT(o.order_date, ' ', d.delivery_time)
            )
        )
    ) AS avg_delivery_time
FROM riders r
JOIN deliveries d
    ON r.rider_id = d.rider_id
JOIN orders o
    ON d.order_id = o.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY
    r.rider_id,
    r.rider_name
ORDER BY
    avg_delivery_time;

-- 📊 Business Insight (Rider Performance & Delivery Efficiency)

-- Insight:
-- Average delivery times are largely consistent across riders, with a small performance gap between the fastest and slowest delivery partners.
-- This indicates a generally stable last-mile delivery operation with minor efficiency variations.

-- Business Impact for Zomato:
-- High-performing riders can be prioritized during peak demand periods and rewarded through incentive programs.
-- Slightly slower riders can be supported with route optimization, workload balancing, or targeted training.
-- Monitoring rider-wise delivery time trends helps improve ETA accuracy, customer satisfaction, and overall delivery SLA compliance.


-- Question 11:
-- Analyze the month-over-month growth ratio of delivered orders for each restaurant on the Zomato platform to evaluate demand trends
-- and restaurant performance over time.

WITH monthly_orders AS (
    SELECT
        o.restaurant_id,
        MAX(r.restaurant_name) AS restaurant_name,
        DATE_FORMAT(o.order_date, '%m-%y') AS month,
        COUNT(o.order_id) AS cnt_orders,
        STR_TO_DATE(DATE_FORMAT(o.order_date, '%Y-%m-01'), '%Y-%m-%d') AS sort_month
    FROM orders o
    JOIN deliveries d
        ON d.order_id = o.order_id
    JOIN restaurants r
        ON r.restaurant_id = o.restaurant_id
    WHERE d.delivery_status = 'Delivered'
    GROUP BY
        o.restaurant_id,
        month,
        sort_month
),
final_data AS (
    SELECT
        restaurant_id,
        restaurant_name,
        month,
        cnt_orders AS current_month_orders,
        sort_month,
        LAG(cnt_orders, 1) OVER (
            PARTITION BY restaurant_id
            ORDER BY sort_month
        ) AS prev_month_orders
    FROM monthly_orders
)
SELECT
    restaurant_id,
    restaurant_name,
    month,
    current_month_orders,
    prev_month_orders,
    ROUND(
        (current_month_orders / NULLIF(prev_month_orders, 0) - 1),
        2
    ) AS growth_ratio
FROM final_data
ORDER BY restaurant_id, sort_month;

-- 📊 Business Insight (Restaurant Growth & Demand Trends)

-- Insight:
-- Monthly order volumes for restaurants show fluctuating growth patterns, with periods of both acceleration and decline.
-- This indicates variability in demand influenced by seasonality, promotions, and restaurant-level operational performance.

-- Business Impact for Zomato:
-- Restaurants with sustained positive growth can be prioritized for premium placements and marketing campaigns.
-- Restaurants experiencing consecutive negative growth can be flagged for intervention through menu optimization or targeted promotions.
-- Monitoring growth ratios enables early detection of declining partners and supports proactive retention and revenue optimization strategies.


-- Question 12:
-- Segment customers on the Zomato platform into ‘Gold’ and ‘Silver’ categories based 
-- on their total spending compared to the overall Average Order Value (AOV), and analyze each segment’s order volume and revenue contribution.

WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.total_amount) AS total_spent,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY
        c.customer_id,
        c.customer_name
),
avg_order_value AS (
    SELECT
        AVG(total_amount) AS aov
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT
    cs.customer_id,
    cs.customer_name,
    cs.total_orders,
    cs.total_spent,
    CASE
        WHEN cs.total_spent >= aov THEN 'Gold'
        ELSE 'Silver'
    END AS segment
FROM customer_spend cs
CROSS JOIN avg_order_value
ORDER BY cs.total_spent DESC;

-- 📊 Business Insight (Customer Segmentation – Gold vs Silver)

-- Insight:
-- The 'Gold' customer segment consists of users with consistently high order frequency and total spending,
-- indicating strong engagement and repeat purchasing behavior. Although this segment represents a smaller portion of the overall customer base, it contributes a disproportionately high share of total revenue.

-- Business Impact for Zomato:
-- 'Gold' customers should be prioritized for premium loyalty programs, personalized offers, and priority delivery benefits to maximize retention and lifetime value.
-- Retaining this segment is critical, as any churn within the Gold group would have a significant impact on overall platform revenue.
-- Behavioral patterns from Gold customers can be used to design upsell strategies and convert high-potential Silver customers into the Gold segment.


-- Question 13:
-- Calculate the monthly earnings of each delivery partner (rider) on the Zomato platform,
-- assuming riders earn a fixed 8% commission per delivered order, to analyze income distribution and rider productivity over time.

SELECT
    r.rider_id,
    r.rider_name,
    DATE_FORMAT(o.order_date, '%Y-%m') AS month_year,
    SUM(o.total_amount * 0.08) AS monthly_earnings
FROM riders r
JOIN deliveries d
    ON r.rider_id = d.rider_id
JOIN orders o
    ON d.order_id = o.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY
    r.rider_id,
    r.rider_name,
    month_year
ORDER BY
    3,4;

-- 📊 Business Insight (Rider Earnings & Incentive Planning)

-- Insight:
-- Monthly earnings of riders vary significantly, reflecting differences in order volume, delivery frequency,
-- and rider engagement levels. Some riders consistently generate higher earnings, indicating stronger productivity and availability.

-- Business Impact for Zomato:
-- High-earning riders can be identified as top performers and rewarded through incentive programs or priority order allocation.
-- Riders with lower or inconsistent monthly earnings may benefit from improved shift allocation, zone optimization, or performance support.
-- Tracking rider earnings over time enables Zomato to design fair payout structures, improve rider retention, and balance supply-demand across regions.


-- Question 14:
-- Analyze rider performance on the Zomato platform by categorizing deliveries into 5-star, 4-star, and 3-star ratings based on delivery time thresholds,
-- and calculate the distribution of ratings for each rider.

WITH delivery_time AS (
    SELECT
        r.rider_id,
        r.rider_name,
        SEC_TO_TIME(
            TIME_TO_SEC(d.delivery_time) - TIME_TO_SEC(o.order_time)
        ) AS total_time
    FROM orders o
    JOIN deliveries d
        ON o.order_id = d.order_id
    JOIN riders r
        ON d.rider_id = r.rider_id
),
rider_rating as (

SELECT
    rider_id,
    rider_name,
    total_time,
    CASE
        WHEN (TIME_TO_SEC(total_time) / 60) < 25 THEN '5 star'
        WHEN (TIME_TO_SEC(total_time) / 60) >= 25
             AND (TIME_TO_SEC(total_time) / 60) < 35 THEN '4 star'
        ELSE '3 star'
    END AS riders_rating
FROM delivery_time)

select rider_id,
    rider_name,
    riders_rating,
    COUNT(riders_rating) rating_count
    from rider_rating
group by 1,2,3
order by 2;

-- 📊 Business Insight (Rider Performance & Quality Control)

-- Insight:
-- Rider ratings based on delivery time show noticeable variation across delivery partners,
-- with some riders consistently achieving higher ratings while others receive a larger share of lower ratings.
-- This reflects differences in delivery efficiency, route familiarity, and workload management.

-- Business Impact for Zomato:
-- Riders with a higher proportion of 5-star ratings can be identified as top performers and rewarded through incentives or priority order allocation.
-- Riders with frequent 3-star ratings can be supported with route optimization, zone reassignment, or targeted training programs.
-- Rating-based performance tracking helps Zomato maintain delivery quality standards and improve overall customer satisfaction.


-- Question 15:
-- Analyze day-wise order frequency for each restaurant on the Zomato platform and 
-- identify the peak ordering day of the week to understand demand patterns.

WITH restaurent_freq_day AS (
    SELECT
        r.restaurant_id,
        r.restaurant_name,
        DAYNAME(o.order_date) AS days,
        COUNT(o.order_id) AS total_order,
        RANK() OVER (
            PARTITION BY r.restaurant_id
            ORDER BY COUNT(o.order_id) DESC
        ) AS day_rank
    FROM orders o
    JOIN restaurants r
        ON o.restaurant_id = r.restaurant_id
    GROUP BY
        1, 2, 3
)
SELECT
    restaurant_id,
    restaurant_name,
    days,
    total_order
FROM restaurent_freq_day
WHERE day_rank = 1
ORDER BY
    1, 4 DESC;

-- 📊 Business Insight (Demand Patterns & Operational Planning)

-- Insight:
-- Order frequency varies significantly across days of the week for different restaurants,
-- with each restaurant exhibiting a distinct peak ordering day.
-- This indicates that customer demand is not uniform and is influenced by weekday-specific consumption patterns.

-- Business Impact for Zomato:
-- Restaurants can optimize staffing, inventory, and preparation capacity based on their identified peak days.
-- Zomato can schedule targeted promotions and push notifications on high-demand days to maximize order volume.
-- Understanding restaurant-specific peak days helps improve delivery planning, reduce order delays, and enhance overall customer experience.


-- Question 16:
-- Calculate the Customer Lifetime Value (CLV) for each customer on the Zomato platform by measuring the total revenue generated across all their orders,
-- and identify high-value customers.

SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY
    total_revenue DESC;

-- 📊 Business Insight (Customer Lifetime Value & Retention Strategy)

-- Insight:
-- Customer lifetime value varies significantly across users, with a small group of customers contributing a disproportionately large share of total revenue.
-- These high-CLV customers demonstrate strong loyalty and repeat purchasing behavior.

-- Business Impact for Zomato:
-- High-CLV customers should be prioritized for retention through loyalty programs, personalized offers, and premium benefits.
-- Protecting this segment from churn is critical, as losing even a small number of high-CLV users can materially impact overall revenue.
-- CLV-based segmentation enables Zomato to optimize marketing spend by focusing on long-term value rather than short-term order volume.


-- Question 17:
-- Analyze month-over-month sales performance on the Zomato platform by comparing each month’s total revenue
-- with the previous month to identify growth or decline trends.
 
SELECT
    month_year,
    prev_month_rev,
    current_month_revenue,
    CASE
        WHEN prev_month_rev IS NULL THEN 'No Previous Data'
        WHEN current_month_revenue > prev_month_rev THEN 'Increase'
        WHEN current_month_revenue < prev_month_rev THEN 'Decrease'
        ELSE 'No Change'
    END AS sales_trend
FROM (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month_year,
        SUM(o.total_amount) AS current_month_revenue,
        LAG(SUM(o.total_amount), 1) OVER (
            ORDER BY DATE_FORMAT(o.order_date, '%Y-%m')
        ) AS prev_month_rev
    FROM orders o
    GROUP BY month_year
) t
ORDER BY month_year;

-- 📊 Business Insight (Monthly Sales Trends & Revenue Momentum)

-- Insight:
-- Monthly sales exhibit a consistent upward trend, with revenue increasing steadily across consecutive months.
-- The lack of significant declines indicates strong customer demand and sustained platform engagement.

-- Business Impact for Zomato:
-- Consistent revenue growth reflects effective customer retention, successful restaurant partnerships, and stable delivery operations.
-- This positive momentum allows Zomato to confidently scale marketing efforts, onboard new restaurants, and expand delivery capacity.
-- Monitoring month-over-month sales trends supports accurate revenue forecasting and proactive business planning.


-- Question 18:
-- Evaluate rider efficiency on the Zomato platform by analyzing average delivery times
-- and identifying the most efficient (fastest) and least efficient (slowest) delivery partners.

WITH avg_time AS (
    SELECT
        r.rider_id,
        r.rider_name,
        AVG(
            TIME_TO_SEC(d.delivery_time) - TIME_TO_SEC(o.order_time)
        ) AS avg_delivery_seconds
    FROM orders o
    JOIN deliveries d
        ON o.order_id = d.order_id
    JOIN riders r
        ON r.rider_id = d.rider_id
    GROUP BY
        r.rider_id,
        r.rider_name
)

SELECT
    rider_id,
    rider_name,
    SEC_TO_TIME(avg_delivery_seconds) AS avg_delivery_time,
    CASE
        WHEN avg_delivery_seconds = (
            SELECT MIN(avg_delivery_seconds) FROM avg_time
        ) THEN 'Most Efficient (Fastest)'
        WHEN avg_delivery_seconds = (
            SELECT MAX(avg_delivery_seconds) FROM avg_time
        ) THEN 'Least Efficient (Slowest)'
        ELSE 'Average'
    END AS rider_efficiency
FROM avg_time;

-- 📊 Business Insight (Rider Performance & Operational Efficiency)

-- Insight:
-- Average delivery times across riders fall within a relatively narrow range, indicating consistent delivery performance overall.
-- However, distinct fastest and slowest riders can still be identified, highlighting measurable efficiency differences at the individual level.

-- Business Impact for Zomato:
-- Most efficient riders can be rewarded with incentives and prioritized during peak demand periods.
-- Least efficient riders can be supported through route optimization, zone reassignment, or performance coaching.
-- Continuous monitoring of rider efficiency helps Zomato improve ETA accuracy, optimize delivery operations, and enhance customer satisfaction.


-- Question 19:
-- Analyze the seasonal popularity of food items on the Zomato platform by identifying the top-ordered items
-- in each season and measuring their order volume and revenue contribution.

WITH season_cte AS (
    SELECT
        o.order_id,
        o.order_item,
        o.total_amount,
        CASE
            WHEN MONTH(o.order_date) BETWEEN 4 AND 7 THEN 'spring'
            WHEN MONTH(o.order_date) > 8
                 AND MONTH(o.order_date) <= 10 THEN 'summer'
            ELSE 'winter'
        END AS season
    FROM orders o
),

season_summary AS (
    SELECT
        season,
        order_item,
        COUNT(order_id) AS total_orders,
        ROUND(SUM(total_amount), 0) AS total_revenue
    FROM season_cte
    GROUP BY
        season,
        order_item
),

ranks AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY season
            ORDER BY total_orders DESC
        ) AS rank_by_season
    FROM season_summary
)

SELECT
    season,
    order_item,
    total_orders,
    total_revenue
FROM ranks
WHERE rank_by_season BETWEEN 1 AND 3;

-- 📊 Business Insight (Seasonal Demand & Menu Optimization)

-- Insight:
-- Food item popularity shows clear seasonal variation, with different dishes dominating order volumes in spring, summer, and winter.
-- This indicates that customer food preferences are strongly influenced by seasonal factors.

-- Business Impact for Zomato:
-- Restaurants can optimize menus and inventory by promoting seasonally high-demand items.
-- Zomato can design season-specific campaigns and personalized recommendations to increase order conversion.
-- Understanding seasonal demand spikes helps improve supply planning, reduce stock wastage, and maximize revenue during peak seasons.


-- Question 20:
-- Evaluate customer ordering consistency on the Zomato platform by measuring active ordering months, average order frequency,
-- and average gap between orders to classify customers into reliability segments.

WITH base_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_date,
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        LAG(o.order_date) OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date
        ) AS prev_order_date
    FROM orders o
    JOIN customers c
        ON c.customer_id = o.customer_id
),

gap_data AS (
    SELECT
        customer_id,
        customer_name,
        order_date,
        order_month,
        CASE
            WHEN prev_order_date IS NULL THEN NULL
            ELSE DATEDIFF(order_date, prev_order_date)
        END AS gap_days
    FROM base_orders
),

customer_metrics AS (
    SELECT
        customer_id,
        customer_name,
        COUNT(DISTINCT order_month) AS active_months,
        COUNT(order_date) AS total_orders,
        ROUND(
            COUNT(order_date) / COUNT(DISTINCT order_month),
            2
        ) AS avg_orders_per_month,
        ROUND(AVG(gap_days), 2) AS avg_gap_days
    FROM gap_data
    GROUP BY
        customer_id,
        customer_name
)

SELECT
    customer_id,
    customer_name,
    active_months,
    avg_orders_per_month,
    avg_gap_days,
    CASE
        WHEN active_months >= 6
             AND avg_gap_days <= 15 THEN 'High Reliability'
        WHEN active_months BETWEEN 3 AND 5
             AND avg_gap_days BETWEEN 16 AND 30 THEN 'Medium Reliability'
        ELSE 'Low Reliability'
    END AS reliability_score
FROM customer_metrics
ORDER BY  customer_id;

-- 📊 Business Insight (Customer Behavior & Retention Analytics)

-- Insight:
-- A large proportion of customers fall into the 'Low Reliability' segment, characterized by long gaps between orders and
-- relatively low monthly ordering frequency. This indicates sporadic engagement rather than habitual usage of the platform.

-- Business Impact for Zomato:
-- Low-reliability customers represent a significant reactivation opportunity through personalized reminders, discounts, and reorder nudges.
-- Medium and high-reliability customers can be targeted with loyalty programs and subscription-based benefits to reinforce consistent ordering behavior.
-- Reliability-based segmentation helps Zomato differentiate retention strategies and
-- focus marketing spend on customers with higher long-term engagement potential.