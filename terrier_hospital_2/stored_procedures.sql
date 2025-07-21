SET search_path = terrier_hospital;

--6. Store Proc to insert records to Appointment table
SELECT * FROM Appointment;

--creating the stored procedure
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

--let's insert some data by calling the stored proc.
CALL appointment_proc(613, 1, 21, '2023-06-21 09:45:00', '2023-06-29 10:15:00', 'The patient has difficulty breathing.', 4, 54, 8, 104, 4);
CALL appointment_proc(614, 1, 21,  CURRENT_TIMESTAMP::TIMESTAMP,  CURRENT_TIMESTAMP::TIMESTAMP, 'The patient has difficulty living.', 4, 54, 8, 104, 4);

--querying to see what it inserted
SELECT * FROM Appointment;
