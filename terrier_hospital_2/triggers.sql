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



--2. trigger that maintains the appointment based on the transactions made to the appointment table

