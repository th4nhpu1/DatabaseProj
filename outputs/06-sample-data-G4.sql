-- ============================================================
-- Sample Data — Campus Space Management System
-- Target: Microsoft SQL Server
-- Lifecycle Simulation: INSERT as pending, then UPDATE to
--   transition statuses to trigger audit columns properly.
-- ============================================================

USE CampusSpaceManagement;
GO

-- ============================================================
-- USERS (10+)
-- ============================================================
INSERT INTO [User] (full_name, email, phone, role, department, account_status, is_active) VALUES
(N'Nguyễn Văn An',     N'an.nguyen@university.edu',   N'090-1001', 'facility_manager', N'Facilities',       'active',   1),
(N'Trần Thị Bình',     N'binh.tran@university.edu',   N'090-1002', 'facility_staff',   N'Facilities',       'active',   1),
(N'Lê Hoàng Cường',    N'cuong.le@university.edu',    N'090-1003', 'lecturer',         N'Computer Science', 'active',   1),
(N'Phạm Thị Dung',     N'dung.pham@university.edu',   N'090-1004', 'student',          N'Computer Science', 'active',   1),
(N'Hoàng Văn Em',      N'em.hoang@university.edu',    N'090-1005', 'ta',               N'Computer Science', 'active',   1),
(N'Võ Thị Phương',     N'phuong.vo@university.edu',   N'090-1006', 'dept_admin',       N'Computer Science', 'active',   1),
(N'Đặng Minh Giàu',    N'giau.dang@university.edu',   N'090-1007', 'student',          N'Computer Science', 'active',   1),
(N'Bùi Thị Hạnh',      N'hanh.bui@university.edu',    N'090-1008', 'lecturer',         N'Computer Science', 'active',   1),
(N'Đỗ Văn In',         N'in.do@university.edu',       N'090-1009', 'facility_staff',   N'Facilities',       'active',   1),
(N'Lý Thị Kiều',       N'kieu.ly@university.edu',     N'090-1010', 'student',          N'Computer Science', 'suspended', 1);
GO

-- ============================================================
-- SPACES (12 — includes unavailable ones)
-- ============================================================
INSERT INTO [Space] (space_code, space_name, space_type, building, floor, room_number, capacity, status, usage_policy, is_active) VALUES
('AU-101', N'Main Auditorium',     'auditorium',      N'Anderson Hall',  '1', '101', 200, 'available',         N'No food or drinks', 1),
('CL-201', N'Lecture Room 201',    'classroom',       N'Clark Building', '2', '201',  60, 'available',         N'Standard classroom policy', 1),
('CL-202', N'Lecture Room 202',    'classroom',       N'Clark Building', '2', '202',  40, 'available',         N'Standard classroom policy', 1),
('CL-203', N'Lecture Room 203',    'classroom',       N'Clark Building', '2', '203',  30, 'under_maintenance', N'Under repair — do not book', 1),
('CS-301', N'Computer Lab Alpha',  'computer_lab',    N'CS Building',    '3', '301',  30, 'available',         N'Workstations with full software stack', 1),
('CS-302', N'Computer Lab Beta',   'computer_lab',    N'CS Building',    '3', '302',  25, 'available',         N'Workstations with standard tools', 1),
('PL-001', N'Project Lab',         'project_lab',     N'CS Building',    '1', '001',  20, 'available',         N'Robotics and hardware projects', 1),
('MR-401', N'Meeting Room A',      'meeting_room',    N'Davis Hall',     '4', '401',  12, 'available',         N'Bookings max 4 hours', 1),
('MR-402', N'Meeting Room B',      'meeting_room',    N'Davis Hall',     '4', '402',   8, 'available',         N'Bookings max 4 hours', 1),
('SW-001', N'Student Workspace',   'student_workspace',N'CS Building',   '1', 'G01',  50, 'available',         N'Open to all CS students', 1),
('AU-102', N'Small Auditorium',    'auditorium',      N'Anderson Hall',  '1', '102', 100, 'temporarily_closed',N'Closed for renovation', 1),
('CS-303', N'Computer Lab Gamma',  'computer_lab',    N'CS Building',    '3', '303',  20, 'retired',           N'Decommissioned — no longer in service', 0);
GO

-- ============================================================
-- FACILITIES (8)
-- ============================================================
INSERT INTO [Facility] (facility_name) VALUES
(N'Projector'),
(N'Whiteboard'),
(N'Microphone'),
(N'Computer Workstation'),
(N'Livestreaming Equipment'),
(N'Air Conditioner'),
(N'Speaker System'),
(N'Document Camera');
GO

-- ============================================================
-- SPACE FACILITY MAPPING
-- ============================================================
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
GO

-- ============================================================
-- BOOKINGS (11 — lifecycle simulation: all start as 'pending')
-- ============================================================

-- Booking 1: Past completed lecture (CL-201, 2026-06-20)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (3, 'CL-201', '2026-06-20 09:00:00', '2026-06-20 11:00:00', N'CS301 — Hệ quản trị cơ sở dữ liệu', 55, 'lecture', 'pending');
GO

-- Booking 2: Past no-show meeting (MR-401, 2026-06-24)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (8, 'MR-401', '2026-06-24 14:00:00', '2026-06-24 16:00:00', N'Họp khoa — đánh giá học kỳ', 10, 'meeting', 'pending');
GO

-- Booking 3: Past cancelled activity (SW-001, 2026-06-22)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (4, 'SW-001', '2026-06-22 15:00:00', '2026-06-22 18:00:00', N'Sinh hoạt nhóm nghiên cứu', 15, 'student_activity', 'pending');
GO

-- Booking 4: Past rejected seminar (AU-101, 2026-06-18)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (5, 'AU-101', '2026-06-18 10:00:00', '2026-06-18 12:00:00', N'Buổi định hướng trợ giảng', 150, 'seminar', 'pending');
GO

-- Booking 5: Past completed lab (CS-302, 2026-06-25)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (5, 'CS-302', '2026-06-25 13:00:00', '2026-06-25 15:00:00', N'Thực hành Python — lớp CS201', 22, 'workshop', 'pending');
GO

-- Booking 6: Current checked-in meeting (MR-402, 2026-06-29)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (8, 'MR-402', '2026-06-29 09:00:00', '2026-06-29 11:00:00', N'Họp nhóm nghiên cứu AI', 6, 'meeting', 'pending');
GO

-- Booking 7: Future approved lecture (CL-202, 2026-07-03)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (3, 'CL-202', '2026-07-03 08:00:00', '2026-07-03 10:00:00', N'CS402 — Công nghệ phần mềm', 35, 'lecture', 'pending');
GO

-- Booking 8: Future approved seminar (AU-101, 2026-07-01)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (3, 'AU-101', '2026-07-01 09:00:00', '2026-07-01 12:00:00', N'Bài giảng khách mời — AI trong Y tế', 180, 'seminar', 'pending');
GO

-- Booking 9: Future pending workshop (CS-301, 2026-07-05)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (4, 'CS-301', '2026-07-05 13:00:00', '2026-07-05 17:00:00', N'Hội thảo lập trình cho sinh viên năm nhất', 25, 'workshop', 'pending');
GO

-- Booking 10: Future pending exam (CL-201, 2026-07-08)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (6, 'CL-201', '2026-07-08 08:00:00', '2026-07-08 12:00:00', N'Thi cuối kỳ CS301', 55, 'examination', 'pending');
GO

-- Booking 11: Future pending project (PL-001, 2026-07-10)
INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
VALUES (7, 'PL-001', '2026-07-10 09:00:00', '2026-07-10 12:00:00', N'Dự án robot tự hành', 8, 'student_activity', 'pending');
GO

-- ============================================================
-- LIFECYCLE TRANSITIONS (UPDATE status to trigger audit)
-- ============================================================

-- Booking 1: pending -> approved -> checked_in -> completed
UPDATE [Booking] SET status = 'approved'   WHERE booking_id = 1;
UPDATE [Booking] SET status = 'checked_in' WHERE booking_id = 1;
UPDATE [Booking] SET status = 'completed'  WHERE booking_id = 1;
GO

-- Booking 2: pending -> approved -> (no-show — never checked in)
UPDATE [Booking] SET status = 'approved' WHERE booking_id = 2;
-- Auto no-show after threshold: application sets this
UPDATE [Booking] SET status = 'no_show'  WHERE booking_id = 2;
GO

-- Booking 3: pending -> cancelled
UPDATE [Booking] SET status = 'cancelled' WHERE booking_id = 3;
GO

-- Booking 4: pending -> rejected
UPDATE [Booking] SET status = 'rejected' WHERE booking_id = 4;
GO

-- Booking 5: pending -> approved -> checked_in -> completed
UPDATE [Booking] SET status = 'approved'   WHERE booking_id = 5;
UPDATE [Booking] SET status = 'checked_in' WHERE booking_id = 5;
UPDATE [Booking] SET status = 'completed'  WHERE booking_id = 5;
GO

-- Booking 6: pending -> approved -> checked_in (currently in session)
UPDATE [Booking] SET status = 'approved'   WHERE booking_id = 6;
UPDATE [Booking] SET status = 'checked_in' WHERE booking_id = 6;
GO

-- Booking 7: pending -> approved
UPDATE [Booking] SET status = 'approved' WHERE booking_id = 7;
GO

-- Booking 8: pending -> approved
UPDATE [Booking] SET status = 'approved' WHERE booking_id = 8;
GO

-- ============================================================
-- BOOKING APPROVAL RECORDS
-- ============================================================
-- Booking 1: approved by Bình (facility_staff)
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (1, 2, 'approved', '2026-06-11 10:00:00', N'Phê duyệt — lịch giảng thường kỳ');
GO

-- Booking 2: approved by Bình
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (2, 2, 'approved', '2026-06-12 09:00:00', N'Phê duyệt');
GO

-- Booking 4: rejected by An (facility_manager)
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (4, 1, 'rejected', '2026-06-06 08:30:00', N'Từ chối — AU-101 đã được đặt cho sự kiện của khoa');
GO

-- Booking 5: approved by Bình
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (5, 2, 'approved', '2026-06-23 10:00:00', N'Phê duyệt');
GO

-- Booking 6: approved by Bình
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (6, 2, 'approved', '2026-06-27 08:00:00', N'Phê duyệt — họp nhóm nghiên cứu');
GO

-- Booking 7: approved by An
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (7, 1, 'approved', '2026-06-28 14:00:00', N'Phê duyệt — lịch giảng');
GO

-- Booking 8: approved by An
INSERT INTO [BookingApproval] (booking_id, staff_id, decision, decision_time, decision_note)
VALUES (8, 1, 'approved', '2026-06-25 14:00:00', N'Phê duyệt — bài giảng khách mời quan trọng');
GO

-- ============================================================
-- BOOKING SESSION (check-in / check-out records)
-- ============================================================
-- Booking 1: Completed session
INSERT INTO [BookingSession] (booking_id, actual_start, checked_in_by, initial_condition, actual_end, final_condition, usage_notes)
VALUES (1, '2026-06-20 09:05:00', 2, N'Sạch sẽ, thiết bị hoạt động tốt', '2026-06-20 11:00:00', N'Sạch sẽ, bóng đèn máy chiếu mờ', N'Cần thay bóng đèn máy chiếu — đã báo Bình');
GO

-- Booking 5: Completed session
INSERT INTO [BookingSession] (booking_id, actual_start, checked_in_by, initial_condition, actual_end, final_condition, usage_notes)
VALUES (5, '2026-06-25 13:02:00', 9, N'Phòng gọn gàng, máy tính hoạt động', '2026-06-25 15:00:00', N'Bình thường', N'Không có sự cố');
GO

-- Booking 6: Checked-in, not yet completed (currently in session)
INSERT INTO [BookingSession] (booking_id, actual_start, checked_in_by, initial_condition, actual_end, final_condition, usage_notes)
VALUES (6, '2026-06-29 09:02:00', 9, N'Phòng sạch, bảng trắng sạch', NULL, NULL, NULL);
GO

-- ============================================================
-- MAINTENANCE RECORDS (5+)
-- ============================================================
-- 1. CL-203 — ongoing maintenance (broken projector)
INSERT INTO [Maintenance] (space_code, reporter_id, assigned_to, problem_description, start_time, completion_time, status, result_note)
VALUES ('CL-203', 3, 2, N'Bóng đèn máy chiếu bị cháy, hình ảnh nhấp nháy', '2026-06-10 09:00:00', NULL, 'in_progress', N'Đã đặt linh kiện thay thế');
GO

-- 2. AU-101 — completed maintenance (AC repair)
INSERT INTO [Maintenance] (space_code, reporter_id, assigned_to, problem_description, start_time, completion_time, status, result_note)
VALUES ('AU-101', 2, 1, N'Máy lạnh không làm mát', '2026-06-01 08:00:00', '2026-06-03 16:00:00', 'completed', N'Đã thay máy nén, thiết bị hoạt động bình thường');
GO

-- 3. CS-301 — reported issue
INSERT INTO [Maintenance] (space_code, reporter_id, assigned_to, problem_description, start_time, completion_time, status, result_note)
VALUES ('CS-301', 4, NULL, N'Bàn phím máy trạm số 12 không hoạt động', '2026-06-27 11:00:00', NULL, 'reported', NULL);
GO

-- 4. PL-001 — cancelled maintenance
INSERT INTO [Maintenance] (space_code, reporter_id, assigned_to, problem_description, start_time, completion_time, status, result_note)
VALUES ('PL-001', 2, NULL, N'Máy in 3D kẹt filament', '2026-06-05 10:00:00', '2026-06-05 15:00:00', 'cancelled', N'Sự cố tự khắc phục trước khi kỹ thuật viên đến — máy tự làm sạch');
GO

-- 5. CS-302 — assigned maintenance (network issue)
INSERT INTO [Maintenance] (space_code, reporter_id, assigned_to, problem_description, start_time, completion_time, status, result_note)
VALUES ('CS-302', 5, 9, N'Mất kết nối mạng tại các máy trạm 5-8', '2026-06-28 14:00:00', NULL, 'assigned', N'Đã phân công In kiểm tra switch mạng');
GO

-- ============================================================
-- NEGATIVE TEST CASES (commented out — intentionally fail)
-- ============================================================
-- These INSERT statements would fail due to triggers/constraints
-- and are provided here for manual testing only.

-- ============================================================
-- Test 1: Overlap Prevention
-- Attempt to insert an approved booking that overlaps with an
-- existing approved booking for the same space (CL-202).
-- Booking 7 is approved for CL-202 on 2026-07-03 08:00-10:00.
-- This would create an overlap at 2026-07-03 09:00-11:00.
-- Expect: TRG_Booking_PreventOverlap throws error 50001.
-- ============================================================
-- BEGIN TRY
--     INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
--     VALUES (4, 'CL-202', '2026-07-03 09:00:00', '2026-07-03 11:00:00', N'Test overlap — sẽ bị lỗi', 30, 'workshop', 'approved');
-- END TRY
-- BEGIN CATCH
--     PRINT 'ERROR (expected): ' + ERROR_MESSAGE();
-- END CATCH;
-- GO

-- ============================================================
-- Test 2: Unavailable Space Block
-- Attempt to book CL-203 which is under maintenance.
-- Expect: TRG_Booking_CheckSpaceAvailable throws error 50002.
-- ============================================================
-- BEGIN TRY
--     INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
--     VALUES (4, 'CL-203', '2026-07-10 08:00:00', '2026-07-10 10:00:00', N'Test unavailable space — sẽ bị lỗi', 20, 'workshop', 'approved');
-- END TRY
-- BEGIN CATCH
--     PRINT 'ERROR (expected): ' + ERROR_MESSAGE();
-- END CATCH;
-- GO

-- ============================================================
-- Test 3: Capacity Enforcement
-- Attempt to book AU-101 (capacity 200) with 250 participants.
-- Expect: TRG_Booking_CheckCapacity throws error 50003.
-- ============================================================
-- BEGIN TRY
--     INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
--     VALUES (4, 'AU-101', '2026-08-01 08:00:00', '2026-08-01 10:00:00', N'Test capacity — sẽ bị lỗi', 250, 'seminar', 'approved');
-- END TRY
-- BEGIN CATCH
--     PRINT 'ERROR (expected): ' + ERROR_MESSAGE();
-- END CATCH;
-- GO

-- ============================================================
-- Test 4: CHECK constraint — requested_end must be after requested_start
-- Expect: CK_Booking_requested_end constraint violation.
-- ============================================================
-- BEGIN TRY
--     INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
--     VALUES (4, 'AU-101', '2026-08-01 10:00:00', '2026-08-01 08:00:00', N'Test time travel — sẽ bị lỗi', 50, 'meeting', 'pending');
-- END TRY
-- BEGIN CATCH
--     PRINT 'ERROR (expected): ' + ERROR_MESSAGE();
-- END CATCH;
-- GO

-- ============================================================
-- Test 5: FK violation — non-existent user
-- Expect: FK_Booking_User constraint violation.
-- ============================================================
-- BEGIN TRY
--     INSERT INTO [Booking] (user_id, space_code, requested_start, requested_end, purpose, expected_participants, booking_type, status)
--     VALUES (999, 'AU-101', '2026-08-01 08:00:00', '2026-08-01 10:00:00', N'Test FK user — sẽ bị lỗi', 50, 'meeting', 'pending');
-- END TRY
-- BEGIN CATCH
--     PRINT 'ERROR (expected): ' + ERROR_MESSAGE();
-- END CATCH;
-- GO