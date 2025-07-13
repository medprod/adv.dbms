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

--13. Correlated subqueries, inline views, window functions
SELECT * FROM supplier;
SELECT * FROM medicine;
SELECT * FROM manufacturer;

--let's try to output all suppliers and their drugs and manufacturers
CREATE VIEW all_drugs AS(
	SELECT s.supplier_id, s.name AS medical_supplier,
	m.name AS drug_name, m.price AS drug_price,
	man.name AS manufacturer_name
	FROM medicine m
	JOIN supplier s ON m.supplier_id = s.supplier_id
	JOIN manufacturer man ON m.manufacturer_id = man.manufacturer_id
	ORDER BY supplier_id, drug_price
);

--CTE that ranks by drug price in descending order for each supplier
WITH CTE_drug_rank AS(
	SELECT supplier_id, medical_supplier, drug_name, drug_price, manufacturer_name,
	DENSE_RANK() OVER(PARTITION BY supplier_id ORDER BY drug_price DESC) AS drug_price_rank
	FROM all_drugs
)
--choosing the suppliers where the drug price is ranked 1 or 2 (as it is top 2 most expensive drugs)
SELECT medical_supplier, drug_name, drug_price, manufacturer_name
FROM CTE_drug_rank
WHERE drug_price_rank IN (1,2);
