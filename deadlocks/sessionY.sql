SELECT * FROM DeadlockerX;
SELECT * FROM DeadlockerY;
SELECT * FROM DeadlockerZ;

COMMIT; 

--step 4
BEGIN 
UPDATE DeadlockerY
SET middleName = 'Red' WHERE firstName = 'Sreenivas'
ROLLBACK


--step 7 (same update as step 5)
BEGIN 
UPDATE DeadlockerZ
SET lastName = 'Musku' WHERE firstName = 'Anitha'
ROLLBACK