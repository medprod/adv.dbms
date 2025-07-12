--Part 1. The Terrier Hospital Schema, DML and DDL
SET search_path = terrier_hospital;
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


--3a. Implement a single sequence on the primary key of the appointment table
SELECT * FROM terrier_hospital.appointment;
DROP SEQUENCE appt_id_seq;

CREATE SEQUENCE appt_id_seq 
AS integer
START WITH 602
INCREMENT BY 1;

INSERT INTO terrier_hospital.appointment 
(appointment_id, appointment_type_id, hospital_id, created_at, scheduled_for, 
patient_concern, patient_vitals_id, patient_id, doctor_id, lab_id, appointment_status_id)
VALUES
(nextval('appt_id_seq'), 1, 21, '2025-07-01 09:00:00', '2025-07-11 08:15:00', 
'The patient is experiencing a mild headache.', 1, 1, 1, 129, 4);


--3b. Demonstrate sequence by inserting two new records to the appointment table

--added myself as a person
INSERT INTO terrier_hospital.person 
(person_id, first_name, last_name, dob, phone, email, sex_id,
marital_status_id, ethnicity_id, nationality_id)
VALUES(121, 'Medha', 'Prodduturi', '2002-08-05', '224-123-4567', 'medhaa.prodduturi@gmail.com', 
2, 2, 4, 1);

--created a patient record for me
INSERT INTO terrier_hospital.patient 
(patient_id, person_id, blood_type_id) VALUES
(54, 121, 6);

--inserted into appointment table using sequences
INSERT INTO terrier_hospital.appointment 
(appointment_id, appointment_type_id, hospital_id, created_at, scheduled_for, 
patient_concern, patient_vitals_id, patient_id, doctor_id, lab_id, appointment_status_id)
VALUES
(nextval('appt_id_seq'), 2, 26, '2025-07-11 19:00:00', '2025-08-01 08:00:00', 
'The patient has a diaper rash.', null, 53, 5, null, 1),
(nextval('appt_id_seq'), 1, 21, '2025-07-11 19:00:00', '2025-08-01 08:00:00', 
'The patient has continuous migraines and neck pain.', 42, 54, 1, null, 1);

SELECT * FROM terrier_hospital.appointment;


--4. create a doctor_review table
CREATE TABLE doctor_review(
	review_id INT NOT NULL,
	doctor_id INT,
	patient_id INT,
	review_date DATE DEFAULT CURRENT_DATE,
	rating CHAR(1) CONSTRAINT rating_check check(rating in ('A','B','C','D','F')),
	patient_review VARCHAR(255),
	PRIMARY KEY (review_id),
  	FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
	FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
);

CREATE sequence review_id_seq
AS integer
START WITH 1
INCREMENT BY 1;

INSERT INTO doctor_review(review_id, doctor_id, patient_id, review_date, rating, patient_review)
VALUES(nextval('review_id_seq'), 1, 54, current_date, 'A', 
'I visited this doctor for a family emergency; super helpful and patient.');

SELECT * FROM doctor_review;

--5a. Insert three records into the doctor_review for patients and doctors of your choice
--●	One of the reviews has to be for today’s date.
INSERT INTO doctor_review(review_id, doctor_id, patient_id, review_date, rating, patient_review)
VALUES(nextval('review_id_seq'), 2, 53, '2025-07-11', 'B', 'She cured me time and time again!');

--●	One of the reviews should not explicitly use a date and should utilize the default constraint that you added.
INSERT INTO doctor_review(review_id, doctor_id, patient_id, review_date, rating, patient_review)
VALUES(nextval('review_id_seq'), 1, 54, current_date, 'A', 
'I visited this doctor for a family emergency; super helpful and patient.');

--●	The last review needs to use the date of our first day of class this semester.
INSERT INTO doctor_review(review_id, doctor_id, patient_id, review_date, rating, patient_review)
VALUES(nextval('review_id_seq'),10, 52, '2025-07-01', 'C', 'He was a bit rude and it was hard to get an appointment.');

--5b. Creating a VIEW
SELECT * FROM doctor;
SELECT * FROM employee;
SELECT * FROM person;
SELECT * FROM patient;

CREATE VIEW review_info AS
SELECT 
pe1.first_name || ' ' || pe1.last_name AS Patient_FullName,
pe2.first_name || ' ' || pe2.last_name AS Doctor_FullName,
r.rating, r.review_date, r.patient_review
FROM doctor_review r 
JOIN Patient pa ON r.patient_id = pa.patient_id
JOIN Person pe1 ON pa.person_id = pe1.person_id
JOIN doctor d ON r.doctor_id = d.doctor_id
JOIN Employee e ON d.employee_id = e.employee_id
JOIN Person pe2 ON e.person_id = pe2.person_id;

SELECT * FROM review_info;

--5c. violating the rating check constraint.
INSERT INTO doctor_review(review_id, doctor_id, patient_id, review_date, rating, patient_review)
VALUES(nextval('review_id_seq'), 2, 53, current_date, 'G', 'This is my family doctor. I recommend 100%.');

