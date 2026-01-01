SHOW DATABASES;
USE ola_analysis;

SELECT * FROM Bookings;      -- Basic overview of table

-- 1. Compare booking volume,success and revenue across vehicle types.
SELECT
    Vehicle_Type,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN Booking_Status = 'Success' THEN 1 ELSE 0 END) AS successful_rides,
    ROUND(AVG(Booking_Value), 2) AS avg_booking_value
FROM bookings
GROUP BY Vehicle_Type; 

-- 2. Identify the most common reasons for incomplete rides.
SELECT
    Incomplete_Ride_Reason,
    COUNT(*) AS total_cases
FROM bookings
WHERE Incomplete_Ride = 'Yes'
GROUP BY Incomplete_Ride_Reason
ORDER BY total_cases DESC;

-- 3. Driver Rating Distribution by Vehicle Type.
SELECT
    Vehicle_Type,
    ROUND(AVG(Driver_Rating), 2) AS avg_driver_rating,
    MIN(Driver_Rating) AS min_rating,
    MAX(Driver_Rating) AS max_rating
FROM bookings
GROUP BY Vehicle_Type;

-- 4. Routes that are most profitable per kilometer.
SELECT
    Pickup_Location,
    Drop_Location,
    ROUND(SUM(Booking_Value) / SUM(`Ride_Distance (Km)`), 2) AS revenue_per_km
FROM bookings
WHERE `Ride_Distance (Km)` > 0
GROUP BY Pickup_Location, Drop_Location
ORDER BY revenue_per_km DESC; 
select * from bookings;

-- 5. Which payment method contributes the most revenue?
SELECT
    Payment_Method,
    SUM(Booking_Value) AS total_revenue
FROM bookings
GROUP BY Payment_Method
ORDER BY total_revenue DESC;

-- 6. Calculate the overall ride completion rate for the month.
SELECT
ROUND(SUM(CASE
WHEN Booking_Status = 'Success' THEN 1 
ELSE 0 
END) * 100.0 / COUNT(*),2) AS completion_rate_percentage
FROM bookings;

-- 7. Top 5 pickup locations by number of bookings.
SELECT
    Pickup_Location,
    COUNT(*) AS total_bookings
FROM bookings
GROUP BY Pickup_Location
ORDER BY total_bookings DESC
LIMIT 5;

-- 8. Top 5 Customers with multiple bookings.
SELECT
    Customer_ID,
    COUNT(*) AS total_bookings
FROM bookings
GROUP BY Customer_ID
HAVING total_bookings > 1
LIMIT 5;

-- 9. Calculate percentage of failed rides.
SELECT
    ROUND(
        SUM(CASE WHEN Booking_Status <> 'Success' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS failed_ride_percentage
FROM bookings; 

-- 10. Average sustomer rating per pickup location.
SELECT
    Pickup_Location,
    ROUND(AVG(Customer_Rating), 2) AS avg_rating
FROM bookings
GROUP BY Pickup_Location;

-- 11. Identify expensive trips with poor customer feedback.
SELECT
    Booking_ID,
    Booking_Value,
    Customer_Rating
FROM bookings
WHERE Booking_Value > 800
  AND Customer_Rating < 3;

-- 12. Identify vehicle categories contributing to maximum revenue loss.
WITH vehicle_revenue AS (
    SELECT
        Vehicle_Type,
        SUM(CASE WHEN Booking_Status = 'Success' THEN Booking_Value ELSE 0 END) AS successful_revenue,
        SUM(CASE WHEN Booking_Status <> 'Success' THEN Booking_Value ELSE 0 END) AS lost_revenue
    FROM bookings
    GROUP BY Vehicle_Type
)
SELECT
    Vehicle_Type,
    successful_revenue,
    lost_revenue,
    ROUND(
        lost_revenue * 100.0 / (successful_revenue + lost_revenue),
        2
    ) AS revenue_loss_percentage
FROM vehicle_revenue
ORDER BY revenue_loss_percentage DESC;