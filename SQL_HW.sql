use sakila;
#1a. Display the first and last names of all actors from the table actor.
select first_name,last_name from actor;
#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name," ",last_name) as 'Actor Name' from actor;
#2a. Find the ID number, first name and last name of whoms first name is Joe.
select actor_id, first_name, last_name from actor where first_name='Joe';
#2b. Find all actors whose last name contain the letters GEN
select * from actor where last_name like '%gen%';
#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select last_name, first_name from actor where last_name like '%li%';
#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan','Bangladesh','China');
#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor add column middle_name varchar(45) after first_name;
#3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor modify column middle_name blob;
#3c. Now delete the middle_name column.
alter table actor drop column middle_name;
#4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as 'actor_number' from actor group by last_name;
#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as 'actor_number' from actor group by last_name having actor_number >1;
#4c. Change Groucho Williams to Harpo Williams
update actor set first_name='Harpo' where last_name='Williams' and first_name='Groucho';
#4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name='Groucho' where last_name='Williams' and first_name='Harpo';
#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address 
	from staff s
    left join address a
    on (s.address_id=a.address_id);
#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select first_name, sum(amount) from(
	select first_name, amount
	from staff s
    left join payment p
    on (s.staff_id=p.staff_id)
    where p.payment_date like '2005-08%'
) as b6 group by first_name;
#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title, count(actor_id) as 'number_of_actors' from(
	select title, actor_id 
    from film f 
    inner join film_actor fa 
    on (f.film_id=fa.film_id)
) as c6 group by title;
#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(title) as 'number_in_inventory' from(
	select title 
    from film f 
    inner join inventory i 
    on (f.film_id=i.film_id)
    where title='Hunchback Impossible'
) as c6 group by title;
#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select e6.last_name, sum(e6.amount) as 'total_paid' from(
	select amount, last_name, p.customer_id
    from payment p
    left join customer c
    on (p.customer_id=c.customer_id)
)as e6 group by customer_id 
order by e6.last_name;
#7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film
where language_id in (
	select language_id 
    from language l
    where l.name = 'English'
) 
and (title like 'K%' or title like 'Q%');
#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name 
from actor where actor_id in (
	select actor_id 
    from film_actor where film_id in(
		select film_id 
        from film where title='Alone Trip'
    )
);
#7c. Find the name and email address of all Canadian customers.
select first_name, last_name, email 
from customer where address_id in (
	select address_id 
    from address where city_id in (
		select city_id 
		from city
		left join country
        on (city.country_id=country.country_id)
        where country='Canada'
    )
);
#7d. Identify all movies categorized as famiy films.
select title from film where film_id in (
	select film_id 
    from film_category f
    left join category c
    on (f.category_id=c.category_id)
    where name='Family'
);

#7e. Display the most frequently rented movies in descending order.
select title, count(title) as 'times_rented'
from inventory i
left join film f
on (i.film_id=f.film_id)
right join rental r
on (r.inventory_id=i.inventory_id)
group by title
order by times_rented desc;

#7f. Write a query to display how much business, in dollars, each store brought in.
select store_id, sum(amount) as 'total_business'
from rental r
left join inventory i
on (r.inventory_id=i.inventory_id)
right join payment p
on (r.rental_id=p.rental_id)
group by store_id;

#7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country 
from city
left join country
on (city.country_id=country.country_id)
right join address
on (city.city_id=address.city_id)
right join store
on (address.address_id=store.address_id);

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name, sum(amount) as 'gross_revenue'
from category
right join film_category
on (category.category_id=film_category.category_id)
right join inventory 
on (film_category.film_id=inventory.film_id)
right join rental
on (inventory.inventory_id=rental.inventory_id)
right join payment
on (rental.rental_id=payment.rental_id)
group by name
order by gross_revenue desc limit 5;

#8a. Use the solution from the problem above to create a view
create view top_five_genres as
select name, sum(amount) as 'gross_revenue'
from category
right join film_category
on (category.category_id=film_category.category_id)
right join inventory 
on (film_category.film_id=inventory.film_id)
right join rental
on (inventory.inventory_id=rental.inventory_id)
right join payment
on (rental.rental_id=payment.rental_id)
group by name
order by gross_revenue desc limit 5;

#8b. How would you display the view that you created in 8a?
select * from top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view if exists top_five_genres;



