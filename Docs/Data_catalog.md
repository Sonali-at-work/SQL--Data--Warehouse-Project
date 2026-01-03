# Data Dictionary – Gold Layer

## Overview
The Gold layer represents the business-ready data model designed for analytics and reporting.
It follows a star schema with conformed dimensions and multiple fact tables at different grains.

---

## 1. gold.dim_customers

**Purpose**  
Stores unique customer information enriched with geographic attributes.

**Grain**  
One row per customer.

| Column Name | Data Type | Description |
|------------|----------|-------------|
| customer_key | INT | Surrogate key for the customer dimension |
| customer_id | VARCHAR | Business key from source system |
| customer_unique_id | VARCHAR | Unique customer identifier across orders |
| customer_zip_code_prefix | VARCHAR | Customer zip code prefix |
| customer_city | VARCHAR | Customer city |
| customer_state | VARCHAR | Customer state |

---

## 2. gold.dim_products

**Purpose**  
Stores descriptive information about products.

**Grain**  
One row per product.

| Column Name | Data Type | Description |
|------------|----------|-------------|
| product_key | INT | Surrogate key for product |
| product_id | VARCHAR | Business product identifier |
| product_category | VARCHAR | Product category (English) |
| product_weight_g | INT | Product weight in grams |
| product_length_cm | INT | Product length |
| product_height_cm | INT | Product height |
| product_width_cm | INT | Product width |

---

## 3. gold.dim_sellers

**Purpose**  
Stores seller and seller location information.

**Grain**  
One row per seller.

| Column Name | Data Type | Description |
|------------|----------|-------------|
| seller_key | INT | Surrogate key for seller |
| seller_id | VARCHAR | Business seller identifier |
| seller_city | VARCHAR | Seller city |
| seller_state | VARCHAR | Seller state |
| latitude | FLOAT | Seller latitude |
| longitude | FLOAT | Seller longitude |

---

## 4. gold.fact_orders

**Purpose**  
Captures order lifecycle events and delivery performance metrics.

**Grain**  
One row per order.

| Column Name | Data Type | Description |
|------------|----------|-------------|
| order_id | VARCHAR | Order business identifier |
| customer_key | INT | FK to dim_customers |
| order_status | VARCHAR | Current order status |
| order_purchase_timestamp | DATETIME | Order purchase time |
| order_delivered_customer_date | DATETIME | Delivery date |
| overall_flag_any_delivery_issue | INT | Delivery issue indicator |

---

## 5. gold.fact_order_items

**Purpose**  
Captures transactional sales data at order-item level.

**Grain**  
One row per order item.

| Column Name | Data Type | Description |
|------------|----------|-------------|
| order_id | VARCHAR | Order identifier |
| order_item_id | INT | Item sequence within order |
| product_key | INT | FK to dim_products |
| seller_key | INT | FK to dim_sellers |
| price | DECIMAL | Item price |
| freight_value | DECIMAL | Shipping cost |

---

## 6. gold.fact_payments

**Purpose**  
Captures payment transactions per order.

**Grain**  
One row per payment event.

| Column Name | Data Type | Description |
|------------|----------|-------------|
| order_id | VARCHAR | Order identifier |
| payment_type | VARCHAR | Payment method |
| payment_installments | INT | Number of installments |
| payment_value | DECIMAL | Payment amount |

---

## 7. gold.fact_reviews

**Purpose**  
Stores customer reviews and feedback.

**Grain**  
One row per review.

| Column Name | Data Type | Description |
|------------|----------|-------------|
| review_id | VARCHAR | Review identifier |
| order_id | VARCHAR | Order identifier |
| review_score | INT | Rating score |
| review_comment_message | VARCHAR | Customer feedback |
| review_creation_date | DATETIME | Review creation timestamp |
