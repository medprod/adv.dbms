SET search_path = terrier_hospital;

--8. aggregates, joins, group by
SELECT * FROM blood_test
SELECT * from employee
SELECT * FROM Person
SELECT * FROM department
SELECT * FROM hospital

SELECT 
pe.first_name || ' ' || pe.last_name AS employee_name,
d.name AS department_name,
h.name AS hospital_name,
COUNT(*) AS total_blood_tests
FROM blood_test bt
LEFT JOIN employee e ON bt.employee_id = e.employee_id
JOIN Person pe ON e.person_id = pe.person_id
JOIN department d ON e.department_id = d.department_id
JOIN hospital h ON d.hospital_id = h.hospital_id
GROUP BY employee_name, department_name, hospital_name
HAVING COUNT(*) >= 5


--9. aggregates, date differences, grouping
doctors + number of appointments they have
group by appointment type and month of appointment for the year (for my choice)





