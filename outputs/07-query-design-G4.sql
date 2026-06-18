-- ============================================================================
-- Campus Space Management System — Query Design
-- Target DBMS: Microsoft SQL Server
-- ============================================================================

USE CampusSpaceManagement;
GO

-- ============================================================================
-- Query 1: Booking history for a specific space
-- Business question: What is the complete booking history for Auditorium A1?
-- Target user(s): Facility staff, facility manager
-- Explanation: Shows all past and future bookings for a space, including status,
--   requester, and time range — useful for understanding utilization patterns.
-- ============================================================================
SELECT
    br.BookingID,
    u.FullName        AS RequestedBy,
    br.RequestedStartTime,
    br.RequestedEndTime,
    br.Purpose,
    br.Status,
    ba.Decision,
    ba.DecisionNote,
    bs.ActualStartTime,
    bs.ActualEndTime
FROM BookingRequest br
INNER JOIN [User] u ON u.UserID = br.RequestedBy
LEFT JOIN BookingApproval ba ON ba.BookingID = br.BookingID
LEFT JOIN BookingSession bs ON bs.BookingID = br.BookingID
WHERE br.SpaceID = (SELECT SpaceID FROM Space WHERE SpaceCode = 'LT-A1')
ORDER BY br.RequestedStartTime DESC;
GO

-- ============================================================================
-- Query 2: Upcoming approved bookings for the next 7 days
-- Business question: Which approved bookings are scheduled for the coming week?
-- Target user(s): Facility staff, department administrator
-- Explanation: Helps staff prepare rooms and anticipate usage for the week ahead.
-- ============================================================================
SELECT
    br.BookingID,
    s.SpaceName,
    s.SpaceCode,
    u.FullName        AS RequestedBy,
    br.RequestedStartTime,
    br.RequestedEndTime,
    br.Purpose,
    br.ExpectedParticipants
FROM BookingRequest br
INNER JOIN Space s ON s.SpaceID = br.SpaceID
INNER JOIN [User] u ON u.UserID = br.RequestedBy
WHERE br.Status = 'Approved'
  AND br.RequestedStartTime >= CAST(SYSUTCDATETIME() AS DATE)
  AND br.RequestedStartTime < DATEADD(DAY, 7, CAST(SYSUTCDATETIME() AS DATE))
ORDER BY br.RequestedStartTime;
GO

-- ============================================================================
-- Query 3: Spaces currently under maintenance
-- Business question: Which spaces have active maintenance issues right now?
-- Target user(s): Facility staff, facility manager
-- Explanation: Identifies spaces that cannot be booked due to maintenance.
-- ============================================================================
SELECT
    s.SpaceCode,
    s.SpaceName,
    s.Building,
    s.RoomNumber,
    mr.MaintenanceID,
    mr.ProblemDescription,
    mr.StartTime,
    mr.Status,
    uRep.FullName     AS ReportedBy,
    uAss.FullName     AS AssignedTo
FROM MaintenanceRecord mr
INNER JOIN Space s ON s.SpaceID = mr.SpaceID
INNER JOIN [User] uRep ON uRep.UserID = mr.ReportedBy
LEFT JOIN [User] uAss ON uAss.UserID = mr.AssignedTo
WHERE mr.Status IN ('Reported', 'InProgress')
ORDER BY mr.StartTime DESC;
GO

-- ============================================================================
-- Query 4: Space utilization rate (completed bookings)
-- Business question: What percentage of time was each space used over the past month?
-- Target user(s): Facility manager, department administrator
-- Explanation: Helps assess whether space allocation is efficient and identify
--   underutilized rooms.
-- ============================================================================
SELECT
    s.SpaceCode,
    s.SpaceName,
    s.SpaceType,
    s.Capacity,
    COUNT(br.BookingID)                                               AS TotalBookings,
    ISNULL(SUM(DATEDIFF(MINUTE, br.RequestedStartTime, br.RequestedEndTime)), 0)
        / 60.0                                                        AS TotalHoursBooked,
    CASE
        WHEN COUNT(br.BookingID) = 0 THEN 0.0
        ELSE ROUND(
            ISNULL(SUM(DATEDIFF(MINUTE, br.RequestedStartTime, br.RequestedEndTime)), 0)
            / (COUNT(br.BookingID) * 8.0 * 60.0) * 100, 2
        )
    END                                                               AS UtilizationPct
FROM Space s
LEFT JOIN BookingRequest br
    ON br.SpaceID = s.SpaceID
    AND br.Status IN ('Completed', 'CheckedIn')
    AND br.RequestedStartTime >= DATEADD(MONTH, -1, SYSUTCDATETIME())
GROUP BY s.SpaceCode, s.SpaceName, s.SpaceType, s.Capacity
ORDER BY UtilizationPct DESC;
GO

-- ============================================================================
-- Query 5: No-show bookings
-- Business question: Which bookings were marked as no-show and who made them?
-- Target user(s): Facility manager, facility staff
-- Explanation: Identifies users who frequently fail to show up, enabling
--   follow-up or policy enforcement.
-- ============================================================================
SELECT
    br.BookingID,
    u.FullName        AS RequestedBy,
    u.Email,
    u.Department,
    s.SpaceName,
    s.SpaceCode,
    br.RequestedStartTime,
    br.RequestedEndTime,
    br.Purpose
FROM BookingRequest br
INNER JOIN [User] u ON u.UserID = br.RequestedBy
INNER JOIN Space s ON s.SpaceID = br.SpaceID
WHERE br.Status = 'NoShow'
ORDER BY br.RequestedStartTime DESC;
GO

-- ============================================================================
-- Query 6: Status transition history for a specific booking
-- Business question: How did a particular booking's status change over time?
-- Target user(s): Facility staff, facility manager
-- Explanation: Audits the complete lifecycle of a booking for dispute resolution.
-- ============================================================================
SELECT
    br.BookingID,
    bsh.FromStatus,
    bsh.ToStatus,
    u.FullName        AS ChangedBy,
    bsh.ChangedAt,
    bsh.Note
FROM BookingStatusHistory bsh
INNER JOIN BookingRequest br ON br.BookingID = bsh.BookingID
INNER JOIN [User] u ON u.UserID = bsh.ChangedBy
WHERE br.BookingID = 1
ORDER BY bsh.ChangedAt;
GO

-- ============================================================================
-- Query 7: All facilities in a given space
-- Business question: What facilities are available in Computer Lab C301?
-- Target user(s): All users (requesters checking before booking)
-- Explanation: Helps users select a space that has the equipment they need.
-- ============================================================================
SELECT
    f.FacilityName,
    sf.Quantity
FROM SpaceFacility sf
INNER JOIN Facility f ON f.FacilityID = sf.FacilityID
INNER JOIN Space s ON s.SpaceID = sf.SpaceID
WHERE s.SpaceCode = 'CL-C301'
ORDER BY f.FacilityName;
GO

-- ============================================================================
-- Query 8: Maintenance history for a specific space
-- Business question: What maintenance issues has Classroom B101 had over time?
-- Target user(s): Facility manager, facility staff
-- Explanation: Tracks recurring problems for proactive maintenance planning.
-- ============================================================================
SELECT
    mr.MaintenanceID,
    mr.ProblemDescription,
    mr.StartTime,
    mr.CompletionTime,
    mr.Status,
    mr.ResultNote,
    uRep.FullName     AS ReportedBy,
    uAss.FullName     AS AssignedTo
FROM MaintenanceRecord mr
INNER JOIN Space s ON s.SpaceID = mr.SpaceID
INNER JOIN [User] uRep ON uRep.UserID = mr.ReportedBy
LEFT JOIN [User] uAss ON uAss.UserID = mr.AssignedTo
WHERE s.SpaceCode = 'CR-B101'
ORDER BY mr.StartTime DESC;
GO

-- ============================================================================
-- Query 9: Bookings by a specific user
-- Business question: What bookings has user Nguyễn Văn An made?
-- Target user(s): Department administrator, facility staff
-- Explanation: Reviews an individual's booking behavior for policy compliance.
-- ============================================================================
SELECT
    br.BookingID,
    s.SpaceName,
    s.SpaceCode,
    br.RequestedStartTime,
    br.RequestedEndTime,
    br.Purpose,
    br.Status,
    ba.Decision,
    CASE
        WHEN bs.ActualStartTime IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END               AS WasCheckedIn
FROM BookingRequest br
INNER JOIN Space s ON s.SpaceID = br.SpaceID
LEFT JOIN BookingApproval ba ON ba.BookingID = br.BookingID
LEFT JOIN BookingSession bs ON bs.BookingID = br.BookingID
WHERE br.RequestedBy = (SELECT UserID FROM [User] WHERE Email = 'an.nguyen@school.edu')
ORDER BY br.RequestedStartTime DESC;
GO

-- ============================================================================
-- Query 10: Potentially conflicting booking requests (pending overlap check)
-- Business question: Are there any pending bookings that would conflict with
--   already-approved bookings for the same space?
-- Target user(s): Facility staff
-- Explanation: Flags pending requests that would fail approval due to time
--   overlap — helps staff reject them proactively.
-- ============================================================================
SELECT
    pending.BookingID       AS PendingBookingID,
    pending.RequestedStartTime AS PendingStart,
    pending.RequestedEndTime   AS PendingEnd,
    u.FullName              AS RequestedBy,
    approved.BookingID      AS ConflictingBookingID,
    approved.RequestedStartTime AS ConflictingStart,
    approved.RequestedEndTime   AS ConflictingEnd,
    s.SpaceName,
    s.SpaceCode
FROM BookingRequest pending
INNER JOIN BookingRequest approved
    ON approved.SpaceID = pending.SpaceID
    AND approved.BookingID <> pending.BookingID
    AND approved.Status IN ('Approved', 'CheckedIn')
    AND approved.RequestedStartTime < pending.RequestedEndTime
    AND approved.RequestedEndTime > pending.RequestedStartTime
INNER JOIN Space s ON s.SpaceID = pending.SpaceID
INNER JOIN [User] u ON u.UserID = pending.RequestedBy
WHERE pending.Status = 'Pending'
ORDER BY pending.RequestedStartTime;
GO

-- ============================================================================
-- Query 11: Average booking duration by purpose
-- Business question: What is the average duration for each type of booking?
-- Target user(s): Facility manager
-- Explanation: Helps set scheduling policies and estimate time requirements
--   for future events.
-- ============================================================================
SELECT
    Purpose,
    COUNT(*)                                                AS NumberOfBookings,
    AVG(DATEDIFF(MINUTE, RequestedStartTime, RequestedEndTime))
        / 60.0                                              AS AvgDurationHours,
    MIN(DATEDIFF(MINUTE, RequestedStartTime, RequestedEndTime))
        / 60.0                                              AS MinDurationHours,
    MAX(DATEDIFF(MINUTE, RequestedStartTime, RequestedEndTime))
        / 60.0                                              AS MaxDurationHours
FROM BookingRequest
WHERE Status NOT IN ('Cancelled', 'Rejected')
GROUP BY Purpose
ORDER BY AvgDurationHours DESC;
GO

-- ============================================================================
-- Query 12: Staff workload (approvals per staff member)
-- Business question: How many booking approvals has each facility staff member handled?
-- Target user(s): Facility manager
-- Explanation: Monitors workload distribution among facility staff.
-- ============================================================================
SELECT
    u.FullName        AS StaffName,
    u.Role,
    COUNT(ba.ApprovalID)                                    AS TotalApprovals,
    SUM(CASE WHEN ba.Decision = 'Approved' THEN 1 ELSE 0 END) AS ApprovedCount,
    SUM(CASE WHEN ba.Decision = 'Rejected' THEN 1 ELSE 0 END) AS RejectedCount
FROM BookingApproval ba
INNER JOIN [User] u ON u.UserID = ba.ApprovedBy
GROUP BY u.FullName, u.Role
ORDER BY TotalApprovals DESC;
GO
