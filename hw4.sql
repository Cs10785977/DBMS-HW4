use hw4_db;
-- Adding primary keys to my already uploaded tables. 
alter table actor 
	add constraint PK_actor primary key (actor_id); 

alter table address 
	add constraint PK_address primary key (address_id); 
    
alter table category 
	add constraint PK_category primary key (category_id); 
    
alter table city 
	add constraint PK_city primary key (city_id); 
    
alter table country 
	add constraint PK_country primary key (country_id); 
    
alter table customer 
	add constraint PK_customer primary key (customer_id); 
    
alter table film 
	add constraint PK_film primary key (film_id);
    
alter table film_actor 
	add constraint PK_film_actor primary key (actor_id, film_id); 
    
alter table rental 
	add constraint PK_rental primary key (rental_id); 
    
alter table staff 
	add constraint PK_staff primary key (staff_id); 
    
alter table store 
	add constraint PK_store primary key (store_id); 
    
alter table film_category 
	add constraint PK_film_category primary key (film_id, category_id); 
    
alter table inventory 
	add constraint PK_inventory primary key (inventory_id); 
    
alter table language 
	add constraint PK_language primary key (language_id); 
    
alter table payment 
	add constraint PK_payment primary key (payment_id); 
-- Adding my foriegn keys to my already uploaded table 
-- address links to city
alter table address 
	add constraint FK_address_city foreign key (city_id) references city(city_id); 
-- city links to country    
alter table city 
	add constraint FK_city_country foreign key (country_id) references country(country_id); 
-- customer links to store and address    
alter table customer 
	add constraint FK_customer_store foreign key (store_id) references store(store_id), 
	add constraint FK_customer_address foreign key (address_id) references address(address_id); 
-- film links to language    
alter table film 
	add constraint FK_film_language foreign key (language_id) references language(language_id); 
-- film_actor links actor and film    
alter table film_actor 
	add constraint FK_film_actor_actor foreign key (actor_id) references actor(actor_id), 
		add constraint FK_film_actor_film foreign key (film_id) references film(film_id); 
-- rental is linked too inventory, customer, and staff
alter table rental 
	add constraint FK_rental_inventory foreign key (inventory_id) references inventory(inventory_id), 
	add constraint FK_rental_customer foreign key (customer_id) references customer(customer_id), 
	add constraint FK_rental_staff foreign key (staff_id) references staff(staff_id); 
-- staff is linked to address and store    
alter table staff 
	add constraint FK_staff_address foreign key (address_id) references address(address_id), 
		add constraint FK_staff_store foreign key (store_id) references store(store_id); 
 -- store links to address       
alter table store 
	add constraint FK_store_address foreign key (address_id) references address(address_id);
-- film_category links film and category toghther.
alter table film_category 
	add constraint FK_film_category_film foreign key (film_id) references film(film_id), 
	add constraint FK_film_category_category foreign key (category_id) references category(category_id);
-- inventory is linked to film and store
alter table inventory 
	add constraint FK_inventory_film foreign key (film_id) references film(film_id), 
	add constraint FK_inventory_store foreign key (store_id) references store(store_id); 
-- payment is linked to customer, staff, rental
alter table payment 
	add constraint FK_payment_customer foreign key (customer_id) references customer(customer_id), 
	add constraint FK_payment_staff foreign key (staff_id) references staff(staff_id), 
    add constraint FK_payment_rental foreign key (rental_id) references rental(rental_id);
    

-- Extra Constraints
alter table rental
	modify column rental_date datetime; -- changes the type from text to datetime so dates will be valid.
    
alter table payment
	modify column payment_date datetime;
    
alter table rental
	modify column return_date datetime;
-- prevents dupliucate rental transactions
alter table rental
	add constraint UQ_rental_transaction unique (rental_date, inventory_id, customer_id);
-- Restricts category names to predetermined set
alter table category
	add constraint category_name check (name in ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 'Children', 
											'Drama', 'Horror', 'Action', 'Classics', 'Games', 'New', 
											'Documentary', 'Sports', 'Music'));
-- film constraints                                            
alter table film
	add constraint film_special_features check (special_features in 
	('Behind the Scenes', 'Commentaries', 'Deleted Scenes', 'Trailers')),
	add constraint film_rental_duration CHECK (rental_duration BETWEEN 2 AND 8),
	add constraint film_rental_rate CHECK (rental_rate BETWEEN 0.99 AND 6.99),
	add constraint film_length CHECK (length BETWEEN 30 AND 200),
	add constraint film_replacement_cost CHECK (replacement_cost BETWEEN 5.00 AND 100.00),
	add constraint film_rating CHECK (rating IN ('PG', 'G', 'NC-17', 'PG-13', 'R'));
-- Customer_active must be a 0 or a 1    
alter table customer
	add constraint customer_active check (active in (0, 1));
-- payment must be greater then 0
alter table payment
	add constraint payment_amount check (amount >= 0);
    
/* **************************************************************************************************************************************************************
Query 1. What is the average length of films in each category? List the results in alphabetic order of categories.
The query joins three table film, film_categorycategory, and category
then groups by category name and sorts alphabetically.

**************************************************************************************************************************************************************** */
select category.name as Category_Name, round(avg(film.length), 2) as Average_Length -- displays the cateogry and computes avg film length
from film 
inner join film_category using(film_id)
inner join category using(category_id)
group by category.name
order by category.name; -- orders alphabetically

/* **************************************************************************************************************************************************************
Query 2. Which categories have the longest and shortest average film lengths?
The query joins three table film, film_categorycategory, and category
Then finds the longest, and shortest average film length. Uses subqueres to gather this result
**************************************************************************************************************************************************************** */
select category.name as Category_Name, round(avg(film.length), 2) as Average_Length
from film 
inner join film_category using(film_id)
inner join category using(category_id)
group by category.name
having round(avg(film.length), 2) = (
    select max(avg_length) -- subquerry for max length
    from (
        select round(avg(f2.length), 2) as avg_length
		from film f2 
        inner join film_category film_cat2 using(film_id)
		inner join category category2 using(category_id)
	group by category2.name
    ) as subquery
)
or round(avg(film.length), 2) = (
    select min(avg_length) -- subquerry for min length
    from (
        select round(avg(f3.length), 2) as avg_length
        from film f3 
        inner join film_category film_cat3 using(film_id)
		inner join category category3 using(category_id)
	group by category3.name
    ) as subquery
);
/* **************************************************************************************************************************************************************
Query 3. Which customers have rented action but not comedy or classic movies?
We will be using 6 tables for this querry, customer, rental, inverntory, film, film_category, and category. This will include inner joins and left joins
There will be a main querry and a sub querry. The main querry will find customers who rented action movies. 
The subquerry which will be left joined with the main querry contains customers who rented comedy or classic movies. 
**************************************************************************************************************************************************************** */
select distinct customer.customer_id, customer.first_name, customer.last_name
from customer 
inner join rental using (customer_id)
inner join inventory using (inventory_id)
inner join film using (film_id)
inner join film_category using (film_id)
inner join category using (category_id)
left join(
	select distinct c2.customer_id  -- subquerry to find customer who rented comedys or classic
	from customer c2 
	inner join rental r2 using (customer_id)
	inner join inventory i2 using (inventory_id)
	inner join film f2 using (film_id)
	inner join film_category fc2 using (film_id)
	inner join category cat2 using (category_id)
    where trim(cat2.name) in ('Comedy' , 'Classics')
) as containsC using(customer_id)
where lower(category.name) in ('action') -- includes people who rented action movies
and containsC.customer_id is null -- discludes people who rented comedy and classics.
order by customer.first_name, customer.last_name;

/* **************************************************************************************************************************************************************
Query 4. Which actor has appeared in the most English-language movies?
This will have an inner join between the tables actor, film_actor, film, and language
We will need to count the filtered films for only enlglish films, and then group by actors.
Finally order by the count descending and limit it by one to get the top actor.
**************************************************************************************************************************************************************** */
select actor.actor_id, actor.first_name, actor.last_name, count(film.film_id) as English_Films 
from actor
inner join film_actor using(actor_id)
inner join film using (film_id)
inner join language using (language_id)
where language.name = 'English' -- language must be english
group by actor.actor_id, actor.first_name, actor.last_name
order by English_Films desc
limit 1; -- limits top actor

/* **************************************************************************************************************************************************************
Query 5. How many distinct movies were rented for exactly 10 days from the store where Mike works?
For this querry we will need to connect four of our tables using an inner join, rental, inventory, film and staff.
SQL has a function called DATEDIFF which can calculate the differnce bwteen two dates. 
**************************************************************************************************************************************************************** */
select count(distinct film.film_id) as Movie_Rented_10_days
from rental
inner join inventory using (inventory_id)
inner join film using (film_id)
inner join staff on inventory.store_id = staff.store_id
where staff.first_name = 'MIKE' -- filters for staff with first name mike
and datediff(rental.return_date, rental.rental_date) = 10; -- special SQL function which does the math automatically

/* **************************************************************************************************************************************************************
Query 6. Alphabetically list actors who appeared in the movie with the largest cast of actors.
joins actors with film_actor to find which actor is in which film. Then creates a subquerry to find how many people(cast) are in each film. 
Finally a third querry is created to find the maximum cast in a certain film.
**************************************************************************************************************************************************************** */
select actor.first_name, actor.last_name
from actor 
inner join film_actor using (actor_id)
where film_actor.film_id in( 
	select film_id -- finds number of people in each cast
    from film_actor
    group by film_id
    having count(actor_id) =( -- selects the film with the largest cast
		select max(actor_count)
        from (
        select count(actor_id) as actor_count
        from film_actor
        group by film_id
	) as subquerry
)
)
order by actor.last_name, actor.first_name;







