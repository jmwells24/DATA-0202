-- Design Project 2: Operate Your Own Airline  --

-- Query scripts
CREATE SCHEMA project2;

SET search_path TO project2;


-- ===============
-- Example Queries 
-- ===============

-- Did you, will you make money?
-- Profit for each flight
WITH flight_data AS (
  SELECT
    f.flight_id,
    f.departure_time,
    COUNT(DISTINCT rp.seat_number) AS seats_filled,
    ROUND(COUNT(DISTINCT rp.seat_number) * r.publish_fare_usd,2) AS revenue,
    ROUND(SUM(EXTRACT(EPOCH FROM (f.arrival_time - f.departure_time)) / 3600 * r.hourly_cost_usd),2) AS total_operating_cost,
    ROUND(COUNT(DISTINCT rp.seat_number) * r.publish_fare_usd - SUM(EXTRACT(EPOCH FROM (f.arrival_time - f.departure_time)) / 3600 * r.hourly_cost_usd),2) AS profit
  FROM flights f
  INNER JOIN routes r ON f.origin_airport = r.origin_airport AND f.destination_airport = r.destination_airport
  INNER JOIN reservations res ON f.flight_id = res.flight_id AND f.departure_time = res.departure_time
  INNER JOIN reservation_passengers rp ON res.reservation_code = rp.reservation_code
  GROUP BY
    f.flight_id,
    f.departure_time,
    r.publish_fare_usd,
    r.hourly_cost_usd
)
SELECT
  flight_id,
  departure_time,
  seats_filled,
  revenue,
  total_operating_cost,
  profit
FROM flight_data
ORDER BY flight_id, departure_time;

-- Overall Profit
WITH flight_data AS (
  SELECT
    f.flight_id,
    f.departure_time,
    COUNT(DISTINCT rp.seat_number) AS seats_filled,
    ROUND(COUNT(DISTINCT rp.seat_number) * r.publish_fare_usd,2) AS revenue,
    ROUND(SUM( EXTRACT(EPOCH FROM (f.arrival_time - f.departure_time)) / 3600 * r.hourly_cost_usd),2) AS total_operating_cost,
    ROUND(COUNT(DISTINCT rp.seat_number) * r.publish_fare_usd - SUM(EXTRACT(EPOCH FROM (f.arrival_time - f.departure_time)) / 3600 * r.hourly_cost_usd),2) AS profit
  FROM flights f
  INNER JOIN routes r ON f.origin_airport = r.origin_airport AND f.destination_airport = r.destination_airport
  INNER JOIN reservations res ON f.flight_id = res.flight_id AND f.departure_time = res.departure_time
  INNER JOIN reservation_passengers rp ON res.reservation_code = rp.reservation_code
  GROUP BY
    f.flight_id,
    f.departure_time,
    r.publish_fare_usd,
    r.hourly_cost_usd
)
SELECT
  ROUND(SUM(profit),2) AS overall_profit
FROM flight_data;



-- How many seats are filled or remaining on a particular flight?
     -- This assumes 60 total seats (12 First + 48 Business) as discussed.
SELECT 
  f.flight_id,
  f.departure_time,
  COUNT(DISTINCT rp.seat_number) AS seats_filled,
  60 - COUNT(DISTINCT rp.seat_number) AS seats_remaining
FROM flights f
INNER JOIN reservations r ON f.flight_id = r.flight_id AND f.departure_time = r.departure_time
INNER JOIN reservation_passengers rp ON r.reservation_code = rp.reservation_code
GROUP BY f.flight_id, f.departure_time
ORDER BY f.flight_id, f.departure_time;

 -- Departure and Arrival Times in Local Time Zones
SELECT 
  f.flight_id,
  f.departure_time AT TIME ZONE ao.timezone AS departure_local_time,
  ao.airport_code AS origin,
  f.arrival_time AT TIME ZONE ad.timezone AS arrival_local_time,
  ad.airport_code AS destination
FROM flights f
INNER JOIN airports ao ON f.origin_airport = ao.airport_code
INNER JOIN airports ad ON f.destination_airport = ad.airport_code
ORDER BY f.flight_id, f.departure_time;
