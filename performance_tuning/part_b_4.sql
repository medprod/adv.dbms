SET search_path = terrier_hospital;

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

--creating indexes

CREATE INDEX idx_bill_appointment_id ON bill(appointment_id);
CREATE INDEX idx_appointment_hospital_id ON appointment(hospital_id);
CREATE INDEX idx_hospital_address_id ON hospital(address_id);
CREATE INDEX idx_address_state_id ON address(state_id);


--creating a materialized view
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_avg_operation_charge AS
SELECT 
  h.name AS hospital_name,
  s.state_name AS state_of_hospital,
  AVG(b.operation_charge) AS avg_operation_charge
FROM bill b
LEFT JOIN appointment a ON b.appointment_id = a.appointment_id
JOIN hospital h ON a.hospital_id = h.hospital_id
JOIN address ad ON h.address_id = ad.address_id
JOIN state s ON ad.state_id = s.state_id
GROUP BY h.name, s.state_name;

SELECT 
  hospital_name,
  state_of_hospital,
  ROUND(avg_operation_charge, 3) AS avg_operation_charge
FROM mv_avg_operation_charge
ORDER BY avg_operation_charge DESC, state_of_hospital ASC
LIMIT 3;
