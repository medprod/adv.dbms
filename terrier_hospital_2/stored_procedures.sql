SET search_path = terrier_hospital;

--6. Store Proc to insert records to Appointment table
SELECT * FROM Appointment;

--STORED PROCEDURE SOLUTION
CREATE OR REPLACE PROCEDURE appointment_proc(
	appointment_id_arg INT,
	appointment_type_id_arg INT,
	hospital_id_arg INT, 
	created_at_arg TIMESTAMP,
	scheduled_for_arg TIMESTAMP,
	patient_concern_arg VARCHAR(255),
	patient_vitals_id_arg INT,
	patient_id_arg INT,
	doctor_id_arg INT,
	lab_id_arg INT,
	appointment_status_id_arg INT
)
LANGUAGE plpgsql
AS
$reusableproc$
BEGIN
	INSERT INTO appointment (
		appointment_id, appointment_type_id, hospital_id, created_at, 
		scheduled_for, patient_concern, patient_vitals_id, patient_id, 
		doctor_id, lab_id, appointment_status_id
	)
	VALUES(
		appointment_id_arg, appointment_type_id_arg, hospital_id_arg, created_at_arg,
		scheduled_for_arg, patient_concern_arg, patient_vitals_id_arg, patient_id_arg,
		doctor_id_arg, lab_id_arg, appointment_status_id_arg
	);
	RAISE NOTICE 'Insert completed successfully.';
END;
$reusableproc$;

--TESTING
--let's insert some data by calling the stored proc.
CALL appointment_proc(613, 1, 21, '2023-06-21 09:45:00', '2023-06-29 10:15:00', 'The patient has difficulty breathing.', 4, 54, 8, 104, 4);
CALL appointment_proc(614, 1, 21,  CURRENT_TIMESTAMP::TIMESTAMP,  CURRENT_TIMESTAMP::TIMESTAMP, 'The patient has difficulty living.', 4, 54, 8, 104, 4);

--querying to see what it inserted
SELECT * FROM Appointment
ORDER BY appointment_id DESC;


--7. stored procedure 2
--(i). let's create a appointment id sequence for it to autofill each time
CREATE SEQUENCE appointment_id_seq
AS INTEGER
START WITH 615
INCREMENT BY 1;

--(ii.)let's run my user defined function from question 4
CREATE OR REPLACE FUNCTION doctor_and_hospital(fxn_doc_id INT, fxn_hosp_id INT)
RETURNS BOOLEAN AS 
$$
BEGIN
	RETURN EXISTS (
		SELECT 1
		FROM Doctor d
		JOIN Employee e ON d.employee_id = e.employee_id
		JOIN Department dep ON e.department_id = dep.department_id
		JOIN Hospital h ON dep.hospital_id = h.hospital_id
		WHERE d.doctor_id = fxn_doc_id AND h.hospital_id = fxn_hosp_id
	);
END;
$$ LANGUAGE PLPGSQL;

--(iii.)let's run the user defined function here that I created in question 5
CREATE OR REPLACE FUNCTION next_available_slot(fxn_doc_id INT, specified_time TIMESTAMP)
RETURNS TIMESTAMP AS 
$$
DECLARE 
	latest_booking TIMESTAMP;
	next_slot TIMESTAMP;
	reference_time TIMESTAMP;
BEGIN
	SELECT scheduled_for INTO latest_booking
	FROM doc_appointments
	WHERE doctor_id = fxn_doc_id AND booked_timings = 1;

	IF specified_time > latest_booking 
	THEN reference_time = specified_time;
	ELSE reference_time = latest_booking + INTERVAL '1 hour';
	END IF;
	

	--for M-F between 8AM to 5PM
	IF EXTRACT(DOW FROM reference_time) BETWEEN 1 AND 5 AND reference_time::time BETWEEN '08:00:00' AND '16:00:00'
	THEN next_slot = reference_time;
	--for friday past 5pm (last appoint 4-5PM)
	ELSEIF EXTRACT(DOW FROM reference_time) = 5 and reference_time::time >= '16:00:00'
	THEN next_slot = reference_time::date + INTERVAL '3 days 8 hours';
	--for saturday
	ELSEIF EXTRACT(DOW FROM reference_time) = 6
	THEN next_slot = reference_time::date + INTERVAL '2 days 8 hours';
	--for sunday or any day past 5pm
	ELSE next_slot = reference_time::date + INTERVAL '1 day 8 hours';

	END IF;
	RETURN next_slot;
END;
$$ 
LANGUAGE plpgsql;

--some additional checks (ignore)
SELECT * FROM Appointment;
SELECT * FROM appointment_status; --to see appointment_status_id of "scheduled"
SELECT * FROM Patient;
SELECT * FROM Hospital;
SELECT * FROM Appointment ORDER BY appointment_id DESC;
SELECT * FROM Appointment_type;
SELECT * FROM Doctor;
SELECT * FROM doc_appointments;

SELECT appointment_id, patient_full_name, scheduled_for, doctor_id, booked_timings,
CASE WHEN scheduled_for::time BETWEEN '08:00:00' AND '17:00:00'  
THEN scheduled_for + INTERVAL '1 hour' --if latest appointment is between 8AM - 5PM
ELSE scheduled_for::date + INTERVAL '1 day 8 hours' --if latest appointment is after 5PM
END AS next_available_appointment
FROM doc_appointments
WHERE booked_timings = 1;

--(iv.) STORED PROCEDURE SOLUTION
CREATE OR REPLACE PROCEDURE appointment_scheduling(
	patient_id_arg INT,
	preferred_time_arg TIMESTAMP,
	patient_concern_arg VARCHAR(255),
	appointment_type_id_arg INT,
	hospital_id_arg INT,
	doctor_id_arg INT	
)
LANGUAGE plpgsql
AS
$$
DECLARE
	--we know appointments will always be under "scheduled" 
	appointment_status_id INT = 1;
	next_slot TIMESTAMP;
	--added patient_exists variable
	patient_exists BOOLEAN;
BEGIN
	--does patient exist in hospital db?
	SELECT EXISTS(SELECT 1 FROM patient WHERE patient_id = patient_id_arg) INTO patient_exists;
	IF NOT patient_exists
	THEN RAISE EXCEPTION 'Please register with the hospital network before booking appointments';
	END IF;
	
	--check if doctor is in hospital; our user-defined function from 4
	IF NOT doctor_and_hospital(doctor_id_arg, hospital_id_arg)
	THEN RAISE EXCEPTION 'The doctor of your choice does not work at the hospital you selected.';
	END IF;

	--checking if appointment is atleast 1 hour from now and less than 3 months from now
	IF preferred_time_arg > (NOW() + INTERVAL '3 months') 
	THEN RAISE EXCEPTION 'Appointment cannot be made more than 3 months from now.';

	ELSIF preferred_time_arg < (NOW() + INTERVAL '1 hour')
	THEN RAISE EXCEPTION 'Appointment cannot be made less than 1 hour from now.';

	END IF;
	
	--using for user-defined function from 5
	next_slot := next_available_slot(doctor_id_arg, preferred_time_arg);
	--what if time slot is not available?
	IF next_slot <> preferred_time_arg 
	THEN RAISE EXCEPTION 'Time slot is not available. Choose another time.';
	END IF;

	--let's try inserting this into appointments
    INSERT INTO appointment (
        appointment_id,appointment_type_id,hospital_id,
        created_at,scheduled_for,patient_concern,
        patient_vitals_id,patient_id,doctor_id,
        lab_id,appointment_status_id
    )
    VALUES (
        nextval('appointment_id_seq'), 
        appointment_type_id_arg, hospital_id_arg,
        NOW(), --created_at date autofilled with current timestamp
        preferred_time_arg, patient_concern_arg,
        NULL, --patient_vitals_id NULL
        patient_id_arg, doctor_id_arg,
        NULL, --lab_id NULL
        appointment_status_id
    );
	RAISE NOTICE 'Appointment created for patient ID % at %', patient_id_arg, preferred_time_arg;
END;
$$;

--TESTING
--doctor_id 13's latest appointment is 2023-07-20 should this patient should get their preferred date and time
CALL appointment_scheduling(
	54, --patient_id
    TIMESTAMP '2025-07-25 10:00:00', --preffered_time
    'Migraine and dizziness', --my concern
	1, --appointment_type (scheduling)
	38, --hospital_id
	13); --doctor_id

--let's check if doctor_and_hospital functionality works within stored proc
--doctor_id 13 works at hospital id 32 so 38 here should throw an error
CALL appointment_scheduling(
	54, --patient_id
    TIMESTAMP '2025-07-25 10:00:00', --preffered_time
    'Migraine and dizziness', --my concern
	1, --appointment_type (scheduling)
	38, --hospital_id
	13); --doctor_id

--let's check if 3 months and 1 hour conditions work
CALL appointment_scheduling(
	54, --patient_id
    TIMESTAMP '2025-12-25 10:00:00', --preffered_time 3 months in advance
    'Migraine and dizziness', --my concern
	1, --appointment_type (scheduling)
	32, --hospital_id
	13); --doctor_id

CALL appointment_scheduling(
	54, --patient_id
    TIMESTAMP '2025-07-21 19:54:00', --preffered_time less than 1 hour
    'Migraine and dizziness', --my concern
	1, --appointment_type (scheduling)
	32, --hospital_id
	13); --doctor_id

--let's trying adding a patient that doesn't exist in database
CALL appointment_scheduling(
	1001, --patient_id does not exist
    TIMESTAMP '2025-07-25 10:00:00', --preffered_time
    'Migraine and dizziness', --concern
	1, --appointment_type (scheduling)
	32, --hospital_id
	13); --doctor_id

--time slot not available test case
CALL appointment_scheduling(
	54, --patient_id
    TIMESTAMP '2025-07-25 10:00:00', --preffered_time
    'Vomiting', --my concern
	1, --appointment_type (scheduling)
	32, --hospital_id
	13); --doctor_id

--positive test case
CALL appointment_scheduling(
	54, --patient_id
    TIMESTAMP '2025-07-29 10:00:00', --preffered_time
    'Vomiting', --my concern
	1, --appointment_type (scheduling)
	32, --hospital_id
	13); --doctor_id

--a friday after 5pm preferred time
CALL appointment_scheduling(
	54, --patient_id
    TIMESTAMP '2025-08-01 17:00:00', --preffered_time (friday post 5pm)
    'Pregnant', --my concern
	1, --appointment_type (scheduling)
	32, --hospital_id
	13); --doctor_id

--a weekend preferred time
CALL appointment_scheduling(
	54, --patient_id
    TIMESTAMP '2025-08-02 10:00:00', --preffered_time (saturday)
    'Pregnant', --my concern
	1, --appointment_type (scheduling)
	32, --hospital_id
	13); --doctor_id


--proof that I am indeed the patient
SELECT a.appointment_id, a.patient_id, per.first_name, per.last_name,
a.created_at, a.scheduled_for, a.patient_concern, a.patient_vitals_id,
a.doctor_id, a.lab_id, a.appointment_status_id
FROM Appointment a
JOIN Patient p ON a.patient_id = p.patient_id
JOIN Person per ON p.person_id = per.person_id
WHERE p.patient_id = 54;
