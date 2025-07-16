SELECT * FROM DeadlockerX;
SELECT * FROM DeadlockerY;
SELECT * FROM DeadlockerZ;

COMMIT; 

----step 5
BEGIN 
UPDATE DeadlockerZ
SET lastName = 'Musku' WHERE firstName = 'Anitha'
ROLLBACK

--step 6 (same update as in step 3)
BEGIN
UPDATE DeadlockerX
SET firstName = 'Med' WHERE firstName = 'Medha'
ROLLBACK
