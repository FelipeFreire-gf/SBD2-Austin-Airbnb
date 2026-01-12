CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.one_big_table CASCADE;

CREATE TABLE silver.one_big_table (
    listing_id INTEGER NOT NULL,
    calendar_date DATE NOT NULL,
    review_id INTEGER,
    
    listing_name VARCHAR(500),
    property_type VARCHAR(100),
    room_type VARCHAR(50),
    bed_type VARCHAR(50),
    accommodates INTEGER,
    bathrooms DECIMAL(3,1),
    bedrooms DECIMAL(3,1),
    beds DECIMAL(3,1),
    
    neighbourhood_cleansed VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(50),
    zipcode VARCHAR(20),
    market VARCHAR(100),
    country_code VARCHAR(5),
    country VARCHAR(100),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_location_exact BOOLEAN,
    
    listing_price DECIMAL(10,2),
    security_deposit DECIMAL(10,2),
    cleaning_fee DECIMAL(10,2),
    guests_included INTEGER,
    extra_people DECIMAL(10,2),
    
    minimum_nights INTEGER,
    maximum_nights INTEGER,
    instant_bookable BOOLEAN,
    cancellation_policy VARCHAR(50),
    require_guest_profile_picture BOOLEAN,
    require_guest_phone_verification BOOLEAN,
    
    availability_30 INTEGER,
    availability_60 INTEGER,
    availability_90 INTEGER,
    availability_365 INTEGER,
    
    number_of_reviews INTEGER,
    first_review DATE,
    last_review DATE,
    reviews_per_month DECIMAL(5,2),
    review_scores_rating DECIMAL(4,2),
    review_scores_accuracy DECIMAL(4,2),
    review_scores_cleanliness DECIMAL(4,2),
    review_scores_checkin DECIMAL(4,2),
    review_scores_communication DECIMAL(4,2),
    review_scores_location DECIMAL(4,2),
    review_scores_value DECIMAL(4,2),
    amenities TEXT,
    
    host_id INTEGER,
    host_name VARCHAR(200),
    host_since DATE,
    host_location VARCHAR(200),
    host_response_time VARCHAR(50),
    host_response_rate VARCHAR(10),
    host_acceptance_rate VARCHAR(10),
    host_is_superhost BOOLEAN,
    host_neighbourhood VARCHAR(100),
    host_listings_count INTEGER,
    host_total_listings_count INTEGER,
    host_verifications TEXT,
    host_has_profile_pic BOOLEAN,
    host_identity_verified BOOLEAN,
    calculated_host_listings_count INTEGER,
    
    calendar_available BOOLEAN,
    calendar_price DECIMAL(10,2),
    
    review_date DATE,
    reviewer_id INTEGER,
    reviewer_name VARCHAR(200)
);

