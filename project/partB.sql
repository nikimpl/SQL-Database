-- 1. Αριθμός ταινιών ανά χρόνο
SELECT EXTRACT (YEAR FROM release_date), COUNT(id)
FROM "PROJECT".Movies_Metadata
GROUP BY EXTRACT (YEAR FROM release_date)
ORDER BY EXTRACT (YEAR FROM release_date)

-- 2. Αριθμός ταινιών ανά είδος(genre)
SELECT y.x->'name' "name", COUNT(id)
FROM "PROJECT".Movies_Metadata
CROSS JOIN LATERAL (SELECT jsonb_array_elements("PROJECT".Movies_Metadata.genres::jsonb) x) y
GROUP BY y.x;

-- 3. Αριθμός ταινιών ανά είδος(genre) και ανά χρόνο
SELECT y.x->'name' "name", EXTRACT (YEAR FROM release_date), count(id)
FROM "PROJECT".Movies_Metadata
CROSS JOIN LATERAL (SELECT jsonb_array_elements("PROJECT".Movies_Metadata.genres::jsonb) x) y
GROUP BY y.x, EXTRACT (YEAR FROM release_date);

-- 4. Μέση βαθμολογία (rating) ανά είδος (ταινίας)
SELECT y.x->'name' "name", AVG(rating)
FROM "PROJECT".Movies_Metadata
INNER JOIN "PROJECT".Ratings ON "PROJECT".Movies_Metadata.id = "PROJECT".Ratings.movieId
CROSS JOIN LATERAL (SELECT jsonb_array_elements("PROJECT".Movies_Metadata.genres::jsonb) x) y
GROUP BY y.x;

-- 5. Αριθμός από ratings ανά χρήστη
SELECT userid, count(rating) AS NumberOfRatings
FROM "PROJECT".Ratings
GROUP BY userid
ORDER BY userid;

-- 6. Μέση βαθμολογία (rating) ανά χρήστη
SELECT userid, AVG(rating)
FROM "PROJECT".Ratings
GROUP BY userid
ORDER BY userid;

/*Τέλος δημιουργήστε ένα view table και αποθηκεύστε για κάθε χρήστη τον αριθμό των ratings
που έχει κάνει καθώς και τη μέση βαθμολογία που έχει βάλει. Παίρνουμε κάποιο insight από
αυτή τη σχέση?*/

CREATE VIEW ViewTable AS
SELECT DISTINCT userid, COUNT(rating), AVG(rating)
FROM "PROJECT".Ratings
GROUP BY userid
ORDER BY userid;

/*To insight που παίρνουμε από το ViewTable είναι κατά πόσο επηρεάζεται η μέση βαθμολογία 
που δίνει κάθε κριτής ανάλογα με το πλήθος των κριτικών που κάνει, δηλαδή η αυστηρότητα του 
κριτή έχει σχέση με το πόσες κριτικές κάνει.*/