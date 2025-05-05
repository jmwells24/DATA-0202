SET search_path TO project2;

-- Fake Person Generator
DROP FUNCTION IF EXISTS faker_person;
CREATE OR REPLACE FUNCTION faker_person() RETURNS TABLE(last_name varchar(50), first_name varchar(50), email varchar(100), phone varchar(30), address varchar(255), city varchar(50), state varchar(2), zip varchar(10)) LANGUAGE plpython3u AS 
$$
	from faker import Faker
	import numpy as np
	fake = Faker()
	# reshape make the array 1 row, -1 (means as many columns as needed)
	return np.array([fake.last_name(), fake.first_name(), fake.email(), fake.phone_number(), fake.address(), fake.city(), fake.state(), fake.zipcode()]).reshape(1,-1)
$$;

-- Use in a query
SELECT (faker_person()).* FROM generate_series(1,100);

-- Fake Passport Generator
DROP FUNCTION IF EXISTS faker_passport;
CREATE OR REPLACE FUNCTION faker_passport()
RETURNS TEXT AS $$
  SELECT 'PAS' || 
         chr(trunc(random() * 26 + 65)::int) ||  -- random uppercase A-Z
         trunc(random() * 9 + 1)::int ||         -- digit 1–9
         chr(trunc(random() * 26 + 65)::int) || 
         trunc(random() * 9 + 1)::int ||
         chr(trunc(random() * 26 + 65)::int) || 
         trunc(random() * 9 + 1)::int ||
         chr(trunc(random() * 26 + 65)::int);
$$ LANGUAGE sql;

-- Use in a query
SELECT faker_passport();


-- Fake Country of Issue Generator
DROP FUNCTION IF EXISTS faker_country_issue;
CREATE OR REPLACE FUNCTION faker_country_issue()
RETURNS VARCHAR AS $$
    import random
    # Define the allowed country codes for the airports.
    allowed_countries = ['US', 'ZA', 'SG', 'UK']
    return random.choice(allowed_countries)
$$ LANGUAGE plpython3u;


-- Fake Reservation Code Generator
DROP FUNCTION IF EXISTS faker_reservation_code();
CREATE OR REPLACE FUNCTION faker_reservation_code()
RETURNS TEXT AS $$
  SELECT 'RES' || 
         chr(trunc(random() * 26 + 65)::int) ||  -- random uppercase A-Z
         trunc(random() * 9 + 1)::int ||         -- digit 1–9
         chr(trunc(random() * 26 + 65)::int) || 
         trunc(random() * 9 + 1)::int ||
         chr(trunc(random() * 26 + 65)::int) || 
         trunc(random() * 9 + 1)::int ||
         chr(trunc(random() * 26 + 65)::int);
$$ LANGUAGE sql;

