-- Import NYC Airbnb dataset from CSV

-- Create a table to store the data
CREATE TABLE nyc_airbnb (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    host_id INT,
    host_name VARCHAR(255),
    neighbourhood_group VARCHAR(255),
    neighbourhood VARCHAR(255),
    latitude DECIMAL(8, 6),
    longitude DECIMAL(9, 6),
    room_type VARCHAR(255),
    price DECIMAL(10, 2),
    minimum_nights INT,
    number_of_reviews INT,
    last_review DATE,
    reviews_per_month DECIMAL(5, 2),
    calculated_host_listings_count INT,
    availability_365 INT
);

-- Copy data from CSV into the table
COPY nyc_airbnb
FROM 'data/NYC_air_bnb_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Complex SQL Queries

-- Query 1: Top 10 listings with the highest prices
SELECT name, neighbourhood_group, neighbourhood, room_type, price
FROM nyc_airbnb
ORDER BY price DESC
LIMIT 10;

-- Query 2: Average price for each neighborhood within the Manhattan borough
SELECT neighbourhood, AVG(price) AS avg_price
FROM nyc_airbnb
WHERE neighbourhood_group = 'Manhattan'
GROUP BY neighbourhood
ORDER BY avg_price DESC;

-- Query 3: Count of listings in each borough
SELECT neighbourhood_group, COUNT(*) AS listing_count
FROM nyc_airbnb
GROUP BY neighbourhood_group;

-- Query 4: Number of listings in each neighborhood with more than 50 reviews
SELECT neighbourhood, COUNT(*) AS listing_count
FROM nyc_airbnb
WHERE number_of_reviews > 50
GROUP BY neighbourhood
ORDER BY listing_count DESC;

-- Query 5: List of hosts with multiple listings and their counts
SELECT host_id, host_name, COUNT(*) AS listing_count
FROM nyc_airbnb
GROUP BY host_id, host_name
HAVING COUNT(*) > 1
ORDER BY listing_count DESC;

-- Query 6: The number of unique room types in each neighborhood
SELECT neighbourhood, COUNT(DISTINCT room_type) AS unique_room_types
FROM nyc_airbnb
GROUP BY neighbourhood;

-- Query 7: Average minimum nights required for booking in each neighborhood group
SELECT neighbourhood_group, AVG(minimum_nights) AS avg_min_nights
FROM nyc_airbnb
GROUP BY neighbourhood_group;

-- Query 8: List of neighborhoods with no Airbnb listings
SELECT DISTINCT neighbourhood_group, neighbourhood
FROM nyc_airbnb
WHERE neighbourhood NOT IN (
    SELECT DISTINCT neighbourhood
    FROM nyc_airbnb
);

-- Query 9: List of hosts with the most reviews
SELECT host_id, host_name, SUM(number_of_reviews) AS total_reviews
FROM nyc_airbnb
GROUP BY host_id, host_name
ORDER BY total_reviews DESC
LIMIT 10;

-- Query 10: Percentage of available listings for each room type in each borough
SELECT neighbourhood_group, room_type,
    COUNT(*) AS total_listings,
    AVG(availability_365) AS avg_availability,
    (COUNT(*) - AVG(availability_365)) / COUNT(*) * 100 AS percentage_available
FROM nyc_airbnb
GROUP BY neighbourhood_group, room_type;

-- Complex Queries

-- Query 11: Top 10 hosts with the highest average price for their listings
SELECT host_id, host_name, AVG(price) AS avg_price
FROM nyc_airbnb
GROUP BY host_id, host_name
HAVING COUNT(*) >= 10
ORDER BY avg_price DESC
LIMIT 10;

-- Query 12: Average price by room type for hosts with multiple listings
SELECT host_id, host_name, room_type, AVG(price) AS avg_price
FROM nyc_airbnb
WHERE host_id IN (
    SELECT host_id
    FROM nyc_airbnb
    GROUP BY host_id
    HAVING COUNT(*) > 1
)
GROUP BY host_id, host_name, room_type
ORDER BY host_id, room_type;

-- Query 13: Listings with a price higher than the neighborhood average
SELECT name, neighbourhood_group, neighbourhood, room_type, price
FROM nyc_airbnb n
WHERE price > (
    SELECT AVG(price)
    FROM nyc_airbnb
    WHERE neighbourhood = n.neighbourhood
)
ORDER BY price DESC;

-- Query 14: Listings with the highest number of reviews in each neighborhood
SELECT name, neighbourhood_group, neighbourhood, room_type, number_of_reviews
FROM nyc_airbnb n
WHERE number_of_reviews = (
    SELECT MAX(number_of_reviews)
    FROM nyc_airbnb
    WHERE neighbourhood = n.neighbourhood
)
ORDER BY neighbourhood;

-- Query 15: Percentage change in minimum nights required for booking between boroughs
SELECT n1.neighbourhood_group AS from_borough, n2.neighbourhood_group AS to_borough,
    AVG(n2.minimum_nights) - AVG(n1.minimum_nights) AS percentage_change
FROM nyc_airbnb n1
JOIN nyc_airbnb n2 ON n1.neighbourhood = n2.neighbourhood
WHERE n1.neighbourhood_group <> n2.neighbourhood_group
GROUP BY n1.neighbourhood_group, n2.neighbourhood_group;