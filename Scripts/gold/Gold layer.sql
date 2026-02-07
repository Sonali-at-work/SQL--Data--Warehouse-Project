
--=================================================
           -- Dimension tables
--=================================================

-- avg(lat) and avg(long) as there exist multiple entries in geolocation table for same ziip code ,city and state causing granualrity issue upon jioning with the sellers dataset
-- Then creating new physical table with the transformed rows
-- This geolocation table will be used with seller table as join to obtain one dimension table
IF OBJECT_ID('silver.olist_geolocations','U') IS NOT NULL
   DROP TABLE silver.olist_geolocations
GO
SELECT 
	geolocation_zip_code_prefix,
	avg(geolocation_lat)as latitude,
	avg(geolocation_lng)as longitude,
	geolocation_city,
	geolocation_state 
into silver.olist_geolocations
from silver.olist_geolocation 
	group by  geolocation_zip_code_prefix,geolocation_city,geolocation_state

create view gold.dim_sellers as
select 
    row_number() over(order by seller_id)as seller_key,
	s.seller_id,
	s.seller_zip_code_prefix,
	s.seller_city,
	s.seller_state,
	g.geolocation_zip_code_prefix,
	g.geolocation_city,
	g.geolocation_state,
	g.latitude,
	g.longitude
from silver.olist_sellers s left join silver.olist_geolocations g 
on s.seller_zip_code_prefix=g.geolocation_zip_code_prefix

create view gold.dim_products as
select 
	row_number() over(order by product_id) as product_key,
	p.product_id,
	pc.product_category_name_english as product_category,
	p.product_name_lenght ,
	p.product_description_lenght,
	p.product_photos_qty as no_of_photos,
	p.product_weight_g as weight_in_gm,
	p.product_length_cm as length_in_cm,
	p.product_height_cm as height_in_cm,
	p.product_width_cm as width_in_cm
from silver.olist_products p left join silver.product_category_translation pc on
p.product_category_name=pc.product_category_name

Create View gold.dim_customers as
select 
    row_number() over(order by customer_id)as customer_key,
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state 
from silver.olist_customers

--=============================================
           -- Fact tables --
--=============================================

--doing left join so as to not miss/loose data of the main table olist_orders
--rearranging column
--renaming them 
--create surrogate keys
Create view gold.fact_orders as
select 
	o.order_id,
	c.customer_key,
	o.order_status,
	o.order_purchase_timestamp,
	o.order_approved_at,
	o.order_delivered_carrier_date,
	o.order_delivered_customer_date,
	o.order_estimated_delivery_date,
	o.Flag_carrier_after_customer,
	o.diff_hours_carrier_to_customer,
	o.Flag_delivered_after_estimated,
	o.diff_hours_delivered_to_estimated,
	o.Overall_Flag_any_Delivery_Issue
from  silver.olist_orders o  left join  gold.dim_customers c
on o.customer_id=c.customer_id 


create view gold.fact_order_items as
select 
oi.order_id,
oi.order_item_id,
p.product_key,
s.seller_key,
oi.shipping_limit_date,
oi.price,
oi.freight_value 
from silver.olist_order_items oi join gold.dim_products p on oi.product_id=p.product_id left
join gold.dim_sellers s on  oi.seller_id=s.seller_id

Create view gold.fact_reviews as
select 
review_id,
order_id,
review_score as score,
review_comment_title as title,
review_comment_message as comment,
review_creation_date as creation_date,
review_answer_timestamp as aswer_timestamp
from silver.olist_order_reviews

create view gold.fact_payments as
select
order_id,
payment_sequential,
payment_type as type,
payment_installments as installment,
payment_value as value
from silver.olist_order_payments


-- ==========================================================================================================
            --chceking if the grain isnt getting disturbed or there arent multiple entries for a column value
-- ==========================================================================================================

--select c.customer_id,count(*) from silver.olist_customers c 
--join silver.olist_orders o on c.customer_id=o.customer_id
--group by c.customer_id having count(*)>1

--select r.order_id,count(*) from silver.olist_order_reviews r
--join silver.olist_orders o on r.order_id=o.order_id
--group by r.order_id having count(*)>1

--select order_id,count(*) from silver.olist_order_reviews group by order_id  having count(*)>1

--select order_id,count(*) from silver.olist_order_payments group by order_id  having count(*)>1

select 
    row_number() over(order by seller_id)as seller_key,
	s.seller_id,
	s.seller_zip_code_prefix,
	s.seller_city,
	s.seller_state,
	g.geolocation_zip_code_prefix,
	g.geolocation_city,
	g.geolocation_state,
	g.latitude,
	g.longitude
from silver.olist_sellers s left join silver.olist_geolocations g 
on s.seller_zip_code_prefix=g.geolocation_zip_code_prefix

select seller_zip_code_prefix ,count(*) from silver.olist_sellers group by seller_zip_code_prefix having count(*)>1
select geolocation_zip_code_prefix ,count(*) from silver.olist_geolocations group by geolocation_zip_code_prefix having count(*)>1
