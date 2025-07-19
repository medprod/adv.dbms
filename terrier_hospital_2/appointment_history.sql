SET SEARCH_PATH = terrier_hospital;

SELECT * FROM appointment;

--let's create a appointment_history_id_seq for easy insertion of id data
CREATE SEQUENCE appointment_history_seq AS integer
START WITH 1
INCREMENT BY 1;

CREATE TABLE appointment_history(
	appointment_history_id int PRIMARY KEY NOT NULL DEFAULT nextval('appointment_history_seq'),
	update_type varchar(255) NOT NULL,
	updated_at TIMESTAMP NOT NULL,
	
	--from appointment table
	appointment_id int NOT NULL REFERENCES appointment(appointment_id),
	scheduled_for TIMESTAMP,
	patient_concern varchar(255),

	--from appointment_type table
	appointment_type_id int REFERENCES appointment_type(appointment_type_id),
	appointment_type varchar(255),

	--from patient table
	patient_id int REFERENCES patient(patient_id),
	patient_first_name varchar(255),
	patient_last_name varchar(255),

	--from doctor table
	doctor_id int REFERENCES doctor(doctor_id),
	doctor_first_name varchar(255),
	doctor_last_name varchar(255),

	--from hospital table
	hospital_id int REFERENCES hospital(hospital_id),
	hospital_name varchar(255),

	--from appointment_status table
	appointment_status_id int REFERENCES appointment_status(appointment_status_id),
	appointment_status varchar(255),

	--from diagnosis table
	diagnosis_code int REFERENCES diagnosis(diagnosis_code),
	diagnosis_name varchar(255),

	--other fields
	lab_id int REFERENCES lab(lab_id),
	patient_vitals_id int REFERENCES patient_vitals(patient_vitals_id),
    medicine_id int REFERENCES medicine(medicine_id)
	
);

--SELECT * FROM appointment_history

INSERT INTO appointment_history (
    update_type, updated_at,
    appointment_id, scheduled_for, patient_concern,
    appointment_type_id, appointment_type,
    patient_id, patient_first_name, patient_last_name,
    doctor_id, doctor_first_name, doctor_last_name,
    hospital_id, hospital_name,
    appointment_status_id, appointment_status,
    diagnosis_code, diagnosis_name,
    lab_id, patient_vitals_id, medicine_id
)
SELECT
    'initial insert',
    CURRENT_TIMESTAMP,
    a.appointment_id,
    a.scheduled_for,
    a.patient_concern,
    a.appointment_type_id,
    at.type AS appointment_type,
    p.patient_id,
    pp.first_name,
    pp.last_name,
    d.doctor_id,
    doc_person.first_name,
    doc_person.last_name,
    h.hospital_id,
    h.name,
    ast.appointment_status_id,
    ast.status,
    -- aggregated diagnosis data
	ad.diagnosis_code,
	diag.diagnosis AS diagnosis_name,
    l.lab_id,
    pv.patient_vitals_id,
    m.medicine_id
FROM appointment a
JOIN patient p ON a.patient_id = p.patient_id
JOIN person pp ON p.person_id = pp.person_id
JOIN doctor d ON a.doctor_id = d.doctor_id
JOIN employee e ON d.employee_id = e.employee_id
JOIN person doc_person ON e.person_id = doc_person.person_id
JOIN hospital h ON a.hospital_id = h.hospital_id
JOIN appointment_type at ON a.appointment_type_id = at.appointment_type_id
JOIN appointment_status ast ON a.appointment_status_id = ast.appointment_status_id
LEFT JOIN appointment_diagnosis ad ON a.appointment_id = ad.appointment_id
LEFT JOIN diagnosis diag ON ad.diagnosis_code = diag.diagnosis_code
LEFT JOIN lab l ON a.lab_id = l.lab_id
LEFT JOIN patient_vitals pv ON a.patient_vitals_id = pv.patient_vitals_id
LEFT JOIN appointment_prescription ap ON a.appointment_id = ap.appointment_id
LEFT JOIN prescription pr ON ap.prescription_id = pr.prescription_id
LEFT JOIN medicine m ON pr.medicine_id = m.medicine_id

--Displaying data pulled from appointment table
SELECT * FROM appointment_history
ORDER BY appointment_id
