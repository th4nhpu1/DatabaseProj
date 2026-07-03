-- ============================================================
-- Query Design — Campus Space Management System
-- Target: Microsoft SQL Server
-- All time comparisons use SYSUTCDATETIME() to stay consistent
-- with the UTC-stored audit/booking columns in the schema.
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
-- Why useful: This is the core self-service search of any booking
--   system. It prevents double-booking at the source by showing
--   only rooms that are genuinely free, so users never request a
--   slot that staff will have to reject.
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
-- Why useful: When staff review a request manually, they need to
--   see exactly what clashes and by how much. The overlap-minutes
--   figure helps them decide whether to shift a slot slightly or
--   reject it outright.
-- ============================================================
DECLARE @TargetSpace    NVARCHAR(20) = 'CL-202';
DECLARE @ProposedStart  DATETIME2    = '2026-07-03 08:30:00';
DECLARE @ProposedEnd    DATETIME2    = '2026-07-03 09:30:00';

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
-- Why useful: Gives staff a full audit trail of one person's
--   activity in a single view. Essential for resolving disputes
--   ("I never booked that"), spotting repeat no-shows, and
--   answering user questions about their own history.
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
-- Why useful: Lets facility teams prepare a room ahead of time
--   (setup, cleaning, equipment checks) and see how many days'
--   lead time they have. It is the "what's next in this room"
--   operational view.
-- ============================================================
DECLARE @SpaceCode NVARCHAR(20) = 'CL-202';

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
    DATEDIFF(DAY, SYSUTCDATETIME(), b.requested_start) AS days_until_booking
FROM [Booking] b
JOIN [User] u ON b.user_id = u.user_id
WHERE b.space_code = @SpaceCode
  AND b.status = 'approved'
  AND b.requested_start >= SYSUTCDATETIME()
ORDER BY b.requested_start;
GO

-- ============================================================
-- Query 5: Spaces Currently Under Maintenance
-- Business Question: Which spaces are under maintenance
--   right now, and what is being done?
-- Target User: Facility Manager, Facility Staff, All Users
-- Logic: Show spaces flagged under_maintenance together with any
--   still-open maintenance record. A LEFT JOIN keeps a space that
--   is flagged under_maintenance even if no maintenance row exists
--   yet, so the OR condition works as intended.
-- Why useful: Combines the room's status flag with the live work
--   order so managers see both "this room is down" and "here is
--   the ticket / who owns it" in one place — the daily operations
--   board for the facilities team.
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
LEFT JOIN [Maintenance] m
    ON s.space_code = m.space_code
    AND m.status IN ('reported', 'assigned', 'in_progress')
LEFT JOIN [User] reporter ON m.reporter_id = reporter.user_id
LEFT JOIN [User] assigned ON m.assigned_to = assigned.user_id
WHERE s.status = 'under_maintenance'
   OR m.maintenance_id IS NOT NULL
ORDER BY m.start_time DESC;
GO

-- ============================================================
-- Query 6: Space Utilization Report (Past 30 Days)
-- Business Question: What percentage of *operating* time was
--   each space used over the past 30 days?
-- Target User: Facility Manager, Department Administrator
-- Logic: Sum minutes of completed/checked_in bookings per space
--   within the window, then divide by realistic operating minutes.
--   Operating hours assumed 07:00-22:00 = 15 h/day over 30 days.
-- Why useful: Utilization is the number that justifies budget and
--   space-planning decisions — which rooms are over-subscribed and
--   need duplicating, and which are idle and could be repurposed.
--   Dividing by operating time (not 24h) gives a figure managers
--   can actually act on.
-- ============================================================
DECLARE @ReportStart DATETIME2 = DATEADD(DAY, -30, SYSUTCDATETIME());
DECLARE @ReportEnd   DATETIME2 = SYSUTCDATETIME();
-- Operating minutes = 15 hours/day * 30 days = 27000 minutes
DECLARE @OperatingMinutes FLOAT = 15.0 * 60.0 * 30.0;

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
    )), 0) AS FLOAT) / @OperatingMinutes * 100.0 AS utilization_pct
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
-- Query 7: Checked-In But Not Completed (Overstay Watch)
-- Business Question: Which bookings are currently checked in
--   but haven't been completed yet?
-- Target User: Facility Staff, Facility Manager
-- Logic: Find bookings with status = 'checked_in' that have
--   a BookingSession record but actual_end is NULL.
-- Why useful: Flags rooms that are still "occupied" in the system
--   so staff can chase a check-out, free the room for the next
--   booking, and catch sessions that ran long — preventing ghost
--   occupancy that blocks new bookings.
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
    DATEDIFF(MINUTE, bs.actual_start, SYSUTCDATETIME()) AS minutes_since_checkin
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
--   and rank by count. Duration is based on requested times.
-- Why useful: Reveals demand patterns by category (e.g. labs vs
--   meeting rooms) to guide investment — build more of what is in
--   demand, and reconsider under-used categories.
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
-- Why useful: A per-room repair log exposes recurring problems.
--   If the same room keeps breaking, that is evidence to replace
--   equipment rather than keep paying for repeated fixes.
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
    DATEDIFF(DAY, m.start_time, ISNULL(m.completion_time, SYSUTCDATETIME())) AS duration_days
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
-- Why useful: This is the approver's work queue. Ordering by wait
--   time ensures the oldest requests are handled first and nothing
--   slips through the cracks — the backbone of a fair, timely
--   approval process.
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
    DATEDIFF(HOUR, b.created_at, SYSUTCDATETIME()) AS hours_since_request
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
-- Why useful: A one-glance health check of the whole system. A
--   spike in 'rejected' or 'no_show' signals a problem worth
--   investigating; it is the headline number on any dashboard.
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
-- Why useful: Identifies power users (for engagement or capacity
--   planning) and flags anyone with a high no-show ratio who may
--   need a reminder or a booking limit.
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

-- ============================================================
-- Query 13: No-Show Rate by User (Reliability Ranking)
-- Business Question: Which users approve bookings but repeatedly
--   fail to show up, and what is their no-show rate?
-- Target User: Facility Manager, Department Administrator
-- Logic: For each user, count approved-or-later bookings and the
--   share that ended as 'no_show'. Only include users who had at
--   least one confirmed booking (HAVING).
-- Why useful: No-shows waste scarce rooms that others were denied.
--   A reliability ranking lets managers warn or restrict repeat
--   offenders and measure whether reminders are working.
-- ============================================================
SELECT
    u.user_id,
    u.full_name,
    u.role,
    u.department,
    COUNT(b.booking_id) AS confirmed_bookings,
    SUM(CASE WHEN b.status = 'no_show' THEN 1 ELSE 0 END) AS no_shows,
    CAST(SUM(CASE WHEN b.status = 'no_show' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(b.booking_id) * 100.0 AS no_show_rate_pct
FROM [User] u
JOIN [Booking] b ON u.user_id = b.user_id
WHERE b.status IN ('approved', 'checked_in', 'completed', 'no_show')
GROUP BY u.user_id, u.full_name, u.role, u.department
HAVING COUNT(b.booking_id) > 0
ORDER BY no_show_rate_pct DESC, confirmed_bookings DESC;
GO

-- ============================================================
-- Query 14: Approver Workload and Decision Split
-- Business Question: How many bookings has each staff member
--   decided, and what is their approve vs reject split?
-- Target User: Facility Manager
-- Logic: Group BookingApproval by the deciding staff member and
--   count approvals vs rejections, plus average time to decide.
-- Why useful: Shows whether approval work is spread fairly across
--   staff and whether any approver is an outlier (rubber-stamping
--   everything, or rejecting far more than peers) — useful for
--   staffing and consistency audits.
-- ============================================================
SELECT
    staff.user_id,
    staff.full_name AS approver,
    staff.role AS approver_role,
    COUNT(*) AS decisions_made,
    SUM(CASE WHEN ba.decision = 'approved' THEN 1 ELSE 0 END) AS approvals,
    SUM(CASE WHEN ba.decision = 'rejected' THEN 1 ELSE 0 END) AS rejections,
    AVG(DATEDIFF(HOUR, b.created_at, ba.decision_time)) AS avg_hours_to_decide
FROM [BookingApproval] ba
JOIN [User] staff ON ba.staff_id = staff.user_id
JOIN [Booking] b ON ba.booking_id = b.booking_id
GROUP BY staff.user_id, staff.full_name, staff.role
ORDER BY decisions_made DESC;
GO

-- ============================================================
-- Query 15: Bookings by Department (Demand by Faculty)
-- Business Question: Which departments generate the most demand
--   for space, and how much time do they consume?
-- Target User: Facility Manager, Department Administrator
-- Logic: Group confirmed bookings by the requester's department;
--   count bookings and total requested minutes.
-- Why useful: Space is often cross-charged or allocated by faculty.
--   Knowing which department drives demand supports fair scheduling
--   priority and internal cost allocation.
-- ============================================================
SELECT
    u.department,
    COUNT(b.booking_id) AS total_bookings,
    SUM(DATEDIFF(MINUTE, b.requested_start, b.requested_end)) AS total_requested_minutes,
    COUNT(DISTINCT u.user_id) AS distinct_requesters
FROM [Booking] b
JOIN [User] u ON b.user_id = u.user_id
WHERE b.status IN ('approved', 'checked_in', 'completed')
GROUP BY u.department
ORDER BY total_bookings DESC;
GO

-- ============================================================
-- Query 16: Peak Booking Hours (Busiest Times of Day)
-- Business Question: At which hours of the day do confirmed
--   bookings most often start?
-- Target User: Facility Manager, Department Administrator
-- Logic: Group confirmed bookings by the hour of requested_start.
-- Why useful: Reveals rush hours so staffing, opening times, and
--   any release of extra rooms can be aligned to real demand. Also
--   exposes dead hours that could host lower-priority activities.
-- ============================================================
SELECT
    DATEPART(HOUR, b.requested_start) AS start_hour,
    COUNT(*) AS bookings_started,
    COUNT(DISTINCT b.space_code) AS spaces_involved
FROM [Booking] b
WHERE b.status IN ('approved', 'checked_in', 'completed')
GROUP BY DATEPART(HOUR, b.requested_start)
ORDER BY bookings_started DESC, start_hour;
GO

-- ============================================================
-- Query 17: Facilities Available in Each Space
-- Business Question: What equipment does each space have, listed
--   as a single readable line per room?
-- Target User: All users, Facility Staff
-- Logic: Join Space to Facility through SpaceFacility and use
--   STRING_AGG to collapse the M:N rows into one row per space.
-- Why useful: Users pick rooms by what is inside them (projector,
--   workstations, mic). A one-line equipment summary per room is
--   exactly what a booking UI needs to show, and avoids sending
--   people to rooms that lack what they need.
-- ============================================================
SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.capacity,
    STRING_AGG(f.facility_name, ', ') WITHIN GROUP (ORDER BY f.facility_name) AS facilities
FROM [Space] s
LEFT JOIN [SpaceFacility] sf ON s.space_code = sf.space_code
LEFT JOIN [Facility] f ON sf.facility_id = f.facility_id
WHERE s.is_active = 1
GROUP BY s.space_code, s.space_name, s.space_type, s.capacity
ORDER BY s.space_code;
GO

-- ============================================================
-- Query 18: Find Spaces That Have Specific Required Equipment
-- Business Question: Which available rooms with capacity >= 20
--   have BOTH a Projector AND a Computer Workstation?
-- Target User: Lecturers, Facility Staff
-- Logic: Match SpaceFacility against the required facility names,
--   then require the count of distinct matches to equal the number
--   of requirements (HAVING), guaranteeing ALL are present.
-- Why useful: Real requests are "I need a lab with a projector for
--   30 people," not "any room." This lets users filter by every
--   must-have feature at once — a genuine search that saves them
--   walking into a room missing the kit they needed.
-- ============================================================
DECLARE @MinCapacity INT = 20;

SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.capacity,
    s.building,
    s.room_number
FROM [Space] s
JOIN [SpaceFacility] sf ON s.space_code = sf.space_code
JOIN [Facility] f ON sf.facility_id = f.facility_id
WHERE s.is_active = 1
  AND s.status NOT IN ('under_maintenance', 'temporarily_closed', 'retired')
  AND s.capacity >= @MinCapacity
  AND f.facility_name IN (N'Projector', N'Computer Workstation')
GROUP BY s.space_code, s.space_name, s.space_type, s.capacity, s.building, s.room_number
HAVING COUNT(DISTINCT f.facility_name) = 2
ORDER BY s.capacity DESC;
GO

-- ============================================================
-- Query 19: Capacity Fit — How Full Was Each Completed Booking
-- Business Question: For completed bookings, how did expected
--   participants compare to the room's capacity?
-- Target User: Facility Manager, Department Administrator
-- Logic: For completed/checked_in bookings, compute the fill ratio
--   of expected participants against space capacity.
-- Why useful: Chronically low fill ratios mean big rooms are being
--   used for tiny groups — a sign to steer small groups to small
--   rooms and keep large rooms for events that need them. Improves
--   how well room sizes are matched to actual demand.
-- ============================================================
SELECT
    s.space_code,
    s.space_name,
    s.capacity,
    b.booking_id,
    b.purpose,
    b.expected_participants,
    CAST(b.expected_participants AS FLOAT) / s.capacity * 100.0 AS fill_ratio_pct
FROM [Booking] b
JOIN [Space] s ON b.space_code = s.space_code
WHERE b.status IN ('checked_in', 'completed')
ORDER BY fill_ratio_pct ASC;
GO

-- ============================================================
-- Query 20: Rooms With Confirmed Bookings While Under Maintenance
-- Business Question: Are there any confirmed bookings sitting on
--   rooms that are currently flagged unavailable?
-- Target User: Facility Manager, Facility Staff
-- Logic: Find approved/checked_in bookings whose space status is
--   under_maintenance, temporarily_closed, or retired — a data
--   integrity / conflict check.
-- Why useful: A safety-net audit. If a room goes down after a
--   booking was approved, this surfaces the clash so staff can
--   relocate the booking before people show up to a closed room —
--   catching problems the booking-time triggers cannot.
-- ============================================================
SELECT
    b.booking_id,
    u.full_name AS requester,
    u.email AS requester_email,
    s.space_code,
    s.space_name,
    s.status AS space_status,
    b.requested_start,
    b.requested_end,
    b.status AS booking_status
FROM [Booking] b
JOIN [Space] s ON b.space_code = s.space_code
JOIN [User] u ON b.user_id = u.user_id
WHERE b.status IN ('approved', 'checked_in')
  AND s.status IN ('under_maintenance', 'temporarily_closed', 'retired')
ORDER BY b.requested_start;
GO