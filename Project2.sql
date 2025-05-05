-- Design Project 2: Operate Your Own Airline  --

CREATE SCHEMA project2;

SET search_path TO project2;

-- Table: airports
DROP TABLE IF EXISTS airports CASCADE;
CREATE TABLE airports (
    airport_code   CHAR(3) PRIMARY KEY,   -- e.g., LAX, JFK, SIN
    airport_name   VARCHAR(100) NOT NULL,
    city           VARCHAR(100) NOT NULL,
    country        VARCHAR(100) NOT NULL,
    timezone       VARCHAR(50) NOT NULL   -- IANA timezone string (e.g., America/New_York)
);

-- Table: planes
DROP TABLE IF EXISTS planes CASCADE;
CREATE TABLE planes (
    registration_number VARCHAR(20) PRIMARY KEY,  -- e.g., "N12345AB"
    model_name          VARCHAR(100) NOT NULL,
    first_class_seats   SMALLINT NOT NULL, 
    business_class_seats SMALLINT NOT NULL
);

-- Table: routes
DROP TABLE IF EXISTS routes CASCADE;
CREATE TABLE routes (
    origin_airport      CHAR(3) NOT NULL,
    destination_airport CHAR(3) NOT NULL,
    publish_fare_usd    NUMERIC(7,2) NOT NULL CHECK (publish_fare_usd > 0),
    hourly_cost_usd     NUMERIC(7,2) NOT NULL CHECK (hourly_cost_usd > 0),

    CONSTRAINT pk_routes PRIMARY KEY (origin_airport, destination_airport),

    CONSTRAINT fk_origin_airport FOREIGN KEY (origin_airport)
         REFERENCES airports(airport_code)
         ON UPDATE CASCADE
         ON DELETE CASCADE,

    CONSTRAINT fk_destination_airport FOREIGN KEY (destination_airport)
         REFERENCES airports(airport_code)
         ON UPDATE CASCADE
         ON DELETE RESTRICT
);

-- Table: flights
DROP TABLE IF EXISTS flights CASCADE;
CREATE TABLE flights (
    flight_id            VARCHAR(10) NOT NULL,  
    registration_number  VARCHAR(20) NOT NULL,  -- FK to planes
    origin_airport       CHAR(3) NOT NULL,      -- FK to airports
    destination_airport  CHAR(3) NOT NULL,      -- FK to airports
    departure_time       TIMESTAMPTZ NOT NULL,
    arrival_time         TIMESTAMPTZ NOT NULL,

    CONSTRAINT pk_flight PRIMARY KEY (flight_id, departure_time),

    CONSTRAINT fk_flight_plane FOREIGN KEY (registration_number)
         REFERENCES planes(registration_number)
         ON UPDATE CASCADE
         ON DELETE RESTRICT,

    CONSTRAINT fk_flight_origin FOREIGN KEY (origin_airport)
         REFERENCES airports(airport_code)
         ON UPDATE CASCADE
         ON DELETE RESTRICT,

    CONSTRAINT fk_flight_destination FOREIGN KEY (destination_airport)
         REFERENCES airports(airport_code)
         ON UPDATE CASCADE
         ON DELETE RESTRICT,

    CONSTRAINT ck_flight_time CHECK (arrival_time > departure_time)
);

-- Table: passengers
DROP TABLE IF EXISTS passengers CASCADE;
CREATE TABLE passengers (
    passport_number   CHAR(20) NOT NULL,   -- full 20 characters; include country code prefix
    country_of_issue  VARCHAR(50) NOT NULL, 
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    expiration_date   DATE NOT NULL,
    
    CONSTRAINT pk_passengers PRIMARY KEY (passport_number, country_of_issue)
);

-- Table: reservations
DROP TABLE IF EXISTS reservations CASCADE;
CREATE TABLE reservations (
    reservation_code  CHAR(20) PRIMARY KEY,
    flight_id         VARCHAR(10) NOT NULL,
    departure_time    TIMESTAMPTZ NOT NULL,
    reservation_date  DATE NOT NULL,

    CONSTRAINT fk_reservation_flight FOREIGN KEY (flight_id, departure_time)
         REFERENCES flights(flight_id, departure_time)
         ON UPDATE CASCADE
         ON DELETE CASCADE
);

-- Table: reservation_passengers
DROP TABLE IF EXISTS reservation_passengers CASCADE;
CREATE TABLE reservation_passengers (
    reservation_code  CHAR(20) NOT NULL,
    passport_number   CHAR(20) NOT NULL,
    country_of_issue  VARCHAR(50) NOT NULL,
    class_of_service  VARCHAR(20) NOT NULL CHECK (class_of_service IN ('First','Business')),
    seat_number       VARCHAR(5) NOT NULL,

    CONSTRAINT pk_reservation_passengers PRIMARY KEY (reservation_code, passport_number),

    CONSTRAINT fk_rp_reservation FOREIGN KEY (reservation_code)
         REFERENCES reservations(reservation_code)
         ON UPDATE CASCADE
         ON DELETE CASCADE,

    CONSTRAINT fk_rp_passenger FOREIGN KEY (passport_number, country_of_issue)
         REFERENCES passengers(passport_number, country_of_issue)
         ON UPDATE CASCADE
         ON DELETE CASCADE
);
