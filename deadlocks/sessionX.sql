--step 1
CREATE TABLE DeadlockerX(
	firstName varchar(50),
	middleName varchar(50),
	lastName varchar(50)
);

CREATE TABLE DeadlockerY(
	firstName varchar(50),
	middleName varchar(50),
	lastName varchar(50)
);

CREATE TABLE DeadlockerZ(
	firstName varchar(50),
	middleName varchar(50),
	lastName varchar(50)
);

COMMIT;

SELECT * FROM DeadlockerX;
SELECT * FROM DeadlockerY;
SELECT * FROM DeadlockerZ;

--step 2
INSERT INTO DeadlockerX(firstName, middleName, lastName)
VALUES('Medha', 'Reddy', 'Prodduturi'),
('Sreenivas', 'Reddy', 'Prodduturi'),
('Anitha', 'Reddy', 'Prodduturi');

INSERT INTO DeadlockerY(firstName, middleName, lastName)
VALUES('Medha', 'Reddy', 'Prodduturi'),
('Sreenivas', 'Reddy', 'Prodduturi'),
('Anitha', 'Reddy', 'Prodduturi');

INSERT INTO DeadlockerZ(firstName, middleName, lastName)
VALUES('Medha', 'Reddy', 'Prodduturi'),
('Sreenivas', 'Reddy', 'Prodduturi'),
('Anitha', 'Reddy', 'Prodduturi');

--step 3
BEGIN
UPDATE DeadlockerX
SET firstName = 'Med' WHERE firstName = 'Medha'
ROLLBACK

--step 8 (same as step 4)
BEGIN 
UPDATE DeadlockerY
SET middleName = 'Red' WHERE firstName = 'Sreenivas'
ROLLBACK



