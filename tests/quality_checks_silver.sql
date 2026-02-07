-- Validity and quality checks

--=====================================================
--   Table - customer_zip_code_prefix
--=====================================================
--checking for duplicate rows in customer_zip_code_prefix-- no duplicates
select customer_id,customer_unique_id,customer_zip_code_prefix
,customer_city,customer_state,count(*) 
from bronze.olist_customers
group by customer_id ,customer_unique_id,customer_zip_code_prefix
,customer_city,customer_state
having count(*)>1

-- check for zip codes with len <>5 -- only 4 digit is present 
select customer_zip_code_prefix,count(*)as count 
from bronze.olist_customers 
where len(customer_zip_code_prefix) < 5 
group by customer_zip_code_prefix
 
-- check null in customer_zip_code_prefix -- no null found
select count(*) as null_count
from bronze.olist_customers 
where customer_zip_code_prefix  is null

-- check for customer_zip_code_prefix with character and int combination-- non is mix of int or char
select customer_zip_code_prefix,count(*) from bronze.olist_customers 
where customer_zip_code_prefix like '%[^0-9]'
group by customer_zip_code_prefix
-- customer_zip_code_prefix-- no leading and trailing spaces
select customer_zip_code_prefix from bronze.olist_customers 
where customer_zip_code_prefix != trim(cast (customer_zip_code_prefix as nvarchar(10)))

-- space in customer_city --no leading trailing spaces 
select customer_city from bronze.olist_customers  
where customer_city != trim(customer_city)

--Casing customer_state -- all are in upper case
select customer_state,count(*) from bronze.olist_customers group by customer_state  
--spaces customer_state -- no leading trailing spaces 
select customer_state from bronze.olist_customers 
where customer_state!=trim(customer_state)

--=====================================================
--  Table - olist_orders
--=====================================================
--Referentail Integrity check
FROM silver.olist_orders o
WHERE o.customer_id NOT IN (
    SELECT c.customer_id
    FROM silver.olist_customers c
);

--Order_id (P.K duplicate check )
--Result - no duplicate found
select * from (
select *,row_number ()
over (partition by order_id order by order_id) as rn from bronze.olist_orders)as t where rn =1

-- null in customer_id -- no null
select  customer_id from bronze.olist_orders where customer_id is null

--null and invalid values in order_status -- no null and no invalid
select  distinct order_status from bronze.olist_orders 
select  order_status from bronze.olist_orders  where order_status is null


--checkk if order_purchase_timestamp is datetime only or something else  -- 5 tables have values other than date
select   distinct(isdate(order_purchase_timestamp)) from bronze.olist_orders 
select   distinct(isdate(order_approved_at)) from bronze.olist_orders 
select   distinct(isdate(order_delivered_carrier_date)) from bronze.olist_orders 
select   distinct(isdate(order_delivered_customer_date)) from bronze.olist_orders 
select   distinct(isdate(order_estimated_delivery_date)) from bronze.olist_orders 
-- upon investifgating found that thos non date values are actually null (queries below)
select   distinct order_approved_at from bronze.olist_orders where isdate(order_approved_at)=0
select   distinct order_delivered_carrier_date from bronze.olist_orders  where isdate(order_delivered_carrier_date)=0
select   distinct order_delivered_customer_date from bronze.olist_orders where isdate(order_delivered_customer_date)=0

--total count of null values 
select   count(*) from bronze.olist_orders  where order_purchase_timestamp is null
select   count(*) from bronze.olist_orders where order_approved_at is null --111
select   count(*) from bronze.olist_orders  where order_delivered_carrier_date is null --1168
select   count(*) from bronze.olist_orders where order_delivered_customer_date is null --1954
select  count(*) from bronze.olist_orders where order_estimated_delivery_date is null

--=====================================================
--  Table - olist_products
--=====================================================
select * from (
select *,row_number ()
over (partition by product_id order by product_id) as rn from bronze.olist_products)as t where rn =1

-- checking if any of numerical columns has -ve or less than value (could be null )
SELECT * FROM bronze.olist_products
WHERE product_name_lenght < = 0 OR product_description_lenght <= 0

-- product_photos_qty null allowed but negative not allowed 
SELECT * FROM bronze.olist_products WHERE product_photos_qty < 0 

-- weight ,length, height,width could be null but could not be zero  - 4 have zero hence,replacing with null
SELECT *
FROM bronze.olist_products
WHERE
  product_weight_g <= 0 OR product_length_cm <= 0 OR product_height_cm <= 0 OR product_width_cm <= 0;

 SELECT
  MAX(product_weight_g)  AS max_weight,
  MAX(product_length_cm) AS max_length,
  MAX(product_height_cm) AS max_height,
  MAX(product_width_cm)  AS max_width
FROM bronze.olist_products;
-- nulls in each column
SELECT
  SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS name_len_nulls,
  SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS desc_len_nulls,
  SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS photos_nulls,
  SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS weight_nulls,
  SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS length_nulls,
  SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS height_nulls,
  SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS width_nulls
FROM bronze.olist_products;

--=====================================================
--  Table - olist_order_items
--=====================================================
--Referentail Integrity check
SELECT *
FROM silver.olist_order_items oi
WHERE oi.order_id NOT IN (
    SELECT o.order_id
    FROM silver.olist_orders o
)

SELECT *
FROM silver.olist_order_items oi
WHERE oi.product_id NOT IN (
    SELECT p.product_id
    FROM silver.olist_products p
);

select * from (select  row_number() 
over(partition by order_id,order_item_id order by order_id)as rn,*
from bronze.olist_order_items )t where  rn =1

--shipping_limit_date is null --  no null
select * from bronze.olist_order_items where shipping_limit_date is null

--shipping_limit_date check datattype -- all are date form 
select count(isdate(shipping_limit_date))as  true from bronze.olist_order_items 

--price is null - no null
select * from bronze.olist_order_items where price is null

--shipping_limit_date check datattype  - no negative no zeroes
select * from bronze.olist_order_items  where price <=0

--price is null -- nonull
select * from bronze.olist_order_items where freight_value is null

--price check datattype - no negative
select * from bronze.olist_order_items  where freight_value < 0

--=====================================================
--  Table - olist_order_payments
--=====================================================
SELECT *
FROM silver.olist_order_payments op
WHERE op.order_id NOT IN (
    SELECT o.order_id
    FROM silver.olist_orders o
)

--no dupicates exist 
select * from (select row_number()over (partition by order_id,payment_sequential  order by payment_sequential) as rn ,*
from bronze.olist_order_payments )t where rn = 1

-- payment_type no null 
select distinct payment_type from bronze.olist_order_payments 

--payment_installments no negative value ,no null
select  payment_installments from bronze.olist_order_payments 
where payment_installments is null or payment_installments <0

--payment_value  no null no -ve value
select  count(*) from bronze.olist_order_payments 
where payment_value is null or payment_value <0

--payment_sequential no -ve and  no null
select  count(*) from bronze.olist_order_payments 
where payment_sequential is null or payment_sequential <=0

--=====================================================
--  Table - olist_order_reviews
--=====================================================
select * from bronze.olist_order_reviews
SELECT *
FROM silver.olist_order_reviews r
WHERE r.order_id NOT IN (
    SELECT o.order_id
    FROM silver.olist_orders o
)

-- review_id (duplicates exist)
select * from(
select row_number() over (partition by review_id order by review_id ) as rn ,* from bronze.olist_order_reviews
) t where rn >=2

--review_score --no null or negative value 
select distinct(review_score) from bronze.olist_order_reviews

--review_creation_date --no non date value 
select distinct(isdate(review_creation_date)) from bronze.olist_order_reviews 
select *  from bronze.olist_order_reviews  where review_creation_date is null

-- review_answer_timestamp--no non date value 
select distinct(isdate(review_answer_timestamp)) from bronze.olist_order_reviews 
select *  from bronze.olist_order_reviews  where review_answer_timestamp is null

-- review_comment_title
-- checking whitespaces and empty strings
-- outcome yes in both tables empty string exist 
SELECT * FROM bronze.olist_order_reviews
WHERE review_comment_title IS NOT NULL AND LTRIM(RTRIM(review_comment_title)) = '';

SELECT * FROM bronze.olist_order_reviews
WHERE review_comment_message IS NOT NULL AND LTRIM(RTRIM(review_comment_message)) = '';

--=====================================================
--  Table - olist_sellers
--=====================================================
-- seller_Id --no duplicates found
select * from(
select row_number() over (partition by seller_id order by seller_id ) as rn ,* from bronze.olist_sellers
) t where rn >=2

--seller_city -- no null or absurd value present
select * from bronze.olist_sellers 
where  seller_city is null or (rtrim(ltrim(seller_city))) =' '  -- NULL / blank check
or seller_city LIKE '%[0-9]%'                                   -- Numeric garbage

--check case inconsistency -- no case inconsistency but found one data quality issue
SELECT seller_city,
   UPPER(LTRIM(RTRIM(seller_city))) AS city_normalized,
    COUNT(DISTINCT seller_city) AS case_variations
FROM bronze.olist_sellers  
group by UPPER(LTRIM(RTRIM(seller_city)))        -- Case consistency (Silver)
HAVING COUNT(DISTINCT seller_city) > 1

--seller_state no null or absurd value present 
SELECT DISTINCT seller_state
FROM bronze.olist_sellers
WHERE seller_state IS NULL                    --null values
   or LTRIM(RTRIM(seller_state)) = ''         --whitespaces
   or len(seller_state) <> 2                  --Length check (structural validity)
-- or seller_state <> UPPER(seller_state)     --Case check or Case consistency (standardization)
   or seller_state NOT IN (                   --Domain (allowed values)
        'AC','AL','AP','AM','BA','CE','DF','ES','GO',
        'MA','MT','MS','MG','PA','PB','PR','PE','PI',
        'RJ','RN','RS','RO','RR','SC','SP','SE','TO')

SELECT DISTINCT seller_state
FROM bronze.olist_sellers
WHERE seller_state IS NOT NULL
  AND seller_state <> UPPER(seller_state);   --Case check or Case consistency (standardization)

SELECT seller_state, COUNT(*) AS sellers
FROM bronze.olist_sellers
GROUP BY seller_state
ORDER BY sellers DESC;

-- seller_zip_code_prefix two zip_code length present  4 and 5 
select distinct(len(seller_zip_code_prefix)) from bronze.olist_sellers --length check

-- distinct wont disply null hence check null separately
select * from bronze.olist_sellers where seller_zip_code_prefix is null or len(seller_zip_code_prefix)<>5



--=====================================================
--  Table - olist_geolocation
--=====================================================

--geolocation_zip_code_prefix
--Correct rule summary
--Must be numeric
--Must be length 5
--Can start with 0
--Not unique
SELECT DISTINCT customer_zip_code_prefix
FROM silver.olist_customers
WHERE customer_zip_code_prefix NOT IN (
    SELECT geolocation_zip_code_prefix
    FROM silver.olist_geolocation
);

-- all rows are 4 digit
select * from bronze.olist_geolocation
WHERE TRY_CAST(geolocation_zip_code_prefix AS INT) IS NULL
  AND geolocation_zip_code_prefix IS NOT NULL;

select * from bronze.olist_geolocation where 
len(geolocation_zip_code_prefix)<>4 

-- no non numeric zip
select * from bronze.olist_geolocation 
where geolocation_zip_code_prefix like '%[^0-9]%'

--geolocation_lat & geolocation_lng
--Null check	
--Must be numeric	
--Valid range
select COUNT(*) from bronze.olist_geolocation  -- no null
where geolocation_lat is null or geolocation_lng is null
select count(*) from bronze.olist_geolocation -- no out of range values 
where geolocation_lat  not between -90 and +90
select count(*) from bronze.olist_geolocation -- no out of range values 
where   geolocation_lng not between -180 and +180 

SELECT *
FROM bronze.olist_geolocation
WHERE TRY_CAST(geolocation_lat AS FLOAT) IS NULL
  AND geolocation_lat IS NOT NULL;

SELECT *
FROM bronze.olist_geolocation
WHERE TRY_CAST(geolocation_lng AS FLOAT) IS NULL
  AND geolocation_lng IS NOT NULL;

--geolocation_city
--NOT NULL
--No digits
--Trim spaces
--Uppercase standardization

select * from bronze.olist_geolocation where geolocation_city is null 
or geolocation_city like '%[0-9]%' -- no null or numeric

SELECT geolocation_city,
   UPPER(LTRIM(RTRIM(geolocation_city))) AS city_normalized,
    COUNT(DISTINCT geolocation_city) AS case_variations
FROM bronze.olist_geolocation  
group by UPPER(LTRIM(RTRIM(geolocation_city)))         -- Case consistency (Silver)
HAVING COUNT(DISTINCT geolocation_city) > 1 
--no case inconsistency

--geolocation_state
 select * from bronze.olist_geolocation where geolocation_state is null
 or  geolocation_state like '%[0-9]%'

--seller_state no null or absurd value present 
SELECT DISTINCT geolocation_state
FROM bronze.olist_geolocation
WHERE geolocation_state IS NULL                    --null values
   or LTRIM(RTRIM(geolocation_state)) = ''         --whitespaces
   or len(geolocation_state) <> 2                  --Length check (structural validity)
-- or seller_state <> UPPER(seller_state)     --Case check or Case consistency (standardization)
   or geolocation_state NOT IN (                   --Domain (allowed values)
        'AC','AL','AP','AM','BA','CE','DF','ES','GO',
        'MA','MT','MS','MG','PA','PB','PR','PE','PI',
        'RJ','RN','RS','RO','RR','SC','SP','SE','TO')

SELECT DISTINCT geolocation_state
FROM bronze.olist_geolocation
WHERE geolocation_state IS NOT NULL
  AND geolocation_state <> UPPER(geolocation_state);   --Case check or Case consistency (standardization)

SELECT geolocation_state, COUNT(*) AS location
FROM bronze.olist_geolocation
GROUP BY geolocation_state
ORDER BY location DESC;
