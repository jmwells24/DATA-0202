CREATE SCHEMA project1;

SET search_path TO project1;

-- 1. Patients
-- Purpose: Stores information about dental patients.

CREATE TABLE patients (
    patient_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    date_of_birth  DATE NOT NULL,
    gender         CHAR(1) NOT NULL,
    phone          VARCHAR(20),
    email          VARCHAR(100),
    street         VARCHAR(100),
    city           VARCHAR(50),
    state          VARCHAR(20),
    zip            VARCHAR(10)
);

ALTER TABLE patients ADD CONSTRAINT ck_gender CHECK (gender IN ('M','F'));


-- Inserts for Patients

INSERT INTO patients (first_name, last_name, date_of_birth, gender, phone, email, street, city, state, zip)
VALUES
  ('John', 'Doe', '1980-05-15', 'M', '555-1234', 'john.doe@example.com', '123 Elm St', 'Medford', 'MA', '02155'),
  ('Jane', 'Smith', '1990-08-20', 'F', '555-5678', 'jane.smith@example.com', '456 Oak St', 'Medford', 'MA', '02155'),
  ('Alice', 'Johnson', '1975-12-30', 'F', '555-9012', 'alice.johnson@example.com', '789 Pine St', 'Boston', 'MA', '02134');
  

------------------------------------------------------------

-- 2. Dentists
-- Purpose: Contains information about dental practitioners.

CREATE TABLE dentists (
    dentist_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    phone          VARCHAR(20),
    email          VARCHAR(100)
);


-- Inserts for Dentists

INSERT INTO dentists (first_name, last_name, phone, email)
VALUES
  ('Emily', 'Clark', '555-1111', 'eclark@dentistry.com'),
  ('Michael', 'Brown', '555-2222', 'mbrown@dentistry.com');



------------------------------------------------------------

-- 3. Appointments
-- Purpose: Tracks scheduled appointments between patients and dentists.

CREATE TABLE appointments (
    appointment_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id        INT NOT NULL,
    dentist_id        INT NOT NULL,
    appointment_range tsrange NOT NULL,  -- Time range for the appointment (start to end)
    status            VARCHAR(20) NOT NULL,
    reason            VARCHAR(255)
);

ALTER TABLE appointments
ADD CONSTRAINT ck_status
CHECK (status IN ('Scheduled','Completed','Cancelled'));

ALTER TABLE appointments
ADD CONSTRAINT no_overlap_dentist
EXCLUDE USING GIST (
    dentist_id WITH =,
    appointment_range WITH &&
);

ALTER TABLE appointments
ADD CONSTRAINT no_overlap_patient
EXCLUDE USING GIST (
    patient_id WITH =,
    appointment_range WITH &&
);

ALTER TABLE appointments
ADD CONSTRAINT fk_appointments_patient
FOREIGN KEY (patient_id)
REFERENCES patients(patient_id)
ON UPDATE CASCADE -- If a patient's ID changes, update it in the appointments table automatically to maintain consistency.
ON DELETE RESTRICT; -- Prevent deletion of a patient record if there are existing appointments referencing it.

ALTER TABLE appointments
ADD CONSTRAINT fk_appointments_dentist
FOREIGN KEY (dentist_id)
REFERENCES dentists(dentist_id)
ON UPDATE CASCADE -- If a dentist's ID changes, update it automatically in related appointments.
ON DELETE RESTRICT; -- Prevent deletion of a dentist record if there are scheduled appointments, ensuring appointment integrity.


-- Inserts for Appointments

INSERT INTO appointments (patient_id, dentist_id, appointment_date, status, reason)
VALUES
  (1, 1, '2025-03-10 09:00:00', 'Scheduled', 'Routine check-up'),  -- patient_id 1 (John Doe), dentist_id 1 (Emily Clark)
  (2, 2, '2025-03-11 10:30:00', 'Scheduled', 'Tooth pain'),        -- patient_id 2 (Jane Smith), dentist_id 2 (Michael Brown)
  (3, 1, '2025-03-12 14:00:00', 'Completed', 'Cavity filling');    -- patient_id 3 (Alice Johnson), dentist_id 1 (Emily Clark)



------------------------------------------------------------

-- 4a. Procedures
-- Purpose: Lists the procedures performed during an appointment.

CREATE TABLE procedures (
    appointment_id INT NOT NULL,
    procedure_id   INT NOT NULL,
    actual_cost    NUMERIC(6,2),
    notes          VARCHAR(255),
    PRIMARY KEY (appointment_id, procedure_id),
    
);

ALTER TABLE procedures
ADD CONSTRAINT ck_actual_cost
CHECK (actual_cost >= 0);

ALTER TABLE procedures
ADD CONSTRAINT fk_proc_appointment
FOREIGN KEY (appointment_id)
REFERENCES appointments(appointment_id)
ON UPDATE CASCADE
ON DELETE CASCADE;
    
ALTER TABLE procedures
ADD CONSTRAINT fk_proc_catalog
FOREIGN KEY (procedure_id)
REFERENCES procedure_catalog(procedure_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;


--  Inserts for Procedures

INSERT INTO procedures (appointment_id, procedure_name, procedure_cost, notes)
VALUES
  (1, 'Teeth Cleaning', 75.00, 'Standard cleaning procedure'),  -- appointment_id 1 (John Doe with Emily Clark)
  (1, 'X-Ray', 50.00, 'Bitewing x-ray performed'),              -- appointment_id 1 (John Doe with Emily Clark)
  (2, 'Filling', 150.00, 'Composite filling for cavity'),       -- appointment_id 2 (Jane Smith with Michael Brown)
  (3, 'Root Canal', 500.00, 'Performed on molar');              -- appointment_id 3 (Alice Johnson with Emily Clark)


------------------------------------------------------------
-- 4b. Procedure Catalog
-- Purpose: Reference table that lists all dental procedures available,
-- along with the current cost and an optional description.

CREATE TABLE procedure_catalog (
    procedure_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    procedure_name VARCHAR(100) NOT NULL,
    current_cost   NUMERIC(6,2) NOT NULL,
    description    VARCHAR(255)
);

ALTER TABLE procedure_catalog
ADD CONSTRAINT uq_procedure_name
UNIQUE (procedure_name);

ALTER TABLE procedure_catalog
ADD CONSTRAINT ck_current_cost
CHECK (current_cost BETWEEN 0 AND 1000);

------------------------------------------------------------

-- 5. Payments
-- Purpose: Records payment information from patients.

CREATE TABLE payments (
    payment_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id    INT NOT NULL,
    payment_date  DATE NOT NULL,
    amount        NUMERIC(7,2) NOT NULL
);

ALTER TABLE payments
ADD CONSTRAINT ck_amount
CHECK (amount > 0);

ALTER TABLE payments
ADD CONSTRAINT fk_payments_patient FOREIGN KEY (patient_id)
REFERENCES patients(patient_id)
ON UPDATE CASCADE -- If a patient's ID changes, the payment record updates automatically.
ON DELETE RESTRICT; -- Prevents deletion of a patient record if there are payment records referencing it.




-- View Tables --
SELECT * FROM patients;
SELECT * FROM dentists;
SELECT * FROM appointments;
SELECT * FROM procedures;

-- Reset Tables --
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS dentists;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS procedures;
DROP TABLE IF EXISTS procedure_catalog
DROP TABLE IF EXISTS payments
