USE airport_management;

INSERT INTO PlaneModel
(model_name, manufacturer, category, max_range_km, engine_type)
VALUES
('737-800', 'Boeing', 'Narrow-body', 5436, 'Turbofan'),
('A320neo', 'Airbus', 'Narrow-body', 6300, 'Turbofan'),
('787-9', 'Boeing', 'Wide-body', 14140, 'Turbofan');

INSERT INTO Airplane
(plane_no, model_id, capacity, year_manufactured, status, last_service_date)
VALUES
('TC-BOE01', 1, 189, 2018, 'Active', '2026-03-10'),
('TC-AIR02', 2, 180, 2020, 'Active', '2026-02-25'),
('TC-BOE03', 3, 290, 2019, 'Maintenance', '2026-04-01');

INSERT INTO Hangar
(hangar_no, location, capacity, hangar_type, is_active)
VALUES
('H1', 'North Maintenance Zone', 3, 'Maintenance', 1),
('H2', 'South Storage Area', 5, 'Storage', 1),
('H3', 'Central Aviation Complex', 4, 'Both', 1);

INSERT INTO HangarStay
(plane_no, hangar_no, in_datetime, out_datetime, notes)
VALUES
('TC-BOE01', 'H1', '2026-05-10 08:00:00', '2026-05-12 17:00:00', 'Routine maintenance'),
('TC-AIR02', 'H2', '2026-05-14 09:30:00', NULL, 'Currently parked'),
('TC-BOE03', 'H3', '2026-05-15 11:00:00', NULL, 'Engine inspection');

INSERT INTO Test
(test_name, description, max_score, pass_threshold, frequency_days)
VALUES
('Engine Safety Test', 'Checks engine performance and safety standards', 100, 75, 180),
('Hydraulic Pressure Test', 'Measures hydraulic system pressure levels', 100, 70, 120),
('Electrical Systems Check', 'Verifies avionics and electrical equipment', 100, 80, 90);

INSERT INTO UnionInfo
(union_name, union_code, contact_email)
VALUES
('Aircraft Engineers Union', 'AEU01', 'contact@aeu.org'),
('Airport Staff Association', 'ASA02', 'info@asa.org');

INSERT INTO Employee
(ssn, full_name, union_membership_no, union_id, phone, email,
 hire_date, salary, department)
VALUES
('123-45-6789', 'Ahmet Yılmaz', 'AEU1001', 1,
 '+90-555-123-4567', 'ahmet.yilmaz@airport.com',
 '2018-06-15', 42000, 'Maintenance'),

('234-56-7890', 'Mehmet Kaya', 'AEU1002', 1,
 '+90-555-222-3344', 'mehmet.kaya@airport.com',
 '2020-03-11', 39500, 'Maintenance'),

('345-67-8901', 'Ayşe Demir', 'ASA2001', 2,
 '+90-555-987-6543', 'ayse.demir@airport.com',
 '2019-09-01', 47000, 'Control Tower');

INSERT INTO Technician
(ssn, certification, cert_expiry, specialty_note)
VALUES
('123-45-6789', 'Aircraft Maintenance Level III', '2028-06-30', 'Jet engine specialist'),
('234-56-7890', 'Hydraulic Systems Certificate', '2027-12-31', 'Hydraulics and landing gear');

INSERT INTO TechnicianExpertise
(ssn, model_id, proficiency, certified_date)
VALUES
('123-45-6789', 1, 'Lead', '2020-05-01'),
('123-45-6789', 3, 'Senior', '2021-08-14'),
('234-56-7890', 2, 'Senior', '2022-02-20');

INSERT INTO TrafficController
(ssn, last_medical_exam, license_no, license_expiry, tower_assignment)
VALUES
('345-67-8901', '2026-01-20', 'ATC-TR-5567', '2028-01-20', 'Tower A');

INSERT INTO TestEvent
(plane_no, ssn, test_id, event_date, hours_spent, score, passed, remarks)
VALUES
('TC-BOE01', '123-45-6789', 1, '2026-05-11', 4.5, 88, 1, 'Passed successfully'),
('TC-AIR02', '234-56-7890', 2, '2026-05-14', 3.0, 72, 1, 'Minor issue corrected'),
('TC-BOE03', '123-45-6789', 3, '2026-05-16', 5.0, 79, 0, 'Requires re-test');

INSERT INTO Flight
(flight_no, plane_no, origin, destination,
 scheduled_dep, scheduled_arr,
 actual_dep, actual_arr, status)
VALUES
('TK101', 'TC-BOE01', 'Istanbul', 'Ankara',
 '2026-06-01 08:00:00',
 '2026-06-01 09:10:00',
 '2026-06-01 08:05:00',
 '2026-06-01 09:15:00',
 'Arrived'),

('TK205', 'TC-AIR02', 'Adana', 'Izmir',
 '2026-06-02 14:30:00',
 '2026-06-02 16:00:00',
 NULL,
 NULL,
 'Scheduled'),

('TK890', 'TC-BOE03', 'Antalya', 'Berlin',
 '2026-06-03 22:00:00',
 '2026-06-04 01:30:00',
 NULL,
 NULL,
 'Cancelled');
