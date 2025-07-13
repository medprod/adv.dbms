SET search_path = terrier_hospital;

--14. CTE, inline views, window functions
SELECT * FROM appointment;
SELECT * FROM appointment_diagnosis;
SELECT * FROM supplier; --supplier name
SELECT * FROM medicine; --drug name, drug price
SELECT * FROM manufacturer; --manufacturer name
SELECT * FROM diagnosis; --diagnosis name
SELECT * FROM prescription; --prescribed at

CREATE VIEW all_drugs_prescriptions AS(
	SELECT s.supplier_id, s.name AS medical_supplier,
	m.name AS drug_name, m.price AS drug_price,
	man.name AS manufacturer_name,
	d.diagnosis AS diagnosis_name,
	p.prescribed_at AS prescribed_date
	FROM medicine m
	JOIN supplier s ON m.supplier_id = s.supplier_id
	JOIN manufacturer man ON m.manufacturer_id = man.manufacturer_id
	JOIN diagnosis d ON m.diagnosis_code = d.diagnosis_code
	JOIN prescription p ON m.medicine_id = p.medicine_id
	ORDER BY supplier_id, drug_price
);
WITH CTE_pres_drug AS (
	SELECT supplier_id, medical_supplier, drug_name, drug_price, manufacturer_name, diagnosis_name, prescribed_date,
	DENSE_RANK() OVER(PARTITION BY supplier_id ORDER BY drug_price DESC) AS drug_price_rank,
	ROW_NUMBER() OVER(PARTITION BY drug_name ORDER BY prescribed_date DESC) AS prescribed_rank
	FROM all_drugs_prescriptions
)
SELECT medical_supplier, drug_name, drug_price, manufacturer_name, 
diagnosis_name, prescribed_date
FROM CTE_pres_drug
WHERE drug_price_rank IN (1,2) AND prescribed_rank = 1;

--15. PIVOT
number of medicines for each manufacturer and supplier

SELECT * FROM supplier; --supplier name
SELECT * FROM medicine; --drug name
SELECT * FROM manufacturer; --manufacturer name

SELECT s.name AS supplier_name, man.name AS manufacturer_name, 
COUNT(*) AS total_medicines
FROM Medicine m
JOIN Supplier s ON m.supplier_id = s.supplier_id
JOIN Manufacturer man ON m.manufacturer_id = man.manufacturer_id
GROUP BY s.name, man.name
ORDER BY s.name, man.name


--17. aggregates, date differences, grouping
patients with more than 1 appointment
average days between appointment 
patient first and last name, DOB month, day, year, email

SELECT * FROM appointment;
SELECT * FROM Person

INSERT INTO appointment (appointment_id, appointment_type_id, hospital_id, created_at, scheduled_for, patient_concern, patient_vitals_id, patient_id, doctor_id, lab_id, appointment_status_id)
VALUES
(608, 1, 21, '2023-06-21 09:00:00', '2023-06-23 08:15:00', 'The patient is experiencing a severe headache.', 1, 1, 1, 100, 4),
(609, 1, 21, '2023-04-21 09:15:00', '2023-04-25 09:45:00', 'The patient is experiencing stomachache and nausea.', 2, 2, 7, 101, 4),
(610, 1, 21, '2023-05-30 09:30:00', '2023-06-18 09:15:00', 'The patient has a high fever and sore throat.', 3, 55, 7, 102, 4),
(611, 1, 21, '2023-06-21 09:45:00', '2023-06-29 10:15:00', 'The patient has a persistent cough and difficulty breathing.', 4, 54, 7, 103, 4);


WITH CTE_dates AS (
	SELECT pe.first_name || ' ' || pe.last_name AS Patient_FullName,
	TO_CHAR(pe.dob::DATE, 'MM/DD/YYYY') AS dob_USformat,
	pe.email, 
	a.scheduled_for as scheduled_date,
	LAG(a.scheduled_for) OVER(PARTITION BY p.patient_id ORDER BY a.scheduled_for) AS prev_scheduled_date
	FROM Appointment a
	JOIN Patient p ON a.patient_id = p.patient_id
	JOIN Person pe ON p.person_id = pe.person_id
),
CTE_days_between AS(
	SELECT Patient_FullName, dob_USformat,
	email, scheduled_date, prev_scheduled_date,
	(scheduled_date - prev_scheduled_date) AS days_between
	FROM CTE_dates
	WHERE prev_scheduled_date IS NOT NULL
	ORDER BY Patient_FullName, scheduled_date
),
CTE_avgdays AS(
	SELECT Patient_FullName, dob_USformat,
	email, AVG(days_between) AS avg_days_between,
	COUNT(*) + 1 AS total_appointments
	FROM CTE_days_between
	GROUP BY Patient_FullName, dob_USformat, email
)
SELECT Patient_FullName, dob_USformat,
email, avg_days_between, total_appointments
FROM CTE_avgdays
WHERE total_appointments > 1;
