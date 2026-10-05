# Plato's Pizza Sales & Operational Analytics

## Project Overview
This project analyzes a full year of transactional sales data from a fictitious artisanal pizzeria (Plato's Pizza). The objective is to extract actionable business insights to optimize kitchen staffing, identify high-margin menu items, and understand seasonal revenue trends. 

**Tech Stack:** PostgreSQL, pgAdmin, SQL Window Functions, Common Table Expressions (CTEs), Aggregations, and Date/Time formatting.

## Database Schema
The dataset consists of four related tables:
* **`orders`**: Transaction timestamps (`order_id`, `date`, `time`)
* **`order_details`**: Line-item basket data (`order_details_id`, `order_id`, `pizza_id`, `quantity`)
* **`pizzas`**: Product sizing and pricing (`pizza_id`, `pizza_type_id`, `size`, `price`)
* **`pizza_types`**: Categorization and recipes (`pizza_type_id`, `name`, `category`, `ingredients`)

## Key Business Questions & Actionable Insights

### 1. What are our peak operating windows?
**Insight:** Order volume predictably spikes during lunch (12:00 PM – 1:00 PM) and dinner (5:00 PM – 7:00 PM), with Thursday through Saturday driving the highest continuous volume.
**Recommendation:** Shift part-time kitchen prep staff to 11:00 AM – 2:00 PM windows on weekends to ensure adequate inventory for the dinner rush.
https://github.com/SayanBiswas23/Plato-s-Pizza-Sales-Operational-Analytics/blob/main/sql/peak-opertating_hours.png

### 2. How do categories contribute to total revenue?
**Insight:** The *Classic* pizza category drives the bulk of the unit volume, but the *Chicken* and *Supreme* categories command a higher price point, heavily influencing the Average Order Value (AOV).
**Recommendation:** Introduce combo bundles pairing high-margin *Classic* baseline items with smaller, premium *Chicken* pizzas to increase the median basket size.
https://github.com/SayanBiswas23/Plato-s-Pizza-Sales-Operational-Analytics/blob/main/sql/revenue-pct-contribution.png

### 3. What is the baseline order sizing?
**Insight:** While total annual revenue is substantial, the median basket contains only a few items, indicating primarily individual or small-group dining rather than large catering events.

## Future Scope
* **Power BI Integration:** Connect the local PostgreSQL database to Power BI to build an automated, interactive dashboard with synced slicers for real-time menu performance tracking.
* **Predictive Modeling:** Implement Python (Pandas/Scikit-learn) to forecast ingredient inventory requirements based on historical day-of-week trends.

## How to Reproduce
1. Clone this repository to your local machine.
2. Open pgAdmin or your preferred PostgreSQL IDE.
3. Run the DDL script in `sql/01_schema_setup.sql` to create the tables.
4. Import the raw CSV files (available via [Maven Analytics](https://mavenanalytics.io/data-playground)) into the newly created tables.
5. Execute the analytical queries in `sql/02_analysis_queries.sql` to view the aggregated results.
