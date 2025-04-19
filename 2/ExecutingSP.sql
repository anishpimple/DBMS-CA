EXEC GetAvailableProvidersForService @category_id = 1;  -- House Cleaning
EXEC GetAvailableProvidersForService @category_id = 3;  -- Electrical
EXEC GetAvailableProvidersForService @category_id = 999;  -- Non-existent category

EXEC CalculateNewAverage @provider_id=1, @new_rating=2;
EXEC UpdateProviderRating @booking_id=1, @provider_id=1, @user_id=1, @rating=2
SELECT * from Ratings;

Drop FUNCTION CalculateNewAverage;
DROP PROCEDURE UpdateProviderRating


EXEC GetTopRatedProvidersByCategory @min_rating=3.6;
DROP PROC GetTopRatedProvidersByCategory;

EXEC CreateBookingWithXML @user_id=1, @provider_id=1, @category_id=3, @address_id=1, @booking_date='2025-05-01', @time_slot='10:00-12:00', @special_instructions="No special instructions", @items_needed="Need coffee", @estimated_duration=3;
Select * from Bookings;
EXEC SearchBookingsByXMLDetails @search_term="coffee";

EXEC UpdateBookingStatusAndXML @booking_id=11, @new_status="Completed", @update_notes="Got Fries";

EXEC GetUserBookingHistory @user_id=9;

EXEC DeleteUserAccountAndData @user_id=4, @confirmation_code="CONFIRM_DELETE_4";
select * from users;