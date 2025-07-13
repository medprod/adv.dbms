SET search_path = terrier_hospital;

--10. ROLLUP, CUBE
SELECT * FROM appointment;
SELECT * FROM marital_status;
SELECT * FROM ethnicity;
SELECT * FROM person;
SELECT * FROM Patient;

SELECT 
m.marital_status,
e.ethnicity,
COUNT(*) AS number_of_appointments
FROM appointment a
LEFT JOIN Patient pa On a.patient_id = pa.patient_id
JOIN Person pe ON pa.person_id = pe.person_id
JOIN marital_status m ON pe.marital_status_id = m.marital_status_id
JOIN ethnicity e ON pe.ethnicity_id = e.ethnicity_id
GROUP BY ROLLUP(m.marital_status,e.ethnicity)
ORDER BY m.marital_status, e.ethnicity;

--labeling subtotals and grandtotals appropriately
SELECT 
COALESCE(m.marital_status, 'All Marital Statuses') AS martial_status,
COALESCE(e.ethnicity, 'All Ethnicities') AS ethnicity,
COUNT(*) AS number_of_appointments
FROM appointment a
LEFT JOIN Patient pa On a.patient_id = pa.patient_id
JOIN Person pe ON pa.person_id = pe.person_id
JOIN marital_status m ON pe.marital_status_id = m.marital_status_id
JOIN ethnicity e ON pe.ethnicity_id = e.ethnicity_id
GROUP BY ROLLUP(m.marital_status,e.ethnicity)
ORDER BY m.marital_status, e.ethnicity;


--11.RANK, GROUP BY
SELECT * FROM urinalysis;
SELECT * FROM lab;
SELECT * FROM appointment;
SELECT * FROM patient;
SELECT * FROM person;

CREATE SEQUENCE person_id_seq 
AS integer
START WITH 122
INCREMENT BY 1;


INSERT INTO person 
(person_id, first_name, last_name, dob, phone, email, sex_id, marital_status_id, ethnicity_id, nationality_id)
VALUES
(nextval('person_id_seq'), 'Allu', 'Arjun', '2023-08-11', '123-456-9999', 'allu.arjun@gmail.com', 1, 2, 4, 12),
(nextval('person_id_seq'), 'Nani', 'Smith', '2018-07-09', '223-456-9999', 'nani.smith@gmail.com', 1, 1, 4, 12),
(nextval('person_id_seq'), 'Christopher', 'Nolin', '1960-01-01', '123-444-9999', 'chris.nolin@gmail.com', 1, 1, 1, 1);

INSERT INTO patient (patient_id, person_id, blood_type_id) 
VALUES(55, 122, 5),
(56, 123, 7),
(57, 124, 2);

INSERT INTO appointment (appointment_id, appointment_type_id, hospital_id, created_at, scheduled_for, patient_concern, 
patient_vitals_id, patient_id, doctor_id, lab_id, appointment_status_id)
VALUES(605, 1, 21, '2023-07-20 09:00:00', '2023-07-21 08:15:00', 'Routine blood pressure check', 1, 55, 1, 100, 4),
(606, 1, 21, '2023-09-20 09:00:00', '2023-01-21 08:15:00', 'Follow up for severe headache.', 1, 56, 1, 100, 4),
(607, 1, 21, '2023-10-20 09:00:00', '2023-06-21 08:15:00', 'The patient has bad migraines.', 1, 57, 1, 100, 4);

--using rank function
WITH CTE_age AS(
	SELECT pa.patient_id,
	EXTRACT(year FROM age(current_date, pe.dob::date)) AS age
	FROM Patient pa
	JOIN person pe ON pa.person_id = pe.person_id
),
CTE_ageGroups AS(
	SELECT u.protein,
	(CASE WHEN age>=0 AND age<=17 THEN 'Child'
	WHEN age>=18 AND age<=59 THEN 'Adult'
	ELSE 'Senior' END) AS age_group
	FROM appointment a
	JOIN lab l ON a.lab_id = l.lab_id
	JOIN urinalysis u ON l.urinalysis_id = u.urinalysis_id
	JOIN CTE_age cte1 ON a.patient_id = cte1.patient_id
)
	SELECT COUNT(*) AS total_urin_analysis,
	age_group, 
	protein,
	RANK() OVER (ORDER BY protein DESC) as protein_rank
	FROM CTE_ageGroups 
	GROUP BY age_group, protein;


--using dense_rank function
WITH CTE_age AS(
	SELECT pa.patient_id,
	EXTRACT(year FROM age(current_date, pe.dob::date)) AS age
	FROM Patient pa
	JOIN person pe ON pa.person_id = pe.person_id
),
CTE_ageGroups AS(
	SELECT u.protein,
	(CASE WHEN age>=0 AND age<=17 THEN 'Child'
	WHEN age>=18 AND age<=59 THEN 'Adult'
	ELSE 'Senior' END) AS age_group
	FROM appointment a
	JOIN lab l ON a.lab_id = l.lab_id
	JOIN urinalysis u ON l.urinalysis_id = u.urinalysis_id
	JOIN CTE_age cte1 ON a.patient_id = cte1.patient_id
)
	SELECT COUNT(*) AS total_urin_analysis,
	age_group, 
	protein,
	DENSE_RANK() OVER (ORDER BY protein DESC) as protein_rank
	FROM CTE_ageGroups 
	GROUP BY age_group, protein;
