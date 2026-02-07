/*
================================================================================================
DDL script: Create Bronze Tables
================================================================================================
Purpose of this Script:
This script creates tables at the bronze schema ,dropping existing tables if they already exists
================================================================================================
*/

IF OBJECT_ID('bronze.olist_customers','U') IS NOT NULL
   DROP TABLE bronze.olist_customers
GO
CREATE TABLE bronze.olist_customers (
    customer_id              VARCHAR(50)  PRIMARY KEY ,
    customer_unique_id       VARCHAR(50)  NOT NULL,
    customer_zip_code_prefix INT,
    customer_city            VARCHAR(100),
    customer_state           CHAR(2),
);

IF OBJECT_ID('bronze.olist_geolocation','U') IS NOT NULL
   DROP TABLE bronze.olist_geolocation
GO
CREATE TABLE bronze.olist_geolocation (
    geolocation_zip_code_prefix INT          NOT NULL,
    geolocation_lat             DECIMAL(9,6) NOT NULL,
    geolocation_lng             DECIMAL(9,6) NOT NULL,
    geolocation_city            VARCHAR(100) NOT NULL,
    geolocation_state           CHAR(2)      NOT NULL
);

IF OBJECT_ID('bronze.olist_order_items','U') IS NOT NULL
   DROP TABLE bronze.olist_order_items
GO
CREATE TABLE bronze.olist_order_items(
    order_id            VARCHAR(50)   NOT NULL,
    order_item_id       INT           NOT NULL,
    product_id          VARCHAR(50)   NOT NULL,
    seller_id           VARCHAR(50)   NOT NULL,
    shipping_limit_date DATETIME      NOT NULL,
    price               DECIMAL(10,2) NOT NULL,
    freight_value       DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_olist_order_items 
        PRIMARY KEY (order_id, order_item_id)
);

IF OBJECT_ID('bronze.olist_order_payments','U') IS NOT NULL
   DROP TABLE bronze.olist_order_payments
GO
CREATE TABLE bronze.olist_order_payments (
    order_id              VARCHAR(50)   NOT NULL,
    payment_sequential    INT           NOT NULL,
    payment_type          VARCHAR(20)   NOT NULL,
    payment_installments  INT           NOT NULL,
    payment_value         DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_olist_order_payments 
        PRIMARY KEY (order_id, payment_sequential)
);

IF OBJECT_ID('bronze.olist_order_reviews','U') IS NOT NULL
   DROP TABLE bronze.olist_order_reviews
GO
CREATE TABLE bronze.olist_order_reviews (
    review_id                VARCHAR(50)   ,
    order_id                 VARCHAR(50)  NOT NULL,
    review_score             INT,
    review_comment_title     VARCHAR(255),
    review_comment_message   VARCHAR(8000),
    review_creation_date     DATETIME,
    review_answer_timestamp  DATETIME,
    
);

IF OBJECT_ID('bronze.olist_orders','U') IS NOT NULL
   DROP TABLE bronze.olist_orders
GO
CREATE TABLE bronze.olist_orders (
    order_id                        CHAR(32)       primary key  ,
    customer_id                     CHAR(32)        NOT NULL,
    order_status                    VARCHAR(20)     NOT NULL,

    order_purchase_timestamp        DATETIME        NOT NULL,
    order_approved_at               DATETIME        ,
    order_delivered_carrier_date    DATETIME        ,
    order_delivered_customer_date   DATETIME        ,
    order_estimated_delivery_date   DATETIME        NOT NULL,
);

IF OBJECT_ID('bronze.olist_products','U') IS NOT NULL
   DROP TABLE bronze.olist_products
GO
   CREATE TABLE bronze.olist_products (
    product_id                      CHAR(32)       PRIMARY KEY  ,
    product_category_name           VARCHAR(50)     NULL,

    product_name_lenght             INT             NULL,
    product_description_lenght      INT             NULL,
    product_photos_qty              INT             NULL,

    product_weight_g                INT             NULL,
    product_length_cm               INT             NULL,
    product_height_cm               INT             NULL,
    product_width_cm                INT             NULL,

);

IF OBJECT_ID('bronze.olist_sellers','U') IS NOT NULL
   DROP TABLE bronze.olist_sellers
GO
CREATE TABLE bronze.olist_sellers (
    seller_id               CHAR(52)       PRIMARY KEY  ,
    seller_zip_code_prefix  INT             NOT NULL,
    seller_city             VARCHAR(50)     NOT NULL,
    seller_state            CHAR(2)          NOT NULL,

);

IF OBJECT_ID('bronze.product_category_translation','U') IS NOT NULL
   DROP TABLE bronze.product_category_translation
GO
CREATE TABLE bronze.product_category_translation (
    product_category_name          VARCHAR(50)     PRIMARY KEY ,
    product_category_name_english  VARCHAR(50)     NOT NULL,

);