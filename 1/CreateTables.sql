-- Drop tables if they exist
DROP TABLE IF EXISTS Payments, Ratings, Bookings, Addresses, Provider_Categories, Service_Categories, Provider_Ratings, Providers, Users, Payment_Methods;
GO

-- Users Table
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    is_verified BIT DEFAULT 0
);
GO

-- Providers Table
CREATE TABLE Providers (
    provider_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    verification_document VARCHAR(255) NOT NULL,
    experience_years INT NOT NULL,
    is_available BIT DEFAULT 1,
    is_verified BIT DEFAULT 0
);
GO

-- Provider Ratings Table
CREATE TABLE Provider_Ratings (
    provider_id INT PRIMARY KEY,
    avg_rating DECIMAL(3,2) DEFAULT NULL,
    FOREIGN KEY (provider_id) REFERENCES Providers(provider_id) ON DELETE CASCADE
);
GO

-- Service Categories Table
CREATE TABLE Service_Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT NOT NULL
);
GO

-- Provider Categories Table
CREATE TABLE Provider_Categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    provider_id INT NOT NULL,
    category_id INT NOT NULL,
    price_rate DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (provider_id) REFERENCES Providers(provider_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Service_Categories(category_id) ON DELETE CASCADE
);
GO

-- Addresses Table
CREATE TABLE Addresses (
    address_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
GO

-- Bookings Table
CREATE TABLE Bookings (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    provider_id INT NOT NULL,
    category_id INT NOT NULL,
    address_id INT NULL,  -- Nullable to prevent cascade conflicts
    booking_date DATE NOT NULL,
    time_slot VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE NO ACTION,
    FOREIGN KEY (provider_id) REFERENCES Providers(provider_id) ON DELETE NO ACTION,
    FOREIGN KEY (category_id) REFERENCES Service_Categories(category_id) ON DELETE NO ACTION,
    FOREIGN KEY (address_id) REFERENCES Addresses(address_id) ON DELETE SET NULL
);
GO

-- Ratings Table
CREATE TABLE Ratings (
    rating_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT UNIQUE NOT NULL,
    provider_id INT NOT NULL,
    user_id INT NOT NULL,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES Providers(provider_id) ON DELETE NO ACTION,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE NO ACTION
);
GO

-- Payment Methods Table
CREATE TABLE Payment_Methods (
    payment_method_id INT IDENTITY(1,1) PRIMARY KEY,
    method_name VARCHAR(50) UNIQUE NOT NULL
);
GO

-- Payments Table
CREATE TABLE Payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method_id INT NOT NULL,
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES Payment_Methods(payment_method_id) ON DELETE NO ACTION
);
GO
