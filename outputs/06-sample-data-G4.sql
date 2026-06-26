-- ============================================================
-- Campus Space Management System — Sample Data
-- Target: Microsoft SQL Server
-- Context: Ho Chi Minh City University of Science
-- Today's date: 2026-06-26
-- ============================================================

USE [CampusSpaceManagement];
GO

-- ============================================================
-- 1. USERS
-- ============================================================
INSERT INTO [User] (FullName, Email, PhoneNumber, Role, Department, AccountStatus)
VALUES
    (N'Nguyễn Văn An',    'an.nguyen@hcmus.edu.vn',    '0901234567', 'lecturer',              N'Khoa học Máy tính',  'active'),
    (N'Trần Thị Bình',    'binh.tran@hcmus.edu.vn',    '0902345678', 'student',               N'Khoa học Máy tính',  'active'),
    (N'Lê Hoàng Cường',   'cuong.le@hcmus.edu.vn',    '0903456789', 'facility_staff',        N'Văn phòng Khoa',     'active'),
    (N'Phạm Minh Dung',   'dung.pham@hcmus.edu.vn',   '0904567890', 'facility_manager',      N'Văn phòng Khoa',     'active'),
    (N'Huỳnh Thị Em',     'em.huynh@hcmus.edu.vn',    '0905678901', 'teaching_assistant',    N'Khoa học Máy tính',  'active'),
    (N'Đỗ Văn Phước',     'phuoc.do@hcmus.edu.vn',    '0906789012', 'department_administrator', N'Khoa học Máy tính', 'active'),
    (N'Ngô Thị Giang',    'giang.ngo@hcmus.edu.vn',    '0907890123', 'student',               N'Công nghệ thông tin','active'),
    (N'Bùi Văn Hải',      'hai.bui@hcmus.edu.vn',     '0908901234', 'lecturer',              N'Công nghệ thông tin','active');
GO

-- ============================================================
-- 2. SPACES
-- ============================================================
INSERT INTO Space (SpaceCode, SpaceName, SpaceType, Building, Floor, RoomNumber, Capacity, Status, UsagePolicy)
VALUES
    ('A101', N'Giảng đường A101', 'auditorium',        N'Tòa A', '1', '101', 200, 'available',         N'Giảng dạy, hội thảo, sự kiện'),
    ('A202', N'Phòng máy A202',   'computer_laboratory', N'Tòa A', '2', '202', 40,  'available',         N'Thực hành tin học'),
    ('B105', N'Phòng học B105',   'classroom',          N'Tòa B', '1', '105', 50,  'available',         N'Giảng dạy lý thuyết'),
    ('B303', N'Phòng họp B303',   'meeting_room',       N'Tòa B', '3', '303', 20,  'available',         N'Họp, hội đồng'),
    ('C201', N'Lab đồ án C201',   'project_laboratory', N'Tòa C', '2', '201', 30,  'available',         N'Sinh viên làm đồ án'),
    ('C101', N'Phòng máy C101',   'computer_laboratory', N'Tòa C', '1', '101', 35,  'under_maintenance', N'Đang bảo trì'),
    ('A001', N'Phòng sinh viên A001', 'student_workspace', N'Tòa A', '0', '001', 15, 'available',       N'Sinh viên tự học');
GO

-- ============================================================
-- 3. FACILITIES
-- ============================================================
INSERT INTO Facility (FacilityName, Description)
VALUES
    (N'Máy chiếu',         N'Projector'),
    (N'Bảng trắng',        N'Whiteboard'),
    (N'Micro không dây',   N'Wireless microphone'),
    (N'Máy tính',          N'Desktop computer'),
    (N'Thiết bị livestream', N'Livestream equipment'),
    (N'Máy lạnh',          N'Air conditioner');
GO

-- ============================================================
-- 4. SPACE-FACILITY MAPPING
-- ============================================================
INSERT INTO SpaceFacility (SpaceID, FacilityID)
VALUES
    (1, 1), (1, 2), (1, 3), (1, 5), (1, 6),   -- A101: projector, whiteboard, mic, livestream, AC
    (2, 1), (2, 2), (2, 4), (2, 6),           -- A202: projector, whiteboard, computers, AC
    (3, 1), (3, 2), (3, 6),                   -- B105: projector, whiteboard, AC
    (4, 1), (4, 2), (4, 3), (4, 6),           -- B303: projector, whiteboard, mic, AC
    (5, 4), (5, 6),                           -- C201: computers, AC
    (6, 1), (6, 2), (6, 4), (6, 6),           -- C101: projector, whiteboard, computers, AC
    (7, 2), (7, 4), (7, 6);                   -- A001: whiteboard, computer, AC
GO

-- ============================================================
-- 5. BOOKING REQUESTS (Past — Lifecycle Simulation)
-- ============================================================

-- Booking 1: Past completed booking (lecture on 2026-06-20)
INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status, CreatedAt)
VALUES (1, 1, '2026-06-20 07:30:00', '2026-06-20 09:30:00', N'Bài giảng Cấu trúc dữ liệu', 'lecture', 150, 'pending', '2026-06-15 08:00:00');

INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (1, NULL, 'pending', 1, '2026-06-15 08:00:00', N'Tạo yêu cầu');

-- Approve
UPDATE BookingRequest SET Status = 'approved', ModifiedAt = '2026-06-15 10:00:00' WHERE BookingID = 1;
INSERT INTO BookingApproval (BookingID, ApprovedByUserID, DecisionTime, Decision, DecisionNote)
VALUES (1, 4, '2026-06-15 10:00:00', 'approved', N'Đã duyệt lịch giảng');
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (1, 'pending', 'approved', 4, '2026-06-15 10:00:00', N'Duyệt bởi quản lý');

-- Check-in
UPDATE BookingRequest SET Status = 'checked_in', ModifiedAt = '2026-06-20 07:25:00' WHERE BookingID = 1;
INSERT INTO CheckIn (BookingID, CheckedInByUserID, ActualStartTime, InitialCondition)
VALUES (1, 3, '2026-06-20 07:25:00', N'Phòng sạch, máy chiếu hoạt động tốt');
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (1, 'approved', 'checked_in', 3, '2026-06-20 07:25:00', N'Check-in thành công');

-- Check-out / Complete
UPDATE BookingRequest SET Status = 'completed', ModifiedAt = '2026-06-20 09:35:00' WHERE BookingID = 1;
INSERT INTO CheckOut (BookingID, CheckedOutByUserID, ActualEndTime, FinalCondition, UsageNotes)
VALUES (1, 3, '2026-06-20 09:35:00', N'Phòng sạch, thiết bị nguyên vẹn', N'Kết thúc buổi học đúng giờ');
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (1, 'checked_in', 'completed', 3, '2026-06-20 09:35:00', N'Hoàn thành');

-- Booking 2: Past rejected booking
INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status, CreatedAt)
VALUES (2, 1, '2026-06-20 10:00:00', '2026-06-20 12:00:00', N'Sự kiện sinh viên', 'student_activity', 180, 'pending', '2026-06-16 14:00:00');

INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (2, NULL, 'pending', 2, '2026-06-16 14:00:00', N'Tạo yêu cầu');

UPDATE BookingRequest SET Status = 'rejected', ModifiedAt = '2026-06-17 08:00:00' WHERE BookingID = 2;
INSERT INTO BookingApproval (BookingID, ApprovedByUserID, DecisionTime, Decision, DecisionNote, RejectionReason)
VALUES (2, 4, '2026-06-17 08:00:00', 'rejected', N'Không thể duyệt', N'Số lượng người tham dự vượt quá sức chứa');
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (2, 'pending', 'rejected', 4, '2026-06-17 08:00:00', N'Từ chối do quá sức chứa');

-- Booking 3: Past no-show booking (2026-06-22, approved but never checked in)
INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status, CreatedAt)
VALUES (7, 4, '2026-06-22 13:00:00', '2026-06-22 15:00:00', N'Họp nhóm đồ án', 'meeting', 10, 'pending', '2026-06-18 09:00:00');

INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (3, NULL, 'pending', 7, '2026-06-18 09:00:00', N'Tạo yêu cầu');

UPDATE BookingRequest SET Status = 'approved', ModifiedAt = '2026-06-18 15:00:00' WHERE BookingID = 3;
INSERT INTO BookingApproval (BookingID, ApprovedByUserID, DecisionTime, Decision, DecisionNote)
VALUES (3, 3, '2026-06-18 15:00:00', 'approved', N'Đã duyệt');
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (3, 'pending', 'approved', 3, '2026-06-18 15:00:00', N'Duyệt bởi nhân viên');

-- Mark as no-show (2026-06-22 after end time with no check-in)
UPDATE BookingRequest SET Status = 'no_show', ModifiedAt = '2026-06-22 15:30:00' WHERE BookingID = 3;
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (3, 'approved', 'no_show', 3, '2026-06-22 15:30:00', N'Không đến sử dụng');

-- Booking 4: Past cancelled booking (2026-06-23, cancelled by requester)
INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status, CreatedAt)
VALUES (5, 3, '2026-06-23 08:00:00', '2026-06-23 10:00:00', N'Bài tập nhóm', 'seminar', 30, 'pending', '2026-06-20 07:00:00');

INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (4, NULL, 'pending', 5, '2026-06-20 07:00:00', N'Tạo yêu cầu');

UPDATE BookingRequest SET Status = 'cancelled', ModifiedAt = '2026-06-22 16:00:00' WHERE BookingID = 4;
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (4, 'pending', 'cancelled', 5, '2026-06-22 16:00:00', N'Hủy bởi người yêu cầu');

-- Booking 5: Past completed computer lab session
INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status, CreatedAt)
VALUES (1, 2, '2026-06-24 13:00:00', '2026-06-24 16:00:00', N'Thực hành CSDL', 'lecture', 35, 'pending', '2026-06-19 10:00:00');

INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (5, NULL, 'pending', 1, '2026-06-19 10:00:00', N'Tạo yêu cầu');

UPDATE BookingRequest SET Status = 'approved', ModifiedAt = '2026-06-19 14:00:00' WHERE BookingID = 5;
INSERT INTO BookingApproval (BookingID, ApprovedByUserID, DecisionTime, Decision, DecisionNote)
VALUES (5, 4, '2026-06-19 14:00:00', 'approved', N'Đã duyệt');
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (5, 'pending', 'approved', 4, '2026-06-19 14:00:00', N'Duyệt');

UPDATE BookingRequest SET Status = 'checked_in', ModifiedAt = '2026-06-24 12:55:00' WHERE BookingID = 5;
INSERT INTO CheckIn (BookingID, CheckedInByUserID, ActualStartTime, InitialCondition)
VALUES (5, 3, '2026-06-24 12:55:00', N'Các máy tính hoạt động tốt');
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (5, 'approved', 'checked_in', 3, '2026-06-24 12:55:00', N'Check-in');

UPDATE BookingRequest SET Status = 'completed', ModifiedAt = '2026-06-24 16:10:00' WHERE BookingID = 5;
INSERT INTO CheckOut (BookingID, CheckedOutByUserID, ActualEndTime, FinalCondition, UsageNotes)
VALUES (5, 3, '2026-06-24 16:10:00', N'Máy tính đã tắt, phòng sạch', N'Hoàn thành buổi thực hành');
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (5, 'checked_in', 'completed', 3, '2026-06-24 16:10:00', N'Hoàn thành');

-- ============================================================
-- 6. BOOKING REQUESTS (Future — Pending & Approved)
-- ============================================================

-- Booking 6: Future approved booking (2026-06-28)
INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status, CreatedAt)
VALUES (8, 1, '2026-06-28 08:00:00', '2026-06-28 11:00:00', N'Hội thảo AI', 'seminar', 100, 'pending', '2026-06-25 09:00:00');

INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (6, NULL, 'pending', 8, '2026-06-25 09:00:00', N'Tạo yêu cầu');

UPDATE BookingRequest SET Status = 'approved', ModifiedAt = '2026-06-25 14:00:00' WHERE BookingID = 6;
INSERT INTO BookingApproval (BookingID, ApprovedByUserID, DecisionTime, Decision, DecisionNote)
VALUES (6, 4, '2026-06-25 14:00:00', 'approved', N'Đã duyệt hội thảo');
INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (6, 'pending', 'approved', 4, '2026-06-25 14:00:00', N'Duyệt hội thảo');

-- Booking 7: Future pending booking (2026-07-01)
INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status, CreatedAt)
VALUES (2, 5, '2026-07-01 09:00:00', '2026-07-01 17:00:00', N'Làm đồ án tốt nghiệp', 'student_activity', 4, 'pending', '2026-06-26 10:00:00');

INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (7, NULL, 'pending', 2, '2026-06-26 10:00:00', N'Tạo yêu cầu');

-- Booking 8: Future pending — overlapping with booking 6 on same space (A101)
INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status, CreatedAt)
VALUES (7, 1, '2026-06-28 09:00:00', '2026-06-28 12:00:00', N'Sự kiện sinh viên', 'student_activity', 80, 'pending', '2026-06-26 11:00:00');

INSERT INTO BookingStatusHistory (BookingID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (8, NULL, 'pending', 7, '2026-06-26 11:00:00', N'Tạo yêu cầu (overlap với booking 6)');

-- ============================================================
-- 7. MAINTENANCE RECORDS
-- ============================================================

-- Maintenance 1: Completed maintenance (C101, AC fixed 2026-06-20)
INSERT INTO MaintenanceRecord (SpaceID, ReportedByUserID, AssignedToUserID, ProblemDescription, ProblemType, StartTime, CompletionTime, Status, ResultNote, CreatedAt)
VALUES (6, 8, 3, N'Máy lạnh phòng C101 không hoạt động', 'ac_failure', '2026-06-18 08:00:00', '2026-06-20 16:00:00', 'completed', N'Đã thay tụ máy lạnh', '2026-06-18 08:30:00');

INSERT INTO MaintenanceStatusHistory (MaintenanceRecordID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (1, NULL, 'reported', 8, '2026-06-18 08:30:00', N'Báo cáo sự cố');

UPDATE MaintenanceRecord SET Status = 'assigned', ModifiedAt = '2026-06-18 09:00:00' WHERE MaintenanceID = 1;
INSERT INTO MaintenanceStatusHistory (MaintenanceRecordID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (1, 'reported', 'assigned', 4, '2026-06-18 09:00:00', N'Phân công cho Lê Hoàng Cường');

UPDATE MaintenanceRecord SET Status = 'in_progress', ModifiedAt = '2026-06-19 08:00:00' WHERE MaintenanceID = 1;
INSERT INTO MaintenanceStatusHistory (MaintenanceRecordID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (1, 'assigned', 'in_progress', 3, '2026-06-19 08:00:00', N'Đang sửa chữa');

UPDATE MaintenanceRecord SET Status = 'completed', CompletionTime = '2026-06-20 16:00:00', ResultNote = N'Đã thay tụ máy lạnh', ModifiedAt = '2026-06-20 16:00:00' WHERE MaintenanceID = 1;
INSERT INTO MaintenanceStatusHistory (MaintenanceRecordID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (1, 'in_progress', 'completed', 3, '2026-06-20 16:00:00', N'Hoàn thành sửa chữa');

-- Maintenance 2: Active maintenance (projector broken, reported 2026-06-25, still in progress)
INSERT INTO MaintenanceRecord (SpaceID, ReportedByUserID, AssignedToUserID, ProblemDescription, ProblemType, StartTime, CompletionTime, Status, CreatedAt)
VALUES (3, 1, 3, N'Máy chiếu phòng B105 bị hỏng bóng đèn', 'broken_projector', '2026-06-25 10:00:00', NULL, 'reported', '2026-06-25 10:30:00');

INSERT INTO MaintenanceStatusHistory (MaintenanceRecordID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (2, NULL, 'reported', 1, '2026-06-25 10:30:00', N'Báo cáo máy chiếu hỏng');

UPDATE MaintenanceRecord SET Status = 'assigned', ModifiedAt = '2026-06-25 11:00:00' WHERE MaintenanceID = 2;
INSERT INTO MaintenanceStatusHistory (MaintenanceRecordID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (2, 'reported', 'assigned', 4, '2026-06-25 11:00:00', N'Phân công sửa');

UPDATE MaintenanceRecord SET Status = 'in_progress', ModifiedAt = '2026-06-26 08:00:00' WHERE MaintenanceID = 2;
INSERT INTO MaintenanceStatusHistory (MaintenanceRecordID, PreviousStatus, NewStatus, ChangedByUserID, ChangedAt, Note)
VALUES (2, 'assigned', 'in_progress', 3, '2026-06-26 08:00:00', N'Đang sửa máy chiếu');

-- ============================================================
-- 8. NEGATIVE TEST CASES (commented out — intentional violations)
-- ============================================================

-- === TEST 1: Overlapping approved booking ===
-- Booking 6 is already approved for A101 on 2026-06-28 08:00-11:00.
-- This insert would succeed (pending is allowed), but approving it should fail.
-- INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status)
-- VALUES (2, 1, '2026-06-28 09:00:00', '2026-06-28 10:30:00', N'Giờ học thêm', 'lecture', 50, 'pending');
-- REASON: Overlaps with approved Booking 6 on space A101. This pending insert succeeds,
-- but if someone tries to approve it, the application-level overlap check should reject it.

-- === TEST 2: Book a space under maintenance ===
-- Space C101 (SpaceID 6) has a completed maintenance now, but if we simulate:
-- INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status)
-- VALUES (1, 6, '2026-07-01 08:00:00', '2026-07-01 10:00:00', N'Thực hành', 'lecture', 30, 'pending');
-- REASON: Space C101 is currently in 'under_maintenance' status. The application
-- should reject this booking because the space status is not 'available'.

-- === TEST 3: End time before start time ===
-- INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status)
-- VALUES (1, 4, '2026-07-02 14:00:00', '2026-07-02 13:00:00', N'Test', 'meeting', 5, 'pending');
-- REASON: CK_BookingRequest_TimeRange constraint will fail because end time is before start time.

-- === TEST 4: Invalid PurposeType ===
-- INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status)
-- VALUES (1, 4, '2026-07-02 08:00:00', '2026-07-02 10:00:00', N'Test', 'invalid_type', 5, 'pending');
-- REASON: CK_BookingRequest_PurposeType constraint will fail — 'invalid_type' is not in the allowed list.

-- === TEST 5: Duplicate approval for same booking ===
-- Booking 1 already has an approval record. The UNIQUE constraint on BookingApproval.BookingID
-- prevents a second approval:
-- INSERT INTO BookingApproval (BookingID, ApprovedByUserID, DecisionTime, Decision, DecisionNote)
-- VALUES (1, 4, '2026-06-20 12:00:00', 'approved', N'Duplicate');
-- REASON: UQ_BookingApproval_BookingID constraint will fail — only one approval per booking allowed.

-- === TEST 6: Book a space that has active maintenance ===
-- Space B105 (SpaceID 3) currently has an active (in_progress) maintenance record
-- for a broken projector. If we try to book it during the maintenance period:
-- INSERT INTO BookingRequest (RequestedByUserID, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status)
-- VALUES (2, 3, '2026-06-26 09:00:00', '2026-06-26 11:00:00', N'Giờ học', 'lecture', 40, 'pending');
-- REASON: Application-level check — B105 has an active maintenance record (MaintenanceID 2)
-- that is still in progress, and the requested time overlaps. The application should reject this.
GO
