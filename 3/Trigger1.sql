-- Trigger 1: Ensure a customer can book a provider only if the provider is available
CREATE TRIGGER tr_CheckProviderAvailability
ON Bookings
INSTEAD OF INSERT
AS
BEGIN
    -- Declare variables to hold inserted values
    DECLARE @provider_id INT
    DECLARE @user_id INT
    DECLARE @category_id INT
    DECLARE @address_id INT
    DECLARE @booking_date DATE
    DECLARE @time_slot VARCHAR(20)
    DECLARE @status VARCHAR(20)
    DECLARE @booking_details XML
    DECLARE @is_available BIT
    DECLARE @is_verified BIT
    
    -- Get values from inserted row
    SELECT @provider_id = i.provider_id FROM inserted i
    SELECT @user_id = i.user_id FROM inserted i
    SELECT @category_id = i.category_id FROM inserted i
    SELECT @address_id = i.address_id FROM inserted i
    SELECT @booking_date = i.booking_date FROM inserted i
    SELECT @time_slot = i.time_slot FROM inserted i
    SELECT @status = i.status FROM inserted i
    SELECT @booking_details = i.booking_details FROM inserted i
    
    -- Check if provider is available and verified
    SELECT @is_available = p.is_available, @is_verified = p.is_verified 
    FROM Providers p 
    WHERE p.provider_id = @provider_id
    
    IF (@is_available = 0 OR @is_verified = 0)
    BEGIN
        PRINT 'Error: Cannot book a provider who is not available or not verified'
        RETURN
    END
    
    -- Check if provider offers this service category
    IF NOT EXISTS (
        SELECT 1 
        FROM Provider_Categories pc 
        WHERE pc.provider_id = @provider_id 
        AND pc.category_id = @category_id
    )
    BEGIN
        PRINT 'Error: The provider does not offer the requested service category'
        RETURN
    END
    
    -- If all checks pass, proceed with the insert
    INSERT INTO Bookings (
        user_id, provider_id, category_id, address_id, 
        booking_date, time_slot, status, booking_details
    )
    VALUES (
        @user_id, @provider_id, @category_id, @address_id, 
        @booking_date, @time_slot, @status, @booking_details
    )
    
    PRINT 'Booking created successfully'
END;
GO