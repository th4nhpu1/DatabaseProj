-- Query Design - Group 04

-- 1. List all upcoming bookings for a specific user (e.g., Alice, UserID=1)
SELECT * FROM Bookings WHERE RequesterID = 1 AND StartTime > GETDATE();

-- 2. List all available spaces (not in maintenance, not booked at this moment)
SELECT * FROM Spaces WHERE Status = 'Available' 
AND SpaceCode NOT IN (SELECT SpaceCode FROM Bookings WHERE Status = 'Approved' AND GETDATE() BETWEEN StartTime AND EndTime);

-- 3. Find booking history for a specific space (e.g., RM101)
SELECT * FROM Bookings WHERE SpaceCode = 'RM101';

-- 4. Get maintenance records for a space (e.g., RM101)
SELECT * FROM Maintenance WHERE SpaceCode = 'RM101';

-- 5. Count usage of each space type (total approved bookings)
SELECT S.SpaceType, COUNT(B.BookingID) as TotalBookings
FROM Spaces S
JOIN Bookings B ON S.SpaceCode = B.SpaceCode
WHERE B.Status = 'Completed'
GROUP BY S.SpaceType;
