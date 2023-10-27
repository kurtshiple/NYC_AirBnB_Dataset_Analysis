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

-- Complex Queries

-- Query 1: Top 10 hosts with the highest average price for their listings
SELECT host_id, host_name, AVG(price) AS avg_price
FROM nyc_airbnb
GROUP BY host_id, host_name
HAVING COUNT(*) >= 10
ORDER BY avg_price DESC
LIMIT 10;

-- Query 2: Average price by room type for hosts with multiple listings
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

-- Query 3: Listings with a price higher than the neighborhood average
SELECT name, neighbourhood_group, neighbourhood, room_type, price
FROM nyc_airbnb n
WHERE price > (
    SELECT AVG(price)
    FROM nyc_airbnb
    WHERE neighbourhood = n.neighbourhood
)
ORDER BY price DESC;

-- Query 4: Listings with the highest number of reviews in each neighborhood
SELECT name, neighbourhood_group, neighbourhood, room_type, number_of_reviews
FROM nyc_airbnb n
WHERE number_of_reviews = (
    SELECT MAX(number_of_reviews)
    FROM nyc_airbnb
    WHERE neighbourhood = n.neighbourhood
)
ORDER BY neighbourhood;

-- Query 5: Percentage change in minimum nights required for booking between boroughs
SELECT n1.neighbourhood_group AS from_borough, n2.neighbourhood_group AS to_borough,
    AVG(n2.minimum_nights) - AVG(n1.minimum_nights) AS percentage_change
FROM nyc_airbnb n1
JOIN nyc_airbnb n2 ON n1.neighbourhood = n2.neighbourhood
WHERE n1.neighbourhood_group <> n2.neighbourhood_group
GROUP BY n1.neighbourhood_group, n2.neighbourhood_group;