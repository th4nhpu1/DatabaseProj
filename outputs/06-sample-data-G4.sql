-- ============================================================================
-- Campus Space Management System — Sample Data
-- Target DBMS: Microsoft SQL Server
-- Order: parents before children (FK dependency order)
-- ============================================================================

USE CampusSpaceManagement;
GO

-- ============================================================================
-- 1. User
-- ============================================================================
INSERT INTO [User] (FullName, Email, Phone, Role, Department, AccountStatus)
VALUES
    (N'Nguyễn Văn An',     N'an.nguyen@school.edu',    N'0901234567', N'Student',               N'Computer Science',    N'Active'),
    (N'Trần Thị Bình',     N'binh.tran@school.edu',    N'0901234568', N'Lecturer',              N'Computer Science',    N'Active'),
    (N'Lê Hoàng Cường',    N'cuong.le@school.edu',     N'0901234569', N'TeachingAssistant',     N'Computer Science',    N'Active'),
    (N'Phạm Minh Dung',    N'dung.pham@school.edu',    N'0901234570', N'FacilityStaff',         N'Facilities',          N'Active'),
    (N'Hoàng Thị Em',      N'em.hoang@school.edu',     N'0901234571', N'DepartmentAdministrator', N'Computer Science',   N'Active'),
    (N'Đặng Văn Phúc',     N'phuc.dang@school.edu',    N'0901234572', N'FacilityManager',       N'Facilities',          N'Active'),
    (N'Võ Thị Giang',      N'giang.vo@school.edu',     N'0901234573', N'Student',               N'Computer Science',    N'Active'),
    (N'Ngô Văn Hải',       N'hai.ngo@school.edu',      N'0901234574', N'Lecturer',              N'Computer Science',    N'Active'),
    (N'Lý Thị Hạnh',       N'hanh.ly@school.edu',      N'0901234575', N'FacilityStaff',         N'Facilities',          N'Active'),
    (N'Đỗ Văn Hòa',        N'hoa.do@school.edu',       N'0901234576', N'Student',               N'Computer Science',    N'Inactive');
GO

-- ============================================================================
-- 2. Space
-- ============================================================================
INSERT INTO Space (SpaceCode, SpaceName, SpaceType, Building, Floor, RoomNumber, Capacity, Status, UsagePolicy)
VALUES
    (N'LT-A1',   N'Large Auditorium A1',   N'Auditorium',         N'Building A', 1, N'A101', 200, N'Available',         N'Lectures and seminars only'),
    (N'CR-B201', N'Classroom B201',         N'Classroom',          N'Building B', 2, N'B201', 50,  N'Available',         N'General teaching'),
    (N'CL-C301', N'Computer Lab C301',      N'ComputerLaboratory', N'Building C', 3, N'C301', 40,  N'Available',         N'Must have IT staff present'),
    (N'PL-C302', N'Project Lab C302',       N'ProjectLaboratory',  N'Building C', 3, N'C302', 20,  N'Available',         N'Student projects only'),
    (N'MR-A202', N'Meeting Room A202',      N'MeetingRoom',        N'Building A', 2, N'A202', 12,  N'Available',         NULL),
    (N'SW-B001', N'Student Workspace B001', N'StudentWorkspace',   N'Building B', 0, N'B001', 30,  N'Available',         N'First-come first-served'),
    (N'CR-B101', N'Classroom B101',         N'Classroom',          N'Building B', 1, N'B101', 35,  N'UnderMaintenance',  NULL),
    (N'CL-D401', N'Computer Lab D401',      N'ComputerLaboratory', N'Building D', 4, N'D401', 30,  N'TemporarilyClosed', NULL),
    (N'MR-B202', N'Meeting Room B202',      N'MeetingRoom',        N'Building B', 2, N'B202', 8,   N'Available',         N'Staff only'),
    (N'LT-D001', N'Small Auditorium D001',  N'Auditorium',         N'Building D', 0, N'D001', 100, N'Available',         NULL);
GO

-- ============================================================================
-- 3. Facility (lookup)
-- ============================================================================
INSERT INTO Facility (FacilityName)
VALUES
    (N'Projector'),
    (N'Whiteboard'),
    (N'Microphone'),
    (N'Computer'),
    (N'Livestreaming Equipment'),
    (N'Air Conditioner');
GO

-- ============================================================================
-- 4. SpaceFacility
-- ============================================================================
INSERT INTO SpaceFacility (SpaceID, FacilityID, Quantity)
VALUES
    (1, 1, 2),  -- Auditorium A1: 2 projectors
    (1, 2, 1),  -- Auditorium A1: 1 whiteboard
    (1, 3, 4),  -- Auditorium A1: 4 microphones
    (1, 5, 1),  -- Auditorium A1: livestreaming equipment
    (1, 6, 4),  -- Auditorium A1: 4 air conditioners
    (2, 1, 1),  -- Classroom B201: 1 projector
    (2, 2, 1),  -- Classroom B201: 1 whiteboard
    (2, 6, 2),  -- Classroom B201: 2 air conditioners
    (3, 1, 1),  -- Computer Lab C301: 1 projector
    (3, 4, 40), -- Computer Lab C301: 40 computers
    (3, 6, 2),  -- Computer Lab C301: 2 air conditioners
    (4, 1, 1),  -- Project Lab C302: 1 projector
    (4, 4, 10), -- Project Lab C302: 10 computers
    (4, 6, 2),  -- Project Lab C302: 2 air conditioners
    (5, 1, 1),  -- Meeting Room A202: 1 projector
    (5, 2, 1),  -- Meeting Room A202: 1 whiteboard
    (5, 6, 1),  -- Meeting Room A202: 1 air conditioner
    (6, 2, 1),  -- Student Workspace B001: 1 whiteboard
    (6, 6, 2),  -- Student Workspace B001: 2 air conditioners
    (9, 1, 1),  -- Meeting Room B202: 1 projector
    (9, 2, 1),  -- Meeting Room B202: 1 whiteboard
    (10, 1, 1), -- Small Auditorium D001: 1 projector
    (10, 3, 2), -- Small Auditorium D001: 2 microphones
    (10, 6, 2); -- Small Auditorium D001: 2 air conditioners
GO

-- ============================================================================
-- 5. BookingRequest
-- ============================================================================
-- Scenario 1: Lecturer Bình requests Auditorium A1 for a lecture — approved, checked in, completed
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (2, 1, '2026-06-20 08:00:00', '2026-06-20 10:00:00', 'Lecture', 150, 'Completed');
GO

-- Scenario 2: Student An requests Computer Lab C301 for a workshop — approved, checked in, completed
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (1, 3, '2026-06-20 14:00:00', '2026-06-20 17:00:00', 'Workshop', 30, 'Completed');
GO

-- Scenario 3: TA Cường requests Meeting Room A202 for a meeting — approved, not yet checked in
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (3, 5, '2026-06-22 09:00:00', '2026-06-22 11:00:00', 'Meeting', 10, 'Approved');
GO

-- Scenario 4: Student Giang requests Project Lab C302 for student activity — pending approval
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (7, 4, '2026-06-23 13:00:00', '2026-06-23 16:00:00', 'StudentActivity', 15, 'Pending');
GO

-- Scenario 5: Lecturer Hải requests Small Auditorium D001 for a seminar — rejected
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (8, 10, '2026-06-21 09:00:00', '2026-06-21 12:00:00', 'Seminar', 80, 'Rejected');
GO

-- Scenario 6: Student Giang requests Classroom B201 for examination preparation — cancelled
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (7, 2, '2026-06-18 08:00:00', '2026-06-18 12:00:00', 'StudentActivity', 20, 'Cancelled');
GO

-- Scenario 7: Lecturer Bình requests Computer Lab C301 for examination — approved and checked in, not yet completed
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (2, 3, '2026-06-25 08:00:00', '2026-06-25 11:00:00', 'Examination', 35, 'CheckedIn');
GO

-- Scenario 8: Student An requests Meeting Room A202 for a meeting — no-show
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (1, 5, '2026-06-19 10:00:00', '2026-06-19 11:30:00', 'Meeting', 8, 'NoShow');
GO

-- Scenario 9: Lecturer Hải requests Classroom B201 for lecture — approved (overlap check for scenario 6 is fine since scenario 6 cancelled)
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (8, 2, '2026-06-24 08:00:00', '2026-06-24 10:00:00', 'Lecture', 30, 'Approved');
GO

-- Scenario 10: Student Hòa (inactive) requests Student Workspace B001 — should fail at app level, but here just pending
INSERT INTO BookingRequest (RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status)
VALUES (10, 6, '2026-06-26 09:00:00', '2026-06-26 12:00:00', 'StudentActivity', 10, 'Pending');
GO

-- ============================================================================
-- 6. BookingApproval
-- ============================================================================
INSERT INTO BookingApproval (BookingID, ApprovedBy, DecisionTime, Decision, DecisionNote, RejectionReason)
VALUES
    (1, 4, '2026-06-18 09:00:00', 'Approved', N'Approved for lecture use', NULL),
    (2, 4, '2026-06-18 09:30:00', 'Approved', N'Workshop approved, IT staff notified', NULL),
    (3, 6, '2026-06-20 10:00:00', 'Approved', N'Meeting room confirmed', NULL),
    (5, 4, '2026-06-19 14:00:00', 'Rejected', NULL, N'Seminar requires larger auditorium; D001 is too small'),
    (6, 4, '2026-06-17 10:00:00', 'Approved', N'Approved', NULL),
    (7, 4, '2026-06-22 08:00:00', 'Approved', N'Examination approved, lab reserved', NULL),
    (9, 4, '2026-06-22 09:00:00', 'Approved', N'Lecture slot confirmed', NULL);
GO

-- ============================================================================
-- 7. BookingSession
-- ============================================================================
INSERT INTO BookingSession (BookingID, CheckedInBy, ActualStartTime, InitialCondition, CheckedOutBy, ActualEndTime, FinalCondition, UsageNotes)
VALUES
    (1, 4, '2026-06-20 08:05:00', N'Clean, all equipment functional', 4, '2026-06-20 10:10:00', N'Clean, projector turned off', N'Lecture went smoothly'),
    (2, 9, '2026-06-20 14:10:00', N'All computers on, lab clean', 9, '2026-06-20 17:15:00', N'All computers shut down, lab tidy', N'Workshop completed successfully'),
    (7, 9, '2026-06-25 08:05:00', N'Lab clean, computers ready', NULL, NULL, NULL, N'Exam in progress');
GO

-- ============================================================================
-- 8. MaintenanceRecord
-- ============================================================================
INSERT INTO MaintenanceRecord (SpaceID, ReportedBy, AssignedTo, ProblemDescription, StartTime, CompletionTime, Status, ResultNote)
VALUES
    (7, 1, 4, N'Projector lamp burned out',               '2026-06-15 08:00:00', '2026-06-16 16:00:00', 'Completed', N'Projector lamp replaced'),
    (8, 2, 4, N'Air conditioning not cooling',            '2026-06-10 09:00:00', NULL,                   'InProgress', N'Waiting for replacement part'),
    (1, 3, 4, N'Microphone static interference',           '2026-06-18 10:00:00', '2026-06-18 14:00:00', 'Completed', N'Cable replaced, tested OK'),
    (4, 1, NULL, N'Computer 5 will not boot',              '2026-06-22 11:00:00', NULL,                   'Reported', NULL),
    (3, 2, 4, N'Projector shows distorted image',          '2026-06-19 08:00:00', '2026-06-19 12:00:00', 'Completed', N'Focus adjusted, image clear'),
    (5, 7, 9, N'Whiteboard marker stains on surface',      '2026-06-20 15:00:00', '2026-06-20 16:30:00', 'Completed', N'Surface cleaned');
GO
