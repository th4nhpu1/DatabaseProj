-- =============================================================
-- Sample Data — Campus Space Management System
-- =============================================================

-- Users
INSERT INTO [User] (FullName, Email, Phone, Role, Department, AccountStatus)
VALUES
('Alice Johnson', 'alice@university.edu', '123-456-7890', 'Student', 'Computer Science', 'Active'),
('Bob Smith', 'bob@university.edu', '123-456-7891', 'Lecturer', 'Computer Science', 'Active'),
('Carol Lee', 'carol@university.edu', '123-456-7892', 'TA', 'Computer Science', 'Active'),
('David Chen', 'david@university.edu', '123-456-7893', 'FacilityStaff', 'Facilities', 'Active'),
('Eva Martinez', 'eva@university.edu', '123-456-7894', 'FacilityManager', 'Facilities', 'Active'),
('Frank Brown', 'frank@university.edu', '123-456-7895', 'Student', 'Computer Science', 'Inactive'),
('Grace Kim', 'grace@university.edu', '123-456-7896', 'DeptAdmin', 'Computer Science', 'Active'),
('Henry Wilson', 'henry@university.edu', NULL, 'Lecturer', 'Computer Science', 'Active');

-- Spaces
INSERT INTO Space (SpaceCode, SpaceName, SpaceType, Building, Floor, RoomNumber, Capacity, CurrentStatus, UsagePolicy)
VALUES
('CS-AUD-101', 'Main Auditorium', 'Auditorium', 'CS Building', 1, '101', 200, 'Available', 'Open to all departments'),
('CS-CL-201', 'Lecture Room 201', 'Classroom', 'CS Building', 2, '201', 60, 'Available', 'Priority for lectures'),
('CS-CL-202', 'Lecture Room 202', 'Classroom', 'CS Building', 2, '202', 50, 'Available', 'Priority for lectures'),
('CS-LAB-301', 'Software Lab 301', 'ComputerLab', 'CS Building', 3, '301', 40, 'Available', 'CS students only'),
('CS-LAB-302', 'Hardware Lab 302', 'ComputerLab', 'CS Building', 3, '302', 30, 'Available', 'CS students only'),
('CS-PL-101', 'Project Lab 101', 'ProjectLab', 'CS Building', 1, '101B', 20, 'Available', 'Student projects'),
('CS-MR-401', 'Meeting Room 401', 'MeetingRoom', 'CS Building', 4, '401', 15, 'Available', 'Staff meetings'),
('CS-MR-402', 'Meeting Room 402', 'MeetingRoom', 'CS Building', 4, '402', 10, 'UnderMaintenance', 'Closed for repair'),
('CS-WS-001', 'Student Workspace', 'StudentWorkspace', 'CS Building', 0, 'G01', 30, 'Available', 'Open study area');

-- Facilities
INSERT INTO Facility (FacilityName)
VALUES
('Projector'),
('Whiteboard'),
('Microphone'),
('Computer'),
('Livestreaming Equipment'),
('Air Conditioner');

-- Space-Facility mapping
INSERT INTO SpaceFacility (SpaceCode, FacilityID, Quantity)
VALUES
('CS-AUD-101', 1, 2),
('CS-AUD-101', 3, 4),
('CS-AUD-101', 5, 1),
('CS-AUD-101', 6, 2),
('CS-CL-201', 1, 1),
('CS-CL-201', 2, 1),
('CS-CL-201', 6, 1),
('CS-CL-202', 1, 1),
('CS-CL-202', 2, 1),
('CS-CL-202', 6, 1),
('CS-LAB-301', 1, 1),
('CS-LAB-301', 4, 40),
('CS-LAB-301', 6, 2),
('CS-LAB-302', 1, 1),
('CS-LAB-302', 4, 30),
('CS-LAB-302', 6, 1),
('CS-PL-101', 2, 2),
('CS-PL-101', 4, 10),
('CS-PL-101', 6, 1),
('CS-MR-401', 1, 1),
('CS-MR-401', 2, 1),
('CS-MR-401', 6, 1),
('CS-MR-402', 2, 1),
('CS-WS-001', 2, 3),
('CS-WS-001', 6, 2);

-- Booking requests (normal cases)
INSERT INTO BookingRequest (SpaceCode, RequesterID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, BookingType, Status)
VALUES
('CS-AUD-101', 2, '2026-06-15 09:00:00', '2026-06-15 11:00:00', 'CS101 Lecture - Introduction to Programming', 150, 'Lecture', 'Approved'),
('CS-CL-201', 2, '2026-06-15 13:00:00', '2026-06-15 15:00:00', 'CS201 Lecture - Data Structures', 50, 'Lecture', 'Approved'),
('CS-LAB-301', 3, '2026-06-16 09:00:00', '2026-06-16 12:00:00', 'CS301 Lab Session - Database Lab', 35, 'Seminar', 'Approved'),
('CS-PL-101', 1, '2026-06-16 14:00:00', '2026-06-16 17:00:00', 'Senior project group meeting', 8, 'StudentActivity', 'Pending'),
('CS-MR-401', 7, '2026-06-17 10:00:00', '2026-06-17 11:30:00', 'Department meeting', 12, 'Meeting', 'Approved'),
('CS-CL-202', 8, '2026-06-18 09:00:00', '2026-06-18 12:00:00', 'CS202 Lecture - Algorithms', 45, 'Lecture', 'Rejected'),
('CS-WS-001', 1, '2026-06-18 10:00:00', '2026-06-18 14:00:00', 'Study group session', 10, 'StudentActivity', 'Cancelled'),
('CS-CL-201', 3, '2026-06-19 09:00:00', '2026-06-19 11:00:00', 'TA tutorial session', 30, 'Workshop', 'Approved'),
('CS-AUD-101', 2, '2026-06-20 14:00:00', '2026-06-20 16:00:00', 'Final examination - CS101', 180, 'Examination', 'Pending'),
('CS-LAB-302', 1, '2026-06-21 09:00:00', '2026-06-21 12:00:00', 'Hardware project testing', 15, 'StudentActivity', 'Pending');

-- Overlapping booking (edge case: same space, overlapping time with an approved booking)
INSERT INTO BookingRequest (SpaceCode, RequesterID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, BookingType, Status)
VALUES
('CS-AUD-101', 1, '2026-06-15 10:00:00', '2026-06-15 12:00:00', 'Student event', 100, 'StudentActivity', 'Pending');

-- Booking for space under maintenance (edge case)
INSERT INTO BookingRequest (SpaceCode, RequesterID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, BookingType, Status)
VALUES
('CS-MR-402', 2, '2026-06-22 10:00:00', '2026-06-22 11:00:00', 'Staff meeting', 8, 'Meeting', 'Pending');

-- Approvals
INSERT INTO Approval (BookingID, StaffID, DecisionTime, DecisionNote, RejectionReason)
VALUES
(1, 4, '2026-06-10 08:00:00', 'Approved for CS101 lecture', NULL),
(2, 4, '2026-06-10 08:05:00', 'Approved for CS201 lecture', NULL),
(3, 4, '2026-06-11 09:00:00', 'Approved for database lab', NULL),
(5, 5, '2026-06-12 10:00:00', 'Department meeting approved', NULL),
(6, 4, '2026-06-12 11:00:00', 'Room needed for priority event', 'Room reserved for faculty workshop'),
(8, 4, '2026-06-14 08:00:00', 'Approved for TA tutorial', NULL);

-- Sessions (check-in and check-out records)
INSERT INTO Session (BookingID, ActualStartTime, ActualEndTime, CheckInBy, InitialCondition, FinalCondition, UsageNotes)
VALUES
(1, '2026-06-15 09:05:00', '2026-06-15 11:10:00', 4, 'Clean, all equipment functional', 'Clean, projector bulb replaced', 'Lecture went well; projector bulb flickered'),
(2, '2026-06-15 13:00:00', '2026-06-15 15:00:00', 4, 'Clean and tidy', 'Clean, whiteboard cleaned', 'No issues'),
(3, '2026-06-16 09:00:00', '2026-06-16 12:00:00', 4, 'All computers functional', 'All computers functional', 'Lab session completed'),
(5, '2026-06-17 10:00:00', '2026-06-17 11:30:00', 4, 'Clean, meeting setup', 'Clean', 'Meeting completed on time'),
(8, '2026-06-19 09:00:00', NULL, 4, 'Clean and tidy', NULL, NULL);

-- No-show booking (checked in but never used)
INSERT INTO BookingRequest (SpaceCode, RequesterID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, BookingType, Status)
VALUES
('CS-CL-202', 1, '2026-06-14 09:00:00', '2026-06-14 11:00:00', 'Study session', 20, 'StudentActivity', 'NoShow');

INSERT INTO Approval (BookingID, StaffID, DecisionTime, DecisionNote, RejectionReason)
VALUES
(13, 4, '2026-06-13 08:00:00', 'Approved', NULL);

INSERT INTO Session (BookingID, ActualStartTime, ActualEndTime, CheckInBy, InitialCondition, FinalCondition, UsageNotes)
VALUES
(13, '2026-06-14 09:00:00', NULL, 4, 'Clean and tidy', NULL, 'Requester did not arrive; marked no-show');

-- Completed booking (past session)
INSERT INTO BookingRequest (SpaceCode, RequesterID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, BookingType, Status)
VALUES
('CS-CL-202', 2, '2026-06-10 09:00:00', '2026-06-10 11:00:00', 'CS202 Make-up lecture', 40, 'Lecture', 'Completed');

INSERT INTO Approval (BookingID, StaffID, DecisionTime, DecisionNote, RejectionReason)
VALUES
(14, 4, '2026-06-09 10:00:00', 'Approved for make-up lecture', NULL);

INSERT INTO Session (BookingID, ActualStartTime, ActualEndTime, CheckInBy, InitialCondition, FinalCondition, UsageNotes)
VALUES
(14, '2026-06-10 09:00:00', '2026-06-10 11:05:00', 4, 'Clean and tidy', 'Clean', 'Make-up lecture completed');

-- Maintenance records
INSERT INTO Maintenance (SpaceCode, ReporterID, AssignedStaffID, ProblemDescription, StartTime, CompletionTime, Status, ResultNote)
VALUES
('CS-MR-402', 8, 4, 'Air conditioning not working', '2026-06-01 09:00:00', NULL, 'InProgress', NULL),
('CS-LAB-301', 3, 4, 'Three computers have broken keyboards', '2026-06-05 10:00:00', '2026-06-07 16:00:00', 'Completed', 'Keyboards replaced'),
('CS-AUD-101', 4, 4, 'Projector bulb needs replacement', '2026-06-12 08:00:00', '2026-06-12 12:00:00', 'Completed', 'Bulb replaced'),
('CS-CL-201', 7, 4, 'Whiteboard surface damaged', '2026-06-08 14:00:00', NULL, 'Reported', NULL),
('CS-WS-001', 1, NULL, 'Broken chair near window', '2026-06-15 09:00:00', NULL, 'Reported', NULL);
