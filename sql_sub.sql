SELECT COUNT(*)
FROM inventory
WHERE film_id = (
    SELECT film_id FROM film WHERE title = 'Hunchback Impossible'
);

SELECT title, length
FROM film
WHERE length > (
    SELECT AVG(length) FROM film
);


SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
);

SELECT f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';


SELECT c.first_name, c.last_name, c.email
FROM customer c
WHERE c.address_id IN (
    SELECT a.address_id
    FROM address a
    WHERE a.city_id IN (
        SELECT ci.city_id
        FROM city ci
        WHERE ci.country_id = (
            SELECT co.country_id
            FROM country co
            WHERE co.country = 'Canada'
        )
    )
);

SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';


-- Encontrar el ID del actor más prolífico
SELECT actor_id
FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 1;

-- Luego usar ese actor_id para encontrar las películas
SELECT f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);

-- Encontrar el ID del cliente más rentable
SELECT p.customer_id
FROM payment p
GROUP BY p.customer_id
ORDER BY SUM(p.amount) DESC
LIMIT 1;

-- Luego usar ese customer_id para encontrar las películas rentadas
SELECT f.title
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE p.customer_id = (
    SELECT p.customer_id
    FROM payment p
    GROUP BY p.customer_id
    ORDER BY SUM(p.amount) DESC
    LIMIT 1
);

-- Promedio del gasto total por cliente
WITH average_spent AS (
    SELECT AVG(total_amount) AS avg_amount
    FROM (
        SELECT customer_id, SUM(amount) AS total_amount
        FROM payment
        GROUP BY customer_id
    ) AS customer_totals
)

SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (
    SELECT avg_amount FROM average_spent
);