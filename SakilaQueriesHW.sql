USE sakila;

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
ALTER TABLE actor ADD COLUMN Actor_Name VARCHAR(50);


SELECT CONCAT(first_name," ",last_name)
FROM actor;

UPDATE actor
SET Actor_Name = CONCAT(first_name," ",last_name);

SELECT first_name, last_name, Actor_Name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query you would
-- use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN
SELECT first_name, last_name, actor_id
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the 
-- following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan","Bangladesh","China");

-- 3a. You want to keep a description of each actor. You don't think you
-- will be performing queries on a description, so create a column in the 
-- table actor named description and use the data type BLOB
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD COLUMN description BLOB(2000);

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

UPDATE actor
SET Actor_Name = CONCAT(first_name," ",last_name);

SELECT *
FROM actor
WHERE last_name = "Williams";


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

UPDATE actor
SET Actor_Name = CONCAT(first_name," ",last_name);

SELECT *
FROM actor
WHERE last_name = "Williams";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- This is what this query shows in the results grid:
-- CREATE TABLE `address` (
 -- `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  -- `address` varchar(50) NOT NULL,
 --  `address2` varchar(50) DEFAULT NULL,
  -- `district` varchar(20) NOT NULL,
  -- `city_id` smallint(5) unsigned NOT NULL,
  -- `postal_code` varchar(10) DEFAULT NULL,
 -- `phone` varchar(20) NOT NULL,
  -- `location` geometry NOT NULL,
 -- `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  -- PRIMARY KEY (`address_id`),
  -- KEY `idx_fk_city_id` (`city_id`),
 --  SPATIAL KEY `idx_location` (`location`),
 --  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
-- ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

SELECT s.first_name,
	s.last_name,
	a.address
FROM staff s
INNER JOIN address a
ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
-- Create Table to do caculations sorted by staff member by joining staff and payment tables to create new table
CREATE TABLE staff_payment AS
SELECT s.first_name,
	s.last_name,
	p.amount,
    p.payment_date
FROM staff s
INNER JOIN payment p
ON s.staff_id = p.staff_id;

-- 6b. final query to determine how much was paid by staff member in August 2005 using newly created joined table:
SELECT SUM(amount) AS August_2005_Total_Paid, first_name, last_name
FROM staff_payment
WHERE payment_date LIKE '%2005-08-%'
GROUP BY first_name, last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
CREATE TABLE film_summary AS
SELECT f.title,
	a.actor_id
FROM film f
INNER JOIN film_actor a
ON f.film_id = a.film_id;

-- 6c. final query to count number of actors per film.
SELECT COUNT(actor_id) AS Total_Actors, title AS Film
FROM film_summary
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- CREATE TABLE film_count AS
SELECT title,
(SELECT COUNT(*) FROM inventory WHERE film.film_id = inventory.film_id)
AS 'Number of copies'
FROM film
WHERE film.title = 'HUNCHBACK IMPOSSIBLE';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
CREATE TABLE customer_payments AS
SELECT c.first_name,
c.last_name,
p.amount
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id;

SELECT *
FROM customer_payments;

-- use this new table to calculate total each customer has paid
SELECT SUM(amount) AS Total_amount_paid, first_name, last_name
FROM customer_payments
GROUP BY last_name, first_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title AS 'English language movies starting with K or Q'
FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id  IN 
(
	SELECT language_id
    FROM language
    WHERE name = "English"
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'ALONE TRIP'
  )
);

-- 7c. You want to run an email marketing campaign in Canada, for which 
-- you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
-- here is is the solution using subqueries:
SELECT  first_name, last_name, email
FROM customer
WHERE address_id IN 
(
SELECT address_id
FROM address
WHERE city_id IN
	(
    SELECT city_id
    FROM city
    WHERE country_id IN
		(
        SELECT country_id
        FROM country
        WHERE country = "Canada"
        )
	)
);

-- Here is the query getting the same result with joins:
SELECT first_name, last_name, email
FROM customer AS c
JOIN address AS a ON c.address_id = a.address_id
JOIN city AS i ON i.city_id = a.city_id
JOIN country AS t ON t.country_id = i.country_id
WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
--       Identify all movies categorized as family films.

SELECT  title as "Family Movies"
FROM film
WHERE film_id IN 
(
SELECT film_id
FROM film_category
WHERE category_id IN
	(
    SELECT category_id
    FROM category
    WHERE name = "Family"
	)
);

-- 7e. Display the most frequently rented movies in descending order.
SELECT COUNT(f.title) AS "Times Rented", f.title AS Movie
FROM rental AS r
JOIN inventory AS i ON r.inventory_id= i.inventory_id
JOIN film AS f ON i.film_id = f.film_id
GROUP BY f.title ORDER BY COUNT(f.title ) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT t.store_id AS Store, SUM(p.amount) AS "Total Business in $"
FROM store AS t
JOIN staff as s ON t.store_id = s.store_id
JOIN payment as p ON s.staff_id = p.staff_id
GROUP BY t.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, y.country
FROM store AS s
JOIN address as a ON a.address_id = s.store_id
JOIN city as c ON a.city_id = c.city_id
JOIN country as y ON y.country_id = c.country_id
GROUP BY s.store_id;

-- 7h. List the top five genres in gross revenue in descending order. 

--       (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name AS Genre, SUM(p.amount) AS "Gross Revenue"
FROM category AS c
JOIN film_category as fc ON c.category_id = fc.category_id
JOIN inventory as i ON i.film_id = fc.film_id
JOIN rental as r ON r.inventory_id = i.inventory_id
JOIN payment as p ON r.rental_id = p.rental_id
GROUP BY c.name ORDER BY SUM(p.amount) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way
--       of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
--       If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres_by_gross_revenue AS
SELECT c.name AS Genre, SUM(p.amount) AS "Gross Revenue"
FROM category AS c
JOIN film_category as fc ON c.category_id = fc.category_id
JOIN inventory as i ON i.film_id = fc.film_id
JOIN rental as r ON r.inventory_id = i.inventory_id
JOIN payment as p ON r.rental_id = p.rental_id
GROUP BY c.name ORDER BY SUM(p.amount) DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM sakila.top_five_genres_by_gross_revenue;
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres_by_gross_revenue;








