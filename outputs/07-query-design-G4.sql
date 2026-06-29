-- ============================================================
-- Query Design — Campus Space Management System
-- Target: Microsoft SQL Server
-- All queries use DECLARE @Variable for WHERE clause filters.
-- ============================================================

USE CampusSpaceManagement;
GO

-- ============================================================
-- Query 1: List Available Spaces for a Given Time Range
-- Business Question: Which spaces are available for booking
--   on 2026-07-05 from 13:00 to 17:00?
-- Target User: All users (students, lecturers, staff)
-- Logic: Find spaces that are active, not under maintenance/
--   closed/retired, and have NO approved or checked_in booking
--   overlapping the requested time range.
-- ============================================================
DECLARE @CheckStart DATETIME2 = '2026-07-05 13:00:00';
DECLARE @CheckEnd   DATETIME2 = '2026-07-05 17:00:00';

SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.building,
    s.floor,
    s.room_number,
    s.capacity,
    s.usage_policy
FROM [Space] s
WHERE s.is_active = 1
  AND s.status NOT IN ('under_maintenance', 'temporarily_closed', 'retired')
  AND NOT EXISTS (
      SELECT 1
      FROM [Booking] b
      WHERE b.space_code = s.space_code
        AND b.status IN ('approved', 'checked_in')
        AND b.requested_start < @CheckEnd
        AND b.requested_end > @CheckStart
  )
ORDER BY s.building, s.floor, s.room_number;
GO

-- ============================================================
-- Query 2: Find Conflicting Bookings for a Space
-- Business Question: What approved/checked_in bookings
--   conflict with a proposed 2-hour slot in CL-201?
-- Target User: Facility Staff, Facility Manager
-- Logic: Show all confirmed bookings for the space that
--   overlap with the candidate time range.
-- ============================================================
DECLARE @TargetSpace    NVARCHAR(20) = 'CL-201';
DECLARE @ProposedStart  DATETIME2    = '2026-07-08 09:00:00';
DECLARE @ProposedEnd    DATETIME2    = '2026-07-08 11:00:00';

SELECT
    b.booking_id,
    u.full_name AS requester,
    u.role AS requester_role,
    b.requested_start,
    b.requested_end,
    b.purpose,
    b.booking_type,
    b.status,
    DATEDIFF(MINUTE,
        CASE WHEN b.requested_start > @ProposedStart THEN b.requested_start ELSE @ProposedStart END,
        CASE WHEN b.requested_end   < @ProposedEnd   THEN b.requested_end   ELSE @ProposedEnd END
    ) AS overlap_minutes
FROM [Booking] b
JOIN [User] u ON b.user_id = u.user_id
WHERE b.space_code = @TargetSpace
  AND b.status IN ('approved', 'checked_in')
  AND b.requested_start < @ProposedEnd
  AND b.requested_end > @ProposedStart
ORDER BY b.requested_start;
GO

-- ============================================================
-- Query 3: Booking History of a User
-- Business Question: Show all past and upcoming bookings
--   for user Phạm Thị Dung (user_id = 4).
-- Target User: Facility Staff, Department Administrator
-- Logic: Join Booking with User, Space, and optional
--   BookingApproval and BookingSession for full context.
-- ============================================================
DECLARE @TargetUserId INT = 4;

SELECT
    b.booking_id,
    s.space_name,
    s.building,
    s.room_number,
    b.requested_start,
    b.requested_end,
    b.purpose,
    b.booking_type,
    b.status,
    ba.decision,
    ba.decision_time,
    ba.decision_note,
    bs.actual_start,
    bs.actual_end,
    b.created_at
FROM [Booking] b
JOIN [Space] s ON b.space_code = s.space_code
LEFT JOIN [BookingApproval] ba ON b.booking_id = ba.booking_id
LEFT JOIN [BookingSession] bs ON b.booking_id = bs.booking_id
WHERE b.user_id = @TargetUserId
ORDER BY b.requested_start DESC;
GO

-- ============================================================
-- Query 4: Upcoming Approved Bookings for a Space
-- Business Question: What approved bookings are coming up
--   for the Main Auditorium (AU-101)?
-- Target User: Facility Staff, Facility Manager
-- Logic: Filter by space, status = 'approved', and future
--   requested_start.
-- ============================================================
DECLARE @SpaceCode NVARCHAR(20) = 'AU-101';

SELECT
    b.booking_id,
    u.full_name AS requester,
    u.email AS requester_email,
    u.role AS requester_role,
    b.requested_start,
    b.requested_end,
    b.purpose,
    b.expected_participants,
    b.booking_type,
    DATEDIFF(DAY, GETDATE(), b.requested_start) AS days_until_booking
FROM [Booking] b
JOIN [User] u ON b.user_id = u.user_id
WHERE b.space_code = @SpaceCode
  AND b.status = 'approved'
  AND b.requested_start >= GETDATE()
ORDER BY b.requested_start;
GO

-- ============================================================
-- Query 5: Spaces Currently Under Maintenance
-- Business Question: Which spaces are under maintenance
--   right now, and what is being done?
-- Target User: Facility Manager, Facility Staff, All Users
-- Logic: Show spaces with status 'under_maintenance' plus
--   any maintenance records that are still open.
-- ============================================================
SELECT
    s.space_code,
    s.space_name,
    s.building,
    s.floor,
    s.room_number,
    m.maintenance_id,
    m.problem_description,
    m.start_time,
    m.status AS maintenance_status,
    reporter.full_name AS reported_by,
    assigned.full_name AS assigned_to,
    m.result_note
FROM [Space] s
JOIN [Maintenance] m ON s.space_code = m.space_code
LEFT JOIN [User] reporter ON m.reporter_id = reporter.user_id
LEFT JOIN [User] assigned ON m.assigned_to = assigned.user_id
WHERE s.status = 'under_maintenance'
   OR m.status IN ('reported', 'assigned', 'in_progress')
ORDER BY m.start_time DESC;
GO

-- ============================================================
-- Query 6: Space Utilization Report (Past 30 Days)
-- Business Question: What percentage of available time was
--   each space used over the past 30 days?
-- Target User: Facility Manager, Department Administrator
-- Logic: Sum minutes of completed/checked_in bookings per
--   space and divide by total available minutes.
-- ============================================================
DECLARE @ReportStart DATETIME2 = DATEADD(DAY, -30, GETDATE());
DECLARE @ReportEnd   DATETIME2 = GETDATE();

SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.building,
    s.capacity,
    COUNT(b.booking_id) AS total_bookings,
    ISNULL(SUM(DATEDIFF(MINUTE,
        CASE WHEN b.requested_start < @ReportStart THEN @ReportStart ELSE b.requested_start END,
        CASE WHEN b.requested_end   > @ReportEnd   THEN @ReportEnd   ELSE b.requested_end   END
    )), 0) AS total_minutes_used,
    CAST(ISNULL(SUM(DATEDIFF(MINUTE,
        CASE WHEN b.requested_start < @ReportStart THEN @ReportStart ELSE b.requested_start END,
        CASE WHEN b.requested_end   > @ReportEnd   THEN @ReportEnd   ELSE b.requested_end   END
    )), 0) AS FLOAT) / (60.0 * 24.0 * 30.0) * 100.0 AS utilization_pct
FROM [Space] s
LEFT JOIN [Booking] b
    ON s.space_code = b.space_code
    AND b.status IN ('checked_in', 'completed')
    AND b.requested_start < @ReportEnd
    AND b.requested_end > @ReportStart
WHERE s.is_active = 1
GROUP BY s.space_code, s.space_name, s.space_type, s.building, s.capacity
ORDER BY utilization_pct DESC;
GO

-- ============================================================
-- Query 7: Checked-In But Not Completed (No-Show Risk)
-- Business Question: Which bookings are currently checked in
--   but haven't been completed yet?
-- Target User: Facility Staff, Facility Manager
-- Logic: Find bookings with status = 'checked_in' that have
--   a BookingSession record but actual_end is NULL.
-- ============================================================
SELECT
    b.booking_id,
    u.full_name AS requester,
    u.email AS requester_email,
    u.role AS requester_role,
    s.space_name,
    s.building,
    s.room_number,
    b.requested_start,
    b.requested_end,
    bs.actual_start,
    bs.checked_in_by,
    bs.initial_condition,
    DATEDIFF(MINUTE, bs.actual_start, GETDATE()) AS minutes_since_checkin
FROM [Booking] b
JOIN [BookingSession] bs ON b.booking_id = bs.booking_id
JOIN [User] u ON b.user_id = u.user_id
JOIN [Space] s ON b.space_code = s.space_code
WHERE b.status = 'checked_in'
  AND bs.actual_end IS NULL
ORDER BY bs.actual_start;
GO

-- ============================================================
-- Query 8: Most Frequently Booked Space Type
-- Business Question: Which type of space is booked most
--   often (by total booking count)?
-- Target User: Facility Manager, Department Administrator
-- Logic: Group completed/approved bookings by space_type
--   and rank by count.
-- ============================================================
SELECT TOP 5
    s.space_type,
    COUNT(b.booking_id) AS total_bookings,
    COUNT(DISTINCT s.space_code) AS unique_spaces_used,
    AVG(DATEDIFF(MINUTE, b.requested_start, b.requested_end)) AS avg_duration_minutes
FROM [Booking] b
JOIN [Space] s ON b.space_code = s.space_code
WHERE b.status IN ('completed', 'checked_in', 'approved')
GROUP BY s.space_type
ORDER BY total_bookings DESC;
GO

-- ============================================================
-- Query 9: Maintenance History for a Specific Space
-- Business Question: What is the complete maintenance
--   history for CL-203?
-- Target User: Facility Staff, Facility Manager
-- Logic: All maintenance records for the space, ordered
--   by start time descending.
-- ============================================================
DECLARE @MaintSpace NVARCHAR(20) = 'CL-203';

SELECT
    m.maintenance_id,
    m.problem_description,
    m.start_time,
    m.completion_time,
    m.status AS maintenance_status,
    reporter.full_name AS reported_by,
    assigned.full_name AS assigned_to,
    m.result_note,
    DATEDIFF(DAY, m.start_time, ISNULL(m.completion_time, GETDATE())) AS duration_days
FROM [Maintenance] m
LEFT JOIN [User] reporter ON m.reporter_id = reporter.user_id
LEFT JOIN [User] assigned ON m.assigned_to = assigned.user_id
WHERE m.space_code = @MaintSpace
ORDER BY m.start_time DESC;
GO

-- ============================================================
-- Query 10: Pending Bookings Needing Approval
-- Business Question: Which bookings are waiting for approval
--   and how long have they been waiting?
-- Target User: Facility Staff, Facility Manager
-- Logic: All bookings with status = 'pending', ordered by
--   created_at (oldest first).
-- ============================================================
SELECT
    b.booking_id,
    u.full_name AS requester,
    u.department,
    u.role AS requester_role,
    s.space_name,
    s.building,
    s.room_number,
    b.requested_start,
    b.requested_end,
    b.purpose,
    b.expected_participants,
    b.booking_type,
    b.created_at,
    DATEDIFF(HOUR, b.created_at, GETDATE()) AS hours_since_request
FROM [Booking] b
JOIN [User] u ON b.user_id = u.user_id
JOIN [Space] s ON b.space_code = s.space_code
WHERE b.status = 'pending'
ORDER BY b.created_at;
GO

-- ============================================================
-- Query 11: Booking Count by Status (Dashboard Summary)
-- Business Question: What is the current distribution of
--   bookings by status?
-- Target User: Facility Manager, Department Administrator
-- Logic: Simple GROUP BY on status with count.
-- ============================================================
SELECT
    b.status,
    COUNT(*) AS booking_count
FROM [Booking] b
GROUP BY b.status
ORDER BY booking_count DESC;
GO

-- ============================================================
-- Query 12: Users with Most Bookings (Top 5)
-- Business Question: Which users have submitted the most
--   booking requests?
-- Target User: Facility Manager
-- Logic: Group by user, count bookings, return top 5.
-- ============================================================
SELECT TOP 5
    u.user_id,
    u.full_name,
    u.role,
    u.department,
    COUNT(b.booking_id) AS total_bookings,
    SUM(CASE WHEN b.status = 'completed' THEN 1 ELSE 0 END) AS completed_bookings,
    SUM(CASE WHEN b.status = 'no_show'   THEN 1 ELSE 0 END) AS no_show_bookings
FROM [User] u
LEFT JOIN [Booking] b ON u.user_id = b.user_id
GROUP BY u.user_id, u.full_name, u.role, u.department
ORDER BY total_bookings DESC;
GO
