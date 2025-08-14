# SQL Case Study: Mobile Cellphone Sales Analysis

## 1. Introduction

This repository contains a detailed case study of mobile cellphone sales analysis using SQL. The project demonstrates the application of SQL queries to a relational database to extract meaningful insights and answer critical business questions. The database, named "Cellphones Information," is structured as a star schema, which is a common approach for data warehousing and business intelligence.

The primary goal of this case study is to showcase proficiency in SQL for data analysis, including complex joins, aggregations, subqueries, window functions, CTE and date manipulations.

*   **Technology:** SQL
*   **Database Model:** Star Schema
*   **Domain:** Retail/Telecommunications

---

## 2. Business Scenario

The database “Cellphones Information” contains details on cell phone sales or transactions. The data is stored across five distinct tables: `Dim_manufacturer`, `Dim_model`, `Dim_customer`, `Dim_Location`, and `Fact_Transactions`. The first four are dimension tables that store descriptive attributes, while `Fact_Transactions` is a fact table that stores quantitative information about each sales transaction.

---

## 3. Database Schema

The database follows a star schema with a central fact table (`Fact_Transactions`) connected to four dimension tables.

**Assumed Schema:**

*   **`Fact_Transactions`**
    *   `ID_Model` (Foreign Key)
    *   `ID_Customer` (Foreign Key)
    *   `ID_Location` (Foreign Key)
    *   `Date` (DATE)
    *   `TotalPrice` (DECIMAL)
    *   `Quantity` (INTEGER)
    

*   **`Dim_Location`**
    *   `ID_Location` (Primary Key)
    *   `ZipCode` (VARCHAR)
    *   `Country` (VARCHAR)
    *   `State` (VARCHAR)
    *   `City` (VARCHAR)


*   **`Dim_Customer`**
    *   `ID_Customer` (Primary Key)
    *   `Customer_Name` (VARCHAR)
    *   `Email` (VARCHAR)
    *   `Phone` (VARCHAR)


*   **`Dim_Model`**
    *   `ID_Model` (Primary Key)
    *   `Model_Name` (VARCHAR)
    *   `ID_Manufacturer` (Foreign Key)
    *   `Unit_Price` (DECIMAL)


*   **`Dim_DATE  **
    *   `DATE` ((Primary Key))
    *   `YEAR` (DATE)
    *   `QUARTER` (DATE)
    *   `MENTH` (DATE)


*   **`Dim_Manufacturer`**
    *   `ID_Manufacturer` (Primary Key)
    *   `Manufacturer_Name` (VARCHAR)


![Database Schema Diagram](https://github.com/vikasnagar31/SQL-Cellphone-Sales-Analysis/blob/main/Database%20Schema%20Digram.png?raw=true)

---

##  Business Questions Solved  

1. **States with Customers Buying Since 2005**  
   List all states where customers purchased cellphones from **2005 to the present**.

2. **Top US State for Samsung Purchases**  
   Identify the **US state** buying the most **Samsung** cellphones.

3. **Transactions per Model/Zip/State**  
   Count the **number of transactions** for each model per **zip code** per **state**.

4. **Cheapest Cellphone**  
   Find the **cheapest mobile model** along with its **price**.

5. **Average Price for Top 5 Manufacturers by Sales Quantity**  
   Find the **average price per model** for the **top 5 manufacturers** (by total quantity sold) and order by average price.

6. **Customers with High Average Spend in 2009**  
   List customer names and their **average amount spent** in **2009**, where the average > 500.

7. **Consistently Top Models (2008–2010)**  
   Find models that were in the **top 5 by quantity sold** in **2008, 2009, and 2010**.

8. **2nd Top Manufacturer (2009 & 2010)**  
   Find the manufacturer with the **2nd highest sales** in **2009** and in **2010**.

9. **New Manufacturers in 2010**  
   List manufacturers that sold in **2010** but **not** in **2009**.

10. **Top 100 Customers — Yearly Spend & Quantity**  
    Find **top 100 customers** and show:  
    - Average spend per year  
    - Average quantity per year  
    - Percentage change in spend year-over-year  

---




