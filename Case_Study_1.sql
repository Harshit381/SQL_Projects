CREATE TABLE booking_table(
	Booking_id VARCHAR(3) NOT NULL,
	Booking_date date NOT NULL,
	User_id VARCHAR(2) NOT NULL,
	Line_of_business VARCHAR(6) NOT NULL);

INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b1','2022-03-23','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b2','2022-03-27','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b3','2022-03-28','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b4','2022-03-31','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b5','2022-04-02','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b6','2022-04-02','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b7','2022-04-06','u5','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b8','2022-04-06','u6','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b9','2022-04-06','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b10','2022-04-10','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b11','2022-04-12','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b12','2022-04-16','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b13','2022-04-19','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b14','2022-04-20','u5','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b15','2022-04-22','u6','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b16','2022-04-26','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b17','2022-04-28','u2','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b18','2022-04-30','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b19','2022-05-04','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b20','2022-05-06','u1','Flight');

CREATE TABLE user_table(
   User_id VARCHAR(3) NOT NULL,
   Segment VARCHAR(2) NOT NULL);

INSERT INTO user_table(User_id,Segment) VALUES ('u1','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u2','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u3','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u4','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u5','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u6','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u7','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u8','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u9','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u10','s3');



--Total distinct user count in April and total flights bookings in April 

SELECT u.Segment, COUNT(DISTINCT u.User_id) AS total_user_count,
COUNT(DISTINCT case WHEN Line_of_business='Flight' AND DATEPART(month,booking_date)=4 then u.User_id end) AS bookings_in_april
FROM  user_table u LEFT JOIN booking_table b ON u.User_id = b.User_id
GROUP BY u.Segment

--write a query to identify users whose first booking was a hotel booking

WITH cte AS (
SELECT user_id, booking_date , line_of_business, ROW_NUMBER() over (partition BY user_id ORDER BY booking_date) AS rn  
FROM booking_table
) 
SELECT user_id FROM cte WHERE rn= 1 AND line_of_business = 'Hotel'

-- Write a query to write the date difference between the first and last booking for each user

SELECT user_id, datediff(DAY,min(Booking_date),Max(booking_date)) AS date_diff 
FROM booking_table
GROUP BY User_id


--write a query to count the number of flight and hotel bookings for each of the user segments for the year 2022


SELECT Segment, COUNT(CASE WHEN Line_of_business = 'hotel' THEN 1 END ) AS no_of_flight_booking
, COUNT(CASE WHEN Line_of_business = 'Flight' THEN 1 END ) AS no_of_flight_booking
FROM user_table u LEFT JOIN booking_table b ON u.User_id =b.User_id 
GROUP BY Segment
