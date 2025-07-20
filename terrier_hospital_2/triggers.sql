--2. Trigger to prevent deletions from the table
SET SEARCH_PATH = terrier_hospital;

SELECT * FROM appointment_history;

--first, we define a trigger function
CREATE OR REPLACE FUNCTION no_deletion()
RETURNS TRIGGER AS 
$$
BEGIN
	RAISE EXCEPTION 'Not allowed to delete a record from the appointment_history table';
	RETURN NULL;
END;
$$
LANGUAGE PLPGSQL;

--then, we create a trigger and associate the trigger function with it
CREATE TRIGGER no_deleting_history
BEFORE DELETE ON appointment_history
FOR EACH ROW
EXECUTE FUNCTION no_deletion();

--testing our trigger
DELETE FROM appointment_history
WHERE appointment_id = 611;


--3. trigger that maintains the appointment based on the transactions made to the appointment table
SELECT * FROM appointment_history
order by appointment_id;

--defining the trigger function
CREATE OR REPLACE FUNCTION appointment_history_trigger()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP ='UPDATE' THEN
		INSERT INTO appointment_history(
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
			CASE WHEN TG_OP = 'INSERT' THEN 'NEW INSERT' ELSE 'UPDATE' END AS update_type,
            CURRENT_TIMESTAMP, a.appointment_id, a.scheduled_for, a.patient_concern, a.appointment_type_id,
            at.type AS appointment_type, p.patient_id, per.first_name, per.last_name, d.doctor_id,
            doc_person.first_name, doc_person.last_name, h.hospital_id,h.name,
            ast.appointment_status_id,ast.status, ad.diagnosis_code, diag.diagnosis AS diagnosis_name,
            l.lab_id, pv.patient_vitals_id, m.medicine_id
        FROM appointment a
        JOIN patient p ON a.patient_id = p.patient_id
        JOIN person per ON p.person_id = per.person_id
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
        WHERE a.appointment_id = NEW.appointment_id;
        RETURN NEW;
	ELSEIF TG_OP = 'DELETE' THEN
		INSERT INTO appointment_history(
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
			'DELETE',
            CURRENT_TIMESTAMP, a.appointment_id, a.scheduled_for, a.patient_concern, a.appointment_type_id,
            at.type AS appointment_type, p.patient_id, per.first_name, per.last_name, d.doctor_id,
            doc_person.first_name, doc_person.last_name, h.hospital_id,h.name,
            ast.appointment_status_id,ast.status, ad.diagnosis_code, diag.diagnosis AS diagnosis_name,
            l.lab_id, pv.patient_vitals_id, m.medicine_id
        FROM appointment a
        JOIN patient p ON a.patient_id = p.patient_id
        JOIN person per ON p.person_id = per.person_id
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
        WHERE a.appointment_id = OLD.appointment_id;
        RETURN OLD;
	END IF;
	RETURN NULL;
END;
$$
LANGUAGE PLPGSQL;

--creating the trigger
CREATE TRIGGER trigger_appointment_history
AFTER INSERT OR UPDATE OR DELETE ON appointment
FOR EACH ROW
EXECUTE FUNCTION appointment_history_trigger();


--i. test case: insert
SELECT * FROM Appointment ORDER BY appointment_id DESC;
SELECT * FROM appointment_history ORDER BY appointment_history_id DESC;

INSERT INTO appointment (appointment_id, appointment_type_id, hospital_id, created_at, scheduled_for, patient_concern, 
patient_vitals_id, patient_id, doctor_id, lab_id, appointment_status_id)
VALUES(612, 1, 21, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Yearly checkups.', 4, 54, 7, 103, 4);

--ii. test case: update
SELECT * FROM Appointment ORDER BY appointment_id DESC;
SELECT * FROM appointment_history ORDER BY appointment_history_id DESC;

UPDATE appointment
SET scheduled_for = '2025-07-25 08:45:00'
WHERE appointment_id = 612;

--iii. test case: delete
DELETE FROM appointment
WHERE appointment_id = 611
AND date_part('year', scheduled_for) = '2023';

ALTER TABLE appointment_history
DROP CONSTRAINT appointment_history_appointment_id_fkey;

--to test if the deletion worked
SELECT * FROM appointment
WHERE appointment_id = 611;

--to test if the deletion updated the history table
SELECT * FROM appointment_history ORDER BY appointment_history_id DESC;

--it didn't update so let's insert this record back
INSERT INTO appointment (appointment_id, appointment_type_id, hospital_id, created_at, scheduled_for, patient_concern, patient_vitals_id, patient_id, doctor_id, lab_id, appointment_status_id)
VALUES(611, 1, 21, '2023-06-21 09:45:00', '2023-06-29 10:15:00', 'The patient has a persistent cough and difficulty breathing.', 4, 54, 7, 103, 4);

--dropped the first trigger I wrote
DROP TRIGGER IF EXISTS trigger_appointment_history ON appointment;

--separated triggers
CREATE TRIGGER trg_appointment_history_after
AFTER INSERT OR UPDATE ON appointment
FOR EACH ROW 
EXECUTE FUNCTION appointment_history_trigger();

CREATE TRIGGER trg_appointment_history_before_delete
BEFORE DELETE ON appointment
FOR EACH ROW 
EXECUTE FUNCTION appointment_history_trigger();

--ran the delete query again
DELETE FROM appointment
WHERE appointment_id = 611
AND date_part('year', scheduled_for) = '2023';

--ran this again and deletion worked here
SELECT * FROM appointment
WHERE appointment_id = 611;

--ran this to check history table and history table also has DELETE record now.
SELECT * FROM appointment_history ORDER BY appointment_history_id DESC;