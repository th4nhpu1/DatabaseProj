-- ============================================================
-- Campus Space Management System — Database Definition (DDL)
-- Target: Microsoft SQL Server
-- ============================================================

-- Database creation with name conflict avoidance
IF DB_ID('CampusSpaceManagement') IS NULL
BEGIN
    CREATE DATABASE [CampusSpaceManagement];
END
ELSE
BEGIN
    DECLARE @Suffix INT = 2;
    WHILE DB_ID('CampusSpaceManagement_v' + CAST(@Suffix AS NVARCHAR(10))) IS NOT NULL
        SET @Suffix = @Suffix + 1;
    DECLARE @DbName NVARCHAR(128) = 'CampusSpaceManagement_v' + CAST(@Suffix AS NVARCHAR(10));
    EXEC('CREATE DATABASE [' + @DbName + ']');
END
GO

USE [CampusSpaceManagement];
GO

-- ============================================================
-- CLEANUP (for re-runnability)
-- ============================================================
DROP TABLE IF EXISTS MaintenanceStatusHistory;
DROP TABLE IF EXISTS BookingStatusHistory;
DROP TABLE IF EXISTS CheckOut;
DROP TABLE IF EXISTS CheckIn;
DROP TABLE IF EXISTS BookingApproval;
DROP TABLE IF EXISTS MaintenanceRecord;
DROP TABLE IF EXISTS BookingRequest;
DROP TABLE IF EXISTS SpaceFacility;
DROP TABLE IF EXISTS Facility;
DROP TABLE IF EXISTS Space;
DROP TABLE IF EXISTS [User];
GO

-- ============================================================
-- REFERENCE / LOOKUP TABLES
-- ============================================================

-- 1. User
CREATE TABLE [User]
(
    UserID          INT           NOT NULL IDENTITY(1,1),
    FullName        NVARCHAR(100) NOT NULL,
    Email           NVARCHAR(255) NOT NULL,
    PhoneNumber     NVARCHAR(20)  NULL,
    Role            NVARCHAR(30)  NOT NULL,
    Department      NVARCHAR(100) NULL,
    AccountStatus   NVARCHAR(20)  NOT NULL DEFAULT 'active',
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt      DATETIME2     NULL,

    CONSTRAINT PK_User PRIMARY KEY (UserID),
    CONSTRAINT UQ_User_Email UNIQUE (Email),
    CONSTRAINT CK_User_Role CHECK (Role IN (
        'student', 'lecturer', 'teaching_assistant',
        'facility_staff', 'department_administrator', 'facility_manager'
    )),
    CONSTRAINT CK_User_AccountStatus CHECK (AccountStatus IN (
        'active', 'disabled', 'suspended'
    ))
);
GO

-- 2. Space
CREATE TABLE Space
(
    SpaceID         INT           NOT NULL IDENTITY(1,1),
    SpaceCode       NVARCHAR(20)  NOT NULL,
    SpaceName       NVARCHAR(100) NOT NULL,
    SpaceType       NVARCHAR(30)  NOT NULL,
    Building        NVARCHAR(100) NOT NULL,
    Floor           NVARCHAR(10)  NOT NULL,
    RoomNumber      NVARCHAR(20)  NOT NULL,
    Capacity        INT           NOT NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'available',
    UsagePolicy     NVARCHAR(500) NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt      DATETIME2     NULL,

    CONSTRAINT PK_Space PRIMARY KEY (SpaceID),
    CONSTRAINT UQ_Space_SpaceCode UNIQUE (SpaceCode),
    CONSTRAINT CK_Space_SpaceType CHECK (SpaceType IN (
        'auditorium', 'classroom', 'computer_laboratory',
        'project_laboratory', 'meeting_room', 'student_workspace'
    )),
    CONSTRAINT CK_Space_Status CHECK (Status IN (
        'available', 'in_use', 'under_maintenance',
        'temporarily_closed', 'retired'
    )),
    CONSTRAINT CK_Space_Capacity CHECK (Capacity > 0)
);
GO

-- 3. Facility
CREATE TABLE Facility
(
    FacilityID      INT           NOT NULL IDENTITY(1,1),
    FacilityName    NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(500) NULL,

    CONSTRAINT PK_Facility PRIMARY KEY (FacilityID),
    CONSTRAINT UQ_Facility_FacilityName UNIQUE (FacilityName)
);
GO

-- 4. SpaceFacility (associative)
CREATE TABLE SpaceFacility
(
    SpaceID     INT NOT NULL,
    FacilityID  INT NOT NULL,

    CONSTRAINT PK_SpaceFacility PRIMARY KEY (SpaceID, FacilityID),
    CONSTRAINT FK_SpaceFacility_Space FOREIGN KEY (SpaceID)
        REFERENCES Space(SpaceID),
    CONSTRAINT FK_SpaceFacility_Facility FOREIGN KEY (FacilityID)
        REFERENCES Facility(FacilityID)
);
GO

-- ============================================================
-- TRANSACTIONAL TABLES
-- ============================================================

-- 5. BookingRequest
CREATE TABLE BookingRequest
(
    BookingID           INT           NOT NULL IDENTITY(1,1),
    RequestedByUserID   INT           NOT NULL,
    SpaceID             INT           NOT NULL,
    RequestedStartTime  DATETIME2     NOT NULL,
    RequestedEndTime    DATETIME2     NOT NULL,
    Purpose             NVARCHAR(500) NOT NULL,
    PurposeType         NVARCHAR(30)  NOT NULL,
    ExpectedParticipants INT          NOT NULL,
    Status              NVARCHAR(20)  NOT NULL DEFAULT 'pending',
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt          DATETIME2     NULL,

    CONSTRAINT PK_BookingRequest PRIMARY KEY (BookingID),
    CONSTRAINT FK_BookingRequest_User FOREIGN KEY (RequestedByUserID)
        REFERENCES [User](UserID),
    CONSTRAINT FK_BookingRequest_Space FOREIGN KEY (SpaceID)
        REFERENCES Space(SpaceID),
    CONSTRAINT CK_BookingRequest_TimeRange CHECK (RequestedEndTime > RequestedStartTime),
    CONSTRAINT CK_BookingRequest_Participants CHECK (ExpectedParticipants > 0),
    CONSTRAINT CK_BookingRequest_PurposeType CHECK (PurposeType IN (
        'lecture', 'examination', 'seminar', 'workshop',
        'meeting', 'student_activity', 'administrative_event'
    )),
    CONSTRAINT CK_BookingRequest_Status CHECK (Status IN (
        'pending', 'approved', 'rejected', 'cancelled',
        'checked_in', 'completed', 'no_show'
    ))
);
GO

-- 6. BookingApproval (0..1 per booking)
CREATE TABLE BookingApproval
(
    ApprovalID      INT           NOT NULL IDENTITY(1,1),
    BookingID       INT           NOT NULL,
    ApprovedByUserID INT          NOT NULL,
    DecisionTime    DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    Decision        NVARCHAR(10)  NOT NULL,
    DecisionNote    NVARCHAR(500) NULL,
    RejectionReason NVARCHAR(500) NULL,

    CONSTRAINT PK_BookingApproval PRIMARY KEY (ApprovalID),
    CONSTRAINT UQ_BookingApproval_BookingID UNIQUE (BookingID),
    CONSTRAINT FK_BookingApproval_BookingRequest FOREIGN KEY (BookingID)
        REFERENCES BookingRequest(BookingID),
    CONSTRAINT FK_BookingApproval_User FOREIGN KEY (ApprovedByUserID)
        REFERENCES [User](UserID),
    CONSTRAINT CK_BookingApproval_Decision CHECK (Decision IN ('approved', 'rejected'))
);
GO

-- 7. CheckIn
CREATE TABLE CheckIn
(
    BookingID           INT           NOT NULL,
    CheckedInByUserID   INT           NOT NULL,
    ActualStartTime     DATETIME2     NOT NULL,
    InitialCondition    NVARCHAR(500) NULL,

    CONSTRAINT PK_CheckIn PRIMARY KEY (BookingID),
    CONSTRAINT FK_CheckIn_BookingRequest FOREIGN KEY (BookingID)
        REFERENCES BookingRequest(BookingID),
    CONSTRAINT FK_CheckIn_User FOREIGN KEY (CheckedInByUserID)
        REFERENCES [User](UserID)
);
GO

-- 8. CheckOut
CREATE TABLE CheckOut
(
    BookingID           INT            NOT NULL,
    CheckedOutByUserID  INT            NOT NULL,
    ActualEndTime       DATETIME2      NOT NULL,
    FinalCondition      NVARCHAR(500)  NULL,
    UsageNotes          NVARCHAR(1000) NULL,

    CONSTRAINT PK_CheckOut PRIMARY KEY (BookingID),
    CONSTRAINT FK_CheckOut_BookingRequest FOREIGN KEY (BookingID)
        REFERENCES BookingRequest(BookingID),
    CONSTRAINT FK_CheckOut_User FOREIGN KEY (CheckedOutByUserID)
        REFERENCES [User](UserID)
);
GO

-- 9. MaintenanceRecord
CREATE TABLE MaintenanceRecord
(
    MaintenanceID     INT            NOT NULL IDENTITY(1,1),
    SpaceID           INT            NOT NULL,
    ReportedByUserID  INT            NOT NULL,
    AssignedToUserID  INT            NULL,
    ProblemDescription NVARCHAR(1000) NOT NULL,
    ProblemType       NVARCHAR(30)   NOT NULL,
    StartTime         DATETIME2      NOT NULL,
    CompletionTime    DATETIME2      NULL,
    Status            NVARCHAR(20)   NOT NULL DEFAULT 'reported',
    ResultNote        NVARCHAR(1000) NULL,
    CreatedAt         DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt        DATETIME2      NULL,

    CONSTRAINT PK_MaintenanceRecord PRIMARY KEY (MaintenanceID),
    CONSTRAINT FK_MaintenanceRecord_Space FOREIGN KEY (SpaceID)
        REFERENCES Space(SpaceID),
    CONSTRAINT FK_MaintenanceRecord_ReportedBy FOREIGN KEY (ReportedByUserID)
        REFERENCES [User](UserID),
    CONSTRAINT FK_MaintenanceRecord_AssignedTo FOREIGN KEY (AssignedToUserID)
        REFERENCES [User](UserID),
    CONSTRAINT CK_MaintenanceRecord_ProblemType CHECK (ProblemType IN (
        'broken_projector', 'ac_failure', 'damaged_furniture',
        'cleaning', 'network', 'other'
    )),
    CONSTRAINT CK_MaintenanceRecord_Status CHECK (Status IN (
        'reported', 'assigned', 'in_progress', 'completed', 'cancelled'
    ))
);
GO

-- ============================================================
-- HISTORY TABLES
-- ============================================================

-- 10. BookingStatusHistory
CREATE TABLE BookingStatusHistory
(
    HistoryID       INT           NOT NULL IDENTITY(1,1),
    BookingID       INT           NOT NULL,
    PreviousStatus  NVARCHAR(20)  NULL,
    NewStatus       NVARCHAR(20)  NOT NULL,
    ChangedByUserID INT           NOT NULL,
    ChangedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    Note            NVARCHAR(500) NULL,

    CONSTRAINT PK_BookingStatusHistory PRIMARY KEY (HistoryID),
    CONSTRAINT FK_BookingStatusHistory_BookingRequest FOREIGN KEY (BookingID)
        REFERENCES BookingRequest(BookingID),
    CONSTRAINT FK_BookingStatusHistory_User FOREIGN KEY (ChangedByUserID)
        REFERENCES [User](UserID)
);
GO

-- 11. MaintenanceStatusHistory
CREATE TABLE MaintenanceStatusHistory
(
    HistoryID           INT           NOT NULL IDENTITY(1,1),
    MaintenanceRecordID INT           NOT NULL,
    PreviousStatus      NVARCHAR(20)  NULL,
    NewStatus           NVARCHAR(20)  NOT NULL,
    ChangedByUserID     INT           NOT NULL,
    ChangedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    Note                NVARCHAR(500) NULL,

    CONSTRAINT PK_MaintenanceStatusHistory PRIMARY KEY (HistoryID),
    CONSTRAINT FK_MaintenanceStatusHistory_MaintenanceRecord FOREIGN KEY (MaintenanceRecordID)
        REFERENCES MaintenanceRecord(MaintenanceID),
    CONSTRAINT FK_MaintenanceStatusHistory_User FOREIGN KEY (ChangedByUserID)
        REFERENCES [User](UserID)
);
GO

-- ============================================================
-- MODIFIEDAT TRIGGERS
-- ============================================================
-- These triggers automatically update ModifiedAt on any row update.
-- Per the skill rules, we do NOT use triggers for history insertion.

CREATE TRIGGER TR_User_ModifiedAt ON [User]
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(ModifiedAt)
    BEGIN
        UPDATE [User]
        SET ModifiedAt = SYSUTCDATETIME()
        FROM [User] U
        INNER JOIN inserted I ON U.UserID = I.UserID;
    END
END;
GO

CREATE TRIGGER TR_Space_ModifiedAt ON Space
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(ModifiedAt)
    BEGIN
        UPDATE Space
        SET ModifiedAt = SYSUTCDATETIME()
        FROM Space S
        INNER JOIN inserted I ON S.SpaceID = I.SpaceID;
    END
END;
GO

CREATE TRIGGER TR_BookingRequest_ModifiedAt ON BookingRequest
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(ModifiedAt)
    BEGIN
        UPDATE BookingRequest
        SET ModifiedAt = SYSUTCDATETIME()
        FROM BookingRequest B
        INNER JOIN inserted I ON B.BookingID = I.BookingID;
    END
END;
GO

CREATE TRIGGER TR_MaintenanceRecord_ModifiedAt ON MaintenanceRecord
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(ModifiedAt)
    BEGIN
        UPDATE MaintenanceRecord
        SET ModifiedAt = SYSUTCDATETIME()
        FROM MaintenanceRecord M
        INNER JOIN inserted I ON M.MaintenanceID = I.MaintenanceID;
    END
END;
GO
