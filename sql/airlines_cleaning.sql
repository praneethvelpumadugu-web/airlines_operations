USE airline_operations;

-- imported airlines.csv file
SELECT * FROM airlines;
SELECT COUNT(*) FROM airlines;

-- imported airports.csv file
SELECT * FROM airports;
SELECT COUNT(*) FROM flights_staging;
TRUNCATE TABLE flights_staging;

SELECT scheduled_departure_time FROM flights_staging
LIMIT 10;

SHOW TABLES;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/prane/OneDrive/Desktop/airlines_operations/flights.csv'
INTO TABLE flights
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DESCRIBE flights;
SELECT * FROM flights
LIMIT 10;
SELECT COUNT(*) FROM flights;

-- creating staging dataset

DROP TABLE IF EXISTS flights_staging;

CREATE TABLE flights_staging
LIKE  flights;

INSERT INTO flights_staging
SELECT * FROM flights;

DESCRIBE flights_staging;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/prane/OneDrive/Desktop/airlines_operations/flights.csv'
INTO TABLE flights_staging
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SET SQL_SAFE_UPDATES = 0;

-- DATA CLEANING
-- FINDING MISSING VALUES
SELECT
    COUNT(*) AS total_rows,

    SUM(DEPARTURE_TIME IS NULL) AS missing_departure_time,
    SUM(DEPARTURE_DELAY IS NULL) AS missing_departure_delay,
    SUM(TAXI_OUT IS NULL) AS missing_taxi_out,
    SUM(WHEELS_OFF IS NULL) AS missing_wheels_off,
    SUM(ELAPSED_TIME IS NULL) AS missing_elapsed_time,
    SUM(AIR_TIME IS NULL) AS missing_air_time,
    SUM(WHEELS_ON IS NULL) AS missing_wheels_on,
    SUM(TAXI_IN IS NULL) AS missing_taxi_in,
    SUM(ARRIVAL_TIME IS NULL) AS missing_arrival_time,
    SUM(ARRIVAL_DELAY IS NULL) AS missing_arrival_delay,

    SUM(CANCELLATION_REASON IS NULL OR CANCELLATION_REASON = '') 
        AS missing_cancellation_reason,

    SUM(AIR_SYSTEM_DELAY IS NULL OR AIR_SYSTEM_DELAY = '') 
        AS missing_air_system_delay,

    SUM(SECURITY_DELAY IS NULL OR SECURITY_DELAY = '') 
        AS missing_security_delay,

    SUM(AIRLINE_DELAY IS NULL OR AIRLINE_DELAY = '') 
        AS missing_airline_delay,

    SUM(LATE_AIRCRAFT_DELAY IS NULL OR LATE_AIRCRAFT_DELAY = '') 
        AS missing_late_aircraft_delay,

    SUM(WEATHER_DELAY IS NULL OR WEATHER_DELAY = '') 
        AS missing_weather_delay
FROM flights_staging;

SELECT
    COUNT(*) AS total_rows,

    SUM(DEPARTURE_DELAY = 0) AS departure_delay_zero,
    SUM(TAXI_OUT = 0) AS taxi_out_zero,
    SUM(SCHEDULED_TIME = 0) AS scheduled_time_zero,
    SUM(ELAPSED_TIME = 0) AS elapsed_time_zero,
    SUM(AIR_TIME = 0) AS air_time_zero,
    SUM(DISTANCE = 0) AS distance_zero,
    SUM(TAXI_IN = 0) AS taxi_in_zero,
    SUM(ARRIVAL_DELAY = 0) AS arrival_delay_zero
FROM flights_staging;

SELECT * FROM flights_staging
WHERE DEPARTURE_DELAY=0;

SELECT ARRIVAL_TIME ,CANCELLED,DEPARTURE_DELAY
FROM flights_staging
WHERE CANCELLED=1;

SELECT
    COUNT(*) AS cancelled_flights,

    SUM(DEPARTURE_DELAY = 0) AS departure_delay_zero,
    SUM(TAXI_OUT = 0) AS taxi_out_zero,
    SUM(ELAPSED_TIME = 0) AS elapsed_time_zero,
    SUM(AIR_TIME = 0) AS air_time_zero,
    SUM(TAXI_IN = 0) AS taxi_in_zero,
    SUM(ARRIVAL_DELAY = 0) AS arrival_delay_zero,

    SUM(DEPARTURE_TIME IS NULL OR TRIM(DEPARTURE_TIME) = '') AS missing_departure_time,
    SUM(ARRIVAL_TIME IS NULL OR TRIM(ARRIVAL_TIME) = '') AS missing_arrival_time
FROM flights_staging
WHERE CANCELLED = 1;


-- NULL HANDLING

UPDATE flights_staging
SET DEPARTURE_DELAY = NULL
WHERE CANCELLED=1 AND ARRIVAL_TIME='';

UPDATE flights_staging
SET ARRIVAL_TIME = NULL
WHERE CANCELLED=1;

SELECT
    SUM(CANCELLED = 1 AND DEPARTURE_DELAY IS NULL) AS cancelled_missing_departure_delay,
    SUM(CANCELLED = 1 AND ARRIVAL_TIME IS NULL) AS cancelled_missing_arrival_time
FROM flights_staging;

SELECT ARRIVAL_TIME,DEPARTURE_DELAY,TAXI_IN,CANCELLED
FROM flights_staging
WHERE CANCELLED=1;

UPDATE flights_staging
SET TAXI_IN = NULL
WHERE CANCELLED=1;

SELECT
    COUNT(*) AS cancelled_flights,

    SUM(TAXI_OUT = 0) AS taxi_out_zero,
    SUM(ELAPSED_TIME = 0) AS elapsed_time_zero,
    SUM(AIR_TIME = 0) AS air_time_zero,
    SUM(ARRIVAL_DELAY = 0) AS arrival_delay_zero

FROM flights_staging
WHERE CANCELLED = 1;

SELECT ARRIVAL_TIME,DEPARTURE_DELAY,TAXI_IN,TAXI_OUT,ELAPSED_TIME,AIR_TIME,ARRIVAL_DELAY,CANCELLED
FROM flights_staging
WHERE CANCELLED=1;

UPDATE flights_staging
SET
    TAXI_OUT = NULL,
    ELAPSED_TIME = NULL,
    AIR_TIME = NULL,
    ARRIVAL_DELAY = NULL
WHERE CANCELLED = 1;

SELECT ARRIVAL_TIME,DEPARTURE_DELAY,DEPARTURE_TIME,WHEELS_OFF,WHEELS_ON,CANCELLED
FROM flights_staging
WHERE CANCELLED=1;

UPDATE flights_staging
SET
    DEPARTURE_TIME = NULL,
    WHEELS_OFF = NULL,
    WHEELS_ON = NULL
WHERE CANCELLED = 1;

SELECT COUNT(*) FROM flights_staging
WHERE CANCELLED=0 AND CANCELLATION_REASON ='';

UPDATE flights_staging
SET CANCELLATION_REASON = NULL
WHERE CANCELLED = 0 AND CANCELLATION_REASON = '';

SELECT CANCELLED,SUM(TAIL_NUMBER='') FROM flights
GROUP BY CANCELLED;

UPDATE flights_staging
SET TAIL_NUMBER = NULL
WHERE CANCELLED = 1 AND TAIL_NUMBER = '';

SELECT COUNT(*) FROM flights_staging
WHERE AIR_SYSTEM_DELAY='' AND SECURITY_DELAY='' AND AIRLINE_DELAY='' AND LATE_AIRCRAFT_DELAY='' AND WEATHER_DELAY='';

UPDATE flights_staging
SET
    AIR_SYSTEM_DELAY = NULL,
    SECURITY_DELAY = NULL,
    AIRLINE_DELAY = NULL,
    LATE_AIRCRAFT_DELAY = NULL,
    WEATHER_DELAY = NULL
WHERE AIR_SYSTEM_DELAY = ''
  AND SECURITY_DELAY = ''
  AND AIRLINE_DELAY = ''
  AND LATE_AIRCRAFT_DELAY = ''
  AND WEATHER_DELAY = '';

-- TRIM CHECKING 

SELECT COUNT(*) AS rows_with_spaces
FROM flights_staging
WHERE AIRLINE != TRIM(AIRLINE);

SELECT
    SUM(ORIGIN_AIRPORT != TRIM(ORIGIN_AIRPORT)) AS origin_spaces,
    SUM(DESTINATION_AIRPORT != TRIM(DESTINATION_AIRPORT)) AS destination_spaces,
    SUM(TAIL_NUMBER != TRIM(TAIL_NUMBER)) AS tail_spaces
FROM flights_staging;

SELECT DISTINCT AIRLINE FROM flights_staging;

SELECT ORIGIN_AIRPORT, COUNT(*) AS count
FROM flights_staging
GROUP BY ORIGIN_AIRPORT
ORDER BY ORIGIN_AIRPORT;

SELECT COUNT(DISTINCT ORIGIN_AIRPORT) FROM flights_staging;

SELECT COUNT(DISTINCT ORIGIN_AIRPORT) FROM flights_staging
WHERE ORIGIN_AIRPORT REGEXP '^[A-Z]{3}$';

SELECT COUNT(DISTINCT ORIGIN_AIRPORT) FROM flights_staging
WHERE ORIGIN_AIRPORT REGEXP '[0-9]';

-- DUPLICATE ROWS
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `YEAR`,`MONTH`,`DAY`,AIRLINE,FLIGHT_NUMBER,ORIGIN_AIRPORT,DESTINATION_AIRPORT) 
FROM flights_staging;

SELECT
    `YEAR`,
    `MONTH`,
    `DAY`,
    AIRLINE,
    FLIGHT_NUMBER,
    ORIGIN_AIRPORT,
    DESTINATION_AIRPORT,
    SCHEDULED_DEPARTURE,
    COUNT(*) AS duplicate_count
FROM flights_staging
GROUP BY
    `YEAR`,
    `MONTH`,
    `DAY`,
    AIRLINE,
    FLIGHT_NUMBER,
    ORIGIN_AIRPORT,
    DESTINATION_AIRPORT,
    SCHEDULED_DEPARTURE
HAVING COUNT(*) > 1
LIMIT 20;

-- SINCE ALL ROWS HAVE 1 HAS ROW_NUMBER THAT MEANS NO DUPLICATE RECORDS.

-- INVALID AND INCONSISTENT VALUES

SELECT DISTINCT DAY_OF_WEEK FROM flights_staging;
SELECT DISTINCT MONTH FROM flights_staging;
SELECT DISTINCT `DAY` FROM flights_staging;
SELECT COUNT(*) AS invalid_flight_dates
FROM flights_staging
WHERE flight_date IS NULL;

SELECT DISTINCT AIRLINE FROM flights_staging;

SELECT COUNT(*) AS invalid_flight_numbers
FROM flights_staging
WHERE FLIGHT_NUMBER <= 0;

SELECT COUNT(*) AS empty_origin
FROM flights_staging
WHERE ORIGIN_AIRPORT = '';

SELECT COUNT(*) FROM flights_staging WHERE DISTANCE<0;

SELECT COUNT(*) AS invalid_departure_time
FROM flights_staging
WHERE DEPARTURE_TIME != ''
  AND (
      CAST(DEPARTURE_TIME AS UNSIGNED) > 2359
      OR MOD(CAST(DEPARTURE_TIME AS UNSIGNED), 100) > 59
  );
  
  SELECT DEPARTURE_TIME, COUNT(*) AS count
FROM flights_staging
WHERE DEPARTURE_TIME != ''
  AND (
      CAST(DEPARTURE_TIME AS UNSIGNED) > 2359
      OR MOD(CAST(DEPARTURE_TIME AS UNSIGNED), 100) > 59
  )
GROUP BY DEPARTURE_TIME
ORDER BY DEPARTURE_TIME;

-- DATA TYPE AND / FORMAT VALIDATION

ALTER TABLE flights_staging
ADD COLUMN flight_date DATE;

UPDATE flights_staging
SET flight_date=STR_TO_DATE(CONCAT_WS('-',`YEAR`,`MONTH`,`DAY`),'%Y-%m-%d');

ALTER TABLE flights_staging
ADD COLUMN scheduled_departure_time TIME;

UPDATE flights_staging 
SET scheduled_departure_time=STR_TO_DATE(SCHEDULED_DEPARTURE,'%H%i');

SELECT SCHEDULED_DEPARTURE_TIME FROM flights_staging
WHERE SCHEDULED_DEPARTURE_TIME IS NULL;

ALTER TABLE flights_staging
ADD COLUMN scheduled_arrival_time TIME,
ADD COLUMN wheels_on_time TIME,
ADD COLUMN wheels_off_time TIME;

UPDATE flights_staging
SET scheduled_arrival_time=
	CASE
		WHEN SCHEDULED_ARRIVAL=2400 THEN '00:00:00'
        ELSE STR_TO_DATE(SCHEDULED_ARRIVAL,'%H%i')
	END;

SELECT COUNT(*) FROM flights_staging
WHERE CANCELLED=0 AND scheduled_arrival_time IS NULL AND SCHEDULED_ARRIVAL IS NOT NULL;

SELECT SCHEDULED_ARRIVAL, scheduled_arrival_time FROM flights_staging
WHERE CAST(SCHEDULED_ARRIVAL AS UNSIGNED)>2359;

UPDATE flights_staging
SET wheels_on_time=
	CASE
		WHEN WHEELS_ON=2400 THEN '00:00:00'
        ELSE STR_TO_DATE(WHEELS_ON,'%H%i')
	END;

SELECT COUNT(*) FROM flights_staging
WHERE CANCELLED=0 AND wheels_on_time IS NULL AND WHEELS_ON IS NOT NULL;

SELECT WHEELS_ON, wheels_on_time FROM flights_staging
WHERE CAST(WHEELS_ON AS UNSIGNED)>2359;

UPDATE flights_staging
SET wheels_off_time=
	CASE
		WHEN WHEELS_OFF=2400 THEN '00:00:00'
        ELSE STR_TO_DATE(WHEELS_OFF,'%H%i')
	END;

SELECT COUNT(*) FROM flights_staging
WHERE CANCELLED=0 AND wheels_off_time IS NULL AND WHEELS_OFF IS NOT NULL;

SELECT WHEELS_OFF, wheels_off_time FROM flights_staging
WHERE CAST(WHEELS_OFF AS UNSIGNED)>2359;

ALTER TABLE flights_staging 
ADD COLUMN departure_time_fmt TIME;

UPDATE flights_staging
SET departure_time_fmt=
	CASE
		WHEN DEPARTURE_TIME=2400 THEN '00:00:00'
        ELSE STR_TO_DATE(DEPARTURE_TIME,'%H%i')
	END;

SELECT COUNT(*) FROM flights_staging
WHERE CANCELLED=0 AND departure_time_fmt IS NULL AND DEPARTURE_TIME IS NOT NULL;

SELECT DEPARTURE_TIME, departure_time_fmt FROM flights_staging
WHERE CAST(DEPARTURE_TIME AS UNSIGNED)>2359;

ALTER TABLE flights_staging 
ADD COLUMN arrival_time_fmt TIME;

UPDATE flights_staging
SET arrival_time_fmt=
	CASE
		WHEN ARRIVAL_TIME=2400 THEN '00:00:00'
        ELSE STR_TO_DATE(ARRIVAL_TIME,'%H%i')
	END;

SELECT COUNT(*) FROM flights_staging
WHERE CANCELLED=0 AND arrival_time_fmt IS NULL AND ARRIVAL_TIME IS NOT NULL;

SELECT ARRIVAL_TIME, arrival_time_fmt FROM flights_staging
WHERE CAST(ARRIVAL_TIME AS UNSIGNED)>2359;

-- DROPPING REDUNDANT AND RAW TEMPORAL COLUMNS
ALTER TABLE flights_staging
DROP COLUMN `YEAR`,
DROP COLUMN `MONTH`,
DROP COLUMN `DAY`,
DROP COLUMN DAY_OF_WEEK,
DROP COLUMN SCHEDULED_DEPARTURE,
DROP COLUMN SCHEDULED_ARRIVAL,
DROP COLUMN WHEELS_ON,
DROP COLUMN WHEELS_OFF,
DROP COLUMN DEPARTURE_TIME,
DROP COLUMN ARRIVAL_TIME;

ALTER TABLE flights_staging
RENAME COLUMN scheduled_departure_time  TO SCHEDULED_DEPARTURE,
RENAME COLUMN  scheduled_arrival_time TO SCHEDULED_ARRIVAL,
RENAME COLUMN departure_time_fmt TO DEPARTURE_TIME,
RENAME COLUMN wheels_on_time TO WHEELS_ON,
RENAME COLUMN wheels_off_time TO WHEELS_OFF,
RENAME COLUMN arrival_time_fmt TO ARRIVAL_TIME;

DESCRIBE flights_staging;