-- ============================================================
-- 06-sample-data-G04.sql
-- Sample Data — School Space Booking System
-- Group 04
-- Insert order respects FK dependencies
-- Normal cases + exceptional/boundary test cases
-- ============================================================

-- Users
INSERT INTO [User] (fullName, email, phone, role, department, accountStatus) VALUES
(N'Nguyen Van An',   N'an.nguyen@university.edu.vn', N'0901000001', N'student', N'Computer Science', N'active'),
(N'Tran Thi Binh',   N'binh.tran@university.edu.vn', N'0901000002', N'student', N'Computer Science', N'active'),
(N'Le Hoang Cuong',  N'cuong.le@university.edu.vn', N'0901000003', N'student', N'Computer Science', N'active'),
(N'Pham Minh Duc',   N'duc.pham@university.edu.vn', N'0901000004', N'lecturer', N'Computer Science', N'active'),
(N'Hoang Thi Em',    N'em.hoang@university.edu.vn', N'0901000005', N'lecturer', N'Computer Science', N'active'),
(N'Vo Van Phuc',     N'phuc.vo@university.edu.vn',  N'0901000006', N'teaching_assistant', N'Computer Science', N'active'),
(N'Bui Van Giau',    N'giau.bui@university.edu.vn', N'0901000007', N'facility_staff', N'Facilities', N'active'),
(N'Duong Thi Hanh',  N'hanh.duong@university.edu.vn',N'0901000008', N'facility_staff', N'Facilities', N'active'),
(N'Dang Van Ich',    N'ich.dang@university.edu.vn', N'0901000009', N'department_administrator', N'Computer Science', N'active'),
(N'Ly Thi Kim',      N'kim.ly@university.edu.vn',   N'0901000010', N'facility_manager', N'Facilities', N'active'),
-- Suspended user (test case)
(N'Nguyen Van Lam',  N'lam.nguyen@university.edu.vn',N'0901000011', N'student', N'Computer Science', N'suspended');

-- Spaces
INSERT INTO [Space] (spaceCode, spaceName, spaceType, building, floor, roomNumber, capacity, currentStatus, usagePolicy) VALUES
(N'CS-A101', N'Main Auditorium',       N'auditorium',         N'Building A', 1, N'A101', 200, N'available',        N'Priority to faculty events. No food/drinks.'),
(N'CS-B201', N'Lecture Hall B201',     N'classroom',          N'Building B', 2, N'B201', 80,  N'available',        N'Standard lecture room. Projector/whiteboard available.'),
(N'CS-B202', N'Computer Lab B202',     N'computer_laboratory',N'Building B', 2, N'B202', 40,  N'available',        N'CS practical sessions only. No food/drinks.'),
(N'CS-C301', N'Project Lab C301',      N'project_laboratory', N'Building C', 3, N'C301', 20,  N'available',        N'Student project groups. Key required.'),
(N'CS-D401', N'Meeting Room D401',     N'meeting_room',       N'Building D', 4, N'D401', 12,  N'available',        N'Staff meetings and small group discussions.'),
(N'CS-D402', N'Student Workspace D402',N'student_workspace',  N'Building D', 4, N'D402', 30,  N'available',        N'Open to all CS students. First-come first-served.'),
-- Under maintenance (test case)
(N'CS-A102', N'Seminar Room A102',     N'classroom',          N'Building A', 1, N'A102', 50,  N'under_maintenance', N'Under renovation until December.'),
-- Temporarily closed (test case)
(N'CS-E501', N'Old Lab E501',          N'computer_laboratory',N'Building E', 5, N'E501', 25,  N'temporarily_closed',N'Closed for inspection.'),
-- Retired (test case)
(N'CS-F601', N'Retired Workshop F601', N'project_laboratory', N'Building F', 6, N'F601', 15,  N'retired',          N'No longer in service.');

-- Facilities
INSERT INTO [Facility] (facilityName, description) VALUES
(N'Projector',         N'HD projector with HDMI/VGA input'),
(N'Whiteboard',        N'Standard whiteboard with markers'),
(N'Microphone',        N'Wireless microphone system'),
(N'Computer',          N'Desktop computer with Windows/Linux dual boot'),
(N'Livestreaming Equipment', N'Camera, microphone, and streaming encoder'),
(N'Air Conditioner',   N'Inverter air conditioning system'),
(N'Speaker System',    N'Surround sound speaker system'),
(N'Smart TV',          N'55-inch smart TV with screen mirroring');

-- SpaceFacility assignments
INSERT INTO [SpaceFacility] (spaceCode, facilityId, quantity) VALUES
-- Auditorium A101
(N'CS-A101', 1, 2), (N'CS-A101', 2, 2), (N'CS-A101', 3, 4),
(N'CS-A101', 5, 1), (N'CS-A101', 6, 4), (N'CS-A101', 7, 1),
-- Lecture Hall B201
(N'CS-B201', 1, 1), (N'CS-B201', 2, 1), (N'CS-B201', 6, 2),
-- Computer Lab B202
(N'CS-B202', 1, 1), (N'CS-B202', 2, 1), (N'CS-B202', 4, 40), (N'CS-B202', 6, 2),
-- Meeting Room D401
(N'CS-D401', 6, 1), (N'CS-D401', 2, 1), (N'CS-D401', 8, 1),
-- Student Workspace D402
(N'CS-D402', 2, 2), (N'CS-D402', 4, 10), (N'CS-D402', 6, 2),
-- Project Lab C301
(N'CS-C301', 2, 1), (N'CS-C301', 4, 20), (N'CS-C301', 6, 1);

-- Bookings
-- Normal case: approved future lecture
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (4, N'CS-B201', '2026-09-01 07:30:00', '2026-09-01 09:30:00', N'Database Systems Week 1 Lecture', 60, N'lecture', N'approved', '2026-08-20 10:00:00');

-- Normal case: pending seminar
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (5, N'CS-A101', '2026-09-05 14:00:00', '2026-09-05 17:00:00', N'AI Research Seminar Series', 150, N'seminar', N'pending', '2026-08-25 09:00:00');

-- Normal case: checked-in (in progress today)
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (4, N'CS-B202', '2026-06-22 08:00:00', '2026-06-22 11:00:00', N'Programming Lab Section 1', 35, N'lecture', N'checked_in', '2026-06-15 10:00:00');

-- Normal case: completed booking
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (4, N'CS-B202', '2026-06-20 08:00:00', '2026-06-20 11:00:00', N'Programming Lab Section 1', 35, N'lecture', N'completed', '2026-06-13 10:00:00');

-- Normal case: rejected booking
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (1, N'CS-D401', '2026-08-15 10:00:00', '2026-08-15 12:00:00', N'Student club meeting', 10, N'meeting', N'rejected', '2026-08-10 08:00:00');

-- Normal case: cancelled booking
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (2, N'CS-C301', '2026-07-01 13:00:00', '2026-07-01 17:00:00', N'Project group work', 8, N'student_activity', N'cancelled', '2026-06-25 14:00:00');

-- Normal case: no-show booking
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (3, N'CS-D402', '2026-06-18 09:00:00', '2026-06-18 12:00:00', N'Group study session', 6, N'student_activity', N'no_show', '2026-06-16 11:00:00');

-- Normal case: approved future workshop
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (5, N'CS-A101', '2026-09-10 08:00:00', '2026-09-10 12:00:00', N'Department Workshop on Machine Learning', 180, N'workshop', N'approved', '2026-08-28 07:00:00');

-- Exceptional case: booking for a space under maintenance
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (6, N'CS-A102', '2026-10-01 09:00:00', '2026-10-01 11:00:00', N'TA workshop in maintenance space (test)', 20, N'workshop', N'rejected', '2026-09-20 09:00:00');

-- Exceptional case: overlap attempt with booking #8
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (1, N'CS-A101', '2026-09-10 09:00:00', '2026-09-10 11:00:00', N'Overlap conflict test booking', 50, N'lecture', N'rejected', '2026-09-01 08:00:00');

-- Exceptional case: multi-day exam booking
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (4, N'CS-B201', '2026-09-21 08:00:00', '2026-09-25 17:00:00', N'Exam Week CS Department', 75, N'examination', N'approved', '2026-08-01 10:00:00');

-- Exceptional case: single-participant meeting (boundary)
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (3, N'CS-D401', '2026-09-12 15:00:00', '2026-09-12 16:00:00', N'Advisor meeting', 1, N'meeting', N'pending', '2026-09-10 12:00:00');

-- Historical: completed past booking for conflict reference
INSERT INTO [Booking] (userId, spaceCode, requestedStartTime, requestedEndTime, purpose, expectedParticipants, bookingType, status, submittedAt)
VALUES (4, N'CS-B202', '2026-05-01 08:00:00', '2026-05-01 11:00:00', N'Past lab session', 30, N'lecture', N'completed', '2026-04-20 10:00:00');

-- BookingApprovals
INSERT INTO [BookingApproval] (bookingId, decisionBy, decisionTime, decisionNote, rejectionReason) VALUES
(1,  7, '2026-08-21 09:00:00', N'Approved. Standard lecture schedule.', NULL),
(5,  8, '2026-08-11 10:00:00', NULL, N'Meeting room D401 reserved for faculty meetings only.'),
(8, 10, '2026-08-29 08:00:00', N'Approved for department workshop.', NULL),
(11, 10, '2026-08-02 08:00:00', N'Approved for examination period.', NULL),
(9,  7, '2026-09-21 10:00:00', NULL, N'Space A102 is under maintenance and cannot be booked.'),
(10, 7, '2026-09-02 09:00:00', NULL, N'Time slot conflicts with approved workshop booking #8.');

-- CheckIns
INSERT INTO [CheckIn] (bookingId, checkedInBy, actualStartTime, initialCondition) VALUES
(3,  8, '2026-06-22 08:05:00', N'All computers functional. Room clean. Projector working.'),
(4,  7, '2026-06-20 08:00:00', N'Room tidy. 35 workstations ready. Whiteboard clean.'),
(13, 8, '2026-05-01 08:02:00', N'All systems operational.');

-- CheckOuts
INSERT INTO [CheckOut] (bookingId, actualEndTime, finalCondition, usageNotes) VALUES
(4,  '2026-06-20 11:10:00', N'Room slightly messy. Whiteboard needs cleaning. All computers shut down.', N'Lab session completed. Students left on time.'),
(13, '2026-05-01 11:05:00', N'Good condition. No issues reported.', N'Regular lab session.');

-- MaintenanceRecords
-- Ongoing: A102 under maintenance
INSERT INTO [MaintenanceRecord] (spaceCode, reportedBy, assignedTo, problemDescription, startTime, completionTime, status, resultNote)
VALUES (N'CS-A102', 3, 7, N'Projector lamp burned out. Ceiling water leak. Multiple issues.', '2026-06-01 09:00:00', NULL, N'in_progress', N'Waiting for projector replacement part. Ceiling repair scheduled.');

-- Completed: B202 computer fix
INSERT INTO [MaintenanceRecord] (spaceCode, reportedBy, assignedTo, problemDescription, startTime, completionTime, status, resultNote)
VALUES (N'CS-B202', 6, 7, N'Computer #15 and #22 faulty RAM. BSOD on boot.', '2026-05-10 08:00:00', '2026-05-12 16:00:00', N'completed', N'RAM replaced. Systems tested and functional.');

-- Open reported: D402 AC failure
INSERT INTO [MaintenanceRecord] (spaceCode, reportedBy, assignedTo, problemDescription, startTime, completionTime, status, resultNote)
VALUES (N'CS-D402', 2, NULL, N'Air conditioner not cooling. Temperature reaches 35C.', '2026-06-20 14:00:00', NULL, N'reported', N'Not assigned yet. Requesting AC technician.');

-- Cancelled: C301 network issue (false alarm)
INSERT INTO [MaintenanceRecord] (spaceCode, reportedBy, assignedTo, problemDescription, startTime, completionTime, status, resultNote)
VALUES (N'CS-C301', 6, 8, N'Network switch port #4 not working.', '2026-06-15 10:00:00', '2026-06-15 14:00:00', N'cancelled', N'Loose cable. No maintenance needed.');

-- Reported: retired space F601 (exceptional)
INSERT INTO [MaintenanceRecord] (spaceCode, reportedBy, assignedTo, problemDescription, startTime, completionTime, status, resultNote)
VALUES (N'CS-F601', 7, NULL, N'Asbestos inspection required before demolition.', '2026-06-01 08:00:00', NULL, N'reported', N'Space is retired. Inspection pending.');
