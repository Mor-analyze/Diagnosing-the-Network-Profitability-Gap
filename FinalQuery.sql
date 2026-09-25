with Revenue as 
(select l.route_id,t.trip_id,l.load_date,
(l.revenue + l.fuel_surcharge+ l.accessorial_charges) as 
Total_revenue from loads as l 
left join trips as t on l.load_id = t.load_id),

total_feul as
(select trip_id, sum(total_cost)as total_cost 
from fuel_purchases
group by trip_id)

select r.route_id,r.trip_id,r.load_date,r.Total_revenue,coalesce(tf.total_cost,0)as Total_cost,
(Total_revenue-coalesce(tf.total_cost,0)) as profit 
from Revenue as r 
left join total_feul as tf 
on r.trip_id = tf.trip_id
order by profit
