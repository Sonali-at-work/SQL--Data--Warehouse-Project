/*
====================================================================
Quality Checks
====================================================================

Script Purpose:
This script performs quality checks to validate the integrity,
consistency, and accuracy of the Gold Layer. These checks ensure:

- Uniqueness of surrogate keys in dimension tables.
- Referential integrity between fact and dimension tables.
- Validation of relationships in the data model for analytical purposes.

Usage Notes:
- Run these checks after data loading Silver Layer.
- Investigate and resolve any discrepancies found during the checks.
====================================================================
*/


-- =======================================================================
-- Checking 'gold.dim_customers','gold.dim_products'and 'gold.dim_sellers'
-- =======================================================================

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results
select customer_key ,count(*) as duplicate  from gold.dim_customers group by customer_key having count(*) >1

select product_key ,count(*) as duplicate  from gold.dim_products group by product_key having count(*) >1

select seller_key ,count(*) as duplicate  from gold.dim_sellers group by seller_key having count(*) >1


-- ================================================================================
-- Check for Referntial Integrity  -'Every fact row points to a valid dimension row'
  --1. gold.fact_order_items ,gold.dim_sellers
  --2. fact_order_items ,gold.dim_products 
  --3. gold.fact_orders
-- =================================================================================
select * from gold.fact_order_items  oi
join
gold.dim_sellers s on oi.seller_key=s.seller_key 
where  s.seller_key is null

select * from gold.fact_order_items  oi
join
gold.dim_products p on oi.product_key=p.product_key 
where  p.product_key is null

select * from gold.fact_orders  oi
join
gold.dim_customers c on oi.customer_key=c.customer_key
where  c.customer_key is null
