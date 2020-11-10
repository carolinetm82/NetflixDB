/* Create a Netflix database */
CREATE DATABASE netflix;

/* Create the 'netflix_titles' table */
DROP TABLE IF EXISTS netflix_titles;

CREATE TABLE netflix_titles( 
  show_id INT NOT NULL,
  type VARCHAR(10),
  title VARCHAR(110),
  director VARCHAR(210),
  cast VARCHAR(780),
  country VARCHAR(130),
  date_added VARCHAR(20),
  release_year INT NOT NULL,
  rating VARCHAR(10),
  duration VARCHAR(10),
  listed_in VARCHAR(80),
  description VARCHAR(280),
  PRIMARY KEY(show_id)
  );
 
 
LOAD DATA LOCAL INFILE 'netflix_titles.csv'
INTO TABLE netflix_titles 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

/* Create the 'netflix_shows' table */
DROP TABLE IF EXISTS netflix_shows;

CREATE TABLE netflix_shows (
    id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(64),
    rating VARCHAR(9),
    ratingLevel VARCHAR(126),
    ratingDescription INT NOT NULL,
    `release year` INT NOT NULL,
    `user rating score` VARCHAR(4),
    `user rating size` INT NOT NULL,
    PRIMARY KEY(id)
);


LOAD DATA LOCAL INFILE 'Netflix\ Shows.csv' 
INTO TABLE netflix_shows
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 LINES(title, rating, ratingLevel, ratingDescription,`release year`, `user rating score`, `user rating size`);

/* Display all the titles from netflix_titles where show_id is lower than 80000000 */
SELECT title 
FROM netflix_titles
WHERE show_id<80000000;

/* Show all the durations of TV Shows */
SELECT duration 
FROM netflix_titles 
WHERE type='TV SHOW';

/* Show all the movies titles present on both tables */
SELECT distinct t.title
FROM netflix_titles as t
INNER JOIN netflix_shows as s
ON t.title = s.title;

/* Calculate the total duration of the movies on netflix_titles */
ALTER TABLE netflix_titles  -- We have to create a new column named durnum with INT values since duration is a VARCHAR column
ADD COLUMN durnum INT 
GENERATED ALWAYS AS (
CASE
    WHEN type='Movie' AND length(duration)=6 THEN (LEFT(duration,2))
    WHEN type='Movie' AND length(duration)=7 THEN (LEFT(duration,3))
    WHEN type='TV Show' AND length(duration)=10 THEN (LEFT(duration,2)*10*50)
    ELSE LEFT(duration,1)*10*50 END) STORED; -- We suppose each season of a TV show is composed of ten 50 min episodes 

SELECT SUM(durnum) FROM netflix_titles WHERE type='Movie';

/* Count the number of TV shows where 'ratingLevel' field is filled*/
SELECT count(distinct s.title)
from netflix_shows as s
INNER JOIN netflix_titles as t
ON s.title = t.title
WHERE ratingLevel<>''AND type='TV Show';

/* Count the number of movies and TV Shows on both tables where release year is higher than 2016 */
SELECT count(distinct t.title) 
from netflix_titles as t 
INNER JOIN netflix_shows as s 
ON t.title = s.title 
WHERE `release year`>2016;

/* Delete 'rating' column from netflix_shows table */
ALTER TABLE netflix_shows
DROP rating;

/* Delete the 100 last rows from netflix_shows table */
DELETE FROM netflix_shows
ORDER BY id DESC
LIMIT 100;

/* Filling a empty cell with some comment in the case of “Marvel's Iron Fist” */
UPDATE netflix_shows
SET ratingLevel = 'This is a comment added'
WHERE title = 'Marvel\'s Iron Fist';