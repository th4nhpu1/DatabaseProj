-- Sample Data for School Space Booking System - Group 04

INSERT INTO Users (UserID, Name, Email, Phone, Role, Department, AccountStatus) VALUES
(1, 'Alice Smith', 'alice@uni.edu', '12345678', 'Lecturer', 'CS', 'Active'),
(2, 'Bob Jones', 'bob@uni.edu', '87654321', 'Staff', 'Facility', 'Active'),
(3, 'Charlie Brown', 'charlie@uni.edu', '11223344', 'Student', 'CS', 'Active');

INSERT INTO Spaces (SpaceCode, Name, SpaceType, Building, Floor, RoomNumber, Capacity, Status, UsagePolicy) VALUES
('RM101', 'Auditorium A', 'Auditorium', 'Building 1', 1, '101', 200, 'Available', 'Keep clean'),
('CL202', 'Computer Lab 2', 'Lab', 'Building 2', 2, '202', 40, 'Available', 'No food');

INSERT INTO FacilityTypes (Name) VALUES ('Projector'), ('Whiteboard'), ('Computer');

INSERT INTO SpaceFacilities (SpaceCode, TypeID) VALUES
('RM101', 1), ('RM101', 2), ('CL202', 1), ('CL202', 3);

INSERT INTO Bookings (SpaceCode, RequesterID, StartTime, EndTime, Purpose, ExpectedParticipants, Status) VALUES
('RM101', 1, '2026-07-01 10:00:00', '2026-07-01 12:00:00', 'Lecture', 50, 'Pending');
