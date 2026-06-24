-- ============================================================
-- 07-query-design-G04.sql
-- Business Queries — School Space Booking System
-- Group 04
-- Microsoft SQL Server T-SQL
-- ============================================================

-- ============================================================
-- Query 1: List all available spaces for a given time range
--
-- Business question:
--   Which spaces are available to book on 2026-09-01 from
--   09:00 to 11:00?
--
-- Target user:
--   Students, lecturers, or staff looking for a free room.
--
-- Explanation:
--   Filters spaces with currentStatus = 'available', then
--   excludes those with overlapping approved/active bookings
--   or overlapping ongoing maintenance records.
-- ============================================================
DECLARE @Q1_Start DATETIME2 = '2026-09-01 09:00:00';
DECLARE @Q1_End   DATETIME2 = '2026-09-01 11:00:00';

SELECT s.spaceCode, s.spaceName, s.spaceType, s.building,
       s.floor, s.roomNumber, s.capacity
FROM [Space] s
WHERE s.currentStatus = 'available'
  AND NOT EXISTS (
      SELECT 1 FROM [Booking] b
      WHERE b.spaceCode = s.spaceCode
        AND b.status IN ('approved', 'checked_in', 'completed')
        AND b.requestedStartTime < @Q1_End
        AND b.requestedEndTime   > @Q1_Start
  )
  AND NOT EXISTS (
      SELECT 1 FROM [MaintenanceRecord] m
      WHERE m.spaceCode = s.spaceCode
        AND m.status IN ('reported', 'in_progress')
        AND m.startTime < @Q1_End
        AND (m.completionTime IS NULL OR m.completionTime > @Q1_Start)
  )
ORDER BY s.building, s.floor, s.roomNumber;

-- ============================================================
-- Query 2: Find conflicting bookings for a specific space
--
-- Business question:
--   Are there existing bookings conflicting with a new
--   request for space CS-A101 on 2026-09-10?
--
-- Target user:
--   Facility staff checking scheduling conflicts.
--
-- Explanation:
--   Retrieves all active (approved/checked_in/completed)
--   bookings for a given space on a target date.
-- ============================================================
DECLARE @Q2_SpaceCode NVARCHAR(20) = 'CS-A101';
DECLARE @Q2_TargetDate DATE = '2026-09-10';

SELECT b.bookingId, u.fullName AS requester,
       b.requestedStartTime, b.requestedEndTime,
       b.status, b.purpose
FROM [Booking] b
JOIN [User] u ON b.userId = u.userId
WHERE b.spaceCode = @Q2_SpaceCode
  AND b.status IN ('approved', 'checked_in', 'completed')
  AND CAST(b.requestedStartTime AS DATE) = @Q2_TargetDate
ORDER BY b.requestedStartTime;

-- ============================================================
-- Query 3: View booking history of a specific user
--
-- Business question:
--   Show all past and present bookings for userId = 4
--   (lecturer Pham Minh Duc).
--
-- Target user:
--   Lecturers and students reviewing their own bookings.
--
-- Explanation:
--   Joins Booking with Space, BookingApproval, CheckIn,
--   and CheckOut to present a complete booking timeline.
-- ============================================================
DECLARE @Q3_UserId INT = 4;

SELECT b.bookingId, s.spaceName, s.spaceCode,
       b.requestedStartTime, b.requestedEndTime,
       b.bookingType, b.status, b.submittedAt,
       ba.decisionTime, ba.decisionNote,
       ci.actualStartTime, co.actualEndTime
FROM [Booking] b
JOIN [Space] s ON b.spaceCode = s.spaceCode
LEFT JOIN [BookingApproval] ba ON b.bookingId = ba.bookingId
LEFT JOIN [CheckIn] ci ON b.bookingId = ci.bookingId
LEFT JOIN [CheckOut] co ON b.bookingId = co.bookingId
WHERE b.userId = @Q3_UserId
ORDER BY b.requestedStartTime DESC;

-- ============================================================
-- Query 4: View upcoming approved bookings for a space
--
-- Business question:
--   What approved bookings are coming up for Computer Lab
--   CS-B202?
--
-- Target user:
--   Facility staff preparing rooms for upcoming sessions.
--
-- Explanation:
--   Lists all future approved bookings for a given space,
--   sorted chronologically.
-- ============================================================
DECLARE @Q4_SpaceCode NVARCHAR(20) = 'CS-B202';

SELECT b.bookingId, u.fullName AS requester,
       b.requestedStartTime, b.requestedEndTime,
       b.bookingType, b.expectedParticipants, b.purpose
FROM [Booking] b
JOIN [User] u ON b.userId = u.userId
WHERE b.spaceCode = @Q4_SpaceCode
  AND b.status = 'approved'
  AND b.requestedStartTime > SYSUTCDATETIME()
ORDER BY b.requestedStartTime;

-- ============================================================
-- Query 5: Find spaces currently under maintenance
--
-- Business question:
--   Which spaces have active maintenance issues and what
--   are the problems?
--
-- Target user:
--   Facility manager and staff monitoring maintenance.
--
-- Explanation:
--   Joins Space with MaintenanceRecord for all reported or
--   in-progress records, showing problem and personnel.
-- ============================================================
SELECT s.spaceCode, s.spaceName, s.building, s.floor, s.roomNumber,
       m.recordId, m.problemDescription, m.startTime,
       reporter.fullName AS reportedByName,
       assignee.fullName AS assignedToName,
       m.status
FROM [Space] s
JOIN [MaintenanceRecord] m ON s.spaceCode = m.spaceCode
JOIN [User] reporter ON m.reportedBy = reporter.userId
LEFT JOIN [User] assignee ON m.assignedTo = assignee.userId
WHERE m.status IN ('reported', 'in_progress')
  AND (m.completionTime IS NULL OR m.completionTime > SYSUTCDATETIME())
ORDER BY m.startTime DESC;

-- ============================================================
-- Query 6: Generate a utilization report (Sep 2026)
--
-- Business question:
--   What percentage of time was each space used during
--   September 2026?
--
-- Target user:
--   Facility manager reviewing space utilization.
--
-- Explanation:
--   Sums hours from approved/active bookings within the
--   month, divides by total available hours (720 for 30
--   days), and returns a utilization percentage.
-- ============================================================
DECLARE @Q6_MonthStart DATETIME2 = '2026-09-01 00:00:00';
DECLARE @Q6_MonthEnd   DATETIME2 = '2026-10-01 00:00:00';

SELECT s.spaceCode, s.spaceName, s.spaceType, s.capacity,
       COALESCE(SUM(
           DATEDIFF(MINUTE,
               CASE WHEN b.requestedStartTime < @Q6_MonthStart
                    THEN @Q6_MonthStart ELSE b.requestedStartTime END,
               CASE WHEN b.requestedEndTime > @Q6_MonthEnd
                    THEN @Q6_MonthEnd ELSE b.requestedEndTime END
           )
       ) / 60.0, 0) AS usedHours,
       720 AS availableHours,
       ROUND(COALESCE(SUM(
           DATEDIFF(MINUTE,
               CASE WHEN b.requestedStartTime < @Q6_MonthStart
                    THEN @Q6_MonthStart ELSE b.requestedStartTime END,
               CASE WHEN b.requestedEndTime > @Q6_MonthEnd
                    THEN @Q6_MonthEnd ELSE b.requestedEndTime END
           )
       ) / 60.0, 0) / 720.0 * 100, 2) AS utilizationPercent
FROM [Space] s
LEFT JOIN [Booking] b ON s.spaceCode = b.spaceCode
    AND b.status IN ('approved', 'checked_in', 'completed')
    AND b.requestedStartTime < @Q6_MonthEnd
    AND b.requestedEndTime   > @Q6_MonthStart
GROUP BY s.spaceCode, s.spaceName, s.spaceType, s.capacity
ORDER BY utilizationPercent DESC;

-- ============================================================
-- Query 7: List bookings checked in but not completed
--          (potential no-shows or abandoned sessions)
--
-- Business question:
--   Which bookings were checked in but never checked out?
--
-- Target user:
--   Facility staff following up on incomplete sessions.
--
-- Explanation:
--   Finds bookings with status 'checked_in' that have a
--   CheckIn record but no corresponding CheckOut record.
-- ============================================================
SELECT b.bookingId, u.fullName AS requester,
       s.spaceName, s.spaceCode,
       b.requestedStartTime, b.requestedEndTime,
       ci.actualStartTime,
       DATEDIFF(MINUTE, ci.actualStartTime, SYSUTCDATETIME()) AS minutesSinceCheckIn
FROM [Booking] b
JOIN [User] u ON b.userId = u.userId
JOIN [Space] s ON b.spaceCode = s.spaceCode
JOIN [CheckIn] ci ON b.bookingId = ci.bookingId
LEFT JOIN [CheckOut] co ON b.bookingId = co.bookingId
WHERE b.status = 'checked_in'
  AND co.bookingId IS NULL
ORDER BY ci.actualStartTime;

-- ============================================================
-- Query 8: Find the most frequently booked space type
--
-- Business question:
--   Which type of space is booked the most in 2026?
--
-- Target user:
--   Facility manager planning resource allocation.
--
-- Explanation:
--   Groups bookings by space type, counts total and sums
--   hours, ordered by total count descending.
-- ============================================================
DECLARE @Q8_YearStart DATE = '2026-01-01';
DECLARE @Q8_YearEnd   DATE = '2027-01-01';

SELECT s.spaceType,
       COUNT(b.bookingId) AS totalBookings,
       SUM(DATEDIFF(MINUTE, b.requestedStartTime, b.requestedEndTime)) / 60.0 AS totalHours,
       COUNT(DISTINCT s.spaceCode) AS numberOfSpaces,
       ROUND(SUM(DATEDIFF(MINUTE, b.requestedStartTime, b.requestedEndTime)) / 60.0 /
             NULLIF(COUNT(DISTINCT s.spaceCode), 0), 2) AS avgHoursPerSpace
FROM [Booking] b
JOIN [Space] s ON b.spaceCode = s.spaceCode
WHERE b.status IN ('approved', 'checked_in', 'completed')
  AND b.requestedStartTime >= @Q8_YearStart
  AND b.requestedStartTime <  @Q8_YearEnd
GROUP BY s.spaceType
ORDER BY totalBookings DESC;

-- ============================================================
-- Query 9: Get maintenance history for a specific space
--
-- Business question:
--   What is the complete maintenance history for the
--   Computer Lab CS-B202?
--
-- Target user:
--   Facility staff reviewing past issues.
--
-- Explanation:
--   Lists all maintenance records for a space with reporter
--   and assignee details, newest first.
-- ============================================================
DECLARE @Q9_SpaceCode NVARCHAR(20) = 'CS-B202';

SELECT m.recordId, m.problemDescription,
       m.startTime, m.completionTime, m.status, m.resultNote,
       reporter.fullName AS reportedByName,
       assignee.fullName AS assignedToName
FROM [MaintenanceRecord] m
JOIN [User] reporter ON m.reportedBy = reporter.userId
LEFT JOIN [User] assignee ON m.assignedTo = assignee.userId
WHERE m.spaceCode = @Q9_SpaceCode
ORDER BY m.startTime DESC;

-- ============================================================
-- Query 10: List pending bookings that need approval
--
-- Business question:
--   Show all pending bookings not yet approved or rejected,
--   with elapsed time since submission.
--
-- Target user:
--   Facility staff processing booking requests.
--
-- Explanation:
--   Left joins BookingApproval and filters for status =
--   'pending' with no approval record, ordered oldest first.
-- ============================================================
SELECT b.bookingId, u.fullName AS requester, u.email, u.phone,
       s.spaceName, s.spaceCode, s.building, s.floor, s.roomNumber,
       b.requestedStartTime, b.requestedEndTime,
       b.bookingType, b.expectedParticipants, b.purpose,
       DATEDIFF(HOUR, b.submittedAt, SYSUTCDATETIME()) AS hoursSinceSubmission
FROM [Booking] b
JOIN [User] u ON b.userId = u.userId
JOIN [Space] s ON b.spaceCode = s.spaceCode
LEFT JOIN [BookingApproval] ba ON b.bookingId = ba.bookingId
WHERE b.status = 'pending'
  AND ba.bookingId IS NULL
ORDER BY b.submittedAt;
