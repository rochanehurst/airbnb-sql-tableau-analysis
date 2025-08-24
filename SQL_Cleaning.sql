
-- Cleaning Data --


DROP TABLE IF EXISTS airbnb_stage; 
CREATE TABLE `airbnb_stage` (
  `id` varchar(20) DEFAULT NULL,
  `name` text,
  `host_id` varchar(20) DEFAULT NULL,
  `host_name` text,
  `host_since` varchar(32) DEFAULT NULL,
  `host_verifications` text,
  `street` text,
  `neighbourhood` text,
  `city` text,
  `state` text,
  `zipcode` text,
  `market` text,
  `country_code` text,
  `country` text,
  `property_type` text,
  `room_type` text,
  `bedrooms` varchar(16) DEFAULT NULL,
  `bathrooms` varchar(16) DEFAULT NULL,
  `beds` varchar(16) DEFAULT NULL,
  `price` varchar(32) DEFAULT NULL,
  `number_of_reviews` varchar(16) DEFAULT NULL,
  `review_scores_rating` varchar(16) DEFAULT NULL,
  `review_scores_value` varchar(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- populate the empty table
INSERT INTO airbnb_stage
SELECT *
FROM airbnb_stage_text;



-- 1. Remove Duplicates


SELECT *
FROM airbnb_stage;


SELECT *,
ROW_NUMBER() OVER (PARTITION BY
id, 
name, 
host_id, 
host_name, 
host_since, 
street, 
neighbourhood, 
city, state, 
zipcode, 
country_code, 
country, 
property_type, 
room_type, 
bedrooms, 
bathrooms, 
beds, 
price, 
number_of_reviews, 
review_scores_rating, 
review_scores_value) as row_num
FROM airbnb_stage;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY
id, 
name, 
host_id, 
host_name, 
host_since, 
street, 
neighbourhood, 
city, state, 
zipcode, 
country_code, 
country, 
property_type, 
room_type, 
bedrooms, 
bathrooms, 
beds, 
price, 
number_of_reviews, 
review_scores_rating, 
review_scores_value) as row_num
FROM airbnb_stage
)
SELECT *
from duplicate_cte
WHERE row_num > 1;


SELECT *
FROM airbnb_stage
WHERE id = '12512133';

SELECT *
FROM airbnb_stage
where id = '2832508';

DROP TABLE IF EXISTS airbnb_stage2;
CREATE TABLE `airbnb_stage2` (
  `id` varchar(20) DEFAULT NULL,
  `name` text,
  `host_id` varchar(20) DEFAULT NULL,
  `host_name` text,
  `host_since` varchar(32) DEFAULT NULL,
  `street` text,
  `neighbourhood` text,
  `city` text,
  `state` text,
  `zipcode` text,
  `country_code` text,
  `country` text,
  `property_type` text,
  `room_type` text,
  `bedrooms` varchar(16) DEFAULT NULL,
  `bathrooms` varchar(16) DEFAULT NULL,
  `beds` varchar(16) DEFAULT NULL,
  `price` varchar(32) DEFAULT NULL,
  `number_of_reviews` varchar(16) DEFAULT NULL,
  `review_scores_rating` varchar(16) DEFAULT NULL,
  `review_scores_value` varchar(16) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM airbnb_stage2;



INSERT INTO airbnb_stage2
SELECT *,
ROW_NUMBER() OVER (PARTITION BY
id, 
name, 
host_id, 
host_name, 
host_since, 
street, 
neighbourhood, 
city, state, 
zipcode, 
country_code, 
country, 
property_type, 
room_type, 
bedrooms, 
bathrooms, 
beds, 
price, 
number_of_reviews, 
review_scores_rating, 
review_scores_value) as row_num
FROM airbnb_stage;


DELETE 
FROM airbnb_stage2
WHERE row_num > 1;

SELECT *
FROM airbnb_stage2
WHERE row_num > 1;


SELECT COUNT(*) FROM airbnb_stage;
SELECT COUNT(*) FROM airbnb_stage2;

SELECT * FROM airbnb_stage2 WHERE id = '2832508';





-- 2. Standardizing Data

-- Trim whitespace and turn '' into NULLs 
UPDATE airbnb_stage2
SET 
	name = NULLIF(TRIM(name), ''),
    host_name = NULLIF(TRIM(host_name), ''),
    street = NULLIF(TRIM(street), ''),
    neighbourhood = NULLIF(TRIM(neighbourhood), ''),
    city = NULLIF(TRIM(city), ''),
    state = NULLIF(TRIM(state), ''),
    zipcode = NULLIF(TRIM(zipcode), ''),
    country_code = NULLIF(TRIM(country_code), ''),
    country = NULLIF(TRIM(country), ''),
    property_type = NULLIF(TRIM(property_type), ''),
    room_type = NULLIF(TRIM(room_type), '');

-- Check for insonsistencies

SELECT *
FROM airbnb_stage2
WHERE country = 'United States';

-- Creating Table for US only


DROP TABLE IF EXISTS airbnb_us
CREATE TABLE airbnb_us AS
SELECT *
FROM airbnb_stage2
WHERE country = 'United States';


-- Using Fuzzy Match to clean city names

DROP PROCEDURE IF EXISTS fuzzy_city;
DELIMITER $$
CREATE PROCEDURE fuzzy_city ()
BEGIN
	SELECT 
		SOUNDEX(state) AS state_soundex,
		SOUNDEX(city) AS city_soundex,
		count(*) AS total,
		GROUP_CONCAT(DISTINCT state ORDER BY state SEPARATOR ', ') AS state_variations,
		GROUP_CONCAT(DISTINCT city ORDER BY city SEPARATOR ', ') AS city_variations
	FROM airbnb_us
	GROUP BY SOUNDEX(state), SOUNDEX(city)
	ORDER BY state_variations, city_variations, total DESC;
END$$
DELIMITER ;

-- State dependend

DROP PROCEDURE IF EXISTS fuzzy_city_state;
DELIMITER $$
CREATE PROCEDURE fuzzy_city_state (IN in_state VARCHAR(10))
BEGIN
	SELECT 
		SOUNDEX(state) AS state_soundex,
		SOUNDEX(city) AS city_soundex,
		count(*) AS total,
		GROUP_CONCAT(DISTINCT state ORDER BY state SEPARATOR ', ') AS state_variations,
		GROUP_CONCAT(DISTINCT city ORDER BY city SEPARATOR ', ') AS city_variations
	FROM airbnb_us
	WHERE state = in_state
	GROUP BY SOUNDEX(state), SOUNDEX(city)
	ORDER BY state_variations, city_variations, total DESC;
END$$
DELIMITER ;

CALL fuzzy_city_state('CA');

UPDATE airbnb_us
SET city = 'Bernal Heights'
WHERE city LIKE 'Bernal Heights%' and state = 'CA';

SELECT DISTINCT city, state
FROM airbnb_us
WHERE city LIKE 'Aptos%' and state = 'CA';

UPDATE airbnb_us
SET city = 'Aptos'
WHERE city LIKE 'Aptos%' and state = 'CA';

SELECT distinct city, state
from airbnb_us
where city Like '%Los Ang%' and state like 'CA';

Update airbnb_us
SET city = 'Los Angeles'
where city Like '%Los Ang%' and state like 'CA';


SELECT distinct city, state
from airbnb_us
where city Like '%Astor%' and state like 'ny';

Update airbnb_us
SET city = 'Astoria'
where city Like '%Astor%' and state like 'ny';
    
    
-- Not as efficient, let's do case statements

call fuzzy_city_state('CA');

-- Starting with CA

SELECT state, city, COUNT(*) AS n
FROM airbnb_us
WHERE state = 'CA'
  AND (city LIKE 'Culver City%'
    OR city LIKE '%Oakland%'
    OR city LIKE '%Glendale%'
    OR city LIKE '%Granada Hills%'
    OR city LIKE '%hacienda%'
    OR city LIKE '%hollywood%'
    OR city LIKE '%inglewood%'
    OR city LIKE '%la jolla%'
    OR city LIKE '%la mesa%'
    OR city LIKE '%lake hughes%'
    OR city LIKE '%redondo beach%'
    OR city LIKE '%lomita%'
    OR city LIKE '%mission valley%'
    OR city LIKE 'mission, va%'
    OR city LIKE '%mission, sa%'
    OR city LIKE '%National City%'
    OR city LIKE 'ocean beach%'    
    OR city LIKE 'pacific beach%'   
    OR city LIKE 'private room nea%'
    OR city LIKE 'redo do%'  
    OR city LIKE 'Redondo Bea%'   
    OR city LIKE 'rockridge%'    
    OR city LIKE 'rowland h%'    
    OR city LIKE 'San Diego%'    
    OR city LIKE 'San Francisco%'   
    OR city LIKE 'Santa Clarita%'   
    OR city LIKE 'SF'  
    OR city LIKE 'Sherman%'  
    OR city LIKE 'Soquel%'    
    OR city LIKE 'Stevenson%'   
    OR city LIKE 'Thousand Oaks%'   
    OR city LIKE 'van nuys%'    
    OR city LIKE 'Venice%'    
    OR city LIKE 'view park%'  
    OR city LIKE 'Venice%'   
    OR city LIKE 'walnut%'    
    OR city LIKE 'woodland%'
    OR city LIKE 'San Dimas%'  

        
        )
GROUP BY state, city
ORDER BY state, city;

UPDATE airbnb_us
SET city = (CASE
    WHEN state = 'CA' AND city LIKE 'Culver City%'    THEN 'Culver City'
    WHEN state = 'CA' AND city LIKE '%Oakland%'       THEN 'Oakland'
    WHEN state = 'CA' AND city LIKE '%Glendale%'      THEN 'Glendale'
    WHEN state = 'CA' AND city LIKE '%Granada Hills%' THEN 'Granada Hills'
    WHEN state = 'CA' AND city LIKE '%hacienda%'      THEN 'Hacienda Heights'
    WHEN state = 'CA' AND city LIKE '%hollywood%'     THEN 'Hollywood'
    WHEN state = 'CA' AND city LIKE '%inglewood%'     THEN 'Inglewood'
    WHEN state = 'CA' AND city LIKE '%la jolla%'      THEN 'La Jolla'
    WHEN state = 'CA' AND city LIKE '%la mesa%'       THEN 'La Mesa'
    WHEN state = 'CA' AND city LIKE '%lake hughes%'   THEN 'Lake Hughes'
    WHEN state = 'CA' AND city LIKE '%redondo beach%' THEN 'Redondo Beach'
    WHEN state = 'CA' AND city LIKE '%lomita%'        THEN 'Lomita'
    WHEN state = 'CA' AND city LIKE '%mission valley%' THEN 'Mission Valley'
    WHEN state = 'CA' AND city LIKE 'mission, va%'    THEN 'Mission Valley'
    WHEN state = 'CA' AND city LIKE 'national city%'    THEN 'national city'
    WHEN state = 'CA' AND city LIKE 'ocean beach%'    THEN 'Ocean Beach'
    WHEN state = 'CA' AND city LIKE 'pacific beach%'    THEN 'pacific beach'
    WHEN state = 'CA' AND city LIKE 'private room nea%'    THEN 'Los Angeles'
    WHEN state = 'CA' AND city LIKE 'redo do%'    THEN 'Redondo Beach'
    WHEN state = 'CA' AND city LIKE 'Redondo Bea%'    THEN 'Redondo Beach'
    WHEN state = 'CA' AND city LIKE 'rockridge%'    THEN 'Oakland'
    WHEN state = 'CA' AND city LIKE 'rowland%'    THEN 'Rowland Heights'
    WHEN state = 'CA' AND city LIKE 'San Diego%'    THEN 'San Diego'
    WHEN state = 'CA' AND city LIKE '%San Francisco%'    THEN 'San Francisco'
    WHEN state = 'CA' AND city LIKE 'Santa Clarita%'    THEN 'Santa Clarita'
    WHEN state = 'CA' AND city LIKE 'SF'    THEN 'San Francisco'
    WHEN state = 'CA' AND city LIKE 'Sherma%'    THEN 'Sherman Oaks'
    WHEN state = 'CA' AND city LIKE 'Soquel%'    THEN 'Soquel'
    WHEN state = 'CA' AND city LIKE 'Stevenson%'    THEN 'Stevenson Ranch'
    WHEN state = 'CA' AND city LIKE 'Thousand Oaks%'    THEN 'Thousand Oaks'
    WHEN state = 'CA' AND city LIKE 'van nuys%'    THEN 'Los Angeles'
    WHEN state = 'CA' AND city LIKE 'Venice%'    THEN 'Venice'
    WHEN state = 'CA' AND city LIKE 'view park%'    THEN 'view park'
    WHEN state = 'CA' AND city LIKE 'walnut%'    THEN 'walnut'
    WHEN state = 'CA' AND city LIKE 'woodland%'    THEN 'Woodland Hills'
    WHEN state = 'CA' AND city LIKE 'San Dimas%'    THEN 'San Dimas'
	WHEN state = 'CA' AND city LIKE 'Pacific P%'    THEN 'Pacific Palisades'

    ELSE city
END
)
WHERE state = 'CA'
  AND (city LIKE 'Culver City%'
    OR city LIKE '%Oakland%'
    OR city LIKE '%Glendale%'
    OR city LIKE '%Granada Hills%'
    OR city LIKE '%hacienda%'
    OR city LIKE '%hollywood%'
    OR city LIKE '%inglewood%'
    OR city LIKE '%la jolla%'
    OR city LIKE '%la mesa%'
    OR city LIKE '%lake hughes%'
    OR city LIKE '%redondo beach%'
    OR city LIKE '%lomita%'
    OR city LIKE '%mission valley%'
    OR city LIKE 'mission, va%'
    OR city LIKE '%National City%'
    OR city LIKE 'ocean beach%'    
    OR city LIKE 'pacific beach%'   
    OR city LIKE 'private room nea%'
    OR city LIKE 'redo do%'  
    OR city LIKE 'Redondo Bea%'   
    OR city LIKE 'rockridge%'    
    OR city LIKE 'rowland%'    
    OR city LIKE 'San Diego%'    
    OR city LIKE '%San Francisco%'   
    OR city LIKE 'Santa Clarita%'   
    OR city LIKE 'SF'  
    OR city LIKE 'Sherman%'  
    OR city LIKE 'Soquel%'    
    OR city LIKE 'Stevenson%'   
    OR city LIKE 'Thousand Oaks%'   
    OR city LIKE 'van nuys%'    
    OR city LIKE 'Venice%'    
    OR city LIKE 'view park%'  
    OR city LIKE 'Venice%'   
    OR city LIKE 'walnut%'    
    OR city LIKE 'woodland%'
    OR city LIKE 'San Dimas%'  
	OR city LIKE 'Pacific P%'
        
        );

SELECT DISTINCT city
FROM airbnb_us
WHERE state = 'CA'
Order by 1;

-- Then Colorado
call fuzzy_city_state('CO');
call fuzzy_city_state('DC');
SELECT state, city, COUNT(*) AS n
FROM airbnb_us
WHERE state = 'DC'
  AND (city LIKE 'Capitol Hill%'
  	OR city LIKE 'Columbia Heights%'
  	OR city LIKE 'Dupont Circle%'
  	OR city LIKE 'Washington%'
          )
GROUP BY state, city
ORDER BY state, city;
UPDATE airbnb_us
SET city = (CASE
    WHEN state = 'DC' AND city LIKE 'Capitol Hill%' THEN 'Capitol Hill'
    WHEN state = 'DC' AND city LIKE 'Columbia Heights%' THEN 'Columbia Heights'
    WHEN state = 'DC' AND city LIKE 'Dupont Circle%' THEN 'Dupont Circle'
    WHEN state = 'DC' AND city LIKE 'Washington%' THEN 'Washington, DC'
    ELSE city
  END)
  WHERE state = 'DC'
  AND (city LIKE 'Capitol Hill%'
  	OR city LIKE 'Columbia Heights%'
  	OR city LIKE 'Dupont Circle%'
  	OR city LIKE 'Washington%'
  	);

CALL fuzzy_city_state('IL');

SELECT state, city, count(*) as n
FROM airbnb_us
WHERE state = 'IL'
	AND (city LIKE 'chicag'
	  OR city LIKE 'chicago,%' 
	  )
GROUP BY state, city
ORDER BY state, city;

UPDATE airbnb_us
SET city = (CASE
		WHEN state = 'IL' AND city LIKE 'chicag' THEN 'Chicago'
	  	WHEN state = 'IL' AND city LIKE 'chicago,%' THEN 'Chicago'
END)
WHERE state = 'IL'
	AND (city LIKE 'chicag'
	  OR city LIKE 'chicago,%' 
);

CALL fuzzy_city_state('LA');

SELECT state, city, count(*) as n
FROM airbnb_us
WHERE state = 'LA'
	AND (city LIKE 'bywat%'
	  OR city LIKE 'New or%' 
	  )
GROUP BY state, city
ORDER BY state, city;

UPDATE airbnb_us
SET city = (CASE
		WHEN state = 'LA' AND city LIKE 'bywat%' THEN 'New Orleans'
	  	WHEN state = 'LA' AND city LIKE 'New or%' THEN 'New Orleans'
END)
WHERE state = 'LA'
	AND (city LIKE 'bywat%'
	  OR city LIKE 'New or%' 
	  );





CALL fuzzy_city_state('MA')

SELECT state, city, count(*) as n
FROM airbnb_us
WHERE state = 'MA'
	AND (city LIKE '%Boston%'
	  OR city LIKE 'dorcherster%' 
	  OR city LIKE 'jamaica%'
	  OR city LIKE 'mission hill%'
	  )
GROUP BY state, city
ORDER BY state, city;

UPDATE airbnb_us
SET city = (CASE
	WHEN state = 'MA' AND city LIKE '%Boston%' THEN 'Boston'
	WHEN state = 'MA' AND city LIKE 'dorcherster%' THEN 'Boston'
	WHEN state = 'MA' AND city LIKE 'jamaica%' THEN 'Boston'
	WHEN state = 'MA' AND city LIKE 'mission hill%' THEN 'Boston'
	ELSE city
END
)
WHERE state = 'MA'
	AND (city LIKE '%Boston%'
	  OR city LIKE 'dorcherster%' 
	  OR city LIKE 'jamaica%'
	  OR city LIKE 'mission hill%'
	  );



CALL fuzzy_city_state('MD');

-- not a real state
-- after investigating we found that is NY
CALL fuzzy_city_state('MP');

SELECT *
FROM airbnb_us 
WHERE state = 'MP';

UPDATE airbnb_us 
SET state = 'NY'
WHERE state = 'MP';


CALL fuzzy_city_state('NJ');


CALL fuzzy_city_state('NY');

SELECT state, city, count(*) as n
FROM airbnb_us
WHERE state = 'NY'
	AND (
			city LIKE '%Elmhurst%' -- elmhurst
		 OR city LIKE '%Elmuhrust'	
		 OR city LIKE 'Astot%' -- astoria
		 OR city LIKE 'Bayside%' -- bayside
		 OR city LIKE 'BK%' -- bushwick
		 OR city LIKE '%Bronx%'
		 OR city LIKE '%Brooklyn'
		 OR city LIKE 'Brookly,' -- brooklyn
		 OR city LIKE 'Broo' -- brooklyn
		 OR city LIKE '%Prospec%' -- prospect heights
		 OR city LIKE 'BrooklynBrooklyn'
		 OR city LIKE '%Williamsburg%' -- WILLIAMSBURG
		 OR city LIKE '%Bushwick%' -- Bushwick
		 OR city LIKE 'Carroll Gardens%'
		 OR city LIKE 'Clinton Hill%'
		 OR city LIKE 'Cobble Hill%'
		 OR city LIKE 'Crown Heights%'
		 OR city LIKE '%flushing%'
		 OR city LIKE 'forest h%' -- forest hills
		 OR city LIKE 'Fort gree%'
		 OR city LIKE 'glendal%'
		 OR city LIKE 'gravesend%'
		 OR city LIKE 'greenpoint%'
		 OR city LIKE '%kitchen%'
		 OR city LIKE 'jackson%'
		 OR city LIKE 'jamaica%'
		 OR city LIKE 'kew Gardens%'
		 OR city LIKE 'L.I.%'
		 OR city LIKE 'LIC'
		 OR city LIKE 'Lawrence%' -- Lawrence
		 OR city LIKE 'long island %'
		 OR city LIKE 'lower east%'
		 OR city LIKE 'Manhattan%'
		 OR city LIKE 'new york, new%'
		 OR city LIKE '%Ridgewood%'
		 OR city LIKE 'ny%'
		 OR city LIKE 'ozone park%'
		 OR city LIKE 'park slop%'
		 OR city LIKE '%sunnyside%'
		 OR city LIKE 'queens, q%'
		 OR city LIKE 'queens/%'
		 OR city LIKE 'red hook%'
		 OR city LIKE '%albans%' -- Saint Albans
		 OR city LIKE 'Staten Islan%'
		 OR city LIKE '%woodside%'
		 OR city LIKE '%beokl%'
		 OR city LIKE '%Brooklyn %'
		 OR city LIKE 'Brookyln'
		 OR city LIKE 'Brookyn'
		 OR city LIKE 'Flyshing'
		 OR city LIKE 'kew Garden H%'
		 OR city LIKE 'longisland%' 
		 OR city LIKE 'Manhatten%' 
		 OR city LIKE 'new york%' 
		 OR city LIKE 'Novayork%' 
		 OR city LIKE 'nueva york%' 
		 OR city LIKE 'queens NY' 
		 OR city LIKE 'queens, NY' 
		 OR city LIKE 'queensvillage'
		 OR city LIKE 'queens, quee%'
		 OR city LIKE 'quenns'
		 OR city LIKE 'statenisl%'
		 OR city LIKE 'Wadsworth%' 
		 OR city LIKE 'wood side' 
		 OR city LIKE '%east new york'
		 OR city LIKE 'Chelsea%'
		 
	)
GROUP BY state, city
ORDER BY state, city;

UPDATE airbnb_us
SET city = (CASE
	WHEN state = 'NY' AND city LIKE '%Elmhurst%' THEN 'Elmhurst' -- elmhurst
	WHEN state = 'NY' AND city LIKE '%Elmuhrust' THEN 'Elmhurst' -- elmhurst
	WHEN state = 'NY' AND city LIKE 'Astot%' THEN 'Astoria' -- astoria
	WHEN state = 'NY' AND city LIKE 'Bayside%' THEN 'Bayside' -- bayside
	WHEN state = 'NY' AND city LIKE 'BK%' THEN 'Bushwick'      -- bushwick
	WHEN state = 'NY' AND city LIKE '%Bronx%' THEN 'Bronx'
	WHEN state = 'NY' AND city LIKE 'Brookly,' THEN 'Brooklyn' -- brooklyn
	WHEN state = 'NY' AND city LIKE 'Broo' THEN 'Brooklyn'-- brooklyn
	WHEN state = 'NY' AND city LIKE '%Prospec%' THEN 'Prospect Heights'-- prospect heights
	WHEN state = 'NY' AND city LIKE 'Brooklyn
%' THEN 'Brooklyn'
	WHEN state = 'NY' AND city LIKE '%Williamsburg%' THEN 'Williamsburg'-- WILLIAMSBURG
	WHEN state = 'NY' AND city LIKE '%Brooklyn, %' THEN 'Brooklyn'-- WILLIAMSBURG
	WHEN state = 'NY' AND city LIKE '%Bushwick%' THEN 'Bushwick' -- Bushwick
	WHEN state = 'NY' AND city LIKE 'Carroll Gardens%' THEN 'Carroll Gardens'
	WHEN state = 'NY' AND city LIKE 'CLinton Hill%' THEN 'Clinton Hill'
	WHEN state = 'NY' AND city LIKE 'Cobble Hill%' THEN 'Cobble Hill'
	WHEN state = 'NY' AND city LIKE 'Crown Heights%' THEN 'Crown Heights'
	WHEN state = 'NY' AND city LIKE '%flushing%' THEN 'Flushing'
	WHEN state = 'NY' AND city LIKE 'forest h%' THEN 'Forest Hills'-- forest hills
	WHEN state = 'NY' AND city LIKE 'Fort gree%' THEN 'Fort Greene'
	WHEN state = 'NY' AND city LIKE 'glendal%' THEN 'Glendale'
	WHEN state = 'NY' AND city LIKE 'gravesend%' THEN 'Gravesend'
	WHEN state = 'NY' AND city LIKE 'greenpoint%' THEN 'Greenpoint'
	WHEN state = 'NY' AND city LIKE '%kitchen%' THEN 'Manhattan'
	WHEN state = 'NY' AND city LIKE 'jackson%' THEN 'Jackson Heights'
	WHEN state = 'NY' AND city LIKE 'jamaica%' THEN 'Jamaica'
	WHEN state = 'NY' AND city LIKE 'kew Gardens%' THEN 'kew Gardens'
	WHEN state = 'NY' AND city LIKE 'L.I.%' THEN 'Long Island City'
	WHEN state = 'NY' AND city LIKE 'LIC' THEN 'Long Island City'
	WHEN state = 'NY' AND city LIKE 'Lawrence%' THEN 'Lawrence' -- Lawrence
	WHEN state = 'NY' AND city LIKE 'long island %' THEN 'Long Island City'
	WHEN state = 'NY' AND city LIKE 'lower east%' THEN 'Manhattan'
	WHEN state = 'NY' AND city LIKE 'Manhattan%' THEN 'Manhattan'
	
	WHEN state = 'NY' AND city LIKE '%Ridgewood%' THEN 'Ridgewood'
	WHEN state = 'NY' AND city LIKE 'ny%' THEN 'New York'
	WHEN state = 'NY' AND city LIKE 'ozone park%' THEN 'Ozone Park'
	WHEN state = 'NY' AND city LIKE 'park slop%' THEN 'Park Slope'
	WHEN state = 'NY' AND city LIKE '%sunnyside%' THEN 'Sunnyside'
	WHEN state = 'NY' AND city LIKE 'queens, q%' THEN 'Queens'
	WHEN state = 'NY' AND city LIKE 'queens/%' THEN 'Queens'
	WHEN state = 'NY' AND city LIKE 'red hook%' THEN 'Red Hook'
	WHEN state = 'NY' AND city LIKE '%albans%' THEN 'Saint Albans'
	WHEN state = 'NY' AND city LIKE 'Staten Islan%' THEN 'Staten Island'
	WHEN state = 'NY' AND city LIKE '%woodside%' THEN 'Woodside'
	WHEN state = 'NY' AND city LIKE '%beokl%' THEN 'Brooklyn'
	WHEN state = 'NY' AND city LIKE '%Brooklyn %' THEN 'Brooklyn'
	WHEN state = 'NY' AND city LIKE 'Brookyln' THEN 'Brooklyn'
	WHEN state = 'NY' AND city LIKE 'Brookyn' THEN 'Brooklyn'
	WHEN state = 'NY' AND city LIKE 'Flyshing' THEN 'Flushing'
	WHEN state = 'NY' AND city LIKE 'kew Garden H%' THEN 'kew Gardens'
	WHEN state = 'NY' AND city LIKE 'longisland%' THEN 'Long Island City'
	WHEN state = 'NY' AND city LIKE 'Manhatten%' THEN 'Manhattan'
 	WHEN state = 'NY' AND city LIKE 'new york%' THEN 'New York'
 	WHEN state = 'NY' AND city LIKE 'Novayork%' THEN 'New York'
 	WHEN state = 'NY' AND city LIKE 'nueva york%' THEN 'New York'
 	WHEN state = 'NY' AND city LIKE 'queens NY' THEN 'Queens'
 	WHEN state = 'NY' AND city LIKE 'queens, NY' THEN 'Queens'
 	WHEN state = 'NY' AND city LIKE 'queensvillage' THEN 'Queens Village'
 	WHEN state = 'NY' AND city LIKE 'queens, quee%' THEN 'Queens'
 	WHEN state = 'NY' AND city LIKE 'quenns' THEN 'Queens'
 	WHEN state = 'NY' AND city LIKE 'statenisl%' THEN 'Staten Island'
 	WHEN state = 'NY' AND city LIKE 'Wadsworth%' THEN 'Manhattan'
 	WHEN state = 'NY' AND city LIKE 'wood side' THEN 'Woodside'
 	WHEN state = 'NY' AND city LIKE '%east new york' THEN 'East New York'
 	WHEN state = 'NY' AND city LIKE 'Chelsea%' THEN 'Manhattan'
	ELSE city	
END)
WHERE state = 'NY'
	AND (
			city LIKE '%Elmhurst%' -- elmhurst
		 OR city LIKE '%Elmuhrust'
		 OR city LIKE 'Astot%' -- astoria
		 OR city LIKE 'Bayside%' -- bayside
		 OR city LIKE 'BK%' -- bushwick
		 OR city LIKE '%Bronx%'
		 OR city LIKE '%Brooklyn'
		 OR city LIKE 'Brookly,' -- brooklyn
		 OR city LIKE 'Broo' -- brooklyn
		 OR city LIKE '%Prospec%' -- prospect heights
		 OR city LIKE 'Brooklyn
%'
		 OR city LIKE '%Williamsburg%' -- WILLIAMSBURG
		 OR city LIKE '%Brooklyn, %'
		 OR city LIKE '%Bushwick%' -- Bushwick
		 OR city LIKE 'Carroll Gardens%'
		 OR city LIKE 'Clinton Hill%'
		 OR city LIKE 'Cobble Hill%'
		 OR city LIKE 'Crown Heights%'
		 OR city LIKE '%flushing%'
		 OR city LIKE 'forest h%' -- forest hills
		 OR city LIKE 'Fort gree%'
		 OR city LIKE 'glendal%'
		 OR city LIKE 'gravesend%'
		 OR city LIKE 'greenpoint%'
		 OR city LIKE '%kitchen%'
		 OR city LIKE 'jackson%'
		 OR city LIKE 'jamaica%'
		 OR city LIKE 'kew Gardens%'
		 OR city LIKE 'L.I.%'
		 OR city LIKE 'LIC'
		 OR city LIKE 'Lawrence%' -- Lawrence
		 OR city LIKE 'long island %'
		 OR city LIKE 'lower east%'
		 OR city LIKE 'Manhattan%'
		 OR city LIKE 'new york, new%'
		 OR city LIKE '%Ridgewood%'
		 OR city LIKE 'ny%'
		 OR city LIKE 'ozone park%'
		 OR city LIKE 'park slop%'
		 OR city LIKE '%sunnyside%'
		 OR city LIKE 'queens, q%'
		 OR city LIKE 'queens/%'
		 OR city LIKE 'red hook%'
		 OR city LIKE '%albans%' -- Saint Albans
		 OR city LIKE 'Staten Islan%'
		 OR city LIKE '%woodside%'
		 OR city LIKE '%beokl%'
		 OR city LIKE '%Brooklyn %'
		 OR city LIKE 'Brookyln'
		 OR city LIKE 'Brookyn'
		 OR city LIKE 'Flyshing'
		 OR city LIKE 'kew Garden H%'
		 OR city LIKE 'longisland%' 
		 OR city LIKE 'Manhatten%' 
		 OR city LIKE 'new york%' 
		 OR city LIKE 'Novayork%' 
		 OR city LIKE 'nueva york%' 
		 OR city LIKE 'queens NY' 
		 OR city LIKE 'queens, NY' 
		 OR city LIKE 'queensvillage'
		 OR city LIKE 'queens, quee%'
		 OR city LIKE 'quenns'
		 OR city LIKE 'statenisl%'
		 OR city LIKE 'Wadsworth%' 
		 OR city LIKE 'wood side' 
		 OR city LIKE '%east new york'
		 OR city LIKE 'Chelsea%'
	);



CALL fuzzy_city_state('OR');

SELECT state, city, count(*) as n
FROM airbnb_us
WHERE state = 'OR'
	AND (city LIKE 'Portlan%')
GROUP BY state, city
ORDER BY state, city;

UPDATE airbnb_us
SET city = 'Portland'
WHERE state = 'OR' AND city LIKE 'Portlan%';


CALL fuzzy_city_state('TN');

SELECT state, city, count(*) as n
FROM airbnb_us
WHERE state = 'TN'
	AND (city LIKE 'Nashville%')
GROUP BY state, city
ORDER BY state, city;

UPDATE airbnb_us
SET city = 'Nashville'
WHERE state = 'TN' AND city LIKE 'Nashville%';

CALL fuzzy_city_state('TX');

SELECT state, city, count(*) as n
FROM airbnb_us
WHERE state = 'TX'
	AND (city LIKE 'Austin%')
GROUP BY state, city
ORDER BY state, city;

UPDATE airbnb_us
SET city = 'Austin'
WHERE state = 'TX' and city LIKE 'Austin%'

CALL fuzzy_city_state('VT');

CALL fuzzy_city_state('WA');

SELECT state, city, count(*) as n
FROM airbnb_us
WHERE state = 'WA'
	AND (city LIKE '%Seattle')
GROUP BY state, city
ORDER BY state, city;

UPDATE airbnb_us
SET city = 'Seattle'
WHERE state = 'WA' AND  city LIKE '%Seattle'

select distinct city
from airbnb_us
order by 1;

select distinct *
from airbnb_us
order by state, city;

select count(*)
from airbnb_us

select distinct LENGTH(zipcode)
from airbnb_us
group by zipcode;

UPDATE airbnb_us
SET zipcode = SUBSTRING(zipcode, 1, 5)
WHERE zipcode IS NOT NULL;


-- removing non-latin characters

SELECT id, city, state
FROM airbnb_us
WHERE city REGEXP '[^a-zA-Z0-9[:space:],,ñ,-]'
   OR state REGEXP '[^a-zA-Z0-9[:space:]]';

DELETE
FROM airbnb_us
WHERE city REGEXP '[^a-zA-Z0-9[:space:],,ñ,-]'
   OR state REGEXP '[^a-zA-Z0-9[:space:]]';

select *
from airbnb_us
where city = '3f';

update airbnb_us
set city = 'Woodside'
where city = '3f'

select *
from airbnb_us
where city = '2';

update airbnb_us
set city = 'Brooklyn'
where city = '2'

select distinct city
from airbnb_us;


-- set as lower case for easier analysis for now, fiz with Proper later on Tableau

UPDATE airbnb_us
SET 
	name =  Lcase(name),
	host_name = Lcase(host_name),
	street = Lcase(street),
	neighbourhood = Lcase(neighbourhood),
	city = Lcase(city),
	property_type = LCASE(property_type),
	room_type = Lcase(room_type)
WHERE name IS NOT NULL
	OR host_name IS NOT NULL
	OR street IS NOT NULL
	OR neighbourhood IS NOT NULL
	OR city IS NOT NULL
	OR property_type IS NOT NULL
	OR room_type IS NOT NULL;
	

-- 3. Convert Data Types

-- Turn common blanks like '' or 'NA' into NULLs
UPDATE airbnb_us
SET
  bedrooms             = NULLIF(TRIM(bedrooms), ''),
  bathrooms            = NULLIF(TRIM(bathrooms), ''),
  beds                 = NULLIF(TRIM(beds), ''),
  number_of_reviews    = NULLIF(TRIM(number_of_reviews), ''),
  review_scores_rating = NULLIF(TRIM(review_scores_rating), ''),
  review_scores_value  = NULLIF(TRIM(review_scores_value), ''),
  host_since           = NULLIF(TRIM(host_since), ''),
  zipcode              = NULLIF(TRIM(zipcode), ''),
  price                = REPLACE(REPLACE(TRIM(price), '$', ''), ',', '');




-- keeping raw price and adding a new price_num column so we can work with decimals easily
ALTER TABLE airbnb_us ADD COLUMN price_num DECIMAL(10,2);


UPDATE airbnb_us
SET price_num = CAST(REPLACE(REPLACE(price, '$',''), ',', '') AS DECIMAL(10,2))
WHERE price REGEXP '^[0-9]+(\\.[0-9]{1,2})?$';


-- keeping raw bathrooms and adding a new bathrooms_num column so we can work with decimals easily
ALTER TABLE airbnb_us ADD COLUMN `bathrooms_num` DECIMAL(3,1);

UPDATE `airbnb_us`
SET `bathrooms_num` = CAST(bathrooms AS DECIMAL(3,1))
WHERE bathrooms REGEXP '^[0-9]+(\\.[0-9])?$';


-- altering the remaining data types needed to modify
ALTER TABLE airbnb_us
MODIFY COLUMN host_since DATE,
MODIFY COLUMN zipcode VARCHAR(20),
MODIFY COLUMN bedrooms INT,
MODIFY COLUMN beds INT;


-- 4. Null/Blank Handling


-- For more accurate analysis we are going to ommit data where city is NULL or empty

select count(*)
from airbnb_us
WHERE city is NULL or city = '';

DELETE 
FROM airbnb_us
WHERE city is NULL or city = '';


-- For more accurate analysis we are going to ommit data where price is NULL or empty

select count(*)
from airbnb_us
WHERE price is NULL or price = '';


DELETE 
FROM airbnb_us
WHERE price is NULL or price = '';



-- 5.Unused Columns

-- unnecessary columns in this analysis

ALTER TABLE airbnb_stage2
DROP COLUMN host_verifications;

ALTER TABLE airbnb_stage2
DROP COLUMN market;

-- dropping columns with the data type not matching analysis-ready

ALTER TABLE airbnb_us 
DROP COLUMN price;

ALTER TABLE airbnb_us 
DROP COLUMN bathrooms;

-- dropping temporary row_num column used to spot duplicates 

ALTER TABLE airbnb_us
DROP COLUMN row_num;

select*
from airbnb_us;



SELECT 'raw_stage' AS table_name, COUNT(*) AS row_count FROM airbnb_stage
UNION ALL
SELECT 'stage2',      COUNT(*)              FROM airbnb_stage2
UNION ALL
SELECT 'clean_us',    COUNT(*)              FROM airbnb_us;

