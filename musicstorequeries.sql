-- Q1: Who is the senior most employee based on job title? 
select * from employee 
order by levels desc limit 1;

-- Q2: Which countries have the most Invoices?
select count(*) as count_invoices,billing_country from invoice
group by billing_country order by count_invoices desc;

-- Q3: What are top 3 values of total invoice?
select total from invoice order by total desc limit 3;

-- Q4: Write a query that returns one city that has the highest sum
--  of invoice totals. Return both the city name & sum of all invoice totals.
select billing_city,SUM(total) as invoice_total from invoice 
group by billing_city order by invoice_total desc;

-- Q5: Write a query that returns the person who has spent the most money.
select customer.customer_id,SUM(total) as total_spent from customer join
invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id order by total_spent desc limit 1;

-------------------------------------------------------------------------
-- Q1: Write query to return the email, first name, last name, & Genre of all 
-- Rock Music listeners. Return your list ordered alphabetically by email
-- starting with A. 
select distinct email,first_name,last_name,genre.genre_id,genre.name 
from customer 
join invoice on customer.customer_id=invoice.customer_id 
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id 
join genre on track.genre_id=genre.genre_id
where genre.name like 'Rock%'
order by email;


-- Q2: Write a query that returns the Artist name and total track count of 
-- the top 10 rock bands.
select artist.artist_id,artist.name,count(artist.artist_id) as count_track
from artist join album on artist.artist_id=album.artist_id join track on
album.album_id=track.album_id   
where track.genre_id='1'
group by artist.artist_id order by count_track 
desc limit 10; 


-- Q3: Return the Name and Milliseconds for each track. Order by the song 
-- length with the longest songs listed first. 
select name,milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

-----------------------------------------------------------------------------

-- Q1: Find how much amount spent by each customer on artists? Write a query 
-- to return customer name, artist name and total spent
select customer.first_name || ' ' || customer.last_name as customer_name,
artist.name, sum(invoice_line.unit_price * invoice_line.quantity)
from customer join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on artist.artist_id = album.artist_id
group by customer.first_name, customer.last_name, artist.name;


-- Q2: We want to find out the most popular music Genre for each country. We 
-- determine the most popular genre as the genre with the highest amount of 
-- purchases. Write a query that returns each country along with the top 
--  Genre.For countries where the maximum number of purchases is shared 
-- return all Genres. 
with genrepopularity as (
select c.country, g.name as genre_name, count(il.invoice_line_id) as purchases,
rank() over (partition by c.country order by count(il.invoice_line_id) desc)
as rnk from invoice_line il join invoice i on i.invoice_id = il.invoice_id
join customer c on c.customer_id = i.customer_id join track t on 
t.track_id = il.track_id join genre g on g.genre_id = t.genre_id
group by c.country, g.genre_id, g.name)
select country, genre_name, purchases from genrepopularity where rnk = 1
order by country;


-- Q3: Write a query that determines the customer that has spent the 
-- most on music for each country.Write a query that returns the country along 
-- with the top customer and how much they spent. For countries where the 
-- top amount spent is shared, provide all customers who spent this amount. 
with CustomerSpending as (
select c.country,c.first_name || ' ' || c.last_name as customer_name,
sum(il.unit_price * il.quantity) as total_spent,
rank() over (partition by c.country order by sum(il.unit_price * il.quantity) 
desc) as rnk from customer c join invoice i on c.customer_id = i.customer_id
 join invoice_line il on i.invoice_id = il.invoice_id group by 
 c.country, c.customer_id, c.first_name, c.last_name)
select country, customer_name, total_spent from CustomerSpending
where rnk = 1 order by country;




