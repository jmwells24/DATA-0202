-- Design Project 2: Operate Your Own Airline  --

-- Insert scripts
CREATE SCHEMA project2;

SET search_path TO project2;


-- Insert data into airports table
DELETE FROM airports;
INSERT INTO airports (airport_code, airport_name, city, country, timezone) VALUES
('BOS', 'Logan International Airport', 'Boston', 'United States', 'America/New_York'),
('LHR', 'Heathrow Airport', 'London', 'United Kingdom', 'Europe/London'),
('CPT', 'Cape Town Intl Airport', 'Cape Town', 'South Africa', 'Africa/Johannesburg'),
('SIN', 'Changi Airport', 'Singapore', 'Singapore', 'Asia/Singapore');

SELECT * FROM airports;


-- Insert data into planes table
DELETE FROM planes;
INSERT INTO planes (registration_number, model_name, first_class_seats, business_class_seats) VALUES
('N123AA', 'Boeing 787 Dreamliner', 12, 48),
('N321BB', 'Airbus A350', 12, 48);

SELECT * FROM planes;


-- Insert data into routes table
DELETE FROM routes;
INSERT INTO routes (origin_airport, destination_airport, publish_fare_usd, hourly_cost_usd) VALUES
('BOS', 'LHR', 850.00, 75.00), -- Boston to London
('LHR', 'CPT', 850.00, 75.00), -- London to Cape Town
('CPT', 'LHR', 900.00, 75.00), -- Cape Town to London
('LHR', 'BOS', 900.00, 75.00), -- London to Boston
('BOS', 'SIN', 1100.00, 50.00), -- Boston to Singapore
('SIN', 'BOS', 1200.00, 50.00); -- Singapore to Boston

SELECT * FROM routes;


-- Insert data into flights table
DELETE FROM flights;
-- Boston to London (Mondays)
INSERT INTO flights (flight_id, registration_number, origin_airport, destination_airport, departure_time, arrival_time)
SELECT 
  'BOS-LHR', 'N123AA', 'BOS', 'LHR',
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 9,0,0, 'America/New_York') AS departure_time,
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 9,0,0, 'Europe/London') + INTERVAL '7 hours' AS arrival_time
FROM generate_series('2025-01-06'::date, '2025-12-29'::date, interval '1 week') d;

-- London to Cape Town (Mondays, after layover)
INSERT INTO flights (flight_id, registration_number, origin_airport, destination_airport, departure_time, arrival_time)
SELECT 
  'LHR-CPT', 'N123AA', 'LHR', 'CPT',
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 18,0,0, 'Europe/London') AS departure_time,
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 18,0,0, 'Africa/Johannesburg') + INTERVAL '7.5 hours' AS arrival_time
FROM generate_series('2025-01-06', '2025-12-29', interval '1 week') d;

-- Cape Town to London (Fridays)
INSERT INTO flights (flight_id, registration_number, origin_airport, destination_airport, departure_time, arrival_time)
SELECT 
  'CPT-LHR', 'N123AA', 'CPT', 'LHR',
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 9,0,0, 'Africa/Johannesburg') AS departure_time,
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 9,0,0, 'Europe/London') + INTERVAL '7.5 hours' AS arrival_time
FROM generate_series('2025-01-03', '2025-12-26', interval '1 week') d;

-- London to Boston (Fridays)
INSERT INTO flights (flight_id, registration_number, origin_airport, destination_airport, departure_time, arrival_time)
SELECT 
  'LHR-BOS', 'N123AA', 'LHR', 'BOS',
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 18,0,0, 'Europe/London') AS departure_time,
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 18,0,0, 'America/New_York') + INTERVAL '7 hours' AS arrival_time
FROM generate_series('2025-01-03', '2025-12-26', interval '1 week') d;

-- Boston to Singapore (Mondays)
INSERT INTO flights (flight_id, registration_number, origin_airport, destination_airport, departure_time, arrival_time)
SELECT 
  'BOS-SIN', 'N321BB', 'BOS', 'SIN',
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 10,0,0, 'America/New_York') AS departure_time,
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 10,0,0, 'Asia/Singapore') + INTERVAL '18.5 hours' AS arrival_time
FROM generate_series('2025-01-06', '2025-12-29', interval '1 week') d;

-- Singapore to Boston (Fridays)
INSERT INTO flights (flight_id, registration_number, origin_airport, destination_airport, departure_time, arrival_time)
SELECT 
  'SIN-BOS', 'N321BB', 'SIN', 'BOS',
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 20,0,0, 'America/New_York') AS departure_time,
  make_timestamptz(EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, EXTRACT(DAY FROM d)::int, 20,0,0, 'Asia/Singapore') + INTERVAL '17.5 hours' AS arrival_time
FROM generate_series('2025-01-03', '2025-12-26', interval '1 week') d;

SELECT * FROM flights;


-- Insert data into passengers table
DELETE FROM passengers;
INSERT INTO passengers (passport_number, first_name, last_name, country_of_issue, expiration_date)
SELECT 
  'PAS' || chr(trunc(random() * 26 + 65)::int) ||  -- random uppercase A-Z
           trunc(random() * 9 + 1)::int ||         -- digit 1–9
           chr(trunc(random() * 26 + 65)::int) || 
           trunc(random() * 9 + 1)::int ||
           chr(trunc(random() * 26 + 65)::int) || 
           trunc(random() * 9 + 1)::int || 
           chr(trunc(random() * 26 + 65)::int),                          -- Generate a fake passport number (20 characters)
  fp.first_name,                             -- Use first name from faker_person()
  fp.last_name,                              -- Use last name from faker_person()
  CASE 
    WHEN random() < 0.25 THEN 'United States'
    WHEN random() < 0.5 THEN 'South Africa'  -- South Africa
    WHEN random() < 0.75 THEN 'Singapore'  -- Singapore
    ELSE 'United Kingdom'                       -- United Kingdom  
  END,                                      
  DATE '2026-01-01' + ((random() * (DATE '2035-12-31' - DATE '2026-01-01'))::int)  -- Random expiration date between 2026-01-01 and 2035-12-31
FROM (
  SELECT (faker_person()).* 
  FROM generate_series(1,5000)
) fp

SELECT * FROM passengers;


-- Insert into reservations table
DELETE FROM reservations;

INSERT INTO reservations (reservation_code, flight_id, departure_time, reservation_date)
SELECT 
  'RES' || chr(trunc(random() * 26 + 65)::int) ||
            trunc(random() * 9)::int ||
            chr(trunc(random() * 26 + 65)::int) ||
            trunc(random() * 9)::int ||
            chr(trunc(random() * 26 + 65)::int) ||
            trunc(random() * 9)::int ||
            chr(trunc(random() * 26 + 65)::int),
  f.flight_id,
  f.departure_time,
  (
    (f.departure_time::date - INTERVAL '3 months') +
    (random() * ((f.departure_time::date - INTERVAL '1 day') - (f.departure_time::date - INTERVAL '3 months')))
  )::date AS reservation_date
FROM flights f
CROSS JOIN  generate_series(1, 30) gs; 
SELECT * FROM reservations ;

-- Insert into reservation_passenger table
DELETE FROM reservation_passengers;

-- Insert passengers for each reservation (guaranteed 1–5 per reservation)
INSERT INTO reservation_passengers (
  reservation_code,
  passport_number,
  country_of_issue,
  class_of_service,
  seat_number
)
SELECT 
  r.reservation_code,
  p.passport_number,
  p.country_of_issue,
  CASE 
    WHEN random() < 0.2 THEN 'First'
    ELSE 'Business'
  END AS class_of_service,
  CASE 
    WHEN random() < 0.2 THEN 
      'F-' || (trunc(random() * 3 + 1))::int || CHR(65 + trunc(random() * 4)::int)
    ELSE 
      'B-' || (trunc(random() * 12 + 4))::int || CHR(65 + trunc(random() * 4)::int)
  END AS seat_number
FROM reservations r
JOIN LATERAL (
  SELECT passport_number, country_of_issue
  FROM passengers
  ORDER BY random()
  LIMIT (trunc(random() * 5 + 1))  
) p ON true;

SELECT * FROM reservation_passengers;

-- show reservation_passengers with flight departure time
SELECT rp.*, r.flight_id, r.departure_time
FROM reservation_passengers rp, reservations r
WHERE rp.reservation_code = r.reservation_code;

