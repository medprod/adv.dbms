SET search_path = terrier_hospital;

--original query 7
SELECT a.scheduled_for::date as scheduled_date,
pe1.first_name || ' ' || pe1.last_name AS PatientName,
d.office AS doctor_office,
h.name AS hospital_name,
dg.diagnosis AS diagnosis_name
FROM appointment a
LEFT JOIN Patient p ON a.patient_id = p.patient_id
JOIN Person pe1 ON p.person_id = pe1.person_id
LEFT JOIN doctor d ON a.doctor_id = d.doctor_id
LEFT JOIN hospital h ON a.hospital_id = h.hospital_id
LEFT JOIN appointment_diagnosis ad ON a.appointment_id = ad.appointment_id
JOIN diagnosis dg ON ad.diagnosis_code = dg.diagnosis_code
WHERE a.appointment_id NOT IN 
(SELECT a.appointment_id FROM appointment a 
LEFT JOIN appointment_prescription ap ON a.appointment_id = ap.appointment_id
JOIN prescription pr ON ap.prescription_id = pr.prescription_id);

--using CTEs & LEFT JOIN..ISNULL
WITH app_pres_CTE AS (
  SELECT DISTINCT a.appointment_id
  FROM appointment a
  LEFT JOIN appointment_prescription ap ON a.appointment_id = ap.appointment_id
  JOIN prescription pr ON ap.prescription_id = pr.prescription_id
)
SELECT a.scheduled_for::date AS scheduled_date,
pe1.first_name || ' ' || pe1.last_name AS PatientName,
d.office AS doctor_office,
h.name AS hospital_name,
dg.diagnosis AS diagnosis_name
FROM appointment a
LEFT JOIN patient p ON a.patient_id = p.patient_id
JOIN person pe1 ON p.person_id = pe1.person_id
LEFT JOIN doctor d ON a.doctor_id = d.doctor_id
LEFT JOIN hospital h ON a.hospital_id = h.hospital_id
LEFT JOIN appointment_diagnosis ad ON a.appointment_id = ad.appointment_id
JOIN diagnosis dg ON ad.diagnosis_code = dg.diagnosis_code
LEFT JOIN app_pres_CTE ap ON a.appointment_id = ap.appointment_id
WHERE ap.appointment_id IS NULL;




