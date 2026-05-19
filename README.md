# Route Profitability Analysis
## 1. Problem
A logistics company wants to identify underperforming transportation routes that are generating low or negative profit. The goal of this analysis is to evaluate revenue and operational costs across routes in order to identify opportunities to improve profitability.

## 2. DataSet

The dataset used in this analysis represents operational data from a logistics company. It contains multiple relational tables describing transportation activities, drivers, vehicles, and fuel purchases.

Key characteristics of the dataset:
- 14 relational tables
- Total Records: 361,799
- Date Range: 2022-2024
- Database Size: ~85,000+ unique operational records
- Core tables: drivers, trucks, trailers, customers, facilities, routes
- Transaction Tables: loads, trips, fuel_purchases, maintenance_records, Delivery events, safety_incidents
- Important fields include revenue, fuel cost, trip distance, and route identifiers
- Tables are linked using primary and foreign keys such as route_id, driver_id and Load_id


## 3. Data Quality Checks
Before conducting the analysis, several data quality checks were performed to ensure the reliability and accuracy of the dataset. The validation focused on the tables that are directly relevant to the route profitability business case.

The following tables were reviewed:
- Trips
- Loads
- Routes
- Fuel_Purchases
- Maintenance_Records

Key data quality checks included:
- Identifying missing values in critical fields
- Checking for duplicate records using primary keys
- Validating data types and logical values (e.g., non-negative cost and distance values)
- During this process, missing values were identified in the Trips and Fuel_Purchases tables. Since these fields are essential for operational and cost analysis, records containing null values were removed to maintain data integrity and ensure accurate profitability calculations.

The full analysis, including data preparation and exploration, is available in the Jupyter Notebook within this repository.

## 4. SQL Analysis
The goal of this step was to identify the most and least profitable routes.
By ranking routes based on total profit, we can:
- Detect underperforming lanes
- Prioritize high-margin routes
- Support pricing and operational decisions

### Methodology

Profit was calculated using the following formula:
Profit = Revenue − Fuel Cost − Maintenance Cost
Then, routes were ranked using a window function based on total profit.
Maintenance costs were allocated proportionally based on miles driven by each truck per route, which provides a more realistic cost distribution compared to flat allocation.

SQL code:
```sql
-- Final Profit Calculation
select 
    trp.route_id,
    trp.Total_revenue,
    fc.Total_Fuel_Cost,
    tmp.Total_Maintenance_Cost,
    fc.total_fuel_cost + tmp.total_maintenance_cost as Total_Cost,
    trp.Total_revenue - (fc.total_fuel_cost + tmp.total_maintenance_cost) as Profit
from fuel_cost as fc 
join Total_revenue_per_route trp on trp.route_id=fc.route_id 
join total_maintenance_per_rout tmp on fc.route_id = tmp.route_id
order by Profit desc
```
#### Full SQL logic is available in the /sql folder.
https://github.com/Mor-analyze/Logistics-Operations---Route-Profitability-Analysis/blob/main/analysis.sql

### Output
<img width="695" height="172" alt="top 10" src="https://github.com/user-attachments/assets/3e8f7c24-5f8d-449a-8786-323eabe3eb41" />

### Challenges

- Allocating maintenance cost to routes required multi-step transformation
- Ensuring no duplication during joins (especially fuel transactions)
- Handling trucks with no associated trips

## 5. Dashboard
- This dashboard provides a high-level view of route profitability, allowing stakeholders to quickly identify underperforming routes and evaluate cost efficiency.
- It enables comparison across routes, highlights the relationship between distance and profit margin, and surfaces loss-making routes for further investigation.
- By combining financial metrics with visual insights, the dashboard supports data-driven decisions around pricing, route optimization, and cost control.

<img width="656" height="363" alt="Project dashboard" src="https://github.com/user-attachments/assets/4c1d8c96-3a5f-4064-bceb-f7aa504b2dcf" />


## 6. Insights
- Base rates are inconsistent between the same routes in opposite directions (e.g., New York → Philadelphia vs Philadelphia → New York), indicating a lack of standardized pricing strategy.
- There is a strong positive correlation between route distance and profit margin, suggesting that longer routes are more cost-efficient.
- Routes under 557 miles consistently show lower or negative profit margins, indicating that current base rates are insufficient to cover operational costs.
- The New York → Philadelphia route is consistently unprofitable, with significantly negative margins compared to other routes.

## 7. Recommendation
- Implement a pricing model that accounts for directional demand while minimizing unjustified rate discrepancies.
- Prioritize long-distance routes and optimize network planning to increase the share of high-mileage trips.
- Introduce a minimum charge or dynamic pricing model for short-haul routes to prevent systematic losses.
- Re-evaluate the New York → Philadelphia route by adjusting pricing, reducing costs, or improving load efficiency before considering termination.

