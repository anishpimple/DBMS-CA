-- First, add an XML column to the Bookings table
ALTER TABLE Bookings
ADD booking_details XML;
GO

-- 1. GetAvailableProvidersForService
-- Uses JOIN, WHERE, AND, and ORDER BY to find available providers for a specific service category
CREATE PROCEDURE GetAvailableProvidersForService
    @category_id INT
AS
BEGIN
    SELECT 
        p.provider_id,
        p.first_name + ' ' + p.last_name AS provider_name,
        pr.avg_rating,
        pc.price_rate,
        p.experience_years
    FROM 
        Providers p
    JOIN 
        Provider_Categories pc ON p.provider_id = pc.provider_id
    JOIN 
        Provider_Ratings pr ON p.provider_id = pr.provider_id
    WHERE 
        pc.category_id = @category_id
        AND p.is_available = 1
        AND p.is_verified = 1
    ORDER BY 
        pr.avg_rating DESC, p.experience_years DESC;
END;
GO

-- 2. Custom Function for UpdateProviderRating
-- USER DEFINED FUNCTION (Requirement iii)
CREATE FUNCTION CalculateNewAverage
(
    @provider_id INT,
    @new_rating TINYINT
)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @total_ratings INT;
    DECLARE @sum_ratings INT;
    DECLARE @new_avg DECIMAL(3,2);
    
    -- Get sum of all existing ratings
    SELECT @sum_ratings = ISNULL(SUM(rating), 0)
    FROM Ratings
    WHERE provider_id = @provider_id;
    
    -- Get count of all existing ratings
    SELECT @total_ratings = COUNT(*)
    FROM Ratings
    WHERE provider_id = @provider_id;
    
    -- Calculate new average based on sum + new rating
    SET @new_avg = CAST((@sum_ratings + @new_rating) AS DECIMAL(10,2)) / CAST((@total_ratings + 1) AS DECIMAL(10,2));
    
    RETURN @new_avg;
END;
GO

-- UpdateProviderRating Stored Procedure
CREATE PROCEDURE UpdateProviderRating
    @booking_id INT,
    @provider_id INT,
    @user_id INT,
    @rating TINYINT
AS
BEGIN
    -- Validate the rating is between 1 and 5
    IF @rating < 1 OR @rating > 5
    BEGIN
        RAISERROR('Rating must be between 1 and 5', 16, 1);
        RETURN;
    END
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Check if rating already exists for this booking
        IF EXISTS (SELECT 1 FROM Ratings WHERE booking_id = @booking_id)
        BEGIN
            -- Update the existing rating
            UPDATE Ratings
            SET rating = @rating
            WHERE booking_id = @booking_id;
        END
        ELSE
        BEGIN
            -- Insert a new rating
            INSERT INTO Ratings (booking_id, provider_id, user_id, rating)
            VALUES (@booking_id, @provider_id, @user_id, @rating);
        END
        
        -- Recalculate average rating directly without the function
        -- This ensures we're always using fresh data for the average
        UPDATE Provider_Ratings
        SET avg_rating = (
            SELECT CAST(AVG(CAST(rating AS DECIMAL(10,2))) AS DECIMAL(3,2))
            FROM Ratings
            WHERE provider_id = @provider_id
        )
        WHERE provider_id = @provider_id;
        
        COMMIT TRANSACTION;
        
        -- Return the updated rating
        SELECT avg_rating 
        FROM Provider_Ratings 
        WHERE provider_id = @provider_id;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 3. GetTopRatedProvidersByCategory
-- Uses GROUP BY with HAVING (Requirement ii)
CREATE PROCEDURE GetTopRatedProvidersByCategory
    @min_rating DECIMAL(3,2) = 4.0
AS
BEGIN
    SELECT 
        sc.category_id,
        sc.name AS category_name,
        COUNT(DISTINCT p.provider_id) AS provider_count,
        AVG(pr.avg_rating) AS average_category_rating
    FROM 
        Service_Categories sc
    JOIN 
        Provider_Categories pc ON sc.category_id = pc.category_id
    JOIN 
        Providers p ON pc.provider_id = p.provider_id
    JOIN 
        Provider_Ratings pr ON p.provider_id = pr.provider_id
    WHERE
        p.is_verified = 1
    GROUP BY 
        sc.category_id, sc.name
    HAVING 
        AVG(pr.avg_rating) >= @min_rating
    ORDER BY 
        average_category_rating DESC;
END;
GO

-- 4. CreateBookingWithXML
-- Developing XML with appropriate elements (Requirement iv)
CREATE PROCEDURE CreateBookingWithXML
    @user_id INT,
    @provider_id INT,
    @category_id INT,
    @address_id INT,
    @booking_date DATE,
    @time_slot VARCHAR(20),
    @special_instructions VARCHAR(MAX),
    @items_needed VARCHAR(MAX),
    @estimated_duration INT
AS
BEGIN
    DECLARE @booking_id INT;
    DECLARE @booking_details XML;
    
    -- Create XML with appropriate elements
    SET @booking_details = (
        SELECT
            @special_instructions AS 'SpecialInstructions',
            @items_needed AS 'ItemsNeeded',
            @estimated_duration AS 'EstimatedDuration'
        FOR XML PATH('BookingDetails'), ROOT('Booking')
    );
    
    -- Insert the new booking with XML data
    INSERT INTO Bookings (
        user_id, 
        provider_id, 
        category_id, 
        address_id, 
        booking_date, 
        time_slot, 
        status, 
        booking_details
    )
    VALUES (
        @user_id, 
        @provider_id, 
        @category_id, 
        @address_id, 
        @booking_date, 
        @time_slot, 
        'Pending', 
        @booking_details
    );
    
    -- Get the newly created booking ID
    SET @booking_id = SCOPE_IDENTITY();
    
    -- Return booking details including XML data
    SELECT 
        b.booking_id,
        u.first_name + ' ' + u.last_name AS user_name,
        p.first_name + ' ' + p.last_name AS provider_name,
        sc.name AS service_name,
        b.booking_date,
        b.time_slot,
        b.status,
        b.booking_details
    FROM 
        Bookings b
    JOIN 
        Users u ON b.user_id = u.user_id
    JOIN 
        Providers p ON b.provider_id = p.provider_id
    JOIN 
        Service_Categories sc ON b.category_id = sc.category_id
    WHERE 
        b.booking_id = @booking_id;
END;
GO

-- 5. SearchBookingsByXMLDetails
-- Searching data in a field of XML data type (Requirement vii)
CREATE PROCEDURE SearchBookingsByXMLDetails
    @search_term VARCHAR(100)
AS
BEGIN
    SELECT 
        b.booking_id,
        u.first_name + ' ' + u.last_name AS customer_name,
        p.first_name + ' ' + p.last_name AS provider_name,
        sc.name AS service_name,
        b.booking_date,
        b.time_slot,
        b.status,
        b.booking_details
    FROM 
        Bookings b
    JOIN 
        Users u ON b.user_id = u.user_id
    JOIN 
        Providers p ON b.provider_id = p.provider_id
    JOIN 
        Service_Categories sc ON b.category_id = sc.category_id
    WHERE 
        b.booking_details.exist('/Booking/BookingDetails/SpecialInstructions[contains(., sql:variable("@search_term"))]') = 1
        OR
        b.booking_details.exist('/Booking/BookingDetails/ItemsNeeded[contains(., sql:variable("@search_term"))]') = 1
    ORDER BY b.booking_date ASC;
END;
GO

-- 6. UpdateBookingStatusAndXML
-- Modifying data in a field of XML data type (Requirement vi)
-- Retrieving data from XML and other data types (Requirement v)
CREATE PROCEDURE UpdateBookingStatusAndXML
    @booking_id INT,
    @new_status VARCHAR(20),
    @update_notes VARCHAR(MAX)
AS
BEGIN
    DECLARE @current_details XML;
    
    -- Get current booking details XML
    SELECT @current_details = booking_details
    FROM Bookings
    WHERE booking_id = @booking_id;
    
    -- Create timestamp
    DECLARE @timestamp VARCHAR(30) = CONVERT(VARCHAR, GETDATE(), 120);
    
    -- Modify the XML directly
    SET @current_details.modify('
        insert <StatusUpdate>
                 <Timestamp>{sql:variable("@timestamp")}</Timestamp>
                 <Notes>{sql:variable("@update_notes")}</Notes>
               </StatusUpdate>
        into (/Booking/BookingDetails)[1]
    ');
    
    -- Update the booking status and XML
    UPDATE Bookings
    SET 
        status = @new_status,
        booking_details = @current_details
    WHERE 
        booking_id = @booking_id;
    
    -- Return updated booking information
    SELECT 
        b.booking_id,
        b.status,
        b.booking_details.value('(/Booking/BookingDetails/SpecialInstructions)[1]', 'VARCHAR(MAX)') AS special_instructions,
        b.booking_details.value('(/Booking/BookingDetails/ItemsNeeded)[1]', 'VARCHAR(MAX)') AS items_needed,
        b.booking_details.value('(/Booking/BookingDetails/EstimatedDuration)[1]', 'INT') AS estimated_duration,
        b.booking_details.query('/Booking/BookingDetails/StatusUpdate') AS status_updates
    FROM 
        Bookings b
    WHERE 
        b.booking_id = @booking_id;
END;
GO

-- 7. GetUserBookingHistory
-- Uses multiple JOINs and ORDER BY
CREATE PROCEDURE GetUserBookingHistory
    @user_id INT
AS
BEGIN
    SELECT 
        b.booking_id,
        sc.name AS service_name,
        p.first_name + ' ' + p.last_name AS provider_name,
        pr.avg_rating AS provider_rating,
        b.booking_date,
        b.time_slot,
        b.status,
        a.address_line + ', ' + a.city + ', ' + a.state + ' ' + a.postal_code AS service_address,
        CASE WHEN pm.payment_id IS NOT NULL THEN pm.amount ELSE NULL END AS payment_amount,
        CASE WHEN pm.payment_id IS NOT NULL THEN pm.status ELSE NULL END AS payment_status,
        CASE WHEN r.rating_id IS NOT NULL THEN r.rating ELSE NULL END AS user_given_rating
    FROM 
        Bookings b
    JOIN 
        Service_Categories sc ON b.category_id = sc.category_id
    JOIN 
        Providers p ON b.provider_id = p.provider_id
    JOIN 
        Provider_Ratings pr ON p.provider_id = pr.provider_id
    JOIN 
        Addresses a ON b.address_id = a.address_id
    LEFT JOIN 
        Payments pm ON b.booking_id = pm.booking_id
    LEFT JOIN 
        Ratings r ON b.booking_id = r.booking_id
    WHERE 
        b.user_id = @user_id
    ORDER BY 
        b.booking_date DESC, b.time_slot ASC;
END;
GO

-- 8. DeleteUserAccountAndData
-- Implements DELETE operations with transaction safety
CREATE PROCEDURE DeleteUserAccountAndData
    @user_id INT,
    @confirmation_code VARCHAR(50)
AS
BEGIN
    -- Safety check to prevent accidental deletions
    IF @confirmation_code <> 'CONFIRM_DELETE_' + CAST(@user_id AS VARCHAR(10))
    BEGIN
        RAISERROR('Invalid confirmation code. Account deletion canceled.', 16, 1);
        RETURN;
    END
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Delete user ratings
        DELETE FROM Ratings
        WHERE user_id = @user_id;
        
        -- Delete payments for user's bookings
        DELETE FROM Payments
        WHERE booking_id IN (SELECT booking_id FROM Bookings WHERE user_id = @user_id);
        
        -- Delete user bookings
        DELETE FROM Bookings
        WHERE user_id = @user_id;
        
        -- Delete user addresses
        DELETE FROM Addresses
        WHERE user_id = @user_id;
        
        -- Finally delete the user account
        DELETE FROM Users
        WHERE user_id = @user_id;
        
        COMMIT TRANSACTION;
        
        SELECT 'User account and all associated data successfully deleted' AS Result;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO