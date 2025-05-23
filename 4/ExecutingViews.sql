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
    ServiceName = 'Plumbing'
    AND Rating >= 3.0
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
    ConfirmedBookings > 1
ORDER BY 
    Revenue DESC;
	GO
	-- Demonstration 2 for view2
	SELECT ProviderName, ServiceName, Rating FROM ProviderServiceDetails 
	WHERE Available = 1 ORDER BY Rating DESC;

	-- Test ServiceBookingSummary view
	SELECT ServiceName, TotalBookings, Revenue FROM ServiceBookingSummary 
	ORDER BY Revenue DESC;
	GO