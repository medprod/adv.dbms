SET search_path = terrier_hospital;

--12.aggregates, TOP, Filtering within Having clause, CTE/Subquery
SELECT * FROM appointment;
SELECT * FROM hospital;
SELECT * FROM address;
SELECT * FROM State;
SELECT * FROM bill;

WITH CTE_operation_charge AS(
	SELECT h.name AS hospital_name,
	s.state_name AS state_of_hospital,
	AVG(b.operation_charge) AS avg_operation_charge
	FROM bill b 
	LEFT JOIN appointment a ON b.appointment_id = a.appointment_id
	JOIN hospital h ON a.hospital_id = h.hospital_id
	JOIN address ad ON h.address_id = ad.address_id
	JOIN state s ON ad.state_id = s.state_id
	GROUP BY hospital_name, state_of_hospital
)
SELECT 
hospital_name, state_of_hospital,
ROUND(avg_operation_charge, 3) 
FROM CTE_operation_charge
ORDER BY avg_operation_charge DESC, state_of_hospital ASC
LIMIT 3;



