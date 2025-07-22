SET SEARCH_PATH = terrier_hospital;

--4. user defined function 1
SELECT * FROM doctor;
SELECT * FROM hospital;
SELECT * FROM employee;
SELECT * FROM department;


--general query to check which doctor belongs to which hospital
SELECT d.doctor_id, e.employee_id,
dep.department_id, h.hospital_id, h.name
FROM Doctor d
JOIN Employee e ON d.employee_id = e.employee_id
JOIN Department dep ON e.department_id = dep.department_id
JOIN Hospital h ON dep.hospital_id = h.hospital_id
ORDER BY doctor_id;

--creating the function 
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


--test case: a doctor and hospital combo which matches
SELECT doctor_and_hospital(1,21);

--test case: a doctor and hospital combo that doesn't match
SELECT doctor_and_hospital(6,26);

--AND Combinations
--true statement + false statement = outputs false
SELECT doctor_and_hospital(1,21) AND doctor_and_hospital(6,26);

--true statement + true statement = outputs true
SELECT doctor_and_hospital(1,21) AND doctor_and_hospital(6,25);

--false statement + false statement = outputs false
SELECT doctor_and_hospital(1,22) AND doctor_and_hospital(6,26);


---OR Combinations
--true statement + false statement = outputs true
SELECT doctor_and_hospital(1,21) OR doctor_and_hospital(6,26);

--true statement + true statement = outputs true
SELECT doctor_and_hospital(1,21) OR doctor_and_hospital(6,25);

--false statement + false statement = outputs false
SELECT doctor_and_hospital(1,22) OR doctor_and_hospital(6,26);


--5. user-defined function 2
SELECT * FROM Appointment;
SELECT * FROM Doctor;
SELECT * FROM Patient;
SELECT * FROM person;

--using row_number to 
DROP VIEW IF EXISTS doc_appointments;

CREATE OR REPLACE VIEW doc_appointments AS
SELECT a.appointment_id, 
per.first_name || ' ' || per.last_name AS patient_full_name,
a.scheduled_for, a.doctor_id,
DENSE_RANK() OVER(PARTITION BY a.doctor_id ORDER BY a.scheduled_for DESC) AS booked_timings
FROM Appointment a
JOIN Patient p ON a.patient_id = p.patient_id
JOIN Person per ON p.person_id = per.person_id
ORDER BY doctor_id;

SELECT * FROM doc_appointments;

--using this view, for the latest appointment I am adding 1 hour or 1 day depending on 8AM - 5PM
SELECT appointment_id, patient_full_name, scheduled_for, doctor_id, booked_timings,
CASE WHEN scheduled_for::time BETWEEN '08:00:00' AND '17:00:00'  
THEN scheduled_for + INTERVAL '1 hour' --if latest appointment is between 8AM - 5PM
ELSE scheduled_for::date + INTERVAL '1 day 8 hours' --if latest appointment is after 5PM
END AS next_available_appointment
FROM doc_appointments
WHERE booked_timings = 1;

--since we want the appointment to be M-F, let's add additional logic
SELECT appointment_id, patient_full_name, scheduled_for, doctor_id, booked_timings, EXTRACT(DOW FROM scheduled_for) AS dayofweek,
CASE 
	WHEN EXTRACT(DOW FROM scheduled_for) BETWEEN 1 AND 5 AND scheduled_for::time BETWEEN '08:00:00' AND '17:00:00' 
	THEN scheduled_for + INTERVAL '1 hour'
	--friday
	WHEN EXTRACT(DOW FROM scheduled_for) = 5 and scheduled_for::time >= '17:00:00'
	THEN scheduled_for::date + INTERVAL '3 days 8 hours'
	--saturday
	WHEN EXTRACT(DOW FROM scheduled_for) = 6
	THEN scheduled_for::date + INTERVAL '2 days 8 hours'
	--sunday or next day
	ELSE scheduled_for::date + INTERVAL '1 day 8 hours'
END AS next_available_appointment
FROM doc_appointments
WHERE booked_timings = 1; 

--now let's create the user-defined function
CREATE OR REPLACE FUNCTION next_available_slot(fxn_doc_id INT)
RETURNS TIMESTAMP AS 
$$
DECLARE 
	latest_booking TIMESTAMP;
	next_slot TIMESTAMP;
BEGIN
	SELECT scheduled_for INTO latest_booking
	FROM doc_appointments
	WHERE doctor_id = fxn_doc_id AND booked_timings = 1;

	--for M-F between 8AM to 5PM
	IF EXTRACT(DOW FROM latest_booking) BETWEEN 1 AND 5 AND latest_booking::time BETWEEN '08:00:00' AND '17:00:00'
	THEN next_slot = latest_booking + INTERVAL '1 hour';
	--for friday past 5pm
	ELSEIF EXTRACT(DOW FROM latest_booking) = 5 and latest_booking::time >= '17:00:00'
	THEN next_slot = latest_booking::date + INTERVAL '3 days 8 hours';
	--for saturday
	ELSEIF EXTRACT(DOW FROM latest_booking) = 6
	THEN next_slot = latest_booking::date + INTERVAL '2 days 8 hours';
	--for sunday or any day past 5pm
	ELSE next_slot = latest_booking::date + INTERVAL '1 day 8 hours';

	END IF;
	RETURN next_slot;
END;
$$ 
LANGUAGE plpgsql;


--testing
SELECT next_available_slot(1);

--here, i realized i need both doctor_id and a specified date and time as parameters so let's add additional logic
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


--testing
--available timeslot: if patient wants appointment for 7/28 (M) at 8AM
SELECT next_available_slot(7,'2025-07-28 08:00:00'); 

--taken timeslot: if patient wants appointment for 7/25 (F) at 8:45AM
SELECT next_available_slot(7,'2025-07-25 08:45:00'); 

--taken timeslot: if patient wants appointment for 7/25 (F) at 5:00PM
SELECT next_available_slot(7,'2025-07-25 017:00:00'); 

--taken timeslot: if patient wants appointment for 7/26 (Sat) 
SELECT next_available_slot(7,'2025-07-26 08:00:00'); 

--taken timeslot: if patient wants appointment for 7/27 (Sun) 
SELECT next_available_slot(7,'2025-07-28 08:00:00'); 

----taken timeslot: if patient wants appointment for 7/28 (Mon) after 5pm
SELECT next_available_slot(7,'2025-07-28 17:00:00'); 


