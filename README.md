Retail Inventory & Sales Management System

A database-driven Retail Inventory & Sales Management System built using MySQL and Power BI.
The system manages products, suppliers, stock levels, sales transactions, and generates real-time analytical insights.

 Project Overview

This project simulates a real-world retail inventory environment by:

Managing supplier and product relationships

Tracking stock levels

Automating inventory updates

Preventing negative stock transactions

Generating business insights through interactive dashboards

🛠 Technologies Used

Database: MySQL

Business Intelligence: Power BI

Language: SQL

Concepts Implemented:

Triggers

Stored Procedures

Transactions (COMMIT / ROLLBACK)

Views

Indexing

Role-Based Access Control

Database Design
Tables Created

suppliers

products

inventory

sales

purchases

inventory_log

Relationships

One Supplier → Many Products

One Product → One Inventory Record

One Product → Many Sales

One Product → Many Purchases

Foreign key constraints ensure data integrity.

 Key Features
 Automated Inventory Management

Trigger reduces stock after sale

Trigger increases stock after purchase

All stock changes logged automatically

 Transaction Control

Stored procedure sell_product():

Validates stock availability

Uses START TRANSACTION

Uses COMMIT and ROLLBACK

Prevents negative inventory

 Reporting Views

inventory_status

sales_report

Simplifies reporting and analytics queries.

🔹 Query Optimization

Indexes created on:

product_name

category

sale_date

supplier_id

 Role-Based Access

inventory_admin

sales_staff

report_analyst

Ensures secure data access.

 Power BI Dashboard

The interactive dashboard includes:

 Monthly Revenue Trend

 Top Selling Products

 Revenue Distribution

 Low Stock Alert Table

 KPI Cards:

Total Revenue

Total Units Sold

Low Stock Products

 Slicers:

Month Filter

Category Filter
