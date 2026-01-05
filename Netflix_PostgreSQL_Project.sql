/* 
   NETFLIX CONTENT ANALYSIS
   Author: Radha Singh
   Database: PostgreSQL
   Purpose: SQL-based analysis of Netflix content catalog
*/

-- TABLE STRUCTURE

-- Create Netflix titles table
CREATE TABLE netflix (
    show_id VARCHAR(10),
    type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(208),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(50),
    duration VARCHAR(50),
    listed_in VARCHAR(100),
    description VARCHAR(300)
);

-- View raw data
SELECT * FROM netflix;


-- CATALOG OVERVIEW

-- 1. Total number of titles in the dataset
SELECT COUNT(*) AS total_titles
FROM netflix;

-- 2. Count of Movies vs TV Shows
SELECT type, COUNT(*) AS total_content
FROM netflix
GROUP BY type;

-- 3. Distinct content types available
SELECT DISTINCT type
FROM netflix;


-- RELEASE YEAR & CONTENT TIMELINE

-- 4. List all the movies released in a specific year (example: 2020)
SELECT *
FROM netflix
WHERE release_year = 2020
  AND type = 'Movie';

-- 5. What is the earliest release year in the dataset
SELECT MIN(release_year) AS earliest_release_year
FROM netflix;

-- 6. Movies and TV Shows count by release year
SELECT release_year, type, COUNT(*) AS total_titles
FROM netflix
GROUP BY release_year, type
ORDER BY release_year;

-- 7. Identify the top 10 oldest titles currently available on Netflix.
SELECT title, (date_added::DATE) AS netflix_date
FROM netflix
WHERE release_year IS NOT NULL
ORDER BY netflix_date, title
LIMIT 10;

-- 8. Find titles that were added to Netflix more than 5 years after their release year.
SELECT title, release_year, date_added 
FROM netflix
WHERE date_added IS NOT NULL
	AND EXTRACT(YEAR FROM date_added::DATE) - release_year > 5;

-- 9. Calculate the total number of titles added to Netflix in each year, ordered chronologically.
SELECT EXTRACT(YEAR FROM date_added::DATE) AS year_added, COUNT(*) AS total_titles
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year_added
ORDER by year_added;

-- 10. How many titles were added after 2019?
SELECT COUNT(*) AS total_titles_after_2019 
FROM netflix
WHERE date_added::date >= DATE '2020-01-01';


-- GENRE ANALYSIS & CONTENT DIVERSITY

-- 11. How many titles mention “Drama” in their genre?
SELECT COUNT(*) AS total_dramas
FROM netflix
WHERE listed_in ILIKE '%Drama%';

-- 12. List all movies that are documentaries
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%documentaries%';

-- 13. Count the number of content items in each genre
SELECT genre, COUNT(DISTINCT show_id) AS total_titles
FROM (
	SELECT show_id, TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
	FROM netflix
	WHERE listed_in IS NOT NULL
	) t
GROUP BY genre
ORDER BY total_titles DESC;

-- 14. For each release year, calculate the number of unique genres available on Netflix.
SELECT release_year, COUNT(DISTINCT genre) AS total_genre
FROM (
	SELECT *,TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
	FROM netflix
	WHERE listed_in IS NOT NULL
	)
GROUP BY release_year
ORDER BY total_genre DESC;

-- 15. Which genres dominated Netflix’s catalog each year, and how did genre popularity shift over time?
SELECT *
FROM (
	SELECT release_year, genre,
	COUNT(*) AS total_titles, RANK() OVER (PARTITION BY release_year ORDER BY COUNT(*) DESC) AS rnk
	FROM (
		SELECT release_year, TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
		FROM netflix
		) t
	GROUP BY release_year, genre
	) ranked
WHERE rnk <= 3
ORDER BY release_year, rnk;


-- COUNTRY-LEVEL CONTENT ANALYSIS

-- 16. How many unique countries are represented?
SELECT COUNT( DISTINCT(TRIM( country_name))) AS total_countries
FROM (
	SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS country_name
	FROM netflix
	WHERE country IS NOT NULL
	);
	
-- 17. Find the top 5 countries with the most content on Netflix
SELECT country_name, COUNT(DISTINCT show_id) AS total_titles
FROM (
	SELECT show_id, TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name
	FROM netflix
	WHERE country IS NOT NULL
	) t
GROUP BY country_name
ORDER BY total_titles DESC
LIMIT 5;

-- 18. Identify countries that contribute more than 5% of the total Netflix catalog.
WITH country_titles AS (
	SELECT DISTINCT show_id, TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name
	FROM netflix
	WHERE country IS NOT NULL
	),
total_catalog AS (
	SELECT COUNT(DISTINCT show_id) AS total_titles
	FROM netflix
	)
SELECT country_name, COUNT(show_id) AS country_titles,
	ROUND(COUNT(show_id) * 100.0 / (SELECT total_titles FROM total_catalog), 2) AS percent_share
FROM country_titles
GROUP BY country_name
HAVING COUNT(show_id) * 1.0 / (SELECT total_titles FROM total_catalog) > 0.05
ORDER BY country_titles DESC;

-- 19. For each country, calculate the total number of titles, number of movies, and number of TV shows.
SELECT country_name,
	COUNT(DISTINCT show_id) AS total_titles,
	COUNT(DISTINCT show_id) FILTER (WHERE type = 'Movie') AS total_movies,
	COUNT(DISTINCT show_id) FILTER (WHERE type = 'TV Show') AS total_tv_shows
FROM (
	SELECT show_id, type,
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name
	FROM netflix
	WHERE country IS NOT NULL
	) t
GROUP BY country_name
ORDER BY total_titles DESC;


-- RATINGS ANALYSIS

-- 20. Which rating appears most frequently?
SELECT rating, COUNT(*) AS total_ratings
FROM netflix
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY total_ratings DESC
LIMIT 1;

-- 21. Show how often each rating appears by type.
SELECT type, rating, COUNT(*) as total_ratings
FROM netflix
WHERE rating IS NOT NULL
GROUP BY type, rating
ORDER BY 
	CASE
		WHEN type = 'Movie' THEN 1
		WHEN type = 'TV Show' THEN 2
	END,
	total_ratings DESC;


-- DURATION & SEASON ANALYSIS

-- 22. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE  type = 'TV Show' AND
	SPLIT_PART(duration, ' ',1):: numeric > 5;

-- 23. Identify the longest movie.
WITH movie_minutes AS (
	SELECT *, CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS minutes
	FROM netflix
	WHERE type = 'Movie' AND duration IS NOT NULL
	)
SELECT *
FROM movie_minutes
WHERE minutes = (SELECT MAX(minutes) FROM movie_minutes);

-- 24. How is Netflix’s movie catalog distributed across short, medium, and long-duration films?
-- Buckets: Long(>180), Medium(60-180), Short(<=60 min)
SELECT 
	CASE
		WHEN minutes > 180 THEN 'Long'  
		WHEN minutes BETWEEN 60 AND 180 THEN 'Medium'
		ELSE 'Short'
		END AS duration_bucket,
		COUNT(*) AS total_movies
FROM (
	SELECT CAST(SPLIT_PART(duration, ' ', 1)AS INT) AS minutes FROM netflix
	WHERE type ILIKE '%Movie%'
	AND duration IS NOT NULL
	)t
GROUP BY duration_bucket
ORDER BY total_movies DESC;


-- CAST & DIRECTOR INSIGHTS

-- 25. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 26. Titles without director information
SELECT * 
FROM netflix
WHERE director IS NULL OR director = '';

-- 27. Percentage of titles missing director data
SELECT 
  COUNT(*) FILTER (WHERE director IS NULL OR director = '') * 100.0 / COUNT(*) 
  AS percent_missing_director
FROM netflix;

-- 28. Show titles where actor  'Salman Khan' has appeared in.

SELECT title, casts 
FROM netflix
WHERE casts ILIKE '%Salman Khan%';

-- 29. Top 10 actors in Indian-produced movies
SELECT actor, total_movies
FROM (
	SELECT TRIM(actor) AS actor, COUNT(DISTINCT show_id) AS total_movies,
	RANK() OVER (ORDER BY COUNT(DISTINCT show_id) DESC) AS rnk
    FROM netflix
    CROSS JOIN UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor
    WHERE country ILIKE '%India%' AND type = 'Movie' AND casts IS NOT NULL
    GROUP BY actor
	) t
WHERE rnk <= 10;


-- CONTENT CLASSIFICATION

-- 30. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
-- Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
WITH new_table AS(
	SELECT *,
	CASE
		WHEN description ILIKE '%kill%' OR description ILIKE '%Violence%' THEN 'Bad Content'
		ELSE 'Good Content'
	END category	
	FROM netflix)
SELECT category, COUNT(*) as total_content
FROM new_table
GROUP BY category
ORDER BY total_content DESC;
