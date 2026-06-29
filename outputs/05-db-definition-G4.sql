-- ============================================================
-- Database Definition (DDL) — Campus Space Management System
-- Target: Microsoft SQL Server
-- ============================================================

-- ------------------------------------------------------------
-- Create database
-- ------------------------------------------------------------
IF DB_ID('CampusSpaceManagement') IS NULL
    CREATE DATABASE CampusSpaceManagement;
GO

USE CampusSpaceManagement;
GO

-- ------------------------------------------------------------
-- Drop tables in reverse dependency order
-- ------------------------------------------------------------
DROP TABLE IF EXISTS [BookingSession];
DROP TABLE IF EXISTS [BookingApproval];
DROP TABLE IF EXISTS [Booking];
DROP TABLE IF EXISTS [SpaceFacility];
DROP TABLE IF EXISTS [Maintenance];
DROP TABLE IF EXISTS [Facility];
DROP TABLE IF EXISTS [Space];
DROP TABLE IF EXISTS [User];
GO

-- ------------------------------------------------------------
-- 1. User
-- ------------------------------------------------------------
CREATE TABLE [User] (
    user_id INT NOT NULL IDENTITY(1,1),
    full_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) NOT NULL,
    phone NVARCHAR(20) NULL,
    role NVARCHAR(30) NOT NULL,
    department NVARCHAR(100) NOT NULL,
    account_status NVARCHAR(20) NOT NULL DEFAULT 'active',
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    modified_at DATETIME2 NULL,
    CONSTRAINT PK_User PRIMARY KEY (user_id),
    CONSTRAINT UQ_User_email UNIQUE (email),
    CONSTRAINT CK_User_role CHECK (role IN (
        'student', 'lecturer', 'ta', 'facility_staff', 'dept_admin', 'facility_manager'
    )),
    CONSTRAINT CK_User_account_status CHECK (account_status IN (
        'active', 'inactive', 'suspended'
    ))
);
GO

-- ------------------------------------------------------------
-- 2. Space
-- ------------------------------------------------------------
CREATE TABLE [Space] (
    space_code NVARCHAR(20) NOT NULL,
    space_name NVARCHAR(100) NOT NULL,
    space_type NVARCHAR(30) NOT NULL,
    building NVARCHAR(100) NOT NULL,
    floor NVARCHAR(10) NOT NULL,
    room_number NVARCHAR(20) NOT NULL,
    capacity INT NOT NULL,
    status NVARCHAR(30) NOT NULL DEFAULT 'available',
    usage_policy NVARCHAR(MAX) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    modified_at DATETIME2 NULL,
    CONSTRAINT PK_Space PRIMARY KEY (space_code),
    CONSTRAINT CK_Space_space_type CHECK (space_type IN (
        'auditorium', 'classroom', 'computer_lab', 'project_lab', 'meeting_room', 'student_workspace'
    )),
    CONSTRAINT CK_Space_capacity CHECK (capacity > 0),
    CONSTRAINT CK_Space_status CHECK (status IN (
        'available', 'in_use', 'under_maintenance', 'temporarily_closed', 'retired'
    ))
);
GO

-- ------------------------------------------------------------
-- 3. Facility
-- ------------------------------------------------------------
CREATE TABLE [Facility] (
    facility_id INT NOT NULL IDENTITY(1,1),
    facility_name NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Facility PRIMARY KEY (facility_id),
    CONSTRAINT UQ_Facility_name UNIQUE (facility_name)
);
GO

-- ------------------------------------------------------------
-- 4. SpaceFacility (M:N between Space and Facility)
-- ------------------------------------------------------------
CREATE TABLE [SpaceFacility] (
    space_code NVARCHAR(20) NOT NULL,
    facility_id INT NOT NULL,
    CONSTRAINT PK_SpaceFacility PRIMARY KEY (space_code, facility_id),
    CONSTRAINT FK_SpaceFacility_Space FOREIGN KEY (space_code)
        REFERENCES [Space](space_code),
    CONSTRAINT FK_SpaceFacility_Facility FOREIGN KEY (facility_id)
        REFERENCES [Facility](facility_id)
);
GO

-- ------------------------------------------------------------
-- 5. Booking
-- ------------------------------------------------------------
CREATE TABLE [Booking] (
    booking_id INT NOT NULL IDENTITY(1,1),
    user_id INT NOT NULL,
    space_code NVARCHAR(20) NOT NULL,
    requested_start DATETIME2 NOT NULL,
    requested_end DATETIME2 NOT NULL,
    purpose NVARCHAR(MAX) NOT NULL,
    expected_participants INT NOT NULL,
    booking_type NVARCHAR(30) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    modified_at DATETIME2 NULL,
    CONSTRAINT PK_Booking PRIMARY KEY (booking_id),
    CONSTRAINT FK_Booking_User FOREIGN KEY (user_id)
        REFERENCES [User](user_id),
    CONSTRAINT FK_Booking_Space FOREIGN KEY (space_code)
        REFERENCES [Space](space_code),
    CONSTRAINT CK_Booking_requested_end CHECK (requested_end > requested_start),
    CONSTRAINT CK_Booking_expected_participants CHECK (expected_participants > 0),
    CONSTRAINT CK_Booking_booking_type CHECK (booking_type IN (
        'lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student_activity', 'admin_event'
    )),
    CONSTRAINT CK_Booking_status CHECK (status IN (
        'pending', 'approved', 'rejected', 'cancelled', 'checked_in', 'completed', 'no_show'
    ))
);
GO

-- ------------------------------------------------------------
-- 6. BookingApproval
-- ------------------------------------------------------------
CREATE TABLE [BookingApproval] (
    approval_id INT NOT NULL IDENTITY(1,1),
    booking_id INT NOT NULL,
    staff_id INT NOT NULL,
    decision NVARCHAR(20) NOT NULL,
    decision_time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    decision_note NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    modified_at DATETIME2 NULL,
    CONSTRAINT PK_BookingApproval PRIMARY KEY (approval_id),
    CONSTRAINT UQ_BookingApproval_booking UNIQUE (booking_id),
    CONSTRAINT FK_BookingApproval_Booking FOREIGN KEY (booking_id)
        REFERENCES [Booking](booking_id),
    CONSTRAINT FK_BookingApproval_Staff FOREIGN KEY (staff_id)
        REFERENCES [User](user_id),
    CONSTRAINT CK_BookingApproval_decision CHECK (decision IN ('approved', 'rejected'))
);
GO

-- ------------------------------------------------------------
-- 7. BookingSession (check-in and check-out)
-- ------------------------------------------------------------
CREATE TABLE [BookingSession] (
    session_id INT NOT NULL IDENTITY(1,1),
    booking_id INT NOT NULL,
    actual_start DATETIME2 NOT NULL,
    checked_in_by INT NOT NULL,
    initial_condition NVARCHAR(MAX) NULL,
    actual_end DATETIME2 NULL,
    final_condition NVARCHAR(MAX) NULL,
    usage_notes NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    modified_at DATETIME2 NULL,
    CONSTRAINT PK_BookingSession PRIMARY KEY (session_id),
    CONSTRAINT UQ_BookingSession_booking UNIQUE (booking_id),
    CONSTRAINT FK_BookingSession_Booking FOREIGN KEY (booking_id)
        REFERENCES [Booking](booking_id),
    CONSTRAINT FK_BookingSession_CheckedInBy FOREIGN KEY (checked_in_by)
        REFERENCES [User](user_id),
    CONSTRAINT CK_BookingSession_actual_end CHECK (actual_end IS NULL OR actual_end > actual_start)
);
GO

-- ------------------------------------------------------------
-- 8. Maintenance
-- ------------------------------------------------------------
CREATE TABLE [Maintenance] (
    maintenance_id INT NOT NULL IDENTITY(1,1),
    space_code NVARCHAR(20) NOT NULL,
    reporter_id INT NULL,
    assigned_to INT NULL,
    problem_description NVARCHAR(MAX) NOT NULL,
    start_time DATETIME2 NOT NULL,
    completion_time DATETIME2 NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'reported',
    result_note NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    modified_at DATETIME2 NULL,
    CONSTRAINT PK_Maintenance PRIMARY KEY (maintenance_id),
    CONSTRAINT FK_Maintenance_Space FOREIGN KEY (space_code)
        REFERENCES [Space](space_code),
    CONSTRAINT FK_Maintenance_Reporter FOREIGN KEY (reporter_id)
        REFERENCES [User](user_id),
    CONSTRAINT FK_Maintenance_AssignedTo FOREIGN KEY (assigned_to)
        REFERENCES [User](user_id),
    CONSTRAINT CK_Maintenance_status CHECK (status IN (
        'reported', 'assigned', 'in_progress', 'completed', 'cancelled'
    )),
    CONSTRAINT CK_Maintenance_completion_time CHECK (completion_time IS NULL OR completion_time >= start_time)
);
GO

-- ------------------------------------------------------------
-- Indexes for performance
-- ------------------------------------------------------------
CREATE INDEX IX_Booking_space_code ON [Booking](space_code);
CREATE INDEX IX_Booking_user_id ON [Booking](user_id);
CREATE INDEX IX_Booking_status ON [Booking](status);
CREATE INDEX IX_Booking_requested_start ON [Booking](requested_start);
CREATE INDEX IX_Maintenance_space_code ON [Maintenance](space_code);
CREATE INDEX IX_Maintenance_status ON [Maintenance](status);
CREATE INDEX IX_BookingApproval_booking_id ON [BookingApproval](booking_id);
CREATE INDEX IX_BookingSession_booking_id ON [BookingSession](booking_id);
GO

-- ============================================================
-- TRIGGERS — Business Rules
-- ============================================================

-- ------------------------------------------------------------
-- Trigger 1: Overlap Prevention
-- Prevents inserting or updating a booking to 'approved' or
-- 'checked_in' when another confirmed booking exists for the
-- same space with overlapping time.
-- ------------------------------------------------------------
CREATE TRIGGER TRG_Booking_PreventOverlap
ON [Booking]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.status IN ('approved', 'checked_in')
          AND EXISTS (
              SELECT 1
              FROM [Booking] b
              WHERE b.space_code = i.space_code
                AND b.booking_id <> i.booking_id
                AND b.status IN ('approved', 'checked_in')
                AND b.requested_start < i.requested_end
                AND b.requested_end > i.requested_start
          )
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Booking overlap: the selected space already has a confirmed booking during this time period.', 1;
    END;
END;
GO

-- ------------------------------------------------------------
-- Trigger 2: Unavailable Space Block
-- Prevents booking a space whose status is under_maintenance,
-- temporarily_closed, or retired.
-- ------------------------------------------------------------
CREATE TRIGGER TRG_Booking_CheckSpaceAvailable
ON [Booking]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN [Space] s ON i.space_code = s.space_code
        WHERE i.status NOT IN ('rejected', 'cancelled')
          AND s.status IN ('under_maintenance', 'temporarily_closed', 'retired')
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, 'Cannot book: the selected space is under maintenance, temporarily closed, or retired.', 1;
    END;
END;
GO

-- ------------------------------------------------------------
-- Trigger 3: Capacity Enforcement
-- Prevents booking when expected_participants exceeds the
-- space capacity.
-- ------------------------------------------------------------
CREATE TRIGGER TRG_Booking_CheckCapacity
ON [Booking]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN [Space] s ON i.space_code = s.space_code
        WHERE i.status NOT IN ('rejected', 'cancelled')
          AND i.expected_participants > s.capacity
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003, 'Capacity exceeded: expected participants exceeds room capacity.', 1;
    END;
END;
GO

-- ============================================================
-- TRIGGERS — Audit (ModifiedAt auto-update)
-- ============================================================

-- User ModifiedAt
CREATE TRIGGER TRG_User_ModifiedAt
ON [User]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;
    UPDATE [User]
    SET modified_at = SYSUTCDATETIME()
    FROM [User] u
    JOIN inserted i ON u.user_id = i.user_id;
END;
GO

-- Space ModifiedAt
CREATE TRIGGER TRG_Space_ModifiedAt
ON [Space]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;
    UPDATE [Space]
    SET modified_at = SYSUTCDATETIME()
    FROM [Space] s
    JOIN inserted i ON s.space_code = i.space_code;
END;
GO

-- Booking ModifiedAt
CREATE TRIGGER TRG_Booking_ModifiedAt
ON [Booking]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;
    UPDATE [Booking]
    SET modified_at = SYSUTCDATETIME()
    FROM [Booking] b
    JOIN inserted i ON b.booking_id = i.booking_id;
END;
GO

-- BookingApproval ModifiedAt
CREATE TRIGGER TRG_BookingApproval_ModifiedAt
ON [BookingApproval]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;
    UPDATE [BookingApproval]
    SET modified_at = SYSUTCDATETIME()
    FROM [BookingApproval] ba
    JOIN inserted i ON ba.approval_id = i.approval_id;
END;
GO

-- BookingSession ModifiedAt
CREATE TRIGGER TRG_BookingSession_ModifiedAt
ON [BookingSession]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;
    UPDATE [BookingSession]
    SET modified_at = SYSUTCDATETIME()
    FROM [BookingSession] bs
    JOIN inserted i ON bs.session_id = i.session_id;
END;
GO

-- Maintenance ModifiedAt
CREATE TRIGGER TRG_Maintenance_ModifiedAt
ON [Maintenance]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;
    UPDATE [Maintenance]
    SET modified_at = SYSUTCDATETIME()
    FROM [Maintenance] m
    JOIN inserted i ON m.maintenance_id = i.maintenance_id;
END;
GO
