SET search_path = terrier_hospital;

--original
SELECT 
pe.first_name || ' ' || pe.last_name AS Doctor_Name,
atp.type AS appointment_type,
date_part('month', a.scheduled_for) AS month_of_appointment,
COUNT(*) AS total_appointments
FROM appointment a 
LEFT JOIN doctor d ON a.doctor_id = d.doctor_id
JOIN Employee e ON d.employee_id = e.employee_id
JOIN Person pe ON e.person_id = pe.person_id
LEFT JOIN appointment_type atp ON a.appointment_type_id = atp.appointment_type_id
WHERE date_part('year', a.scheduled_for) = 2023
GROUP BY Doctor_Name, atp.type, date_part('month', a.scheduled_for);

--removing date_part
SELECT 
pe.first_name || ' ' || pe.last_name AS Doctor_Name,
atp.type AS appointment_type,
date_part('month', a.scheduled_for) AS month_of_appointment,
COUNT(*) AS total_appointments
FROM appointment a 
JOIN doctor d ON a.doctor_id = d.doctor_id
JOIN Employee e ON d.employee_id = e.employee_id
JOIN Person pe ON e.person_id = pe.person_id
JOIN appointment_type atp ON a.appointment_type_id = atp.appointment_type_id
WHERE a.scheduled_for >= DATE '2023-01-01' AND a.scheduled_for < DATE '2024-01-01'
GROUP BY Doctor_Name, atp.type, date_part('month', a.scheduled_for);

--early filtering
WITH filtered_appointments AS (
  SELECT *
  FROM appointment
  WHERE scheduled_for >= DATE '2023-01-01' AND scheduled_for < DATE '2024-01-01'
),
doctor_info AS (
  SELECT d.doctor_id, e.person_id, pe.first_name, pe.last_name
  FROM doctor d
  JOIN employee e ON d.employee_id = e.employee_id
  JOIN person pe ON e.person_id = pe.person_id
)
SELECT di.first_name || ' ' || di.last_name AS Doctor_Name,
atp.type AS appointment_type,
EXTRACT(MONTH FROM fa.scheduled_for) AS month_of_appointment,
COUNT(*) AS total_appointments
FROM filtered_appointments fa
JOIN doctor_info di ON fa.doctor_id = di.doctor_id
LEFT JOIN appointment_type atp ON fa.appointment_type_id = atp.appointment_type_id
GROUP BY di.first_name, di.last_name, atp.type, month_of_appointment
ORDER BY Doctor_Name, month_of_appointment;

