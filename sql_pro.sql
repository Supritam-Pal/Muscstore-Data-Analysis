
-- EASY:
	
-- Q1: Who is the senior most employee vbased on job title?
select * from employee
order by levels desc
limit 1;

-- Q2: Which Countres have the most invoices?
select count(*) as c , billing_country
from invoice
group by billing_country
order by c desc;

-- Q3:What are top 3 values of total invoices?
select * from invoice
order by total desc 
limit 3;


-- Q4: Write a query to return one city that has highest sum of invoice total.
select sum(total) as total , billing_city
from invoice
group by billing_city
order by total desc;

-- Q5: Write  a query that returns the person who has spent the most money.
   select c.customer_id , c.first_name , c.last_name , SUM(i.total) as total
   from customer as c
   join invoice as i on c.customer_id = i.customer_id 
   group by c.customer_id
   order by total desc
   limit 1;


-- MODERATE:

-- Q1: Write a query to return the email, first name,last name & Genre of all Rock Music listeners. 
--    Return your list ordered alaphabetically by email starting with A.
      SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
      FROM customer
      JOIN invoice ON invoice.customer_id = customer.customer_id
      JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
      JOIN track ON track.track_id = invoice_line.track_id
      JOIN genre ON genre.genre_id = track.genre_id
      WHERE genre.name LIKE 'Rock'
      ORDER BY email;

-- Q2: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
   SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
   FROM track
   JOIN album ON album.album_id = track.album_id
   JOIN artist ON artist.artist_id = album.artist_id
   JOIN genre ON genre.genre_id = track.genre_id
   WHERE genre.name LIKE 'Rock'
   GROUP BY artist.artist_id
   ORDER BY number_of_songs DESC
   LIMIT 10;

--  Q3: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
    SELECT name,milliseconds
    FROM track
    WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
    ORDER BY milliseconds DESC;

-- Advance

 -- Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 

 WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--  Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


-- Q3:Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH customer_total AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.country,
        SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
),
country_max AS (
    SELECT
        country,
        MAX(total_spent) AS max_spent
    FROM customer_total
    GROUP BY country
)
SELECT
    ct.country,
    ct.customer_name,
    ct.total_spent
FROM customer_total ct
JOIN country_max cm 
  ON ct.country = cm.country 
  AND ct.total_spent = cm.max_spent
ORDER BY ct.country;
