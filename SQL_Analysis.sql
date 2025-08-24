-- Data Analysis -- 



select *
from airbnb_us;


-- Which cities and states have the most airbnb listings

SELECT city, state, count(*) as row_count_cities
FROM airbnb_us
group by state, city
ORDER BY row_count_cities DESC
LIMIT 10;

-- What is the distributions of property types

SELECT property_type, count(*) AS row_count_prop_type
FROM airbnb_us
WHERE property_type != 'other'
GROUP BY property_type
ORDER BY row_count_prop_type DESC;

-- Top 10 only:
SELECT property_type, count(*) AS row_count_prop_type
FROM airbnb_us
WHERE property_type != 'other'
GROUP BY property_type
ORDER BY row_count_prop_type DESC
LIMIT 10;

-- How hosts number grew over time

WITH yearly_cte AS (
  SELECT
    YEAR(host_since) AS joined_year,
    COUNT(DISTINCT host_id) AS new_hosts
  FROM airbnb_us
  WHERE host_since IS NOT NULL
  GROUP BY YEAR(host_since)
),
cumul_cte AS (
  SELECT
    joined_year,
    new_hosts,
    SUM(new_hosts) OVER (ORDER BY joined_year) AS cumulative_hosts
  FROM yearly_cte
)
SELECT
  joined_year,
  new_hosts,
  cumulative_hosts,
  ROUND(cumulative_hosts / LAG(cumulative_hosts) OVER (ORDER BY joined_year) - 1, 4) AS yoy_growth_cum
FROM cumul_cte
ORDER BY joined_year;

-- Which year had the most growth? 

WITH yearly_cte AS (
  SELECT
    YEAR(host_since) AS joined_year,
    COUNT(DISTINCT host_id) AS new_hosts
  FROM airbnb_us
  WHERE host_since IS NOT NULL
  GROUP BY YEAR(host_since)
),
cumul_cte AS (
  SELECT
    joined_year,
    new_hosts,
    SUM(new_hosts) OVER (ORDER BY joined_year) AS cumulative_hosts
  FROM yearly_cte
)
SELECT
  joined_year,
  new_hosts,
  cumulative_hosts,
  ROUND(cumulative_hosts / LAG(cumulative_hosts) OVER (ORDER BY joined_year) - 1, 4) AS yoy_growth_cum
FROM cumul_cte
ORDER BY yoy_growth_cum desc;


-- WHAT IS THE AVERAGE PRICE PER CITY/STATE for cities with 10 or more listings


SELECT state, city, AVG(price_num) as ave_price, count(*) AS num_listings
FROM airbnb_us
GROUP BY state, city
having count(*) > 9
order by ave_price DESC;


-- WHAT IS THE AVERAGE PRICE PER CITY/STATE for cities with 30 or more listings


SELECT state, city, AVG(price_num) as ave_price, count(*) AS num_listings
FROM airbnb_us
GROUP BY state, city
having count(*) > 29
order by ave_price DESC;



-- How does price vary by property type (entire home vs. private room)?

SELECT room_type, ROUND(avg(price_num), 2) AS Avg_price
FROM airbnb_us
GROUP BY room_type 
order by avg_price;


-- How many listings are controlled by multi-property hosts vs. single-property hosts?

WITH host_count_cte AS (
	SELECT host_id, count(*) as listing_count
	FROM airbnb_us
	GROUP BY host_id
)
SELECT 
	CASE 
		WHEN listing_count = 1 THEN 'Single Property Host'
		ELSE 'Multi-Property Host'
	END AS host_type,
	COUNT(*) AS num_hosts,
	SUM(listing_count) as num_listings
FROM host_count_cte
GROUP BY host_type
ORDER BY host_type;
	




-- Who are the top 10 hosts by number of listings, and where are they located?

SELECT host_id, state, city, count(*) as listing_count
FROM airbnb_us
GROUP BY host_id, state, city
HAVING COUNT(*) > 1
ORDER BY listing_count DESC
LIMIT 10;




-- What is the average review score across states/cities?


SELECT state, city, AVG(review_scores_rating) as avg_rev
FROM airbnb_us 
WHERE review_scores_rating is not null
GROUP BY state, city
ORDER BY avg_rev desc;

-- What is the average review score across states (with count)?


SELECT state, AVG(review_scores_rating) AS avg_rev, count(review_scores_rating) AS cnt
FROM airbnb_us 
WHERE review_scores_rating is not null
GROUP BY state
ORDER BY avg_rev desc, cnt;


-- Is there a relationship between price and review score?


SELECT 
	CASE 
		WHEN price_num < 50 THEN '<$50'
		WHEN price_num BETWEEN 50 AND 100 THEN '$50-$100'
		WHEN price_num BETWEEN 100 AND 200 THEN '$100-$200'
		WHEN price_num BETWEEN 200 AND 400 THEN '$200-$400'
		ELSE '>$400'
	END AS price_range,
	AVG(review_scores_rating) AS avg_rev,
	COUNT(*) AS num_listings
FROM airbnb_us
WHERE review_scores_rating IS NOT NULL AND price_num > 0
GROUP BY price_range
ORDER BY MIN(price_num);



-- Are newer hosts pricing differently compared to older hosts?


SELECT 
	CASE 
		WHEN YEAR(host_since) < 2010 THEN '2010'
		WHEN YEAR(host_since) BETWEEN 2010 AND 2013 THEN '2010-2013'
		ELSE '2013'
	END hosts_start_year,
	AVG(price_num) AS avg_price
FROM airbnb_us
WHERE host_since IS NOT NULL AND price_num > 0
GROUP BY hosts_start_year 
ORDER BY hosts_start_year;






