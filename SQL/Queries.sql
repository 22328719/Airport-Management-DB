USE airport_management;
SELECT
    a.plane_no,
    pm.manufacturer,
    pm.model_name,
    a.status,
    COUNT(te.event_id)                      AS total_tests,
    ROUND(AVG(te.score), 2)                 AS avg_score,
    SUM(CASE WHEN te.passed = 0 THEN 1 ELSE 0 END) AS failed_tests
FROM Airplane a
JOIN PlaneModel pm ON a.model_id = pm.model_id
LEFT JOIN TestEvent te ON a.plane_no = te.plane_no
GROUP BY a.plane_no, pm.manufacturer, pm.model_name, a.status
ORDER BY total_tests DESC, avg_score DESC;
SELECT
    hs.plane_no,
    pm.model_name,
    a.status,
    hs.hangar_no,
    h.location,
    DATE_FORMAT(hs.in_datetime, '%d %b %Y %H:%i') AS checked_in,
    TIMESTAMPDIFF(HOUR, hs.in_datetime, NOW())     AS hours_in_hangar,
    hs.notes
FROM HangarStay hs
JOIN Airplane a   ON hs.plane_no  = a.plane_no
JOIN PlaneModel pm ON a.model_id  = pm.model_id
JOIN Hangar h     ON hs.hangar_no = h.hangar_no
WHERE hs.out_datetime IS NULL
ORDER BY hours_in_hangar DESC;
SELECT
    e.full_name                             AS technician_name,
    t.certification,
    COUNT(te.event_id)                      AS tests_performed,
    ROUND(SUM(te.hours_spent), 1)           AS total_hours_spent,
    ROUND(AVG(te.score), 2)                 AS avg_score_given,
    SUM(CASE WHEN te.passed = 0 THEN 1 ELSE 0 END) AS failures_recorded
FROM Technician t
JOIN Employee e ON t.ssn = e.ssn
LEFT JOIN TestEvent te ON t.ssn = te.ssn
GROUP BY e.full_name, t.certification
HAVING tests_performed > 0
ORDER BY total_hours_spent DESC;
SELECT
    ts.test_name,
    ts.pass_threshold,
    COUNT(te.event_id)                                    AS times_administered,
    SUM(CASE WHEN te.passed = 0 THEN 1 ELSE 0 END)        AS times_failed,
    ROUND(
        SUM(CASE WHEN te.passed = 0 THEN 1 ELSE 0 END)
        / COUNT(te.event_id) * 100, 1
    )                                                     AS failure_rate_pct,
    ROUND(AVG(te.score), 2)                               AS avg_score
FROM Test ts
LEFT JOIN TestEvent te ON ts.test_id = te.test_id
GROUP BY ts.test_name, ts.pass_threshold
ORDER BY failure_rate_pct DESC, times_administered DESC;
SELECT
    a.plane_no,
    pm.model_name,
    a.status,
    ts.test_name,
    ts.frequency_days,
    MAX(te.event_date)                              AS last_tested,
    DATEDIFF(CURDATE(), MAX(te.event_date))         AS days_since_test,
    ts.frequency_days - DATEDIFF(CURDATE(), MAX(te.event_date)) AS days_overdue
FROM Airplane a
JOIN PlaneModel pm   ON a.model_id   = pm.model_id
CROSS JOIN Test ts
LEFT JOIN TestEvent te ON te.plane_no = a.plane_no
                      AND te.test_id  = ts.test_id
WHERE a.status != 'Retired'
GROUP BY a.plane_no, pm.model_name, a.status, ts.test_name, ts.frequency_days
HAVING days_overdue < 0
ORDER BY days_overdue ASC;
SELECT
    h.hangar_no,
    h.location,
    h.hangar_type,
    h.capacity                                               AS max_capacity,
    COUNT(hs.stay_id)                                        AS total_visits,
    SUM(CASE WHEN hs.out_datetime IS NULL THEN 1 ELSE 0 END) AS currently_occupied,
    ROUND(AVG(
        TIMESTAMPDIFF(HOUR, hs.in_datetime,
            COALESCE(hs.out_datetime, NOW()))
    ), 1)                                                    AS avg_stay_hours
FROM Hangar h
LEFT JOIN HangarStay hs ON h.hangar_no = hs.hangar_no
GROUP BY h.hangar_no, h.location, h.hangar_type, h.capacity
ORDER BY total_visits DESC;
SELECT
    pm.manufacturer,
    pm.model_name,
    pm.category,
    COUNT(a.plane_no)                                                   AS total_aircraft,
    SUM(CASE WHEN a.status = 'Active'      THEN 1 ELSE 0 END)           AS active,
    SUM(CASE WHEN a.status = 'Maintenance' THEN 1 ELSE 0 END)           AS in_maintenance,
    SUM(CASE WHEN a.status = 'Grounded'    THEN 1 ELSE 0 END)           AS grounded,
    SUM(CASE WHEN a.status = 'Retired'     THEN 1 ELSE 0 END)           AS retired,
    ROUND(AVG(YEAR(CURDATE()) - a.year_manufactured), 1)                AS avg_age_years
FROM PlaneModel pm
LEFT JOIN Airplane a ON pm.model_id = a.model_id
GROUP BY pm.manufacturer, pm.model_name, pm.category
ORDER BY total_aircraft DESC;
SELECT
    e.full_name,
    tc.license_no,
    tc.tower_assignment,
    tc.last_medical_exam,
    DATEDIFF(CURDATE(), tc.last_medical_exam)   AS days_since_exam,
    tc.license_expiry,
    DATEDIFF(tc.license_expiry, CURDATE())       AS days_until_expiry,
    CASE
        WHEN DATEDIFF(CURDATE(), tc.last_medical_exam) > 365
             THEN 'OVERDUE - Medical Exam Required'
        WHEN DATEDIFF(tc.license_expiry, CURDATE()) <= 90
             THEN 'WARNING - License Expiring Soon'
        ELSE 'OK'
    END AS alert_status
FROM TrafficController tc
JOIN Employee e ON tc.ssn = e.ssn
WHERE DATEDIFF(CURDATE(), tc.last_medical_exam) > 300
   OR DATEDIFF(tc.license_expiry, CURDATE()) <= 90
ORDER BY days_since_exam DESC;
SELECT
    pm.model_name,
    pm.manufacturer,
    COUNT(te.ssn)                                       AS num_technicians,
    SUM(CASE WHEN te.proficiency = 'Lead'   THEN 1 ELSE 0 END) AS lead_count,
    SUM(CASE WHEN te.proficiency = 'Senior' THEN 1 ELSE 0 END) AS senior_count,
    SUM(CASE WHEN te.proficiency = 'Junior' THEN 1 ELSE 0 END) AS junior_count,
    (SELECT COUNT(*) FROM Airplane a WHERE a.model_id = pm.model_id
        AND a.status != 'Retired')                      AS active_aircraft_of_type
FROM PlaneModel pm
LEFT JOIN TechnicianExpertise te ON pm.model_id = te.model_id
GROUP BY pm.model_id, pm.model_name, pm.manufacturer
ORDER BY num_technicians ASC;
SELECT
    ts.test_name,
    te.plane_no,
    pm.model_name,
    te.event_date,
    te.score,
    e.full_name AS tested_by
FROM TestEvent te
JOIN Test ts       ON te.test_id   = ts.test_id
JOIN Airplane a    ON te.plane_no  = a.plane_no
JOIN PlaneModel pm ON a.model_id   = pm.model_id
JOIN Employee e    ON te.ssn       = e.ssn
WHERE te.score = (
    SELECT MAX(te2.score)
    FROM TestEvent te2
    WHERE te2.test_id = te.test_id
)
ORDER BY ts.test_name, te.score DESC;
SELECT
    DATE_FORMAT(te.event_date, '%Y-%m')     AS year_month,
    COUNT(te.event_id)                      AS tests_conducted,
    COUNT(DISTINCT te.plane_no)             AS unique_planes_tested,
    COUNT(DISTINCT te.ssn)                  AS unique_technicians,
    ROUND(AVG(te.score), 2)                 AS avg_score,
    SUM(CASE WHEN te.passed = 0 THEN 1 ELSE 0 END) AS failures,
    ROUND(SUM(te.hours_spent), 1)           AS total_tech_hours
FROM TestEvent te
WHERE te.event_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(te.event_date, '%Y-%m')
ORDER BY year_month ASC;
SELECT
    a.plane_no,
    pm.manufacturer,
    pm.model_name,
    a.status,
    a.year_manufactured,
    a.last_service_date,
    YEAR(CURDATE()) - a.year_manufactured   AS age_years
FROM Airplane a
JOIN PlaneModel pm ON a.model_id = pm.model_id
LEFT JOIN TestEvent te ON a.plane_no = te.plane_no
WHERE te.event_id IS NULL
  AND a.status != 'Retired'
ORDER BY age_years DESC;
SELECT
    DATE_FORMAT(f.scheduled_dep, '%Y-%m')           AS year_month,
    COUNT(*)                                         AS total_flights,
    SUM(CASE WHEN f.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN f.status = 'Delayed'   THEN 1 ELSE 0 END) AS delayed,
    SUM(CASE WHEN f.status = 'Arrived'   THEN 1 ELSE 0 END) AS completed,
    ROUND(
        SUM(CASE WHEN f.status = 'Cancelled' THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 1
    )                                                AS cancellation_rate_pct,
    ROUND(AVG(
        CASE WHEN f.actual_dep IS NOT NULL
             THEN TIMESTAMPDIFF(MINUTE, f.scheduled_dep, f.actual_dep)
             ELSE NULL END
    ), 0)                                            AS avg_departure_delay_mins
FROM Flight f
GROUP BY DATE_FORMAT(f.scheduled_dep, '%Y-%m')
ORDER BY year_month;
-- QUERY 14
SELECT
    e.department,
    CASE
        WHEN t.ssn  IS NOT NULL AND tc.ssn IS NOT NULL THEN 'Technician + ATC'
        WHEN t.ssn  IS NOT NULL                         THEN 'Technician'
        WHEN tc.ssn IS NOT NULL                         THEN 'Traffic Controller'
        ELSE 'General Staff'
    END                                             AS role,
    COUNT(e.ssn)                                    AS headcount,
    ROUND(AVG(e.salary), 2)                         AS avg_salary,
    MIN(e.salary)                                   AS min_salary,
    MAX(e.salary)                                   AS max_salary,
    ROUND(SUM(e.salary), 2)                         AS total_payroll
FROM Employee e
LEFT JOIN Technician t       ON e.ssn = t.ssn
LEFT JOIN TrafficController tc ON e.ssn = tc.ssn
GROUP BY e.department, role
ORDER BY total_payroll DESC;
SELECT
    plane_no,
    model_name,
    status,
    alert_type,
    detail
FROM (
   
    SELECT
        a.plane_no,
        pm.model_name,
        a.status,
        'FAILED TEST'                       AS alert_type,
        CONCAT(ts.test_name, ' on ', te.event_date,
               ' (score: ', te.score, ')')  AS detail
    FROM TestEvent te
    JOIN Airplane a    ON te.plane_no  = a.plane_no
    JOIN PlaneModel pm ON a.model_id   = pm.model_id
    JOIN Test ts       ON te.test_id   = ts.test_id
    WHERE te.passed = 0
    UNION
    SELECT
        a.plane_no,
        pm.model_name,
        a.status,
        'GROUNDED'                          AS alert_type,
        CONCAT('Last service: ', COALESCE(a.last_service_date, 'Unknown'))
                                            AS detail
    FROM Airplane a
    JOIN PlaneModel pm ON a.model_id = pm.model_id
    WHERE a.status = 'Grounded'

    UNION
    SELECT
        a.plane_no,
        pm.model_name,
        a.status,
        'LONG HANGAR STAY'                  AS alert_type,
        CONCAT('In hangar ', hs.hangar_no, ' for ',
               DATEDIFF(NOW(), hs.in_datetime), ' days')
                                            AS detail
    FROM HangarStay hs
    JOIN Airplane a    ON hs.plane_no  = a.plane_no
    JOIN PlaneModel pm ON a.model_id   = pm.model_id
    WHERE hs.out_datetime IS NULL
      AND DATEDIFF(NOW(), hs.in_datetime) > 30
) AS compliance_issues
ORDER BY alert_type, plane_no;

