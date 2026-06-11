-- =============================================================
-- Database Definition — Campus Space Management System
-- DBMS: Microsoft SQL Server
-- =============================================================

CREATE TABLE [User] (
    UserID INT IDENTITY(1,1) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20) NULL,
    Role NVARCHAR(50) NOT NULL,
    Department NVARCHAR(100) NOT NULL,
    AccountStatus NVARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT PK_User PRIMARY KEY (UserID),
    CONSTRAINT UQ_User_Email UNIQUE (Email),
    CONSTRAINT CK_User_Role CHECK (Role IN (
        'Student', 'Lecturer', 'TA', 'FacilityStaff', 'DeptAdmin', 'FacilityManager'
    )),
    CONSTRAINT CK_User_AccountStatus CHECK (AccountStatus IN ('Active', 'Inactive', 'Suspended'))
);

CREATE TABLE Space (
    SpaceCode NVARCHAR(20) NOT NULL,
    SpaceName NVARCHAR(100) NOT NULL,
    SpaceType NVARCHAR(50) NOT NULL,
    Building NVARCHAR(100) NOT NULL,
    Floor INT NOT NULL,
    RoomNumber NVARCHAR(20) NOT NULL,
    Capacity INT NOT NULL,
    CurrentStatus NVARCHAR(30) NOT NULL,
    UsagePolicy NVARCHAR(MAX) NULL,
    CONSTRAINT PK_Space PRIMARY KEY (SpaceCode),
    CONSTRAINT CK_Space_SpaceType CHECK (SpaceType IN (
        'Auditorium', 'Classroom', 'ComputerLab', 'ProjectLab', 'MeetingRoom', 'StudentWorkspace'
    )),
    CONSTRAINT CK_Space_CurrentStatus CHECK (CurrentStatus IN (
        'Available', 'InUse', 'UnderMaintenance', 'TemporarilyClosed', 'Retired'
    )),
    CONSTRAINT CK_Space_Capacity CHECK (Capacity > 0)
);

CREATE TABLE Facility (
    FacilityID INT IDENTITY(1,1) NOT NULL,
    FacilityName NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Facility PRIMARY KEY (FacilityID),
    CONSTRAINT UQ_Facility_FacilityName UNIQUE (FacilityName)
);

CREATE TABLE SpaceFacility (
    SpaceCode NVARCHAR(20) NOT NULL,
    FacilityID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_SpaceFacility PRIMARY KEY (SpaceCode, FacilityID),
    CONSTRAINT FK_SpaceFacility_Space FOREIGN KEY (SpaceCode) REFERENCES Space(SpaceCode),
    CONSTRAINT FK_SpaceFacility_Facility FOREIGN KEY (FacilityID) REFERENCES Facility(FacilityID),
    CONSTRAINT CK_SpaceFacility_Quantity CHECK (Quantity > 0)
);

CREATE TABLE BookingRequest (
    BookingID INT IDENTITY(1,1) NOT NULL,
    SpaceCode NVARCHAR(20) NOT NULL,
    RequesterID INT NOT NULL,
    RequestedStartTime DATETIME2 NOT NULL,
    RequestedEndTime DATETIME2 NOT NULL,
    Purpose NVARCHAR(MAX) NOT NULL,
    ExpectedParticipants INT NOT NULL,
    BookingType NVARCHAR(50) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
    CONSTRAINT PK_BookingRequest PRIMARY KEY (BookingID),
    CONSTRAINT FK_BookingRequest_Space FOREIGN KEY (SpaceCode) REFERENCES Space(SpaceCode),
    CONSTRAINT FK_BookingRequest_User FOREIGN KEY (RequesterID) REFERENCES [User](UserID),
    CONSTRAINT CK_BookingRequest_TimeRange CHECK (RequestedEndTime > RequestedStartTime),
    CONSTRAINT CK_BookingRequest_Participants CHECK (ExpectedParticipants > 0),
    CONSTRAINT CK_BookingRequest_Type CHECK (BookingType IN (
        'Lecture', 'Examination', 'Seminar', 'Workshop', 'Meeting', 'StudentActivity', 'AdminEvent'
    )),
    CONSTRAINT CK_BookingRequest_Status CHECK (Status IN (
        'Pending', 'Approved', 'Rejected', 'Cancelled', 'CheckedIn', 'Completed', 'NoShow'
    ))
);

CREATE TABLE Approval (
    ApprovalID INT IDENTITY(1,1) NOT NULL,
    BookingID INT NOT NULL,
    StaffID INT NOT NULL,
    DecisionTime DATETIME2 NOT NULL DEFAULT GETDATE(),
    DecisionNote NVARCHAR(MAX) NULL,
    RejectionReason NVARCHAR(MAX) NULL,
    CONSTRAINT PK_Approval PRIMARY KEY (ApprovalID),
    CONSTRAINT FK_Approval_Booking FOREIGN KEY (BookingID) REFERENCES BookingRequest(BookingID),
    CONSTRAINT FK_Approval_Staff FOREIGN KEY (StaffID) REFERENCES [User](UserID),
    CONSTRAINT UQ_Approval_BookingID UNIQUE (BookingID)
);

CREATE TABLE Session (
    SessionID INT IDENTITY(1,1) NOT NULL,
    BookingID INT NOT NULL,
    ActualStartTime DATETIME2 NULL,
    ActualEndTime DATETIME2 NULL,
    CheckInBy INT NULL,
    InitialCondition NVARCHAR(MAX) NULL,
    FinalCondition NVARCHAR(MAX) NULL,
    UsageNotes NVARCHAR(MAX) NULL,
    CONSTRAINT PK_Session PRIMARY KEY (SessionID),
    CONSTRAINT FK_Session_Booking FOREIGN KEY (BookingID) REFERENCES BookingRequest(BookingID),
    CONSTRAINT FK_Session_CheckInBy FOREIGN KEY (CheckInBy) REFERENCES [User](UserID),
    CONSTRAINT UQ_Session_BookingID UNIQUE (BookingID)
);

CREATE TABLE Maintenance (
    MaintenanceID INT IDENTITY(1,1) NOT NULL,
    SpaceCode NVARCHAR(20) NOT NULL,
    ReporterID INT NOT NULL,
    AssignedStaffID INT NULL,
    ProblemDescription NVARCHAR(MAX) NOT NULL,
    StartTime DATETIME2 NOT NULL,
    CompletionTime DATETIME2 NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Reported',
    ResultNote NVARCHAR(MAX) NULL,
    CONSTRAINT PK_Maintenance PRIMARY KEY (MaintenanceID),
    CONSTRAINT FK_Maintenance_Space FOREIGN KEY (SpaceCode) REFERENCES Space(SpaceCode),
    CONSTRAINT FK_Maintenance_Reporter FOREIGN KEY (ReporterID) REFERENCES [User](UserID),
    CONSTRAINT FK_Maintenance_AssignedStaff FOREIGN KEY (AssignedStaffID) REFERENCES [User](UserID),
    CONSTRAINT CK_Maintenance_Status CHECK (Status IN (
        'Reported', 'InProgress', 'Completed', 'Cancelled'
    ))
);

-- Index to support overlap detection queries
CREATE INDEX IX_BookingRequest_SpaceCode_TimeRange
    ON BookingRequest (SpaceCode, RequestedStartTime, RequestedEndTime)
    WHERE Status IN ('Approved', 'CheckedIn');

-- Index for maintenance lookup by space
CREATE INDEX IX_Maintenance_SpaceCode_Status
    ON Maintenance (SpaceCode, Status)
    WHERE Status IN ('Reported', 'InProgress');
