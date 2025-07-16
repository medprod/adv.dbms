SELECT * FROM Deadlocker1;
SELECT * FROM Deadlocker2;

COMMIT;

--step 5. updating deadlocker2
BEGIN
UPDATE Deadlocker2 
SET lastName = 'Musku' WHERE firstName = 'Anitha'
ROLLBACK


--step 6. updating deadlocker1 table
BEGIN
UPDATE Deadlocker1 SET firstName = 'Med'
WHERE firstName = 'Medha'
ROLLBACK


