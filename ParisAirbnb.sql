
-- 1. Retrieve all listings with property type "Entire rental unit". 
-- 80,516 listings
SELECT *
FROM paris_airbnb
WHERE property_type = 'Entire rental unit';

-- 2. How many people, on average, room type of "Entire home/apt" accommodates?
-- Three people on average. 
SELECT AVG(accommodates) AS "Avg Number of People to Accommodate"
FROM paris_airbnb
WHERE room_type = 'Entire home/apt';

-- 3. Identify hosts with more than one listing in the current file, sort descending.  
-- 5,666 hosts are identified. 
SELECT host_id, COUNT(id) AS Listings_Count
FROM paris_airbnb
GROUP BY host_id
HAVING COUNT(id) > 1
ORDER BY Listings_Count DESC; 

-- 4. Find listings in the "Entire condo" property type with the highest number of bedrooms. 
-- The highest number of bedrooms for an entire condo is 6. 
SELECT TOP 1 (id), property_type, bedrooms
FROM paris_airbnb 
WHERE property_type = 'Entire condo'
ORDER BY bedrooms DESC;

-- 5. Determine how many hosts started between 2008 and 2010.
-- Between 2008 and 2010, 592 hosts started. 
SELECT COUNT(host_id) AS Hosts_2008_2010
FROM paris_airbnb
WHERE host_since between '2008-01-01' and '2010-12-31';

-- 6. Identify hosts with a variety of property types (more than one type) using a Common Table Expression; order results descending. 
-- The highest number of property types is 6 (out of 70 types available). 
WITH Property_Type_Variety AS 
(SELECT host_id, COUNT(DISTINCT(property_type)) AS Type_Count
FROM paris_airbnb
GROUP BY host_id
HAVING COUNT(DISTINCT(property_type)) > 1)
SELECT host_id, Type_Count
FROM Property_Type_Variety
ORDER BY Type_Count DESC;
-- Check all property types available. 
SELECT DISTINCT(property_type)
FROM paris_airbnb;

-- 7.  Find the average score for value for property types "Entire rental unit" and "Private room in rental unit"; use a CTE to find the average scores.
WITH New_Table AS
(
SELECT property_type, AVG(review_scores_value) AS Avg_Value_Score_Select_Type
FROM paris_airbnb
GROUP BY property_type
HAVING property_type IN('Entire rental unit', 'Private room in rental unit')
)
SELECT property_type, Avg_Value_Score_Select_Type
FROM New_table;

-- 8. List average value scores for each property type and its comparison to the overall average 4.6; mark comparison as "Lower/Equal" or "Higher"
SELECT property_type, AVG(review_scores_value) AS Ind_Type_Average,
CASE 
	WHEN AVG(review_scores_value) <= 4.6 THEN 'Lower/Equal'
	WHEN AVG(review_scores_value) > 4.6 THEN 'Higher'
END AS Comparison_to_All_Average_Value_Score
FROM paris_airbnb
GROUP BY property_type
ORDER BY Ind_Type_Average DESC;

-- 9. Determine the Best Value for each property type:
-- Firstly, what is min and max of price? 
SELECT property_type, MIN(price) AS Min_Price, MAX(price) AS Max_Price
FROM paris_airbnb
GROUP BY property_type; 
-- What are distinct price points categories? 
SELECT price, COUNT(DISTINCT(price)) AS Count_Price_Points
FROM paris_airbnb
GROUP BY price
ORDER By price DESC;
-- -Use a CTE to calculate a value score for each property type based on the number of bedrooms, bathrooms, and price range. Then, identify the host id with the highest value score. 
WITH New_Table AS
(
SELECT id, host_id, property_type, bathrooms, bedrooms, (bathrooms + bedrooms) / 
	CASE
		WHEN price between '10.00' and '99.00' THEN 10
		WHEN price between '100.00' and '249.00' THEN 20
		WHEN price between '250.00' and '499.00' THEN 30
		WHEN price >= '500.00' THEN 40
	END AS listing_rel_value
FROM paris_airbnb
)
SELECT TOP 1 (host_id), MAX(listing_rel_value) AS Top_Rel_Value_Score
FROM New_Table
GROUP BY host_id
ORDER BY Top_Rel_Value_Score DESC;

-- 10. Retrieve entries with the word "balcony" from the "name" field; sort by price. 
SELECT id, property_type, price, name
FROM paris_airbnb
WHERE name LIKE '%balcony%'
ORDER BY price DESC; 

-- 11.  Check if there are hosts who never had a review posted.
SELECT COUNT(host_id) AS No_reviews
FROM paris_airbnb
WHERE number_of_reviews = '0';

-- 12. Count the number of last reviews for 2024 (Jan - Jul) by host. 
SELECT host_id, COUNT(last_review) AS Reviews_2020
FROM paris_airbnb
WHERE last_review BETWEEN '2024-01-01' AND '2024-07-31'
GROUP BY host_id
ORDER BY Reviews_2020 DESC;

-- 13. Find the host with the highest value of reviews per month. 
SELECT TOP 1 host_id, AVG(reviews_per_month) AS Highest_Reviews_Month
FROM paris_airbnb
GROUP BY host_id
ORDER BY Highest_Reviews_Month DESC;

-- 14. Identify percentage of listings with the property_type "cave".
SELECT (COUNT(property_type) * 100.0 / (SELECT COUNT(*) FROM paris_airbnb)) AS Percentage_Cave
FROM paris_airbnb
WHERE property_type = 'Cave'

-- 15. Retrieve hosts who received over 100 reviews and have average rating of over 4.5.
WITH New_Table AS
(
	SELECT host_id, SUM(number_of_reviews) AS Reviews_Count, AVG(review_scores_rating) AS Avg_Host_Rating
		FROM paris_airbnb
		GROUP BY host_id
)
SELECT host_id, Reviews_Count, Avg_Host_Rating
FROM New_Table
WHERE Reviews_Count > 100 AND Avg_Host_Rating > 4.5
ORDER BY Avg_Host_Rating DESC;

-- 16. Do super hosts communicate better than hosts? Find the averages for communication ratings.  
SELECT host_is_superhost, AVG(review_scores_communication) AS Group_AVG_Comm
FROM paris_airbnb
GROUP BY host_is_superhost; 

