SET search_path = terrier_hospital;

--6. select w/inner and left joins
SELECT * FROM appointment;
SELECT * FROM patient;
SELECT * FROM person;
SELECT * FROM doctor;
SELECT * FROM employee;
SELECT * from hospital;
SELECT * from lab;
SELECT * from blood_test;
SELECT * FROM appointment_type;

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
ORDER BY a.scheduled_for, PatientName

--7. subqueries and joins
SELECT * FROM appointment;
SELECT * FROM doctor;
SELECT * FROM hospital;
SELECT * FROM appointment_prescription;
SELECT * FROM prescription;
SELECT * FROM appointment_diagnosis
SELECT * FROM diagnosis

--all patients with prescriptions
SELECT a.scheduled_for::date as scheduled_date,
pe1.first_name || ' ' || pe1.last_name AS PatientName,
d.office AS doctor_office,
h.name AS hospital_name,
dg.diagnosis AS diagnosis_name,
pr.prescription_id, pr.comments
FROM appointment a
LEFT JOIN Patient p ON a.patient_id = p.patient_id
JOIN Person pe1 ON p.person_id = pe1.person_id
LEFT JOIN doctor d ON a.doctor_id = d.doctor_id
LEFT JOIN hospital h ON a.hospital_id = h.hospital_id
LEFT JOIN appointment_diagnosis ad ON a.appointment_id = ad.appointment_id
JOIN diagnosis dg ON ad.diagnosis_code = dg.diagnosis_code
LEFT JOIN appointment_prescription ap ON a.appointment_id = ap.appointment_id
JOIN prescription pr ON ap.prescription_id = pr.prescription_id 

--seeing which appointments don't have a prescription
SELECT a.appointment_id 
FROM appointment a
WHERE a.appointment_id not in(
SELECT a.appointment_id FROM appointment a 
LEFT JOIN appointment_prescription ap ON a.appointment_id = ap.appointment_id
JOIN prescription pr ON ap.prescription_id = pr.prescription_id);

--let's add some data for those appointments without prescription
SELECT * FROM appointment_diagnosis
SELECT * FROM diagnosis
SELECT * FROM appointment

INSERT INTO appointment_diagnosis(appointment_id, diagnosis_code)
VALUES(100, 1), 
(101,24),
(200,7),
(602,2),
(603,9),
(604,10);

--shows all users without prescription that have a diagnosis
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
















