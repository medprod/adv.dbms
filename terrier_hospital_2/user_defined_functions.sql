SET SEARCH_PATH = terrier_hospital;

--4. user defined function 1
SELECT * FROM doctor;
SELECT * FROM hospital;
SELECT * FROM employee;
SELECT * FROM department;

--general query to check which doctor belongs to which hospital
SELECT d.doctor_id, e.employee_id,
dep.department_id, h.hospital_id, h.name
FROM Doctor d
JOIN Employee e ON d.employee_id = e.employee_id
JOIN Department dep ON e.department_id = dep.department_id
JOIN Hospital h ON dep.hospital_id = h.hospital_id
ORDER BY doctor_id;

--creating the function 
CREATE OR REPLACE FUNCTION doctor_and_hospital(fxn_doc_id INT, fxn_hosp_id INT)
RETURNS BOOLEAN AS 
$$
BEGIN
	RETURN EXISTS (
		SELECT 1
		FROM Doctor d
		JOIN Employee e ON d.employee_id = e.employee_id
		JOIN Department dep ON e.department_id = dep.department_id
		JOIN Hospital h ON dep.hospital_id = h.hospital_id
		WHERE d.doctor_id = fxn_doc_id AND h.hospital_id = fxn_hosp_id
	);
END;
$$ LANGUAGE PLPGSQL;


--test case: a doctor and hospital combo which matches
SELECT doctor_and_hospital(1,21);

--test case: a doctor and hospital combo that doesn't match
SELECT doctor_and_hospital(6,26);

--AND Combinations
--true statement + false statement = outputs false
SELECT doctor_and_hospital(1,21) AND doctor_and_hospital(6,26);

--true statement + true statement = outputs true
SELECT doctor_and_hospital(1,21) AND doctor_and_hospital(6,25);

--false statement + false statement = outputs false
SELECT doctor_and_hospital(1,22) AND doctor_and_hospital(6,26);


---OR Combinations
--true statement + false statement = outputs true
SELECT doctor_and_hospital(1,21) OR doctor_and_hospital(6,26);

--true statement + true statement = outputs true
SELECT doctor_and_hospital(1,21) OR doctor_and_hospital(6,25);

--false statement + false statement = outputs false
SELECT doctor_and_hospital(1,22) OR doctor_and_hospital(6,26);


--5. user-defined function 2




