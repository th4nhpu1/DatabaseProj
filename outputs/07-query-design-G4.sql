-- ============================================================
-- Query Design — Campus Space Management System
-- Target: Microsoft SQL Server
-- ============================================================

-- ------------------------------------------------------------
-- Query 1: Booking History for a Specific Space
-- Business Question: What is the complete booking history for
--   the Main Auditorium (AU-101)?
-- Target User(s): Facility Manager, Facility Staff
-- Usefulness: Allows staff to review past and upcoming usage
--   of a specific space for scheduling and reporting.
-- ------------------------------------------------------------
SELECT
    b.booking_id,
    u.full_name AS requester,
    u.role AS requester_role,
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
    bs.usage_notes
FROM [Booking] b
JOIN [User] u ON b.user_id = u.user_id
LEFT JOIN [BookingApproval] ba ON b.booking_id = ba.booking_id
LEFT JOIN [BookingSession] bs ON b.booking_id = bs.booking_id
WHERE b.space_code = 'AU-101'
ORDER BY b.requested_start DESC;

-- ------------------------------------------------------------
-- Query 2: Upcoming Approved Bookings (Next 7 Days)
-- Business Question: Which approved bookings are scheduled
--   for the next 7 days?
-- Target User(s): Facility Staff, Facility Manager
-- Usefulness: Helps staff prepare spaces and anticipate
--   upcoming usage.
-- ------------------------------------------------------------
SELECT
    b.booking_id,
    s.space_name,
    s.building,
    s.floor,
    s.room_number,
    u.full_name AS requester,
    u.email AS requester_email,
    b.requested_start,
    b.requested_end,
    b.purpose,
    b.expected_participants,
    b.booking_type
FROM [Booking] b
JOIN [Space] s ON b.space_code = s.space_code
JOIN [User] u ON b.user_id = u.user_id
WHERE b.status = 'approved'
  AND b.requested_start >= GETDATE()
  AND b.requested_start < DATEADD(DAY, 7, GETDATE())
ORDER BY b.requested_start;

-- ------------------------------------------------------------
-- Query 3: Spaces Currently Under Maintenance
-- Business Question: Which spaces are currently under
--   maintenance, and what is being done?
-- Target User(s): Facility Manager, Facility Staff, Users
-- Usefulness: Prevents users from attempting to book
--   unavailable spaces and helps managers track workload.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- Query 4: No-Show Bookings
-- Business Question: Which approved bookings were never
--   checked in (no-show)?
-- Target User(s): Facility Manager, Facility Staff
-- Usefulness: Identifies wasted space reservations and
--   helps enforce booking accountability.
-- ------------------------------------------------------------
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
    b.purpose,
    b.booking_type,
    b.created_at
FROM [Booking] b
JOIN [User] u ON b.user_id = u.user_id
JOIN [Space] s ON b.space_code = s.space_code
WHERE b.status = 'no_show'
ORDER BY b.requested_start DESC;

-- Note: No-show records are created by application logic
-- when an approved booking passes its requested_start time
-- without a corresponding check-in. In the sample data,
-- Booking #2 (MR-401, 2026-06-20 14:00-16:00) would be
-- flagged as no-show by the application after the threshold.

-- ------------------------------------------------------------
-- Query 5: Space Utilization Report
-- Business Question: What percentage of total available time
--   was each space booked over the past month?
-- Target User(s): Facility Manager, Department Administrator
-- Usefulness: Helps analyze space usage patterns and make
--   data-driven decisions about space allocation.
-- ------------------------------------------------------------
SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.building,
    s.capacity,
    COUNT(b.booking_id) AS total_bookings,
    SUM(DATEDIFF(MINUTE,
        CASE WHEN b.requested_start >= DATEADD(MONTH, -1, GETDATE())
             THEN b.requested_start
             ELSE DATEADD(MONTH, -1, GETDATE())
        END,
        CASE WHEN b.requested_end <= GETDATE()
             THEN b.requested_end
             ELSE GETDATE()
        END
    )) AS total_minutes_used,
    CAST(SUM(DATEDIFF(MINUTE,
        CASE WHEN b.requested_start >= DATEADD(MONTH, -1, GETDATE())
             THEN b.requested_start
             ELSE DATEADD(MONTH, -1, GETDATE())
        END,
        CASE WHEN b.requested_end <= GETDATE()
             THEN b.requested_end
             ELSE GETDATE()
        END
    )) AS FLOAT) / (60.0 * 24.0 * 30.0) * 100.0 AS utilization_pct
FROM [Space] s
LEFT JOIN [Booking] b
    ON s.space_code = b.space_code
    AND b.status IN ('approved', 'checked_in', 'completed')
    AND b.requested_start < GETDATE()
    AND b.requested_end > DATEADD(MONTH, -1, GETDATE())
GROUP BY s.space_code, s.space_name, s.space_type, s.building, s.capacity
ORDER BY utilization_pct DESC;

-- ------------------------------------------------------------
-- Query 6: Pending Approvals Queue
-- Business Question: Which bookings are waiting for approval?
-- Target User(s): Facility Staff, Facility Manager
-- Usefulness: Provides a clear queue of requests that need
--   staff attention.
-- ------------------------------------------------------------
SELECT
    b.booking_id,
    u.full_name AS requester,
    u.department,
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
