-- ============================================================
-- Indian Tourism SQL Analysis
-- Dataset: Top Indian Places to Visit
-- SQL dialect: PostgreSQL
-- ============================================================
-- Portfolio objective:
-- Analyse 325 tourist attractions across India using SQL,
-- progressing from basic filtering and aggregation to CTEs
-- and window functions.
--
-- IMPORTANT:
-- establishment_year is stored as VARCHAR because the source
-- dataset contains values such as 'Unknown'.
-- weekly_off is nullable because most attractions have no value.
-- ============================================================


-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================

DROP TABLE IF EXISTS tourist_places;

CREATE TABLE tourist_places (
    place_id                         INTEGER PRIMARY KEY,
    zone                             VARCHAR(50) NOT NULL,
    state                            VARCHAR(100) NOT NULL,
    city                             VARCHAR(100) NOT NULL,
    place_name                       VARCHAR(200) NOT NULL,
    attraction_type                  VARCHAR(100) NOT NULL,
    establishment_year               VARCHAR(30) NOT NULL,
    visit_duration_hours             NUMERIC(5,2) NOT NULL,
    google_review_rating             NUMERIC(3,2) NOT NULL,
    entrance_fee_inr                 INTEGER NOT NULL,
    airport_within_50km              VARCHAR(3) NOT NULL,
    weekly_off                       VARCHAR(30),
    significance                     VARCHAR(100) NOT NULL,
    dslr_allowed                     VARCHAR(3) NOT NULL,
    google_reviews_lakhs             NUMERIC(8,2) NOT NULL,
    best_time_to_visit               VARCHAR(30) NOT NULL
);


-- ============================================================
-- 2. IMPORT THE CSV
-- ============================================================
-- Run this from psql after changing the path to the CSV file.
-- The column order matches the source CSV.
--
-- \copy tourist_places (
--     place_id,
--     zone,
--     state,
--     city,
--     place_name,
--     attraction_type,
--     establishment_year,
--     visit_duration_hours,
--     google_review_rating,
--     entrance_fee_inr,
--     airport_within_50km,
--     weekly_off,
--     significance,
--     dslr_allowed,
--     google_reviews_lakhs,
--     best_time_to_visit
-- )
-- FROM '/your/path/top_indian_places_to_visit.csv'
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');


-- ============================================================
-- 3. DATA QUALITY CHECKS
-- ============================================================

-- Confirm row count.
SELECT COUNT(*) AS total_places
FROM tourist_places;

-- Check whether the source contains duplicate place IDs.
SELECT place_id, COUNT(*) AS duplicate_count
FROM tourist_places
GROUP BY place_id
HAVING COUNT(*) > 1;

-- Inspect non-numeric establishment-year values.
SELECT DISTINCT establishment_year
FROM tourist_places
WHERE establishment_year !~ '^[0-9]{4}$'
ORDER BY establishment_year;


-- ============================================================
-- QUESTION 1 — EASY
-- Which 10 attractions have the highest Google review ratings?
-- Use review volume as a tie-breaker.
-- Skills: SELECT, ORDER BY, LIMIT
-- ============================================================

SELECT
    place_name,
    city,
    state,
    google_review_rating,
    google_reviews_lakhs
FROM tourist_places
ORDER BY google_review_rating DESC,
         google_reviews_lakhs DESC
LIMIT 10;


-- ============================================================
-- QUESTION 2 — EASY
-- Which highly rated attractions are free to enter?
-- Return places rated 4.5 or above.
-- Skills: WHERE, filtering, ORDER BY
-- ============================================================

SELECT
    place_name,
    city,
    state,
    attraction_type,
    google_review_rating
FROM tourist_places
WHERE entrance_fee_inr = 0
  AND google_review_rating >= 4.5
ORDER BY google_review_rating DESC,
         google_reviews_lakhs DESC;


-- ============================================================
-- QUESTION 3 — EASY / INTERMEDIATE
-- Which states have the largest number of listed attractions?
-- Skills: GROUP BY, COUNT, ORDER BY
-- ============================================================

SELECT
    state,
    COUNT(*) AS number_of_attractions
FROM tourist_places
GROUP BY state
ORDER BY number_of_attractions DESC,
         state;


-- ============================================================
-- QUESTION 4 — INTERMEDIATE
-- What is the average rating and average entrance fee for each
-- attraction significance category with at least 5 places?
-- Skills: GROUP BY, AVG, HAVING, ROUND
-- ============================================================

SELECT
    significance,
    COUNT(*) AS number_of_places,
    ROUND(AVG(google_review_rating), 2) AS avg_rating,
    ROUND(AVG(entrance_fee_inr), 2) AS avg_entrance_fee_inr
FROM tourist_places
GROUP BY significance
HAVING COUNT(*) >= 5
ORDER BY avg_rating DESC,
         number_of_places DESC;


-- ============================================================
-- QUESTION 5 — INTERMEDIATE
-- Which cities offer the strongest combination of variety and
-- quality, considering only cities with at least 3 attractions?
-- Skills: COUNT DISTINCT, AVG, HAVING
-- ============================================================

SELECT
    city,
    state,
    COUNT(*) AS number_of_attractions,
    COUNT(DISTINCT attraction_type) AS distinct_attraction_types,
    ROUND(AVG(google_review_rating), 2) AS avg_rating
FROM tourist_places
GROUP BY city, state
HAVING COUNT(*) >= 3
ORDER BY avg_rating DESC,
         distinct_attraction_types DESC,
         number_of_attractions DESC;


-- ============================================================
-- QUESTION 6 — INTERMEDIATE
-- Which attraction types receive the greatest public engagement?
-- Compare average rating and total Google-review volume.
-- Skills: aggregation, SUM, AVG, HAVING
-- Note: review volume is stored in lakhs in the source dataset.
-- ============================================================

SELECT
    attraction_type,
    COUNT(*) AS number_of_places,
    ROUND(AVG(google_review_rating), 2) AS avg_rating,
    ROUND(SUM(google_reviews_lakhs), 2) AS total_reviews_lakhs
FROM tourist_places
GROUP BY attraction_type
HAVING COUNT(*) >= 3
ORDER BY total_reviews_lakhs DESC,
         avg_rating DESC;


-- ============================================================
-- QUESTION 7 — INTERMEDIATE / ADVANCED
-- For each zone, what percentage of attractions are both
-- airport-accessible (within 50 km) and DSLR-friendly?
-- Skills: CASE WHEN, conditional aggregation, percentage
-- ============================================================

SELECT
    zone,
    COUNT(*) AS total_places,
    SUM(
        CASE
            WHEN airport_within_50km = 'Yes'
             AND dslr_allowed = 'Yes'
            THEN 1 ELSE 0
        END
    ) AS accessible_dslr_friendly_places,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN airport_within_50km = 'Yes'
                 AND dslr_allowed = 'Yes'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS percentage_of_zone
FROM tourist_places
GROUP BY zone
ORDER BY percentage_of_zone DESC;


-- ============================================================
-- QUESTION 8 — ADVANCED
-- Which attractions are more popular than the average attraction
-- in their own state?
-- Skills: CTE, JOIN, state-level benchmarking
-- ============================================================

WITH state_benchmarks AS (
    SELECT
        state,
        AVG(google_reviews_lakhs) AS state_avg_reviews_lakhs
    FROM tourist_places
    GROUP BY state
)
SELECT
    t.place_name,
    t.city,
    t.state,
    t.google_review_rating,
    t.google_reviews_lakhs,
    ROUND(s.state_avg_reviews_lakhs, 2) AS state_avg_reviews_lakhs
FROM tourist_places AS t
JOIN state_benchmarks AS s
  ON t.state = s.state
WHERE t.google_reviews_lakhs > s.state_avg_reviews_lakhs
ORDER BY t.google_reviews_lakhs DESC;


-- ============================================================
-- QUESTION 9 — ADVANCED
-- What are the top 3 attractions in each geographic zone,
-- ranked by rating and then review volume?
-- Skills: CTE, DENSE_RANK, window functions, PARTITION BY
-- ============================================================

WITH ranked_places AS (
    SELECT
        zone,
        place_name,
        city,
        state,
        google_review_rating,
        google_reviews_lakhs,
        DENSE_RANK() OVER (
            PARTITION BY zone
            ORDER BY google_review_rating DESC,
                     google_reviews_lakhs DESC
        ) AS zone_rank
    FROM tourist_places
)
SELECT
    zone,
    zone_rank,
    place_name,
    city,
    state,
    google_review_rating,
    google_reviews_lakhs
FROM ranked_places
WHERE zone_rank <= 3
ORDER BY zone,
         zone_rank,
         place_name;


-- ============================================================
-- QUESTION 10 — HARD
-- Which attractions are the strongest overall candidates for a
-- traveller seeking quality, popularity and affordability?
--
-- Create a transparent recommendation score:
--   50% rating score
--   30% review-popularity score
--   20% affordability score
--
-- Each component is min-max normalised to a 0–1 scale.
-- This is an analytical score created for this project; it is
-- not a score supplied by the original dataset.
--
-- Skills: CTEs, CROSS JOIN, CASE, min-max normalisation,
-- derived business metric, multi-factor ranking
-- ============================================================

WITH bounds AS (
    SELECT
        MIN(google_review_rating) AS min_rating,
        MAX(google_review_rating) AS max_rating,
        MIN(google_reviews_lakhs) AS min_reviews,
        MAX(google_reviews_lakhs) AS max_reviews,
        MIN(entrance_fee_inr) AS min_fee,
        MAX(entrance_fee_inr) AS max_fee
    FROM tourist_places
),
scored_places AS (
    SELECT
        t.place_name,
        t.city,
        t.state,
        t.attraction_type,
        t.google_review_rating,
        t.google_reviews_lakhs,
        t.entrance_fee_inr,

        CASE
            WHEN b.max_rating = b.min_rating THEN 1
            ELSE (t.google_review_rating - b.min_rating)
                 / (b.max_rating - b.min_rating)
        END AS rating_score,

        CASE
            WHEN b.max_reviews = b.min_reviews THEN 1
            ELSE (t.google_reviews_lakhs - b.min_reviews)
                 / (b.max_reviews - b.min_reviews)
        END AS popularity_score,

        CASE
            WHEN b.max_fee = b.min_fee THEN 1
            ELSE 1 - (
                (t.entrance_fee_inr - b.min_fee)
                / (b.max_fee - b.min_fee)
            )
        END AS affordability_score
    FROM tourist_places AS t
    CROSS JOIN bounds AS b
)
SELECT
    place_name,
    city,
    state,
    attraction_type,
    google_review_rating,
    google_reviews_lakhs,
    entrance_fee_inr,
    ROUND(
        (
            0.50 * rating_score +
            0.30 * popularity_score +
            0.20 * affordability_score
        ) * 100,
        2
    ) AS recommendation_score
FROM scored_places
ORDER BY recommendation_score DESC
LIMIT 15;
