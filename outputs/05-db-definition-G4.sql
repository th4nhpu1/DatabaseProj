-- ============================================================================
-- Campus Space Management System — Database Definition
-- Target DBMS: Microsoft SQL Server
-- ============================================================================

-- Drop existing database if present (for clean re-run)
IF DB_ID('CampusSpaceManagement') IS NOT NULL
BEGIN
    ALTER DATABASE CampusSpaceManagement SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CampusSpaceManagement;
END
GO

CREATE DATABASE CampusSpaceManagement;
GO

USE CampusSpaceManagement;
GO

-- ============================================================================
-- DROP statements for clean re-runs (order respects FK dependencies)
-- ============================================================================
DROP TABLE IF EXISTS MaintenanceStatusHistory;
DROP TABLE IF EXISTS BookingStatusHistory;
DROP TABLE IF EXISTS BookingSession;
DROP TABLE IF EXISTS BookingApproval;
DROP TABLE IF EXISTS MaintenanceRecord;
DROP TABLE IF EXISTS BookingRequest;
DROP TABLE IF EXISTS SpaceFacility;
DROP TABLE IF EXISTS Facility;
DROP TABLE IF EXISTS Space;
DROP TABLE IF EXISTS [User];
GO

-- ============================================================================
-- 1. User
-- ============================================================================
CREATE TABLE [User] (
    UserID          INT           IDENTITY(1,1) NOT NULL,
    FullName        NVARCHAR(100) NOT NULL,
    Email           NVARCHAR(255) NOT NULL,
    Phone           NVARCHAR(20)  NULL,
    Role            NVARCHAR(30)  NOT NULL,
    Department      NVARCHAR(100) NOT NULL,
    AccountStatus   NVARCHAR(20)  NOT NULL DEFAULT 'Active',
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt      DATETIME2     NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    DeletedAt       DATETIME2     NULL,

    CONSTRAINT PK_User PRIMARY KEY (UserID),
    CONSTRAINT UQ_User_Email UNIQUE (Email),
    CONSTRAINT CK_User_Role CHECK (Role IN (
        'Student', 'Lecturer', 'TeachingAssistant',
        'FacilityStaff', 'DepartmentAdministrator', 'FacilityManager'
    )),
    CONSTRAINT CK_User_AccountStatus CHECK (AccountStatus IN ('Active', 'Inactive'))
);
GO

-- ============================================================================
-- 2. Space
-- ============================================================================
CREATE TABLE Space (
    SpaceID         INT           IDENTITY(1,1) NOT NULL,
    SpaceCode       NVARCHAR(20)  NOT NULL,
    SpaceName       NVARCHAR(100) NOT NULL,
    SpaceType       NVARCHAR(30)  NOT NULL,
    Building        NVARCHAR(100) NOT NULL,
    Floor           INT           NOT NULL,
    RoomNumber      NVARCHAR(20)  NOT NULL,
    Capacity        INT           NOT NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Available',
    UsagePolicy     NVARCHAR(500) NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt      DATETIME2     NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    DeletedAt       DATETIME2     NULL,

    CONSTRAINT PK_Space PRIMARY KEY (SpaceID),
    CONSTRAINT UQ_Space_SpaceCode UNIQUE (SpaceCode),
    CONSTRAINT CK_Space_SpaceType CHECK (SpaceType IN (
        'Auditorium', 'Classroom', 'ComputerLaboratory',
        'ProjectLaboratory', 'MeetingRoom', 'StudentWorkspace'
    )),
    CONSTRAINT CK_Space_Capacity CHECK (Capacity > 0),
    CONSTRAINT CK_Space_Status CHECK (Status IN (
        'Available', 'InUse', 'UnderMaintenance',
        'TemporarilyClosed', 'Retired'
    ))
);
GO

-- ============================================================================
-- 3. Facility (lookup)
-- ============================================================================
CREATE TABLE Facility (
    FacilityID      INT           IDENTITY(1,1) NOT NULL,
    FacilityName    NVARCHAR(100) NOT NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt      DATETIME2     NULL,

    CONSTRAINT PK_Facility PRIMARY KEY (FacilityID),
    CONSTRAINT UQ_Facility_FacilityName UNIQUE (FacilityName)
);
GO

-- ============================================================================
-- 4. SpaceFacility (junction)
-- ============================================================================
CREATE TABLE SpaceFacility (
    SpaceFacilityID INT           IDENTITY(1,1) NOT NULL,
    SpaceID         INT           NOT NULL,
    FacilityID      INT           NOT NULL,
    Quantity        INT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt      DATETIME2     NULL,

    CONSTRAINT PK_SpaceFacility PRIMARY KEY (SpaceFacilityID),
    CONSTRAINT UQ_SpaceFacility UNIQUE (SpaceID, FacilityID),
    CONSTRAINT FK_SpaceFacility_Space FOREIGN KEY (SpaceID) REFERENCES Space(SpaceID),
    CONSTRAINT FK_SpaceFacility_Facility FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID),
    CONSTRAINT CK_SpaceFacility_Quantity CHECK (Quantity > 0)
);
GO

-- ============================================================================
-- 5. BookingRequest
-- ============================================================================
CREATE TABLE BookingRequest (
    BookingID           INT           IDENTITY(1,1) NOT NULL,
    RequestedBy         INT           NOT NULL,
    SpaceID             INT           NOT NULL,
    RequestedStartTime  DATETIME2     NOT NULL,
    RequestedEndTime    DATETIME2     NOT NULL,
    Purpose             NVARCHAR(30)  NOT NULL,
    ExpectedParticipants INT          NOT NULL,
    Status              NVARCHAR(20)  NOT NULL DEFAULT 'Pending',
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt          DATETIME2     NULL,

    CONSTRAINT PK_BookingRequest PRIMARY KEY (BookingID),
    CONSTRAINT FK_BookingRequest_User FOREIGN KEY (RequestedBy) REFERENCES [User](UserID),
    CONSTRAINT FK_BookingRequest_Space FOREIGN KEY (SpaceID) REFERENCES Space(SpaceID),
    CONSTRAINT CK_BookingRequest_TimeRange CHECK (RequestedEndTime > RequestedStartTime),
    CONSTRAINT CK_BookingRequest_Purpose CHECK (Purpose IN (
        'Lecture', 'Examination', 'Seminar', 'Workshop',
        'Meeting', 'StudentActivity', 'AdministrativeEvent'
    )),
    CONSTRAINT CK_BookingRequest_ExpectedParticipants CHECK (ExpectedParticipants > 0),
    CONSTRAINT CK_BookingRequest_Status CHECK (Status IN (
        'Pending', 'Approved', 'Rejected', 'Cancelled',
        'CheckedIn', 'Completed', 'NoShow'
    ))
);
GO

-- ============================================================================
-- 6. BookingApproval
-- ============================================================================
CREATE TABLE BookingApproval (
    ApprovalID      INT           IDENTITY(1,1) NOT NULL,
    BookingID       INT           NOT NULL,
    ApprovedBy      INT           NOT NULL,
    DecisionTime    DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    Decision        NVARCHAR(10)  NOT NULL,
    DecisionNote    NVARCHAR(500) NULL,
    RejectionReason NVARCHAR(500) NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_BookingApproval PRIMARY KEY (ApprovalID),
    CONSTRAINT UQ_BookingApproval_BookingID UNIQUE (BookingID),
    CONSTRAINT FK_BookingApproval_BookingRequest FOREIGN KEY (BookingID) REFERENCES BookingRequest(BookingID),
    CONSTRAINT FK_BookingApproval_ApprovedBy FOREIGN KEY (ApprovedBy) REFERENCES [User](UserID),
    CONSTRAINT CK_BookingApproval_Decision CHECK (Decision IN ('Approved', 'Rejected'))
);
GO

-- ============================================================================
-- 7. BookingSession
-- ============================================================================
CREATE TABLE BookingSession (
    SessionID       INT            IDENTITY(1,1) NOT NULL,
    BookingID       INT            NOT NULL,
    CheckedInBy     INT            NOT NULL,
    ActualStartTime DATETIME2      NOT NULL,
    InitialCondition NVARCHAR(500) NULL,
    CheckedOutBy    INT            NULL,
    ActualEndTime   DATETIME2      NULL,
    FinalCondition  NVARCHAR(500)  NULL,
    UsageNotes      NVARCHAR(1000) NULL,
    CreatedAt       DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt      DATETIME2      NULL,

    CONSTRAINT PK_BookingSession PRIMARY KEY (SessionID),
    CONSTRAINT UQ_BookingSession_BookingID UNIQUE (BookingID),
    CONSTRAINT FK_BookingSession_BookingRequest FOREIGN KEY (BookingID) REFERENCES BookingRequest(BookingID),
    CONSTRAINT FK_BookingSession_CheckedInBy FOREIGN KEY (CheckedInBy) REFERENCES [User](UserID),
    CONSTRAINT FK_BookingSession_CheckedOutBy FOREIGN KEY (CheckedOutBy) REFERENCES [User](UserID),
    CONSTRAINT CK_BookingSession_EndTime CHECK (
        ActualEndTime IS NULL OR ActualEndTime > ActualStartTime
    )
);
GO

-- ============================================================================
-- 8. BookingStatusHistory
-- ============================================================================
CREATE TABLE BookingStatusHistory (
    StatusHistoryID INT           IDENTITY(1,1) NOT NULL,
    BookingID       INT           NOT NULL,
    FromStatus      NVARCHAR(20)  NULL,
    ToStatus        NVARCHAR(20)  NOT NULL,
    ChangedBy       INT           NOT NULL,
    ChangedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    Note            NVARCHAR(500) NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_BookingStatusHistory PRIMARY KEY (StatusHistoryID),
    CONSTRAINT FK_BookingStatusHistory_BookingRequest FOREIGN KEY (BookingID) REFERENCES BookingRequest(BookingID),
    CONSTRAINT FK_BookingStatusHistory_ChangedBy FOREIGN KEY (ChangedBy) REFERENCES [User](UserID),
    CONSTRAINT CK_BookingStatusHistory_ToStatus CHECK (ToStatus IN (
        'Pending', 'Approved', 'Rejected', 'Cancelled',
        'CheckedIn', 'Completed', 'NoShow'
    ))
);
GO

-- ============================================================================
-- 9. MaintenanceRecord
-- ============================================================================
CREATE TABLE MaintenanceRecord (
    MaintenanceID       INT            IDENTITY(1,1) NOT NULL,
    SpaceID             INT            NOT NULL,
    ReportedBy          INT            NOT NULL,
    AssignedTo          INT            NULL,
    ProblemDescription  NVARCHAR(1000) NOT NULL,
    StartTime           DATETIME2      NOT NULL,
    CompletionTime      DATETIME2      NULL,
    Status              NVARCHAR(20)   NOT NULL DEFAULT 'Reported',
    ResultNote          NVARCHAR(1000) NULL,
    CreatedAt           DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt          DATETIME2      NULL,

    CONSTRAINT PK_MaintenanceRecord PRIMARY KEY (MaintenanceID),
    CONSTRAINT FK_MaintenanceRecord_Space FOREIGN KEY (SpaceID) REFERENCES Space(SpaceID),
    CONSTRAINT FK_MaintenanceRecord_ReportedBy FOREIGN KEY (ReportedBy) REFERENCES [User](UserID),
    CONSTRAINT FK_MaintenanceRecord_AssignedTo FOREIGN KEY (AssignedTo) REFERENCES [User](UserID),
    CONSTRAINT CK_MaintenanceRecord_Status CHECK (Status IN (
        'Reported', 'InProgress', 'Completed', 'Cancelled'
    ))
);
GO

-- ============================================================================
-- 10. MaintenanceStatusHistory
-- ============================================================================
CREATE TABLE MaintenanceStatusHistory (
    StatusHistoryID INT           IDENTITY(1,1) NOT NULL,
    MaintenanceID   INT           NOT NULL,
    FromStatus      NVARCHAR(20)  NULL,
    ToStatus        NVARCHAR(20)  NOT NULL,
    ChangedBy       INT           NOT NULL,
    ChangedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    Note            NVARCHAR(500) NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_MaintenanceStatusHistory PRIMARY KEY (StatusHistoryID),
    CONSTRAINT FK_MaintenanceStatusHistory_MaintenanceRecord FOREIGN KEY (MaintenanceID) REFERENCES MaintenanceRecord(MaintenanceID),
    CONSTRAINT FK_MaintenanceStatusHistory_ChangedBy FOREIGN KEY (ChangedBy) REFERENCES [User](UserID),
    CONSTRAINT CK_MaintenanceStatusHistory_ToStatus CHECK (ToStatus IN (
        'Reported', 'InProgress', 'Completed', 'Cancelled'
    ))
);
GO

-- ============================================================================
-- Triggers
-- ============================================================================

-- Trigger: Prevent overlapping bookings for the same space
CREATE OR ALTER TRIGGER trg_PreventOverlappingBookings
ON BookingRequest
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN BookingRequest br
            ON br.SpaceID = i.SpaceID
            AND br.BookingID <> i.BookingID
            AND br.Status IN ('Approved', 'CheckedIn')
            AND i.Status IN ('Approved', 'CheckedIn')
            AND br.RequestedStartTime < i.RequestedEndTime
            AND br.RequestedEndTime > i.RequestedStartTime
    )
    BEGIN
        THROW 50001, 'Cannot approve booking: time period conflicts with an existing approved booking for the same space.', 1;
    END;
END;
GO

-- Trigger: Prevent booking a space that is under active maintenance
CREATE OR ALTER TRIGGER trg_CheckSpaceAvailableForBooking
ON BookingRequest
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Space s ON s.SpaceID = i.SpaceID
        WHERE i.Status IN ('Approved', 'CheckedIn')
          AND s.Status IN ('UnderMaintenance', 'TemporarilyClosed', 'Retired')
    )
    BEGIN
        THROW 50002, 'Cannot approve booking: the selected space is under maintenance, closed, or retired.', 1;
    END;

    -- Also check for active maintenance records
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN MaintenanceRecord mr
            ON mr.SpaceID = i.SpaceID
            AND mr.Status IN ('Reported', 'InProgress')
        WHERE i.Status IN ('Approved', 'CheckedIn')
    )
    BEGIN
        THROW 50003, 'Cannot approve booking: the selected space has active maintenance in progress.', 1;
    END;
END;
GO

-- Trigger: Record status changes in BookingStatusHistory
CREATE OR ALTER TRIGGER trg_BookingStatusHistory
ON BookingRequest
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO BookingStatusHistory (BookingID, FromStatus, ToStatus, ChangedBy, ChangedAt, Note)
    SELECT
        i.BookingID,
        d.Status AS FromStatus,
        i.Status AS ToStatus,
        i.RequestedBy,  -- fallback, ideally from application context
        SYSUTCDATETIME(),
        CASE
            WHEN d.Status IS NULL THEN 'Initial booking created'
            ELSE 'Status changed from ' + ISNULL(d.Status, '(none)') + ' to ' + i.Status
        END
    FROM inserted i
    LEFT JOIN deleted d ON d.BookingID = i.BookingID
    WHERE d.Status IS NULL OR d.Status <> i.Status;
END;
GO

-- Trigger: Record status changes in MaintenanceStatusHistory
CREATE OR ALTER TRIGGER trg_MaintenanceStatusHistory
ON MaintenanceRecord
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO MaintenanceStatusHistory (MaintenanceID, FromStatus, ToStatus, ChangedBy, ChangedAt, Note)
    SELECT
        i.MaintenanceID,
        d.Status AS FromStatus,
        i.Status AS ToStatus,
        i.ReportedBy,  -- fallback
        SYSUTCDATETIME(),
        CASE
            WHEN d.Status IS NULL THEN 'Maintenance record created'
            ELSE 'Status changed from ' + ISNULL(d.Status, '(none)') + ' to ' + i.Status
        END
    FROM inserted i
    LEFT JOIN deleted d ON d.MaintenanceID = i.MaintenanceID
    WHERE d.Status IS NULL OR d.Status <> i.Status;
END;
GO
