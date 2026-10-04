-- ============================================================================
-- 1. REVENUE BASELINE & TREND
-- Business Intent: Establish high-level financial health and identify seasonal/weekly sales patterns.
-- ============================================================================

-- 1A. Total Annual Revenue
SELECT 
    ROUND(SUM(d.quantity * p.price)::numeric, 2) AS total_annual_revenue
FROM public.order_details d
JOIN public.pizzas p ON d.pizza_id = p.pizza_id;

-- 1B. Monthly Revenue Trend
SELECT 
    DATE_TRUNC('month', o.date)::date AS sales_month,
    ROUND(SUM(d.quantity * p.price)::numeric, 2) AS monthly_revenue,
    SUM(d.quantity) AS total_units_sold,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM public.orders o
JOIN public.order_details d ON o.order_id = d.order_id
JOIN public.pizzas p ON d.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY sales_month;

-- 1C. Day of Week Revenue Trend
SELECT 
    TO_CHAR(o.date, 'FMDay') AS day_of_week,
    EXTRACT(ISODOW FROM o.date)::int AS dow_index,
    ROUND(SUM(d.quantity * p.price)::numeric, 2) AS gross_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM public.orders o
JOIN public.order_details d ON o.order_id = d.order_id
JOIN public.pizzas p ON d.pizza_id = p.pizza_id
GROUP BY 1, 2
ORDER BY dow_index;


-- ============================================================================
-- 2. TOP & BOTTOM SELLERS (VOLUME & REVENUE)
-- Business Intent: Identify prime targets for menu pruning or promotional focus.
-- ============================================================================

WITH product_metrics AS (
    SELECT 
        p.pizza_id,
        t.name AS pizza_name,
        p.size,
        SUM(d.quantity) AS units_sold,
        ROUND(SUM(d.quantity * p.price)::numeric, 2) AS total_revenue,
        DENSE_RANK() OVER (ORDER BY SUM(d.quantity * p.price) DESC) AS rank_rev_desc,
        DENSE_RANK() OVER (ORDER BY SUM(d.quantity * p.price) ASC) AS rank_rev_asc,
        DENSE_RANK() OVER (ORDER BY SUM(d.quantity) DESC) AS rank_vol_desc,
        DENSE_RANK() OVER (ORDER BY SUM(d.quantity) ASC) AS rank_vol_asc
    FROM public.order_details d
    JOIN public.pizzas p ON d.pizza_id = p.pizza_id
    JOIN public.pizza_types t ON p.pizza_type_id = t.pizza_type_id
    GROUP BY p.pizza_id, t.name, p.size
)
SELECT 
    pizza_id,
    pizza_name,
    size,
    units_sold,
    total_revenue,
    CASE 
        WHEN rank_rev_desc <= 5 THEN 'Top 5 Revenue'
        WHEN rank_rev_asc <= 5 THEN 'Bottom 5 Revenue'
        WHEN rank_vol_desc <= 5 THEN 'Top 5 Volume'
        WHEN rank_vol_asc <= 5 THEN 'Bottom 5 Volume'
    END AS performance_bracket
FROM product_metrics
WHERE rank_rev_desc <= 5 
   OR rank_rev_asc <= 5 
   OR rank_vol_desc <= 5 
   OR rank_vol_asc <= 5
ORDER BY total_revenue DESC;


-- ============================================================================
-- 3. PEAK OPERATING WINDOWS
-- Business Intent: Provide data for optimal shift scheduling and kitchen prep times.
-- ============================================================================

SELECT 
    TO_CHAR(o.date, 'FMDay') AS day_of_week,
    EXTRACT(ISODOW FROM o.date)::int AS dow_index,
    EXTRACT(HOUR FROM o.time)::int AS order_hour,
    COUNT(DISTINCT o.order_id) AS order_volume,
    SUM(d.quantity) AS total_pizzas_sold,
    ROUND(SUM(d.quantity * p.price)::numeric, 2) AS hourly_revenue
FROM public.orders o
JOIN public.order_details d ON o.order_id = d.order_id
JOIN public.pizzas p ON d.pizza_id = p.pizza_id
GROUP BY 1, 2, 3
ORDER BY dow_index, order_hour;


-- ============================================================================
-- 4. ORDER SIZING (AOV & TYPICAL BASKET SIZE)
-- Business Intent: Determine the average spend and volume per customer transaction.
-- ============================================================================

WITH order_summary AS (
    SELECT 
        o.order_id,
        SUM(d.quantity) AS basket_units,
        SUM(d.quantity * p.price)::numeric AS basket_spend
    FROM public.orders o
    JOIN public.order_details d ON o.order_id = d.order_id
    JOIN public.pizzas p ON d.pizza_id = p.pizza_id
    GROUP BY o.order_id
)
SELECT 
    COUNT(order_id) AS total_orders,
    ROUND(AVG(basket_spend), 2) AS avg_order_value,
    ROUND(AVG(basket_units), 2) AS avg_units_per_order,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY basket_spend) AS median_order_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY basket_units) AS median_units_per_order
FROM order_summary;


-- ============================================================================
-- 5. CATEGORY PERFORMANCE & REVENUE CONTRIBUTION SHARE
-- Business Intent: Evaluate category share using window functions for overarching menu strategy.
-- ============================================================================

SELECT 
    t.category,
    SUM(d.quantity) AS units_sold,
    ROUND(SUM(d.quantity * p.price)::numeric, 2) AS category_revenue,
    ROUND(
        (SUM(d.quantity * p.price)::numeric / 
         SUM(SUM(d.quantity * p.price)::numeric) OVER ()) * 100.0, 
        2
    ) AS revenue_pct_contribution,
    ROUND(
        (SUM(d.quantity)::numeric / 
         SUM(SUM(d.quantity)::numeric) OVER ()) * 100.0, 
        2
    ) AS unit_pct_contribution
FROM public.order_details d
JOIN public.pizzas p ON d.pizza_id = p.pizza_id
JOIN public.pizza_types t ON p.pizza_type_id = t.pizza_type_id
GROUP BY t.category
ORDER BY category_revenue DESC;
