# SQL--Data--Warehouse-Project
Building a modern data warehouse with SQL Server, including ETL processes, data modelling and analytics
# Data Warehouse and Analytics Project 
  
This project demonstrates an end-to-end data warehousing and analytics solution, designed as a **portfolio project** showcasing industry best practices in **data engineering, data modeling, and analytics**.

---

## 📌 Project Overview

This project involves:

### 1️⃣ Data Architecture
Designing a modern **Medallion Architecture** using:
- **Bronze** – Raw ingestion layer  
- **Silver** – Cleaned and transformed data  
- **Gold** – Business-ready fact and dimension tables  

### 2️⃣ ETL Pipelines
- Extracting data from source systems  
- Transforming and cleansing data  
- Loading curated datasets into analytical tables  

### 3️⃣ Data Modeling
- Star / constellation schema design  
- Fact and dimension tables  
- Surrogate keys & referential integrity  

### 4️⃣ Analytics & Reporting
- SQL-based analysis
- Business KPIs
- Analytical queries optimized for performance  

---

## 🎯 Skills Demonstrated

This repository showcases expertise in:

- SQL Development  
- Data Warehousing  
- Data Engineering  
- ETL Pipeline Design  
- Dimensional Modeling  
- Analytics & Reporting  

---
### Data Modeling
Overview

The Gold layer follows a dimensional modeling approach optimized for analytical and reporting use cases.
The model is designed using a Fact Constellation (Galaxy Schema), where multiple fact tables exist at different grains and share conformed dimensions.

This approach supports:

Flexible analysis at order, order-item, payment, and review levels

High query performance

Clear separation of business entities (dimensions) and measurable events (facts)

### Schema Type

Fact Constellation (Galaxy Schema)

The model contains:

3 Dimension tables

4 Fact tables

Shared dimensions reused across multiple facts

This is intentionally not a single star schema, because the business processes operate at different granularities.

## Dimension Tables

Dimensions store descriptive attributes and use surrogate keys for analytical joins.

### 1. gold.dim_customers

Grain: One row per customer

Surrogate Key: customer_key

Business Key: customer_id

Attributes:Customer identifiers, Geographic details (city, state, zip)

Used by:fact_orders

### 2. gold.dim_products

Grain: One row per product

Surrogate Key: product_key

Business Key: product_id

Attributes:Product category, Physical characteristics (weight, dimensions), Metadata for product analysis

Used by:fact_order_items

### 3. gold.dim_sellers

Grain: One row per seller

Surrogate Key: seller_key

Business Key: seller_id

Attributes:Seller location, Geographic enrichment using aggregated geolocation data

Used by:fact_order_items

## Fact Tables

Fact tables store transactional and event-level data.
Each fact table maintains a clearly defined grain and references dimensions via surrogate keys where applicable.

### 1. gold.fact_orders

Grain: One row per order

Purpose: Tracks order lifecycle and delivery performance

Keys:order_id (degenerate dimension), customer_key (FK to dim_customers)

Measures / Indicators:Order status, Timestamps (purchase, approval, delivery), Delivery delay flags and duration metrics

Connected to:Customers, Payments, Reviews, Order items

2. gold.fact_order_items

Grain: One row per order item

Purpose: Captures line-level sales and logistics details

Keys:order_id, order_item_id, product_key (FK), seller_key (FK)

Measures:Item price, Freight value, Shipping limit date

This table represents the core sales fact of the model.

3. gold.fact_payments

Grain: One row per payment record per order

Purpose: Captures payment behavior and methods

Keys:order_id

Measures / Attributes:Payment type, Installments, Payment value, Payment sequence

Connected to:fact_orders via order_id

4. gold.fact_reviews

Grain: One row per review (1 order_id has many reviews in reviews tbl) -- 1:M Relationship

Purpose: Captures customer feedback and satisfaction

Keys:review_id, order_id

Measures / Attributes:Review score, Comments, Review creation and response timestamps

Connected to: fact_orders via order_id

### Relationships & Grain Alignment

Orders act as a central business process linking:

Customers

Order items

Payments

Reviews

Order items connect products and sellers at the most detailed transactional level.

Dimensions are never joined directly to each other — joined only through facts.

Surrogate keys are used only in dimensions and facts, never in the Silver layer.

## Design Principles Applied

Clear grain definition for every fact table

Surrogate keys used for analytical stability

Business keys preserved for traceability

No dimension-to-dimension joins

Referential integrity validated via data quality checks

Optimized for BI tools and SQL-based analytics

## Summary

This dimensional model accurately reflects real-world e-commerce processes and supports advanced analytics such as:

Delivery performance analysis

Product and seller performance

Customer behavior and satisfaction

Payment method and installment analysis

The use of a Fact Constellation schema ensures scalability, clarity, and professional-grade data warehouse design.

##  Repository Structure

```text
datasets/        → Source data
scripts/         → SQL scripts (ETL, modeling, QA)
docs/            → Architecture & data dictionary
tests/           → Data quality checks
README.md        → Project overview

data-warehouse-project/
│
├── datasets/
│   └── Raw datasets used for the project (ERP and CRM data)
│
├── docs/
│   ├── etl.drawio                  # Project documentation and architecture details
│   ├── data_architecture.drawio    # Draw.io file showing the project’s architecture
│   ├── data_catalog.md             # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio            # Draw.io file for the data flow diagram
│   ├── data_models.drawio          # Draw.io file for data models (star schema)
│   └── naming_conventions.md       # Consistent naming guidelines for tables, columns, and files
│
├── scripts/
│   ├── bronze/                     # Scripts for extracting and loading raw data
│   ├── silver/                     # Scripts for cleaning and transforming data
│   └── gold/                       # Scripts for creating analytical models
│
├── tests/
│   └── Test scripts and quality checks
│
├── README.md                       # Project overview and instructions
├── LICENSE                         # License information for the repository
├── .gitignore                      # Files and directories to be ignored by Git
└── requirements.txt                # Dependencies and requirements for the project

