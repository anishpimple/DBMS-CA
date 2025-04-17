-- Users table
INSERT INTO Users (first_name, last_name, email, phone, password, is_verified)
VALUES 
    ('John', 'Doe', 'john.doe@email.com', '123-456-7890', 'hashed_password_1', 1),
    ('Jane', 'Smith', 'jane.smith@email.com', '123-456-7891', 'hashed_password_2', 1),
    ('Michael', 'Johnson', 'michael.johnson@email.com', '123-456-7892', 'hashed_password_3', 1),
    ('Emily', 'Williams', 'emily.williams@email.com', '123-456-7893', 'hashed_password_4', 0),
    ('Robert', 'Brown', 'robert.brown@email.com', '123-456-7894', 'hashed_password_5', 1),
    ('Sarah', 'Jones', 'sarah.jones@email.com', '123-456-7895', 'hashed_password_6', 1),
    ('David', 'Miller', 'david.miller@email.com', '123-456-7896', 'hashed_password_7', 0),
    ('Jennifer', 'Davis', 'jennifer.davis@email.com', '123-456-7897', 'hashed_password_8', 1),
    ('James', 'Garcia', 'james.garcia@email.com', '123-456-7898', 'hashed_password_9', 1),
    ('Lisa', 'Rodriguez', 'lisa.rodriguez@email.com', '123-456-7899', 'hashed_password_10', 0);

-- Providers table
INSERT INTO Providers (first_name, last_name, email, phone, password, verification_document, experience_years, is_available, is_verified)
VALUES 
    ('Thomas', 'Wilson', 'thomas.wilson@email.com', '987-654-3210', 'provider_pass_1', 'doc_path_1.pdf', 5, 1, 1),
    ('Emma', 'Martinez', 'emma.martinez@email.com', '987-654-3211', 'provider_pass_2', 'doc_path_2.pdf', 3, 1, 1),
    ('Alexander', 'Anderson', 'alexander.anderson@email.com', '987-654-3212', 'provider_pass_3', 'doc_path_3.pdf', 7, 1, 1),
    ('Olivia', 'Taylor', 'olivia.taylor@email.com', '987-654-3213', 'provider_pass_4', 'doc_path_4.pdf', 2, 0, 1),
    ('William', 'Thomas', 'william.thomas@email.com', '987-654-3214', 'provider_pass_5', 'doc_path_5.pdf', 6, 1, 0),
    ('Sophia', 'Hernandez', 'sophia.hernandez@email.com', '987-654-3215', 'provider_pass_6', 'doc_path_6.pdf', 4, 1, 1),
    ('Benjamin', 'Moore', 'benjamin.moore@email.com', '987-654-3216', 'provider_pass_7', 'doc_path_7.pdf', 8, 0, 1),
    ('Ava', 'Martin', 'ava.martin@email.com', '987-654-3217', 'provider_pass_8', 'doc_path_8.pdf', 3, 1, 1),
    ('Ethan', 'Jackson', 'ethan.jackson@email.com', '987-654-3218', 'provider_pass_9', 'doc_path_9.pdf', 5, 1, 0),
    ('Isabella', 'Thompson', 'isabella.thompson@email.com', '987-654-3219', 'provider_pass_10', 'doc_path_10.pdf', 4, 1, 1);

-- Provider_Ratings table
INSERT INTO Provider_Ratings (provider_id, avg_rating)
VALUES 
    (1, 4.75),
    (2, 4.20),
    (3, 4.90),
    (4, 3.85),
    (5, 4.30),
    (6, 4.50),
    (7, 4.80),
    (8, 4.15),
    (9, 3.95),
    (10, 4.60);

-- Service_Categories table
INSERT INTO Service_Categories (name, description)
VALUES 
    ('House Cleaning', 'General house cleaning services including dusting, vacuuming, and surface cleaning.'),
    ('Plumbing', 'Installation and repair of pipes, fixtures, and appliances related to water distribution.'),
    ('Electrical', 'Installation, maintenance, and repair of electrical systems and components.'),
    ('Gardening', 'Lawn maintenance, plant care, and landscape design services.'),
    ('Painting', 'Interior and exterior painting services for residential and commercial properties.'),
    ('Carpentry', 'Woodworking, furniture building, and structural repair services.'),
    ('Tutoring', 'Academic assistance and educational support across various subjects.'),
    ('Personal Training', 'Customized fitness programs and physical training services.'),
    ('Pet Care', 'Pet sitting, dog walking, and basic animal care services.'),
    ('Tech Support', 'Technical assistance with computers, networks, and electronic devices.');

-- Provider_Categories table
INSERT INTO Provider_Categories (provider_id, category_id, price_rate)
VALUES 
    (1, 1, 25.50),  -- Thomas Wilson offers House Cleaning
    (1, 4, 30.00),  -- Thomas Wilson also offers Gardening
    (2, 2, 45.75),  -- Emma Martinez offers Plumbing
    (3, 3, 50.00),  -- Alexander Anderson offers Electrical
    (4, 5, 35.25),  -- Olivia Taylor offers Painting
    (5, 6, 40.50),  -- William Thomas offers Carpentry
    (6, 7, 28.00),  -- Sophia Hernandez offers Tutoring
    (7, 8, 35.00),  -- Benjamin Moore offers Personal Training
    (8, 9, 20.75),  -- Ava Martin offers Pet Care
    (9, 10, 45.00); -- Ethan Jackson offers Tech Support

-- Addresses table
INSERT INTO Addresses (user_id, address_line, city, state, postal_code)
VALUES 
    (1, '123 Main St', 'Seattle', 'Washington', '98101'),
    (2, '456 Pine Ave', 'Portland', 'Oregon', '97201'),
    (3, '789 Oak Blvd', 'San Francisco', 'California', '94101'),
    (4, '321 Cedar Dr', 'Los Angeles', 'California', '90001'),
    (5, '654 Elm St', 'Chicago', 'Illinois', '60601'),
    (6, '987 Maple Rd', 'New York', 'New York', '10001'),
    (7, '135 Birch Ln', 'Boston', 'Massachusetts', '02108'),
    (8, '246 Spruce Way', 'Miami', 'Florida', '33101'),
    (9, '789 Willow Ave', 'Denver', 'Colorado', '80201'),
    (10, '975 Cherry St', 'Austin', 'Texas', '73301');

-- Bookings table (first creating 10 standard bookings)
INSERT INTO Bookings (user_id, provider_id, category_id, address_id, booking_date, time_slot, status)
VALUES 
    (1, 1, 1, 1, '2025-05-01', '10:00-12:00', 'Confirmed'),
    (2, 2, 2, 2, '2025-05-02', '14:00-16:00', 'Pending'),
    (3, 3, 3, 3, '2025-05-03', '09:00-11:00', 'Confirmed'),
    (4, 4, 5, 4, '2025-05-04', '13:00-15:00', 'Confirmed'),
    (5, 5, 6, 5, '2025-05-05', '11:00-13:00', 'Cancelled'),
    (6, 6, 7, 6, '2025-05-06', '16:00-18:00', 'Confirmed'),
    (7, 7, 8, 7, '2025-05-07', '07:00-08:00', 'Pending'),
    (8, 8, 9, 8, '2025-05-08', '17:00-18:00', 'Confirmed'),
    (9, 9, 10, 9, '2025-05-09', '15:00-17:00', 'Pending'),
    (10, 1, 4, 10, '2025-05-10', '10:00-12:00', 'Confirmed');

-- Payment_Methods table
INSERT INTO Payment_Methods (method_name)
VALUES 
    ('Credit Card'),
    ('Debit Card'),
    ('PayPal'),
    ('Venmo'),
    ('Cash'),
    ('Bank Transfer'),
    ('Apple Pay'),
    ('Google Pay'),
    ('Cryptocurrency'),
    ('Check');

-- Ratings table
INSERT INTO Ratings (booking_id, provider_id, user_id, rating)
VALUES 
    (1, 1, 1, 5),
    (3, 3, 3, 5),
    (4, 4, 4, 4),
    (5, 5, 5, 3),
    (6, 6, 6, 5),
    (8, 8, 8, 4),
    (10, 1, 10, 5),
    -- Adding 3 more ratings requires 3 more bookings first
    -- Let's assume these are additional completed bookings in the past:
    (2, 2, 2, 4),
    (7, 7, 7, 3),
    (9, 9, 9, 4);

-- Payments table
INSERT INTO Payments (booking_id, amount, payment_method_id, transaction_id, status)
VALUES 
    (1, 51.00, 1, 'TXN123456789', 'Completed'),
    (2, 91.50, 2, 'TXN123456790', 'Pending'),
    (3, 100.00, 3, 'TXN123456791', 'Completed'),
    (4, 70.50, 1, 'TXN123456792', 'Completed'),
    (5, 81.00, 2, 'TXN123456793', 'Refunded'),
    (6, 56.00, 4, 'TXN123456794', 'Completed'),
    (7, 35.00, 5, 'TXN123456795', 'Pending'),
    (8, 20.75, 1, 'TXN123456796', 'Completed'),
    (9, 90.00, 3, 'TXN123456797', 'Pending'),
    (10, 60.00, 2, 'TXN123456798', 'Completed');
