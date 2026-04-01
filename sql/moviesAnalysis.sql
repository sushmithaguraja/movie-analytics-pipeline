-- =========================================
-- 1. DATABASE + SCHEMA
-- =========================================
CREATE DATABASE IF NOT EXISTS MOVIE_DB;
USE DATABASE MOVIE_DB;
USE SCHEMA PUBLIC;

-- =========================================
-- 2. RAW TABLE (FIXED STRUCTURE)
-- =========================================
CREATE OR REPLACE TABLE movies_raw (
    title STRING,
    rating FLOAT,
    release_date DATE
);

-- =========================================
-- 3. STAGE (S3 CONNECTION)
-- =========================================
CREATE OR REPLACE STAGE movie_stage
URL = 's3://movie-snowflake-sushmitha-2001/'
STORAGE_INTEGRATION = S3_INT
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
);

-- =========================================
-- 4. CHECK FILES (DEBUG)
-- =========================================
LIST @movie_stage;

-- =========================================
-- 5. LOAD DATA (CORRECT MAPPING)
-- =========================================
COPY INTO movies_raw
FROM @movie_stage
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
)
ON_ERROR = 'CONTINUE';

-- =========================================
-- 6. VERIFY RAW DATA
-- =========================================
SELECT COUNT(*) AS RAW_COUNT FROM movies_raw;
SELECT * FROM movies_raw LIMIT 10;

-- =========================================
-- 7. CLEAN TABLE
-- =========================================
CREATE OR REPLACE TABLE movies_clean AS
SELECT *
FROM movies_raw
WHERE title IS NOT NULL
  AND rating IS NOT NULL
  AND release_date IS NOT NULL;

-- =========================================
-- 8. VERIFY CLEAN DATA
-- =========================================
SELECT COUNT(*) AS CLEAN_COUNT FROM movies_clean;

-- =========================================
-- 9. ANALYTICS TABLE (FIXED LOGIC)
-- =========================================
CREATE OR REPLACE TABLE movie_analysis AS
SELECT
    YEAR(release_date) AS release_year,
    COUNT(*) AS total_movies,
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM movies_clean
GROUP BY release_year
ORDER BY release_year;

-- =========================================
-- 10. FINAL OUTPUT (FOR DASHBOARD)
-- =========================================
SELECT * FROM movie_analysis;