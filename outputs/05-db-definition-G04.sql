-- SQL Server DDL for School Space Booking System - Group 04

CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    Role NVARCHAR(50),
    Department NVARCHAR(100),
    AccountStatus NVARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE Spaces (
    SpaceCode NVARCHAR(20) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    SpaceType NVARCHAR(50),
    Building NVARCHAR(100),
    Floor INT,
    RoomNumber NVARCHAR(20),
    Capacity INT,
    Status NVARCHAR(20) DEFAULT 'Available',
    UsagePolicy NVARCHAR(MAX)
);

CREATE TABLE FacilityTypes (
    TypeID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL
);

CREATE TABLE SpaceFacilities (
    SpaceCode NVARCHAR(20) REFERENCES Spaces(SpaceCode),
    TypeID INT REFERENCES FacilityTypes(TypeID),
    PRIMARY KEY (SpaceCode, TypeID)
);

CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    SpaceCode NVARCHAR(20) REFERENCES Spaces(SpaceCode),
    RequesterID INT REFERENCES Users(UserID),
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    Purpose NVARCHAR(100),
    ExpectedParticipants INT,
    Status NVARCHAR(20) DEFAULT 'Pending',
    DecisionByUserID INT REFERENCES Users(UserID),
    DecisionTime DATETIME,
    DecisionNote NVARCHAR(MAX),
    RejectionReason NVARCHAR(MAX),
    ActualStartTime DATETIME,
    CheckerInUserID INT REFERENCES Users(UserID),
    InitialCondition NVARCHAR(MAX),
    ActualEndTime DATETIME,
    FinalCondition NVARCHAR(MAX),
    UsageNotes NVARCHAR(MAX)
);

CREATE TABLE Maintenance (
    MaintenanceID INT PRIMARY KEY IDENTITY(1,1),
    SpaceCode NVARCHAR(20) REFERENCES Spaces(SpaceCode),
    ReporterUserID INT REFERENCES Users(UserID),
    AssignedStaffID INT REFERENCES Users(UserID),
    Description NVARCHAR(MAX),
    StartTime DATETIME,
    CompletionTime DATETIME,
    Status NVARCHAR(20) DEFAULT 'Pending',
    ResultNote NVARCHAR(MAX)
);
