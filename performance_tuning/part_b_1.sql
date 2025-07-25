SET search_path = terrier_hospital;

--6. original query
SELECT a.scheduled_for::date AS scheduled_date,
a.scheduled_for::time AS scheduled_time,
-- a.appointment_type_id,
ate.description AS appointment_description,
-- a.patient_id,
pe1.first_name || ' ' || pe1.last_name AS PatientName,
h.name AS HospitalName,
-- a.doctor_id,
pe2.first_name || ' ' || pe2.last_name AS DoctorName,
bt.mcv AS MCV, 
a.patient_concern
FROM appointment a
LEFT JOIN Patient p ON a.patient_id = p.patient_id
JOIN Person pe1 ON p.person_id = pe1.person_id
LEFT JOIN hospital h ON a.hospital_id = h.hospital_id
LEFT JOIN doctor d ON a.doctor_id = d.doctor_id
JOIN Employee e ON d.employee_id = e.employee_id
JOIN Person pe2 ON e.person_id = pe2.person_id
LEFT JOIN appointment_type ate ON a.appointment_type_id = ate.appointment_type_id
LEFT JOIN lab l ON a.lab_id = l.lab_id
LEFT JOIN blood_test bt ON l.blood_test_id = bt.blood_test_id
WHERE ate.description = 'Comprehensive examination to assess overall health'
ORDER BY a.scheduled_for, PatientName;

--improving throught CTEs
WITH filtered_CTE AS (
  SELECT a.*, at.description AS appointment_description
  FROM appointment a
  JOIN appointment_type at ON a.appointment_type_id = at.appointment_type_id
  WHERE at.description = 'Comprehensive examination to assess overall health'
)
SELECT a.scheduled_for::date AS scheduled_date, a.scheduled_for::time AS scheduled_time,
a.appointment_description,
pe1.first_name || ' ' || pe1.last_name AS PatientName,
h.name AS HospitalName,
pe2.first_name || ' ' || pe2.last_name AS DoctorName,
bt.mcv AS MCV, 
a.patient_concern
FROM filtered_CTE a
LEFT JOIN patient p ON a.patient_id = p.patient_id
JOIN person pe1 ON p.person_id = pe1.person_id
LEFT JOIN hospital h ON a.hospital_id = h.hospital_id
LEFT JOIN doctor d ON a.doctor_id = d.doctor_id
JOIN employee e ON d.employee_id = e.employee_id
JOIN person pe2 ON e.person_id = pe2.person_id
LEFT JOIN lab l ON a.lab_id = l.lab_id
LEFT JOIN blood_test bt ON l.blood_test_id = bt.blood_test_id
ORDER BY a.scheduled_for, PatientName;

--implementing indexes
CREATE INDEX idx_appointment_scheduled_for ON appointment(scheduled_for);

CREATE INDEX idx_person_fullname ON person ((first_name || ' ' || last_name));

WITH filtered_CTE AS (
  SELECT a.*, at.description AS appointment_description
  FROM appointment a
  JOIN appointment_type at ON a.appointment_type_id = at.appointment_type_id
  WHERE at.description = 'Comprehensive examination to assess overall health'
)
SELECT a.scheduled_for::date AS scheduled_date, a.scheduled_for::time AS scheduled_time,
a.appointment_description,
pe1.first_name || ' ' || pe1.last_name AS PatientName,
h.name AS HospitalName,
pe2.first_name || ' ' || pe2.last_name AS DoctorName,
bt.mcv AS MCV, 
a.patient_concern
FROM filtered_CTE a
LEFT JOIN patient p ON a.patient_id = p.patient_id
JOIN person pe1 ON p.person_id = pe1.person_id
LEFT JOIN hospital h ON a.hospital_id = h.hospital_id
LEFT JOIN doctor d ON a.doctor_id = d.doctor_id
JOIN employee e ON d.employee_id = e.employee_id
JOIN person pe2 ON e.person_id = pe2.person_id
LEFT JOIN lab l ON a.lab_id = l.lab_id
LEFT JOIN blood_test bt ON l.blood_test_id = bt.blood_test_id
ORDER BY a.scheduled_for, pe1.first_name || ' ' || pe1.last_name;

