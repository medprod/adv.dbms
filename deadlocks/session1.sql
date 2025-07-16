--STEP 2. creating 2 tables
CREATE TABLE Deadlocker1(
	firstName varchar(50),
	lastName varchar(50)
);

CREATE TABLE Deadlocker2(
	firstName varchar(50),
	lastName varchar(50)
);

-- DROP TABLE Deadlocker1;
-- DROP TABLE Deadlocker2;
-- DELETE FROM Deadlocker1;
-- DELETE FROM Deadlocker2;

--STEP 3. inserting data
INSERT INTO Deadlocker1(firstName, lastName)
VALUES('Medha', 'Prodduturi'),
('Anitha', 'Prodduturi');

INSERT INTO Deadlocker2(firstName, lastName)
VALUES('Medha', 'Prodduturi'),
('Anitha', 'Prodduturi');

SELECT * FROM Deadlocker1;
SELECT * FROM Deadlocker2;

COMMIT; --turned of auto commit

--STEP 4. starting transaction
BEGIN
UPDATE Deadlocker1 SET firstName = 'Med'
WHERE firstName = 'Medha'
ROLLBACK

--STEP 8. updating deadlocker2
BEGIN
UPDATE Deadlocker2 
SET lastName = 'Musku' WHERE firstName = 'Anitha'
ROLLBACK