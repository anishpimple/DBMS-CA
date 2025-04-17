-- Testing trigger 1

SELECT provider_id, first_name, last_name, is_available, is_verified FROM Providers;

-- Making provider 2 to be unavailable:

UPDATE Providers
SET is_available = 0
WHERE provider_id = 2;

-- BOOKING a provider who is unavailable i.e provider 2
INSERT INTO Bookings (user_id, provider_id, category_id, address_id, booking_date, time_slot, status)
VALUES (1, 4, 2, 1, '2025-06-01', '13:00-15:00', 'Pending');

--running this should throw an error...

-- reverting to available 
UPDATE Providers
SET is_available = 1
WHERE provider_id = 2;

-- After making provider two available we should be able to boob him
INSERT INTO Bookings (user_id, provider_id, category_id, address_id, booking_date, time_slot, status)
VALUES (1, 2, 2, 1, '2025-06-01', '13:00-15:00', 'Pending');

-- this should run successfully without any errors. 

-- testing trigger 2
-- creating a booking with "pending" status
INSERT INTO Bookings (user_id, provider_id, category_id, address_id, booking_date, time_slot, status)
VALUES (3, 3, 3, 3, '2025-06-15', '14:00-16:00', 'Pending');

-- priting the booking id for the booking we created 
DECLARE @new_booking_id INT = SCOPE_IDENTITY();
PRINT 'New booking created with ID: ' + CAST(@new_booking_id AS VARCHAR);
SELECT * FROM Bookings WHERE booking_id = @new_booking_id;

-- creating a payment which coorelates to the same booking id and stating the payment status as "Completed"
DECLARE @last_booking_id INT = (SELECT MAX(booking_id) FROM Bookings);
INSERT INTO Payments (booking_id, amount, payment_method_id, transaction_id, status)
VALUES (@last_booking_id, 100.00, 1, 'TXN' + CAST(@last_booking_id AS VARCHAR) + '123456', 'Completed');

-- checking if the booking status of that booking status was updated to "confirmed" upon successfull payment
SELECT booking_id, status FROM Bookings WHERE booking_id = (SELECT MAX(booking_id) FROM Bookings);



