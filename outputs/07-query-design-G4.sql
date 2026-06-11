-- =============================================================
-- Query Design — Campus Space Management System
-- =============================================================

-- -------------------------------------------------------------
-- Query 1: Booking History for a Specific Space
-- -------------------------------------------------------------
-- Business question: What is the complete booking history for
--   the Main Auditorium, including status and approval info?
-- Target users: Facility staff, facility manager, dept admin
-- Usefulness: Allows staff to review past and upcoming bookings
--   for a space, verify utilization, and audit decisions.
SELECT
    br.BookingID,
    br.RequestedStartTime,
    br.RequestedEndTime,
    br.Purpose,
    br.BookingType,
    br.Status,
    u.FullName AS Requester,
    a.DecisionTime,
    a.DecisionNote,
    a.RejectionReason,
    s.ActualStartTime,
    s.ActualEndTime
FROM BookingRequest br
JOIN [User] u ON br.RequesterID = u.UserID
LEFT JOIN Approval a ON br.BookingID = a.BookingID
LEFT JOIN Session s ON br.BookingID = s.BookingID
WHERE br.SpaceCode = 'CS-AUD-101'
ORDER BY br.RequestedStartTime DESC;

-- -------------------------------------------------------------
-- Query 2: Upcoming Approved Bookings (Today and Forward)
-- -------------------------------------------------------------
-- Business question: Which approved bookings are scheduled from
--   today onward?
-- Target users: Facility staff (for daily check-in preparation)
-- Usefulness: Helps staff prepare spaces and know what is
--   expected for the day/week.
SELECT
    br.BookingID,
    s.SpaceName,
    s.SpaceCode,
    br.RequestedStartTime,
    br.RequestedEndTime,
    br.Purpose,
    br.BookingType,
    br.ExpectedParticipants,
    u.FullName AS Requester,
    u.Email AS RequesterEmail
FROM BookingRequest br
JOIN Space s ON br.SpaceCode = s.SpaceCode
JOIN [User] u ON br.RequesterID = u.UserID
WHERE br.Status IN ('Approved', 'CheckedIn')
  AND br.RequestedStartTime >= CAST(GETDATE() AS DATETIME2)
ORDER BY br.RequestedStartTime;

-- -------------------------------------------------------------
-- Query 3: Spaces Currently Under Maintenance
-- -------------------------------------------------------------
-- Business question: Which spaces have active (unresolved)
--   maintenance issues?
-- Target users: Facility staff, facility manager
-- Usefulness: Identifies spaces that cannot be booked and
--   tracks ongoing maintenance work.
SELECT
    sp.SpaceCode,
    sp.SpaceName,
    sp.Building,
    sp.Floor,
    sp.RoomNumber,
    m.MaintenanceID,
    m.ProblemDescription,
    m.StartTime,
    m.Status AS MaintenanceStatus,
    reporter.FullName AS ReportedBy,
    assigned.FullName AS AssignedTo
FROM Space sp
JOIN Maintenance m ON sp.SpaceCode = m.SpaceCode
JOIN [User] reporter ON m.ReporterID = reporter.UserID
LEFT JOIN [User] assigned ON m.AssignedStaffID = assigned.UserID
WHERE m.Status IN ('Reported', 'InProgress')
ORDER BY m.StartTime;

-- -------------------------------------------------------------
-- Query 4: Space Utilization (Completed Bookings by Space)
-- -------------------------------------------------------------
-- Business question: Which spaces had the most completed booking
--   hours in a given month?
-- Target users: Facility manager, dept admin
-- Usefulness: Helps assess which spaces are most heavily used
--   and identify underutilized spaces.
SELECT
    sp.SpaceCode,
    sp.SpaceName,
    sp.SpaceType,
    sp.Capacity,
    COUNT(br.BookingID) AS TotalBookings,
    SUM(DATEDIFF(HOUR, br.RequestedStartTime, br.RequestedEndTime)) AS TotalHoursBooked,
    AVG(DATEDIFF(HOUR, br.RequestedStartTime, br.RequestedEndTime)) AS AvgHoursPerBooking
FROM Space sp
LEFT JOIN BookingRequest br ON sp.SpaceCode = br.SpaceCode
    AND br.Status = 'Completed'
    AND br.RequestedStartTime >= '2026-06-01'
    AND br.RequestedStartTime < '2026-07-01'
GROUP BY sp.SpaceCode, sp.SpaceName, sp.SpaceType, sp.Capacity
ORDER BY TotalHoursBooked DESC;

-- -------------------------------------------------------------
-- Query 5: No-Show Bookings
-- -------------------------------------------------------------
-- Business question: Which bookings were marked as no-show,
--   and who was the requester?
-- Target users: Facility manager, facility staff
-- Usefulness: Tracks unreliable users or patterns; helps
--   enforce no-show policies.
SELECT
    br.BookingID,
    br.RequestedStartTime,
    br.RequestedEndTime,
    br.Purpose,
    br.BookingType,
    u.FullName AS Requester,
    u.Email AS RequesterEmail,
    u.Department,
    s.CheckInBy,
    s.InitialCondition
FROM BookingRequest br
JOIN [User] u ON br.RequesterID = u.UserID
JOIN Session s ON br.BookingID = s.BookingID
WHERE br.Status = 'NoShow'
ORDER BY br.RequestedStartTime DESC;

-- -------------------------------------------------------------
-- Query 6: Pending Approvals (for Staff Dashboard)
-- -------------------------------------------------------------
-- Business question: Which bookings are waiting for approval?
-- Target users: Facility staff, facility manager
-- Usefulness: Provides a queue of requests that need action.
SELECT
    br.BookingID,
    sp.SpaceName,
    sp.SpaceCode,
    u.FullName AS Requester,
    u.Role AS RequesterRole,
    br.RequestedStartTime,
    br.RequestedEndTime,
    br.Purpose,
    br.BookingType,
    br.ExpectedParticipants,
    DATEDIFF(DAY, GETDATE(), br.RequestedStartTime) AS DaysUntilBooking
FROM BookingRequest br
JOIN Space sp ON br.SpaceCode = sp.SpaceCode
JOIN [User] u ON br.RequesterID = u.UserID
WHERE br.Status = 'Pending'
ORDER BY br.RequestedStartTime;
