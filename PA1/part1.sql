--Part 1. The Terrier Hospital Schema, DML and DDL

--1a. Select all data from the Doctor table and review it.
SELECT * FROM terrier_hospital.doctor;

--1b. Add an attribute called room_number 
ALTER TABLE terrier_hospital.doctor
ADD COLUMN room_number VARCHAR(3);

UPDATE terrier_hospital.doctor
SET room_number = LEFT(office, 3);

SELECT * FROM terrier_hospital.doctor;

--1c. Next, add another attribute called building_code 
ALTER TABLE terrier_hospital.doctor
ADD COLUMN building_code VARCHAR(1);

UPDATE terrier_hospital.doctor
SET building_code = RIGHT(office, 1);

SELECT * FROM terrier_hospital.doctor;

--1d. Select all data from the doctor table 
SELECT * FROM terrier_hospital.doctor;







