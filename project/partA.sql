--Table Links
CREATE TABLE "PROJECT".Links(
	movieid int,
	imdbid int,
	tmdbid int
);

--Διαγράφουμε τα διπλότυπα
SELECT * INTO "PROJECT".copy_links
FROM "PROJECT".Links;

DELETE FROM "PROJECT".links where movieid in (
select movieid
	from(select movieid,
	ROW_NUMBER() OVER (
            PARTITION BY 
			imdbid,
			tmdbid
            ORDER BY 
             imdbid,
			tmdbid
	) row_num
		from "PROJECT".copy_links
)t

DROP TABLE "PROJECT".copy_links;
		
--45843 records
-- 0 deleted

--Θέτουμε το primary key
ALTER TABLE "PROJECT".Links ADD PRIMARY KEY (movieid);


--Table Ratings
CREATE TABLE "PROJECT".Ratings(
	userId int,
	movieId int,
	rating numeric(5, 1),
	timestamp int
);

--100004 records

--Θέτουμε το primary key
ALTER TABLE "PROJECT".Ratings ADD PRIMARY KEY (userId, movieId);


--Table Movies_Metadata	
CREATE TABLE "PROJECT".Movies_Metadata(
	adult boolean,
	belongs_to_collection varchar(190),
	budget int,
	genres text,
	homepage varchar(250),
	id int,
	imdb_id varchar(10),
	original_language varchar(10),
	original_title varchar(110),
	overview varchar(1000),
	popularity numeric(12, 6),
	poster_path varchar(40),
	production_companies varchar(1260),
	production_countries varchar(1040),
	release_date date,
	revenue int,
	runtime numeric(5, 1),
	spoken_languages varchar(770),
	status varchar(20),
	tagline varchar(300),
	title varchar(110),
	video boolean,
	vote_average numeric(5, 1),
	vote_count int
);

--remove tt from imbd_id and change its type to int
UPDATE "PROJECT".Movies_Metadata SET imdb_id = replace(imdb_id, 'tt','');
ALTER TABLE "PROJECT".Movies_Metadata ALTER COLUMN imdb_id TYPE int USING imdb_id::integer;

--replace ' with " in genres
UPDATE "PROJECT".Movies_Metadata
SET genres = REPLACE(genres,E'\'', E'\"');


--Διαγράφουμε τα διπλότυπα
ALTER TABLE "PROJECT".movies_metadata add temp serial;

SELECT * INTO "PROJECT".copy_movie
from "PROJECT".movies_metadata

DELETE FROM "PROJECT".movies_metadata where temp in (
select temp
	from(select temp,
	ROW_NUMBER() OVER (
            PARTITION BY 
			id
            ORDER BY 
            id
	) row_num
		from "PROJECT".copy_movie
)t

WHERE t.row_num > 1);

--45463 records originally
--30 deleted
--45433 records left

DROP TABLE "PROJECT".copy_movie;

ALTER TABLE "PROJECT".Movies_Metadata DROP COLUMN temp;

--Θέτουμε το primary key
ALTER TABLE "PROJECT".Movies_Metadata ADD PRIMARY KEY (id);


--Table Keywords
CREATE TABLE "PROJECT".Keywords(
	id int,
	keywords text
);

--Διαγράφουμε τα διπλότυπα
ALTER TABLE "PROJECT".keywords add temp serial;

SELECT * INTO "PROJECT".copy_key
from "PROJECT".keywords

DELETE FROM "PROJECT".keywords where temp in (
select temp
	from(select temp,
	ROW_NUMBER() OVER (
            PARTITION BY 
			id,
			keywords
            ORDER BY 
            id,
			keywords
	) row_num
		from "PROJECT".copy_key
)t

WHERE t.row_num > 1);

DROP TABLE "PROJECT".copy_key;

ALTER TABLE "PROJECT".Keywords DROP COLUMN temp;

--46419 records originally
--987 deleted
--45432 records left

--Θέτουμε το primary key
ALTER TABLE "PROJECT".Keywords ADD PRIMARY KEY (id);


--Table Credits
CREATE TABLE "PROJECT".Credits(
	moviecast text, 
	crew text,
	id int
);

--Διαγράφουμε τα διπλότυπα
ALTER TABLE "PROJECT".credits add temp serial;

DELETE FROM "PROJECT".credits where temp in (
select temp
	from(select temp,
	ROW_NUMBER() OVER (
            PARTITION BY 
			id
            ORDER BY 
            id
			) 
	row_num
		from "PROJECT".credits
)t

WHERE t.row_num > 1);

-- 45475 records originally
-- 44 deleted
-- 45431 records left

--Θέτουμε το primary key
ALTER TABLE "PROJECT".Credits ADD PRIMARY KEY (id);


/*Διαγράφουμε δεδομένα ταινιών οι οποίες δεν υπάρχουν στον
πίνακα “movies_metadata” αλλά υπάρχουν σε κάποιον από τους υπόλοιπους πίνακες*/
DELETE FROM "PROJECT".Ratings WHERE movieId IN (
SELECT movieId FROM "PROJECT".Ratings 
LEFT OUTER JOIN "PROJECT".Movies_Metadata ON "PROJECT".Movies_Metadata.id = "PROJECT".Ratings.movieId
WHERE "PROJECT".Movies_Metadata.id is null);

--deleted 55015

DELETE FROM "PROJECT".Links WHERE movieid IN (
SELECT movieid FROM "PROJECT".Links 
LEFT OUTER JOIN "PROJECT".Movies_Metadata ON "PROJECT".Movies_Metadata.id = "PROJECT".Links.movieid
WHERE "PROJECT".Movies_Metadata.id is null);

--deleted 38208

DELETE FROM "PROJECT".Keywords WHERE id IN (
SELECT "PROJECT".Keywords.id FROM "PROJECT".Keywords 
LEFT OUTER JOIN "PROJECT".Movies_Metadata ON "PROJECT".Movies_Metadata.id = "PROJECT".Keywords.id
WHERE "PROJECT".Movies_Metadata.id is null);

--deleted 0

DELETE FROM "PROJECT".Credits WHERE id IN (
SELECT "PROJECT".Credits.id FROM "PROJECT".Credits 
LEFT OUTER JOIN "PROJECT".Movies_Metadata ON "PROJECT".Movies_Metadata.id = "PROJECT".Credits.id
WHERE "PROJECT".Movies_Metadata.id is null);

--deleted 0


--Θέτουμε τα foreign keys
ALTER TABLE "PROJECT".Ratings ADD FOREIGN KEY (movieId) REFERENCES "PROJECT".Movies_Metadata(id);
ALTER TABLE "PROJECT".Links ADD FOREIGN KEY (movieid) REFERENCES "PROJECT".Movies_Metadata(id);
ALTER TABLE "PROJECT".Keywords ADD FOREIGN KEY (id) REFERENCES "PROJECT".Movies_Metadata(id);
ALTER TABLE "PROJECT".Credits ADD FOREIGN KEY (id) REFERENCES "PROJECT".Movies_Metadata(id);
