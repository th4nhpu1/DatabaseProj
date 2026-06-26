-- ============================================================
-- Campus Space Management System — Query Design (10+ Queries)
-- Target: Microsoft SQL Server
-- ============================================================

USE [CampusSpaceManagement];
GO

-- ============================================================
-- QUERY 1: View upcoming approved bookings for a specific space
-- Business Question: What approved bookings are coming up for a given room?
-- Target Users: Facility Staff, Facility Manager
-- Usefulness: Helps staff prepare the room before each booking and avoid double-booking.
-- ============================================================
DECLARE @TargetSpaceCode NVARCHAR(20) = 'A101';

SELECT
    BR.BookingID,
    U.FullName       AS RequestedBy,
    BR.RequestedStartTime,
    BR.RequestedEndTime,
    BR.Purpose,
    BR.ExpectedParticipants
FROM BookingRequest BR
INNER JOIN [User] U       ON BR.RequestedByUserID = U.UserID
INNER JOIN Space S        ON BR.SpaceID = S.SpaceID
WHERE S.SpaceCode = @TargetSpaceCode
  AND BR.Status = 'approved'
  AND BR.RequestedStartTime > SYSUTCDATETIME()
ORDER BY BR.RequestedStartTime ASC;
GO

-- ============================================================
-- QUERY 2: Check space availability for a given time window
-- Business Question: Is a specific space available during a given time period?
-- Target Users: All users (when submitting booking requests)
-- Usefulness: Prevents the user from requesting a slot that is already booked or blocked.
-- ============================================================
DECLARE @CheckSpaceID INT = 1;          -- A101
DECLARE @CheckStart DATETIME2 = '2026-06-28 08:00:00';
DECLARE @CheckEnd DATETIME2   = '2026-06-28 11:00:00';

SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM BookingRequest
            WHERE SpaceID = @CheckSpaceID
              AND Status = 'approved'
              AND RequestedStartTime < @CheckEnd
              AND RequestedEndTime > @CheckStart
        ) THEN N'Occupied — approved booking overlaps'
        WHEN EXISTS (
            SELECT 1 FROM MaintenanceRecord
            WHERE SpaceID = @CheckSpaceID
              AND Status NOT IN ('completed', 'cancelled')
              AND StartTime < @CheckEnd
              AND (CompletionTime IS NULL OR CompletionTime > @CheckStart)
        ) THEN N'Occupied — active maintenance'
        WHEN EXISTS (
            SELECT 1 FROM Space
            WHERE SpaceID = @CheckSpaceID
              AND Status NOT IN ('available', 'in_use')
        ) THEN N'Unavailable — space is ' + (SELECT Status FROM Space WHERE SpaceID = @CheckSpaceID)
        ELSE N'Available'
    END AS AvailabilityStatus;
GO

-- ============================================================
-- QUERY 3: List all spaces currently under maintenance
-- Business Question: Which spaces are currently unavailable due to maintenance?
-- Target Users: Facility Staff, Facility Manager, all users
-- Usefulness: Helps everyone avoid requesting spaces that are down for repair.
-- ============================================================
SELECT
    S.SpaceCode,
    S.SpaceName,
    S.Building,
    S.RoomNumber,
    MR.ProblemDescription,
    MR.ProblemType,
    MR.StartTime,
    MR.Status AS MaintenanceStatus,
    U.FullName AS AssignedTo
FROM MaintenanceRecord MR
INNER JOIN Space S   ON MR.SpaceID = S.SpaceID
LEFT JOIN [User] U   ON MR.AssignedToUserID = U.UserID
WHERE MR.Status NOT IN ('completed', 'cancelled')
ORDER BY MR.StartTime DESC;
GO

-- ============================================================
-- QUERY 4: Booking history for a specific user (all past bookings)
-- Business Question: What is the complete booking history for a given user?
-- Target Users: Department Administrator, Facility Manager, the user themselves
-- Usefulness: Shows a user's booking patterns, no-shows, cancellations.
-- ============================================================
DECLARE @TargetUserEmail NVARCHAR(255) = 'binh.tran@hcmus.edu.vn';

SELECT
    BR.BookingID,
    S.SpaceCode + ' - ' + S.SpaceName AS Space,
    BR.RequestedStartTime,
    BR.RequestedEndTime,
    BR.Purpose,
    BR.PurposeType,
    BR.Status,
    BSH.NewStatus  AS LastStatus,
    BSH.ChangedAt  AS LastStatusTime,
    BSH.Note       AS LastStatusNote
FROM BookingRequest BR
INNER JOIN Space S              ON BR.SpaceID = S.SpaceID
INNER JOIN [User] U             ON BR.RequestedByUserID = U.UserID
CROSS APPLY (
    SELECT TOP 1 NewStatus, ChangedAt, Note
    FROM BookingStatusHistory
    WHERE BookingID = BR.BookingID
    ORDER BY ChangedAt DESC
) BSH
WHERE U.Email = @TargetUserEmail
ORDER BY BR.RequestedStartTime DESC;
GO

-- ============================================================
-- QUERY 5: No-show booking report (past 7 days)
-- Business Question: Which approved bookings resulted in no-shows last week?
-- Target Users: Facility Manager, Facility Staff
-- Usefulness: Identifies wasted slots and users who habitually no-show.
-- ============================================================
DECLARE @WindowStart DATETIME2 = DATEADD(DAY, -7, SYSUTCDATETIME());

SELECT
    BR.BookingID,
    U.FullName               AS RequestedBy,
    U.Email                  AS RequesterEmail,
    S.SpaceCode + ' - ' + S.SpaceName AS Space,
    BR.RequestedStartTime,
    BR.RequestedEndTime,
    BR.Purpose,
    BSH.ChangedAt            AS MarkedNoShowAt
FROM BookingRequest BR
INNER JOIN [User] U            ON BR.RequestedByUserID = U.UserID
INNER JOIN Space S             ON BR.SpaceID = S.SpaceID
INNER JOIN BookingStatusHistory BSH ON BSH.BookingID = BR.BookingID
    AND BSH.NewStatus = 'no_show'
WHERE BR.Status = 'no_show'
  AND BSH.ChangedAt >= @WindowStart
ORDER BY BSH.ChangedAt DESC;
GO

-- ============================================================
-- QUERY 6: Utilization rate for each space (percentage of time booked)
-- Business Question: What percentage of available time was each space booked last month?
-- Target Users: Facility Manager, Department Administrator
-- Usefulness: Identifies underutilized and overutilized spaces for resource planning.
-- Assumption: Facility utilization is calculated as (total booked hours / total available hours)
-- for the past 30 days. Available hours assume 12-hour days (07:00-19:00) per standard university
-- operating hours. This is a documented mathematical assumption.
-- ============================================================
DECLARE @PeriodStart DATETIME2 = DATEADD(DAY, -30, SYSUTCDATETIME());
DECLARE @PeriodEnd   DATETIME2 = SYSUTCDATETIME();
-- Assumption: 12 operating hours per day (07:00-19:00), 7 days/week
DECLARE @TotalAvailableHours FLOAT = DATEDIFF(HOUR, @PeriodStart, @PeriodEnd) * 1.0;

SELECT
    S.SpaceID,
    S.SpaceCode,
    S.SpaceName,
    S.Building,
    S.RoomNumber,
    S.Capacity,
    COALESCE(SUM(
        DATEDIFF(HOUR,
            CASE WHEN BR.RequestedStartTime < @PeriodStart THEN @PeriodStart ELSE BR.RequestedStartTime END,
            CASE WHEN BR.RequestedEndTime > @PeriodEnd THEN @PeriodEnd ELSE BR.RequestedEndTime END
        )
    ), 0) AS TotalBookedHours,
    ROUND(
        COALESCE(SUM(
            DATEDIFF(HOUR,
                CASE WHEN BR.RequestedStartTime < @PeriodStart THEN @PeriodStart ELSE BR.RequestedStartTime END,
                CASE WHEN BR.RequestedEndTime > @PeriodEnd THEN @PeriodEnd ELSE BR.RequestedEndTime END
            )
        ), 0) / @TotalAvailableHours * 100, 2
    ) AS UtilizationPct
FROM Space S
LEFT JOIN BookingRequest BR
    ON BR.SpaceID = S.SpaceID
    AND BR.Status IN ('approved', 'checked_in', 'completed')
    AND BR.RequestedStartTime < @PeriodEnd
    AND BR.RequestedEndTime > @PeriodStart
GROUP BY S.SpaceID, S.SpaceCode, S.SpaceName, S.Building, S.RoomNumber, S.Capacity
ORDER BY UtilizationPct DESC;
GO

-- ============================================================
-- QUERY 7: Pending bookings awaiting approval
-- Business Question: Which booking requests still need a decision?
-- Target Users: Facility Staff, Facility Manager
-- Usefulness: Provides a work queue for approval decisions.
-- ============================================================
SELECT
    BR.BookingID,
    U.FullName           AS RequestedBy,
    U.Role               AS RequesterRole,
    U.Department,
    S.SpaceCode,
    S.SpaceName,
    BR.RequestedStartTime,
    BR.RequestedEndTime,
    BR.Purpose,
    BR.PurposeType,
    BR.ExpectedParticipants,
    BR.CreatedAt         AS RequestedAt
FROM BookingRequest BR
INNER JOIN [User] U  ON BR.RequestedByUserID = U.UserID
INNER JOIN Space S   ON BR.SpaceID = S.SpaceID
WHERE BR.Status = 'pending'
ORDER BY BR.RequestedStartTime ASC;
GO

-- ============================================================
-- QUERY 8: Spaces with the most no-show bookings
-- Business Question: Which rooms have the highest no-show rate?
-- Target Users: Facility Manager
-- Usefulness: May indicate rooms that are unpopular or have recurring phantom bookings.
-- ============================================================
SELECT
    S.SpaceID,
    S.SpaceCode,
    S.SpaceName,
    COUNT(CASE WHEN BR.Status = 'no_show' THEN 1 END) AS NoShowCount,
    COUNT(BR.BookingID)                                AS TotalBookings,
    ROUND(
        COUNT(CASE WHEN BR.Status = 'no_show' THEN 1 END) * 100.0 / NULLIF(COUNT(BR.BookingID), 0), 2
    ) AS NoShowPct
FROM Space S
LEFT JOIN BookingRequest BR ON BR.SpaceID = S.SpaceID
GROUP BY S.SpaceID, S.SpaceCode, S.SpaceName
HAVING COUNT(BR.BookingID) > 0
ORDER BY NoShowPct DESC;
GO

-- ============================================================
-- QUERY 9: Maintenance history for a specific space
-- Business Question: What maintenance issues has a particular room had over time?
-- Target Users: Facility Staff, Facility Manager
-- Usefulness: Helps identify recurring problems with a specific space.
-- ============================================================
DECLARE @TargetSpaceCode2 NVARCHAR(20) = 'B105';

SELECT
    MR.MaintenanceID,
    MR.ProblemDescription,
    MR.ProblemType,
    MR.StartTime,
    MR.CompletionTime,
    MR.Status,
    MR.ResultNote,
    Reporter.FullName   AS ReportedBy,
    Assignee.FullName   AS AssignedTo
FROM MaintenanceRecord MR
INNER JOIN Space S            ON MR.SpaceID = S.SpaceID
INNER JOIN [User] Reporter    ON MR.ReportedByUserID = Reporter.UserID
LEFT JOIN [User] Assignee     ON MR.AssignedToUserID = Assignee.UserID
WHERE S.SpaceCode = @TargetSpaceCode2
ORDER BY MR.StartTime DESC;
GO

-- ============================================================
-- QUERY 10: Active bookings in a given building right now
-- Business Question: What is happening in Tòa A right now?
-- Target Users: Facility Staff, Facility Manager
-- Usefulness: Real-time awareness of space usage across a building.
-- ============================================================
DECLARE @Building NVARCHAR(100) = N'Tòa A';
DECLARE @Now DATETIME2 = SYSUTCDATETIME();

SELECT
    BR.BookingID,
    S.SpaceCode,
    S.SpaceName,
    S.RoomNumber,
    U.FullName           AS RequestedBy,
    BR.Purpose,
    BR.RequestedStartTime,
    BR.RequestedEndTime,
    BR.Status,
    CI.ActualStartTime   AS CheckedInAt,
    COALESCE(CO.FinalCondition, N'—') AS FinalCondition
FROM BookingRequest BR
INNER JOIN Space S     ON BR.SpaceID = S.SpaceID
INNER JOIN [User] U    ON BR.RequestedByUserID = U.UserID
LEFT JOIN CheckIn CI   ON CI.BookingID = BR.BookingID
LEFT JOIN CheckOut CO  ON CO.BookingID = BR.BookingID
WHERE S.Building = @Building
  AND BR.RequestedStartTime <= @Now
  AND BR.RequestedEndTime >= @Now
  AND BR.Status IN ('approved', 'checked_in')
ORDER BY S.RoomNumber, BR.RequestedStartTime;
GO

-- ============================================================
-- QUERY 11: Staff workload — maintenance assignments
-- Business Question: How many active maintenance tasks does each staff member have?
-- Target Users: Facility Manager
-- Usefulness: Workload balancing among facility staff.
-- ============================================================
SELECT
    U.UserID,
    U.FullName,
    U.Role,
    COUNT(MR.MaintenanceID) AS ActiveTasks
FROM [User] U
LEFT JOIN MaintenanceRecord MR
    ON MR.AssignedToUserID = U.UserID
    AND MR.Status NOT IN ('completed', 'cancelled')
WHERE U.Role IN ('facility_staff', 'facility_manager')
GROUP BY U.UserID, U.FullName, U.Role
ORDER BY ActiveTasks DESC;
GO

-- ============================================================
-- QUERY 12: Full status transition history for a specific booking
-- Business Question: What was the complete lifecycle of a given booking?
-- Target Users: Facility Manager, Department Administrator
-- Usefulness: Audit trail for dispute resolution or analysis.
-- ============================================================
DECLARE @TargetBookingID INT = 1;

SELECT
    BSH.HistoryID,
    BSH.PreviousStatus,
    BSH.NewStatus,
    U.FullName       AS ChangedBy,
    BSH.ChangedAt,
    BSH.Note
FROM BookingStatusHistory BSH
INNER JOIN [User] U ON BSH.ChangedByUserID = U.UserID
WHERE BSH.BookingID = @TargetBookingID
ORDER BY BSH.ChangedAt ASC;
GO
