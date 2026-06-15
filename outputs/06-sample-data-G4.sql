-- ============================================================
-- Sample Data — Campus Space Management System
-- Target: Microsoft SQL Server
-- ============================================================

-- ------------------------------------------------------------
-- Users
-- ------------------------------------------------------------
INSERT INTO [User] (full_name, email, phone, role, department, account_status) VALUES
('Alice Johnson',  'alice.johnson@university.edu',   '555-0101', 'facility_manager', 'Facilities',       'active'),
('Bob Smith',      'bob.smith@university.edu',       '555-0102', 'facility_staff',   'Facilities',       'active'),
('Carol White',    'carol.white@university.edu',     '555-0103', 'lecturer',         'Computer Science', 'active'),
('David Lee',      'david.lee@university.edu',       '555-0104', 'student',          'Computer Science', 'active'),
('Eve Brown',      'eve.brown@university.edu',       '555-0105', 'ta',               'Computer Science', 'active'),
('Frank Zhang',    'frank.zhang@university.edu',     '555-0106', 'dept_admin',       'Computer Science', 'active'),
('Grace Kim',      'grace.kim@university.edu',       '555-0107', 'student',          'Computer Science', 'active'),
('Henry Park',     'henry.park@university.edu',      '555-0108', 'lecturer',         'Computer Science', 'active'),
('Ivy Martinez',   'ivy.martinez@university.edu',    '555-0109', 'facility_staff',   'Facilities',       'active'),
('Jack Thompson',  'jack.thompson@university.edu',   '555-0110', 'student',          'Computer Science', 'suspended');

-- ------------------------------------------------------------
-- Spaces
-- ------------------------------------------------------------
INSERT INTO [Space] (space_code, space_name, space_type, building, floor, room_number, capacity, status, usage_policy) VALUES
('AU-101',  'Main Auditorium',     'auditorium',      'Anderson Hall',  '1', '101', 200, 'available',         'No food or drinks'),
('CL-201',  'Lecture Room 201',    'classroom',       'Clark Building', '2', '201',  60, 'available',         'Standard classroom policy'),
('CL-202',  'Lecture Room 202',    'classroom',       'Clark Building', '2', '202',  40, 'available',         'Standard classroom policy'),
('CL-203',  'Lecture Room 203',    'classroom',       'Clark Building', '2', '203',  30, 'under_maintenance', 'Under repair — do not book'),
('CS-301',  'Computer Lab Alpha',  'computer_lab',    'CS Building',    '3', '301',  30, 'available',         'Workstations with full software stack'),
('CS-302',  'Computer Lab Beta',   'computer_lab',    'CS Building',    '3', '302',  25, 'available',         'Workstations with standard tools'),
('PL-001',  'Project Lab',         'project_lab',     'CS Building',    '1', '001',  20, 'available',         'Robotics and hardware projects'),
('MR-401',  'Meeting Room A',       'meeting_room',    'Davis Hall',     '4', '401',  12, 'available',         'Bookings max 4 hours'),
('MR-402',  'Meeting Room B',       'meeting_room',    'Davis Hall',     '4', '402',   8, 'available',         'Bookings max 4 hours'),
('SW-001',  'Student Workspace',    'student_workspace','CS Building',   '1', 'G01',  50, 'available',         'Open to all CS students'),
('AU-102',  'Small Auditorium',     'auditorium',      'Anderson Hall',  '1', '102', 100, 'temporarily_closed','Closed for renovation'),
('CS-303',  'Computer Lab Gamma',   'computer_lab',    'CS Building',    '3', '303',  20, 'retired',           'Decommissioned — no longer in service');

-- ------------------------------------------------------------
-- Facilities
-- ------------------------------------------------------------
INSERT INTO [Facility] (facility_name) VALUES
('Projector'),
('Whiteboard'),
('Microphone'),
('Computer Workstation'),
('Livestreaming Equipment'),
('Air Conditioner'),
('Speaker System'),
('Document Camera');

-- ------------------------------------------------------------
-- SpaceFacility mapping
-- ------------------------------------------------------------
INSERT INTO [SpaceFacility] (space_code, facility_id) VALUES
('AU-101', 1), ('AU-101', 2), ('AU-101', 3), ('AU-101', 5), ('AU-101', 6), ('AU-101', 7),
('CL-201', 1), ('CL-201', 2), ('CL-201', 6), ('CL-201', 8),
('CL-202', 1), ('CL-202', 2), ('CL-202', 6),
('CL-203', 1), ('CL-203', 2), ('CL-203', 6),
('CS-301', 1), ('CS-301', 2), ('CS-301', 4), ('CS-301', 6),
('CS-302', 1), ('CS-302', 2), ('CS-302', 4), ('CS-302', 6),
('PL-001', 2), ('PL-001', 4), ('PL-001', 6),
('MR-401', 1), ('MR-401', 2), ('MR-401', 6),
('MR-402', 1), ('MR-402', 2), ('MR-402', 6),
('SW-001', 2), ('SW-001', 4), ('SW-001', 6);

-- ------------------------------------------------------------
-- Bookings
-- ------------------------------------------------------------
-- 1. Approved booking that will be checked in
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at)
VALUES (3, 'CL-201', '2026-06-20 09:00:00', '2026-06-20 11:00:00', 'CS301 Lecture — Database Systems', 55, 'lecture', 'approved', '2026-06-10 08:00:00');

-- 2. Approved booking that will become no-show
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at)
VALUES (8, 'MR-401', '2026-06-20 14:00:00', '2026-06-20 16:00:00', 'Faculty Meeting', 10, 'meeting', 'approved', '2026-06-11 09:30:00');

-- 3. Pending booking awaiting approval
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at)
VALUES (4, 'CS-301', '2026-06-22 13:00:00', '2026-06-22 17:00:00', 'Programming Workshop for Freshmen', 25, 'workshop', 'pending', '2026-06-15 10:00:00');

-- 4. Rejected booking
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at)
VALUES (5, 'AU-101', '2026-06-18 10:00:00', '2026-06-18 12:00:00', 'TA Orientation Session', 150, 'seminar', 'rejected', '2026-06-05 14:00:00');

-- 5. Completed booking (with session data)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at)
VALUES (3, 'CL-202', '2026-06-14 10:00:00', '2026-06-14 12:00:00', 'CS401 Lecture — Software Engineering', 35, 'lecture', 'completed', '2026-06-01 08:00:00');

-- 6. Cancelled booking
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at)
VALUES (7, 'SW-001', '2026-06-25 15:00:00', '2026-06-25 18:00:00', 'Study Group Session', 15, 'student_activity', 'cancelled', '2026-06-12 11:00:00');

-- 7. Booking that conflicts with booking #1 (same space, overlapping time) — should be prevented
-- (This is a negative test case — comment out to avoid actual insert failure)
-- INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
-- VALUES (6, 'CL-201', '2026-06-20 10:00:00', '2026-06-20 12:00:00', 'Admin Review', 5, 'admin_event', 'approved');

-- 8. Checked-in booking (currently in progress)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at)
VALUES (8, 'MR-402', '2026-06-15 09:00:00', '2026-06-15 11:00:00', 'Research Group Discussion', 6, 'meeting', 'checked_in', '2026-06-08 07:00:00');

-- 9. Booking for upcoming seminar (approved)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at)
VALUES (3, 'AU-101', '2026-07-01 09:00:00', '2026-07-01 12:00:00', 'Guest Lecture — AI in Healthcare', 180, 'seminar', 'approved', '2026-06-10 13:00:00');

-- 10. Booking for examination
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at)
VALUES (6, 'CL-201', '2026-07-05 08:00:00', '2026-07-05 12:00:00', 'CS301 Final Exam', 55, 'examination', 'pending', '2026-06-18 09:00:00');

-- ------------------------------------------------------------
-- BookingApproval records
-- ------------------------------------------------------------
-- Booking #1 approved by Bob (facility_staff)
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (1, 2, 'approved', '2026-06-11 10:00:00', 'Approved — standard lecture booking');

-- Booking #2 approved by Bob
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (2, 2, 'approved', '2026-06-12 09:00:00', 'Approved');

-- Booking #4 rejected by Alice (facility_manager)
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (4, 1, 'rejected', '2026-06-06 08:30:00', 'Rejected — Main Auditorium reserved for department event on that day');

-- Booking #5 approved by Bob
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (5, 2, 'approved', '2026-06-02 10:00:00', 'Approved');

-- Booking #6 cancelled (no approval needed — cancelled before review)

-- Booking #8 approved by Bob
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (8, 2, 'approved', '2026-06-09 08:00:00', 'Approved');

-- Booking #9 approved by Alice
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (9, 1, 'approved', '2026-06-12 14:00:00', 'Approved — high-profile guest lecture');

-- ------------------------------------------------------------
-- BookingSession (check-in / check-out records)
-- ------------------------------------------------------------
-- Booking #5: Completed session
INSERT INTO [BookingSession] (booking_id, actual_start, checked_in_by, initial_condition, actual_end, final_condition, usage_notes)
VALUES (5, '2026-06-14 10:05:00', 2, 'Clean, all equipment functional', '2026-06-14 12:00:00', 'Clean, projector bulb dim', 'Projector bulb needs replacement; notified Bob');

-- Booking #8: Checked-in, not yet completed
INSERT INTO [BookingSession] (booking_id, actual_start, checked_in_by, initial_condition, actual_end, final_condition, usage_notes)
VALUES (8, '2026-06-15 09:02:00', 9, 'Room tidy, whiteboard clean', NULL, NULL, NULL);

-- ------------------------------------------------------------
-- Maintenance records
-- ------------------------------------------------------------
-- 1. CL-203 — ongoing maintenance (broken projector)
INSERT INTO [Maintenance] (space_code, reporter_id, assigned_to, problem_description, start_time, completion_time, status, result_note)
VALUES ('CL-203', 3, 2, 'Projector lamp burnt out, image flickering', '2026-06-10 09:00:00', NULL, 'in_progress', 'Replacement part ordered');

-- 2. AU-101 — completed maintenance (AC repair)
INSERT INTO [Maintenance] (space_code, reporter_id, assigned_to, problem_description, start_time, completion_time, status, result_note)
VALUES ('AU-101', 2, 1, 'Air conditioner not cooling', '2026-06-01 08:00:00', '2026-06-03 16:00:00', 'completed', 'AC compressor replaced, unit now functional');

-- 3. CS-301 — reported issue
INSERT INTO [Maintenance] (space_code, reporter_id, assigned_to, problem_description, start_time, completion_time, status, result_note)
VALUES ('CS-301', 4, NULL, 'Workstation 12 keyboard not working', '2026-06-14 11:00:00', NULL, 'reported', NULL);

-- 4. PL-001 — cancelled maintenance
INSERT INTO [Maintenance] (space_code, reporter_id, assigned_to, problem_description, start_time, completion_time, status, result_note)
VALUES ('PL-001', 2, NULL, '3D printer filament jam', '2026-06-05 10:00:00', '2026-06-05 15:00:00', 'cancelled', 'Issue resolved before technician arrived — printer self-cleared');
