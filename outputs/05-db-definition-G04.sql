-- ============================================================
-- 05-db-definition-G04.sql
-- Database Schema Definition — School Space Booking System
-- Group 04
-- Microsoft SQL Server
-- Creation order respects FK dependencies
-- ============================================================

-- 1. User (no FK dependencies)
CREATE TABLE [User] (
    userId          INT             NOT NULL IDENTITY(1,1),
    fullName        NVARCHAR(150)   NOT NULL,
    email           NVARCHAR(255)   NOT NULL,
    phone           NVARCHAR(20)    NULL,
    role            NVARCHAR(50)    NOT NULL,
    department      NVARCHAR(100)   NULL,
    accountStatus   NVARCHAR(20)    NOT NULL CONSTRAINT DF_User_accountStatus DEFAULT 'active',
    CONSTRAINT PK_User PRIMARY KEY CLUSTERED (userId),
    CONSTRAINT UQ_User_email UNIQUE (email),
    CONSTRAINT CK_User_role CHECK (role IN (
        'student', 'lecturer', 'teaching_assistant',
        'facility_staff', 'department_administrator', 'facility_manager'
    )),
    CONSTRAINT CK_User_accountStatus CHECK (accountStatus IN ('active', 'suspended', 'disabled'))
);

-- 2. Space (no FK dependencies)
CREATE TABLE [Space] (
    spaceCode       NVARCHAR(20)    NOT NULL,
    spaceName       NVARCHAR(200)   NOT NULL,
    spaceType       NVARCHAR(50)    NOT NULL,
    building        NVARCHAR(100)   NOT NULL,
    floor           INT             NOT NULL,
    roomNumber      NVARCHAR(20)    NOT NULL,
    capacity        INT             NOT NULL,
    currentStatus   NVARCHAR(30)    NOT NULL CONSTRAINT DF_Space_currentStatus DEFAULT 'available',
    usagePolicy     NVARCHAR(MAX)   NULL,
    CONSTRAINT PK_Space PRIMARY KEY CLUSTERED (spaceCode),
    CONSTRAINT CK_Space_spaceType CHECK (spaceType IN (
        'auditorium', 'classroom', 'computer_laboratory',
        'project_laboratory', 'meeting_room', 'student_workspace'
    )),
    CONSTRAINT CK_Space_capacity CHECK (capacity > 0),
    CONSTRAINT CK_Space_currentStatus CHECK (currentStatus IN (
        'available', 'in_use', 'under_maintenance', 'temporarily_closed', 'retired'
    ))
);

-- 3. Facility (no FK dependencies)
CREATE TABLE [Facility] (
    facilityId      INT             NOT NULL IDENTITY(1,1),
    facilityName    NVARCHAR(100)   NOT NULL,
    description     NVARCHAR(500)   NULL,
    CONSTRAINT PK_Facility PRIMARY KEY CLUSTERED (facilityId),
    CONSTRAINT UQ_Facility_facilityName UNIQUE (facilityName)
);

-- 4. SpaceFacility (depends on Space, Facility)
CREATE TABLE [SpaceFacility] (
    spaceCode       NVARCHAR(20)    NOT NULL,
    facilityId      INT             NOT NULL,
    quantity        INT             NOT NULL CONSTRAINT DF_SpaceFacility_quantity DEFAULT 1,
    CONSTRAINT PK_SpaceFacility PRIMARY KEY CLUSTERED (spaceCode, facilityId),
    CONSTRAINT FK_SpaceFacility_Space FOREIGN KEY (spaceCode)
        REFERENCES [Space](spaceCode) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_SpaceFacility_Facility FOREIGN KEY (facilityId)
        REFERENCES [Facility](facilityId) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT CK_SpaceFacility_quantity CHECK (quantity > 0)
);

-- 5. Booking (depends on User, Space)
CREATE TABLE [Booking] (
    bookingId               INT             NOT NULL IDENTITY(1,1),
    userId                  INT             NOT NULL,
    spaceCode               NVARCHAR(20)    NOT NULL,
    requestedStartTime      DATETIME2(2)    NOT NULL,
    requestedEndTime        DATETIME2(2)    NOT NULL,
    purpose                 NVARCHAR(500)   NULL,
    expectedParticipants    INT             NOT NULL,
    bookingType             NVARCHAR(30)    NOT NULL,
    status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Booking_status DEFAULT 'pending',
    submittedAt             DATETIME2(2)    NOT NULL CONSTRAINT DF_Booking_submittedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Booking PRIMARY KEY CLUSTERED (bookingId),
    CONSTRAINT FK_Booking_User FOREIGN KEY (userId)
        REFERENCES [User](userId) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_Booking_Space FOREIGN KEY (spaceCode)
        REFERENCES [Space](spaceCode) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT CK_Booking_requestedEndTime CHECK (requestedEndTime > requestedStartTime),
    CONSTRAINT CK_Booking_expectedParticipants CHECK (expectedParticipants > 0),
    CONSTRAINT CK_Booking_bookingType CHECK (bookingType IN (
        'lecture', 'examination', 'seminar', 'workshop',
        'meeting', 'student_activity', 'administrative_event'
    )),
    CONSTRAINT CK_Booking_status CHECK (status IN (
        'pending', 'approved', 'rejected', 'cancelled',
        'checked_in', 'completed', 'no_show'
    ))
);

-- 6. BookingApproval (depends on Booking, User)
CREATE TABLE [BookingApproval] (
    bookingId       INT             NOT NULL,
    decisionBy      INT             NOT NULL,
    decisionTime    DATETIME2(2)    NOT NULL,
    decisionNote    NVARCHAR(500)   NULL,
    rejectionReason NVARCHAR(500)   NULL,
    CONSTRAINT PK_BookingApproval PRIMARY KEY CLUSTERED (bookingId),
    CONSTRAINT FK_BookingApproval_Booking FOREIGN KEY (bookingId)
        REFERENCES [Booking](bookingId) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_BookingApproval_User FOREIGN KEY (decisionBy)
        REFERENCES [User](userId) ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- 7. CheckIn (depends on Booking, User)
CREATE TABLE [CheckIn] (
    bookingId           INT             NOT NULL,
    checkedInBy         INT             NOT NULL,
    actualStartTime     DATETIME2(2)    NOT NULL,
    initialCondition    NVARCHAR(500)   NULL,
    CONSTRAINT PK_CheckIn PRIMARY KEY CLUSTERED (bookingId),
    CONSTRAINT FK_CheckIn_Booking FOREIGN KEY (bookingId)
        REFERENCES [Booking](bookingId) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_CheckIn_User FOREIGN KEY (checkedInBy)
        REFERENCES [User](userId) ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- 8. CheckOut (depends on Booking)
CREATE TABLE [CheckOut] (
    bookingId       INT             NOT NULL,
    actualEndTime   DATETIME2(2)    NOT NULL,
    finalCondition  NVARCHAR(500)   NULL,
    usageNotes      NVARCHAR(MAX)   NULL,
    CONSTRAINT PK_CheckOut PRIMARY KEY CLUSTERED (bookingId),
    CONSTRAINT FK_CheckOut_Booking FOREIGN KEY (bookingId)
        REFERENCES [Booking](bookingId) ON UPDATE CASCADE ON DELETE CASCADE
);

-- 9. MaintenanceRecord (depends on Space, User x2)
CREATE TABLE [MaintenanceRecord] (
    recordId            INT             NOT NULL IDENTITY(1,1),
    spaceCode           NVARCHAR(20)    NOT NULL,
    reportedBy          INT             NOT NULL,
    assignedTo          INT             NULL,
    problemDescription  NVARCHAR(1000)  NOT NULL,
    startTime           DATETIME2(2)    NOT NULL,
    completionTime      DATETIME2(2)    NULL,
    status              NVARCHAR(20)    NOT NULL CONSTRAINT DF_MaintenanceRecord_status DEFAULT 'reported',
    resultNote          NVARCHAR(1000)  NULL,
    CONSTRAINT PK_MaintenanceRecord PRIMARY KEY CLUSTERED (recordId),
    CONSTRAINT FK_MaintenanceRecord_Space FOREIGN KEY (spaceCode)
        REFERENCES [Space](spaceCode) ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT FK_MaintenanceRecord_ReportedBy FOREIGN KEY (reportedBy)
        REFERENCES [User](userId) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT FK_MaintenanceRecord_AssignedTo FOREIGN KEY (assignedTo)
        REFERENCES [User](userId) ON UPDATE NO ACTION ON DELETE SET NULL,
    CONSTRAINT CK_MaintenanceRecord_status CHECK (status IN (
        'reported', 'in_progress', 'completed', 'cancelled'
    ))
);
