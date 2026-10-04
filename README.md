# Airline Flight Operations Analysis

## Project Overview

This project focuses on cleaning and preparing real-world airline flight data using MySQL for further exploratory data analysis.

The dataset contains flight operations, airline information, airport information, delays, cancellations, and time-related flight details.

The project demonstrates practical SQL skills required for handling and preparing large datasets for analysis.

## Dataset

The project uses three datasets:

- `airlines.csv` – Airline codes and airline names
- `airports.csv` – Airport codes, names, cities, states, countries, latitude, and longitude
- `flights.csv` – Flight-level operational data including schedules, delays, cancellations, airports, and aircraft information
The main flight dataset contains approximately 5.8 million flight records.
## 💾 Dataset Access

Due to GitHub's file size limits (>100MB), the raw `flights.csv` dataset is excluded from this repository via `.gitignore`. 

- **Source:** 2015 Flight Delays and Cancellations Dataset
- **Download Link:** [Kaggle 2015 Flight Delays & Cancellations](https://www.kaggle.com/datasets/usdot/flight-delays)
- **Setup Instruction:** Download `flights.csv` from Kaggle and place it inside the `data/` directory to execute the scripts in `sql/airlines_cleaning.sql`.

## Tools & Technologies

- MySQL
- MySQL Workbench
- SQL
- CSV datasets

## Project Workflow

```text
Raw CSV Data
     ↓
Data Import
     ↓
Staging Table Creation
     ↓
Data Quality Checks
     ↓
Data Cleaning
     ↓
Data Validation
     ↓
Data Type & Format Transformation
     ↓
Cleaned Dataset

1. Ingestion & Staging Setup
    Established database context (airline_operations) and verified dimensional lookup tables (airlines, airports).

    Ingested bulk raw data into flights via LOAD DATA LOCAL INFILE with custom delimiters (FIELDS TERMINATED BY ',' ENCLOSED BY '"').

    Cloned table structure (CREATE TABLE flights_staging LIKE flights) to isolate raw source data from transformation logic.

2. Comprehensive Audit & Null Handling
    Audited missing values across operational metrics (DEPARTURE_DELAY, TAXI_OUT, AIR_TIME, ARRIVAL_DELAY, and breakdown causes) using SUM(col IS NULL).

    Analyzed zero-value counts (SUM(col = 0)) to distinguish between actual zero delays and missing operational events.

    Updated flights_staging under disabled safe mode (SET SQL_SAFE_UPDATES = 0) to enforce domain constraints for cancelled flights (CANCELLED = 1):

        Converted un-flown operational metrics (DEPARTURE_DELAY, DEPARTURE_TIME, ARRIVAL_TIME, ARRIVAL_DELAY, TAXI_IN, TAXI_OUT, ELAPSED_TIME, AIR_TIME, WHEELS_OFF, WHEELS_ON, TAIL_NUMBER) to NULL.

        Set empty strings ('') to NULL across CANCELLATION_REASON (for non-cancelled flights) and delay breakdown categories (AIR_SYSTEM_DELAY, SECURITY_DELAY, AIRLINE_DELAY, LATE_AIRCRAFT_DELAY, WEATHER_DELAY).

3. Quality & Duplicate Verification
    String Cleaning: Audited text columns (AIRLINE, ORIGIN_AIRPORT, DESTINATION_AIRPORT, TAIL_NUMBER) using TRIM() comparison checks.
    
    Format Checking: Validated 3-letter IATA airport codes using REGEXP '^[A-Z]{3}$'.

    Duplicate Elimination: Applied ROW_NUMBER() OVER(PARTITION BY YEAR, MONTH, DAY, AIRLINE, FLIGHT_NUMBER, ORIGIN_AIRPORT, DESTINATION_AIRPORT, SCHEDULED_DEPARTURE) to confirm zero duplicate records.
    
    Integrity Validation: Audited range boundaries for valid integer flight numbers, non-negative flight distances (DISTANCE >= 0), and valid military time limits ($\le 2359$).

4. Schema Refactoring & Temporal Conversion
Converted legacy numeric date/time columns into native SQL DATE and TIME types:

    Generated unified flight_date (DATE) using STR_TO_DATE(CONCAT_WS('-', YEAR, MONTH, DAY), '%Y-%m-%d').
    
    Processed midnight edge cases (2400 $\rightarrow$ '00:00:00') and formatted 4-digit numeric time values into SQL TIME data types for SCHEDULED_DEPARTURE, SCHEDULED_ARRIVAL, DEPARTURE_TIME, ARRIVAL_TIME, WHEELS_OFF, and WHEELS_ON.
    
    Dropped redundant raw integer columns (YEAR, MONTH, DAY, DAY_OF_WEEK, raw integer times) and renamed formatted TIME columns to standard schema names.

--> EXPLORATORY DATA ANALYSIS
1. Exploratory & Macro Baseline Metrics
    Record Volume: Evaluated total row count (COUNT(*)) across the cleaned staging table.

    Carrier Footprint: Calculated distinct airline counts (COUNT(DISTINCT AIRLINE)) and listed carrier codes.

    Temporal Scope: Verified active dataset boundaries using MIN(flight_date) and MAX(flight_date).

    System Baselines: Computed global cancellation counts (CANCELLED = 1), overall cancellation percentage (SUM(CANCELLED = 1) / COUNT(*)), and overall average departure/arrival delays (AVG(DEPARTURE_DELAY), AVG(ARRIVAL_DELAY)).

2. Carrier Reliability & Performance Rankings
    Delay Breakdown: Joined flights_staging with airlines on IATA_CODE to aggregate total volume, average departure delay, and average arrival delay per airline (ORDER BY AVG_DEP_DELAY DESC, AVG_ARR_DELAY DESC).

    Cancellation Analysis: Calculated total scheduled flights, total cancellations, and cancellation rates grouped by carrier (ORDER BY CANCELLATION_RATE DESC) to pinpoint underperforming airlines.

3. Geographic & Airport Bottlenecks
    Outbound Delay Hotspots: Filtered origin airports with at least 10,000 outbound flights (HAVING COUNT(*) >= 10000) joined with airports dimension metadata to identify top 20 origin hubs with highest average departure delays.
    
    Inbound Arrival Congestion: Aggregated destination airports with >=10,000 inbound flights to isolate top 10 airports experiencing the highest average arrival delays.

4. Temporal Trend Analysis
    Monthly Progression: Extracted month numbers (MONTH(flight_date)) to track total flights, cancellations, cancellation percentages, and average arrival delays across the year.
    
    Day-of-Week Cycles: Grouped performance by day integer (DAYOFWEEK(flight_date)) to evaluate day-to-day volatility in departure delays, arrival delays, and cancellation rates.
5. Route & Distance Metrics
    Distance Tier Segmentation: Categorized flights into operational haul tiers using CASE statements:
    Short Haul (< 500 miles)
    Medium Haul (500 - 1500 miles)
    Long Haul (1501 - 3000 miles)
    Ultra Long Haul (> 3000 miles)
    Measured total volume, average arrival delay, and cancellation rate per tier.

    Top Air Corridors: Identified the top 10 most frequently flown route pairs (ORIGIN_AIRPORT --> DESTINATION_AIRPORT) with corresponding flight counts, average distance in miles, and average arrival delay metrics.

Key Business Insights & Strategic Recommendations

Core Analytical Insights
    1.Regional Carrier Vulnerability: Envoy Air / American Eagle (MQ) exhibited the highest cancellation rate. Regional partners operating short feeder routes into major hubs are routinely cancelled first during air traffic ground stops to preserve hub capacity for mainline routes.
    
    2.Geographic Hub Congestion: Outbound departure delays heavily concentrate at major hub airports such as Chicago O'Hare (ORD), Newark Liberty (EWR), and LaGuardia (LGA), averaging over 10–15 minutes of delay per flight.
    
    3.Weekly Volume & Delay Patterns: Mondays experience peak volume, highest departure delays (10.82 mins avg), and highest cancellation rates (2.43%) due to business travel demand. Saturdays show the lowest volume and average arrival delays (1.85 mins avg).
    
    4.Short-Haul vs. Long-Haul Recovery: Short-haul routes (<500 miles) face higher cancellation rates and delay propagation (e.g., SFO <--> LAX averaging +10–11 mins delay) because flights lack sufficient cruise time to recover from runway ground delays. High-density long-haul routes (e.g., JFK --> LAX) maintain early average arrival times (-2.67 mins) due to flight plan schedule padding.

Actionable Operational Recommendations

    1.Regional Feeder Buffers: Allocate dedicated standby crews and aircraft for regional feeder partners (MQ) at major hubs (ORD, DFW) to absorb local disruptions before cancellations cascade.

    2.Dynamic Staffing Alignment: Shift ground crew, maintenance, and gate personnel dynamically across the week—concentrating operational buffers on high-volume Monday/Thursday peaks and scheduling routine fleet servicing during low-demand Saturdays.

    3.Corridor Slot Optimization: De-congest high-density short corridors during peak morning/evening push hours by re-fleeting with larger aircraft operating at lower frequencies.

Tech Stack & Key SQL Constructs

    Database Management System: MySQL

    Ingestion: Bulk LOAD DATA LOCAL INFILE

    Schema Control: CREATE TABLE LIKE, ALTER TABLE, RENAME COLUMN, DROP COLUMN

    Data Cleaning Constructs: STR_TO_DATE(), CONCAT_WS(), TRIM(), REGEXP, CASE WHEN, UPDATE with NULL assignments

    Analytical Constructs: Window Functions (ROW_NUMBER() OVER PARTITION BY), Aggregations (COUNT, SUM, AVG, MIN, MAX), Explicit Null Handling, Conditional Summaries (SUM(CANCELLED = 1)), Multi-table LEFT JOIN, GROUP BY, HAVING, ORDER BY, LIMIT
