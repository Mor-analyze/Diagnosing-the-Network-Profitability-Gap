--- Step 1: Total Miles per Truck
WITH truck_total_miles AS (
    SELECT 
        truck_id,
        SUM(actual_distance_miles) AS total_miles
    FROM trips
    GROUP BY truck_id
),

---Step 2: Maintenance Cost per Truck
maintenance_per_truck AS (
    SELECT
        truck_id,
        SUM(total_cost) AS maintenance_cost
    FROM maintenance_records
    GROUP BY truck_id
),

--- Step 3: Cost per Mile per Truck
truck_cost_per_mile AS (
    SELECT
        ttm.truck_id,
        mpt.maintenance_cost * 1.0 / NULLIF(ttm.total_miles,0) AS cost_per_mile
    FROM truck_total_miles ttm
    JOIN maintenance_per_truck mpt 
        ON ttm.truck_id = mpt.truck_id
),

---Step 4: Route-Level Miles per Truck
route_truck_miles AS (
    SELECT 
        l.route_id,
        t.truck_id,
        SUM(t.actual_distance_miles) AS route_miles
    FROM loads l
    JOIN trips t ON l.load_id = t.load_id
    GROUP BY l.route_id, t.truck_id
),

---Step 5: Allocate Cost to Routes
---Allocates maintenance cost proportionally based on mileage.
total_maintenance_per_rout as (
SELECT
    rtm.route_id,
    SUM(rtm.route_miles) as total_miles_per_route,
    SUM(rtm.route_miles * tcp.cost_per_mile) AS total_maintenance_cost
FROM route_truck_miles rtm
JOIN truck_cost_per_mile tcp 
    ON rtm.truck_id = tcp.truck_id
GROUP BY rtm.route_id),


--- Step 6: Total Revenue per Route
Total_revenue_per_route as 
(
select 
    route_id , sum(revenue) as Total_revenue
from loads
group by route_id),


---Step 7: Fuel Cost per Route
fuel_cost as 
(
select 
    l.route_id, 
    sum(fp.total_cost) as total_feul_cost
from FUEL_PURCHASES as fp
join trips as t on t.trip_id=fp.trip_id 
join loads as l on l.load_id = t.load_id
group by l.route_id
),


--- Step 8: Profit Calculation
profit as
(
select 
    trp.route_id,
    trp.Total_revenue,
    fc.Total_Feul_Cost,
    tmp.Total_Maintenance_Cost,
    fc.total_feul_cost + tmp.total_maintenance_cost as Total_Cost,
    trp.Total_revenue - (fc.total_feul_cost + tmp.total_maintenance_cost) as Profit
from fuel_cost as fc 
left join Total_revenue_per_route trp on trp.route_id=fc.route_id 
left join total_maintenance_per_rout tmp on fc.route_id = tmp.route_id
)

--- Last Step: Add Route Context
select 
    r.origin_city,r.destination_city , p.* 
from routes as r 
join profit as p on r.route_id = p.route_id
order by p.profit desc

    
