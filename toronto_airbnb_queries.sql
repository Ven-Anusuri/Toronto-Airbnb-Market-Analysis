--ROW COUNT AND NULLS

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT neighbourhood) AS unique_neighbourhoods,
  COUNT(DISTINCT host_id) AS unique_hosts,
  COUNTIF(reviews_per_month IS NULL) AS null_review_per_month,
  COUNTIF(last_review IS NULL) AS null_last_review,
  COUNTIF(license IS NOT NULL AND license != '') AS licensed_count
FROM prime-task-498715-d3.listings.listing;

----- Room type distrubution 


  SELECT 
  room_type,
  COUNT(*) AS listing_count,
  ROUND(COUNT(*) * 100.0/ SUM(COUNT(*)) OVER(), 1) AS pct
FROM prime-task-498715-d3.listings.listing
GROUP BY room_type
ORDER BY listing_count DESC;

----Minimum Nights distribution 

SELECT
  MIN(minimum_nights) AS min_val,
  MAX(minimum_nights) AS max_val,
  APPROX_QUANTILES(minimum_nights, 2)[OFFSET(1)] AS median_val,
  ROUND(AVG(minimum_nights), 1) AS avg_val
FROM prime-task-498715-d3.listings.listing;


--Multi-listing Host

SELECT
  COUNTIF(calculated_host_listings_count > 1) AS multi_listing_entries,
  COUNT(*) AS total,
  ROUND(COUNTIF(calculated_host_listings_count > 1) * 100.0 / COUNT(*), 1) AS pct
FROM prime-task-498715-d3.listings.listing;

-- supply concentration 

-- Top 15 neighbourhoods
SELECT
  neighbourhood,
  COUNT(*) AS listing_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM prime-task-498715-d3.listings.listing), 1) AS pct_of_total
FROM prime-task-498715-d3.listings.listing
GROUP BY neighbourhood
ORDER BY listing_count DESC
LIMIT 15;

-- Top 15 neighbourhoods x room type
SELECT
  neighbourhood,
  room_type,
  COUNT(*) AS listing_count
FROM prime-task-498715-d3.listings.listing
WHERE neighbourhood IN 
    (SELECT
      neighbourhood
    FROM prime-task-498715-d3.listings.listing
    GROUP BY neighbourhood
    ORDER BY COUNT(*) DESC
    LIMIT 15)
GROUP BY neighbourhood, room_type
ORDER BY listing_count DESC;


-- Room Type Distribution
SELECT
  room_type,
  COUNT(*) AS listing_count,
FROM prime-task-498715-d3.listings.listing
GROUP BY room_type
ORDER BY listing_count DESC;

-- Where is the demand strongest? 

SELECT 
  neighbourhood,
  COUNT(*) AS listing_count,
  ROUND(AVG(COALESCE(SAFE_CAST(reviews_per_month AS FLOAT64), 0)), 2) AS avg_rpm,
  APPROX_QUANTILES(COALESCE(SAFE_CAST(reviews_per_month AS FLOAT64), 0), 2)[OFFSET(1)] AS median_rpm,
  SUM(SAFE_CAST(number_of_reviews AS INT64)) AS total_reviews
FROM prime-task-498715-d3.listings.listing
WHERE SAFE_CAST(number_of_reviews AS INT64) > 0
GROUP BY neighbourhood
HAVING COUNT(*) >= 10
ORDER BY avg_rpm DESC
LIMIT 15;

-- Competition: How many professional vs casual operators?

SELECT 
  CASE WHEN calculated_host_listings_count > 1 THEN 'Professional' ELSE 'Casual' END AS host_type,
  COUNT(*) AS listing_count,
  ROUND(AVG(COALESCE(SAFE_CAST(reviews_per_month AS FLOAT64), 0)), 2) AS avg_rpm,
  APPROX_QUANTILES(COALESCE(SAFE_CAST(reviews_per_month AS FLOAT64), 0), 2)[OFFSET(1)] AS median_rpm,
  SUM(SAFE_CAST(number_of_reviews AS INT64)) AS total_reviews
FROM prime-task-498715-d3.listings.listing
WHERE SAFE_CAST(number_of_reviews AS INT64) > 0
GROUP BY host_type
HAVING COUNT(*) >= 10
ORDER BY avg_rpm DESC;

---  Licensing: What percentage of listings are licensed? and how does this vary by neighbourhood?

-- Percentage of listings by License

SELECT
  CASE WHEN license IS NULL THEN 'No' ELSE 'Yes' END AS licensed_flag,
  COUNT(*) AS number_of_listings,
   ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `prime-task-498715-d3.listings.listing`), 1) AS pct_of_total
FROM prime-task-498715-d3.listings.listing
GROUP BY licensed_flag
ORDER BY number_of_listings DESC;

-- Neighbourhood Level

SELECT 
  neighbourhood,
  COUNT(CASE WHEN license is NULL THEN id ELSE NULL END) AS unlicensed,
  COUNT(CASE WHEN license is NOT NULL THEN id ELSE NULL END) AS licensed,
  ROUND(COUNT(CASE WHEN license is NOT NULL THEN id ELSE NULL END) / COUNT(*), 2) AS licensed_pct 
FROM prime-task-498715-d3.listings.listing
GROUP BY neighbourhood
ORDER BY licensed DESC;
