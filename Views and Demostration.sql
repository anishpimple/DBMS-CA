-- View 1: ProviderServiceDetails
-- Shows providers with their services and ratings
CREATE VIEW ProviderServiceDetails (ProviderId, ProviderName, Experience, Available, Verified, 
                                  ServiceId, ServiceName, Description, Price, Rating)
AS
    SELECT p.provider_id,
           p.first_name + ' ' + p.last_name,
           p.experience_years,
           p.is_available,
           p.is_verified,
           sc.category_id,
           sc.name,
           sc.description,
           pc.price_rate,
           pr.avg_rating
    FROM Providers p
    INNER JOIN Provider_Categories pc
        ON p.provider_id = pc.provider_id
    INNER JOIN Service_Categories sc
        ON pc.category_id = sc.category_id
    INNER JOIN Provider_Ratings pr
        ON p.provider_id = pr.provider_id
    WHERE p.is_verified = 1
GO

-- Test query for View 1
SELECT ProviderName, Experience, ServiceName, Price, Rating
FROM ProviderServiceDetails
WHERE Available = 1
ORDER BY Rating DESC
GO

-- View 2: ServiceBookingSummary
-- Aggregates booking data by service category with GROUP BY
CREATE VIEW ServiceBookingSummary (CategoryId, ServiceName, TotalBookings, 
                                  ConfirmedBookings, Revenue, AvgPrice, AvgRating)
AS
    SELECT sc.category_id,
           sc.name,
           COUNT(b.booking_id),
           SUM(CASE WHEN b.status = 'Confirmed' THEN 1 ELSE 0 END),
           SUM(p.amount),
           AVG(p.amount),
           AVG(CAST(r.rating AS DECIMAL(3,2)))
    FROM Service_Categories sc
    LEFT JOIN Bookings b
        ON sc.category_id = b.category_id
    LEFT JOIN Payments p
        ON b.booking_id = p.booking_id
    LEFT JOIN Ratings r
        ON b.booking_id = r.booking_id
    GROUP BY sc.category_id, sc.name
GO

-- Test query for View 2
SELECT ServiceName, TotalBookings, ConfirmedBookings, Revenue
FROM ServiceBookingSummary
WHERE TotalBookings > 0
ORDER BY Revenue DESC
GO

-- Test queries to demonstrate the views:

-- 1. Query ProviderServicesView to find all electricians with ratings above 4.0
SELECT 
    ProviderName, 
    Experience, 
    ServiceName, 
    Price, 
    Rating
FROM 
    ProviderServiceDetails
WHERE 
    ServiceName = 'Electrical'
    AND Rating >= 4.0
    AND Available = 1
ORDER BY 
    Rating DESC;
GO

-- 2. Query ServiceBookingAnalytics to find most profitable service categories
SELECT 
    ServiceName, 
    TotalBookings, 
    ConfirmedBookings, 
    Revenue, 
    AvgRating
FROM 
    ServiceBookingSummary
WHERE 
    TotalBookings > 0
ORDER BY 
    Revenue DESC;
GO