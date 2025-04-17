-- Trigger 2: Ensure a booking is confirmed only after payment is successful
CREATE TRIGGER tr_UpdateBookingOnPayment
ON Payments
AFTER INSERT, UPDATE
AS
BEGIN
    -- Declare variables to hold values
    DECLARE @booking_id INT
    DECLARE @payment_status VARCHAR(20)
    
    -- Get values from inserted row
    SELECT @booking_id = i.booking_id FROM inserted i
    SELECT @payment_status = i.status FROM inserted i
    
    -- Check if payment is completed
    IF (@payment_status = 'Completed')
    BEGIN
        -- Update booking status to Confirmed
        UPDATE Bookings
        SET status = 'Confirmed'
        WHERE booking_id = @booking_id AND status = 'Pending'
        
        -- Print message
        PRINT 'Booking status updated to Confirmed'
    END
END;
GO