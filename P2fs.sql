
-- Project 2 --
-- part1
use project2;

select * from cust_dimen;
select * from market_fact;
select * from orders_dimen;
select * from prod_dimen;
select * from shipping_dimen;


#Question 2.1.Find the top 3 customers who have the maximum number of orders
select * from cust_dimen;
select * from orders_dimen;
select * from market_fact;
with subquery as (select customer_name,cd.cust_id,count(ord_id) as cn,dense_rank()over(order by count(ord_id) desc) as dr
from cust_dimen cd join market_fact mf
on cd.cust_id=mf.cust_id
group by cd.cust_id
order by cn desc)select * from subquery where dr<=3;

#Question 2.2 Create a new column DaysTakenForDelivery that contains the date 
#difference between Order_Date and Ship_Date.
select o.order_id,order_date, ship_date, 
datediff(str_to_date(ship_date,"%d-%m-%Y"), str_to_date(order_date,"%d-%m-%Y")) daystakenfordelivery
from orders_dimen o join shipping_dimen s
using (order_id)
order by o.order_id;

#Question 2.3 Find the customer whose order took the maximum time to get delivered.
select cust_id,o.order_id, ord_id,order_date, ship_date, 
datediff(str_to_date(ship_date,"%d-%m-%Y"), str_to_date(order_date,"%d-%m-%Y")) daystakenfordelivery
from market_fact m join orders_dimen o
using (ord_id)
join shipping_dimen s
using (order_id)
order by daystakenfordelivery desc
limit 1;

#Question 2.4 Retrieve total sales made by each product from the data (use Windows function)
select prod_id, round(sum(sales),3) sales
from market_fact
group by prod_id
order by sales desc;

#Question 2.5 Retrieve the total profit made from each product from the data (use windows function)
select prod_id, round(sum(profit),3) profit
from market_fact
group by prod_id
order by profit desc;

#Question 2.6 Count the total number of unique customers in January and how many of them came 
#back every month over the entire year in 2011

select cust_id, count(distinct cust_id) from market_fact m join orders_dimen o 
using (ord_id) 
where str_to_date(order_date,"%d-%m-%Y") between "2011-01-01" and "2011-01-31"
group by cust_id;

select cust_id, count(distinct cust_id) from 
(select cust_id, count(distinct cust_id) from market_fact m join orders_dimen o 
using (ord_id) 
where str_to_date(order_date,"%d-%m-%Y") between "2011-01-01" and "2011-01-31"
group by cust_id)T
where cust_id in (select cust_id from market_fact where ord_id in
(select ord_id from orders_dimen 
where str_to_date(order_date,"%d-%m-%Y") between "2011-02-01" and "2011-12-31"))
group by cust_id;

#Part 2 – Restaurant:
select * from chefmozaccepts;
select * from chefmozcuisine;
select * from chefmozhours4;
select * from chefmozparking;
select * from geoplaces2;
select * from usercuisine;
select * from userpayment;
select * from userprofile;
select * from rating_final;

#Question 2.1 - We need to find out the total visits to all restaurants under all alcohol categories available.

select count(userid )from rating_final where placeid in 
(select placeid from geoplaces2 where alcohol not like'No_alcohol_served');

#Question 2.2 -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.

select * from rating_final;
select * from geoplaces2;

select alcohol,price,avg(rating)
from geoplaces2 gp join rating_final rf
on gp.placeid=rf.placeid
where alcohol not like'No_alcohol_served'
group by alcohol,price;

#Question 2.3 Let’s write a query to quantify that what are the parking availability 
#as well in different alcohol categories along with the total number of restaurants.

select distinct parking_lot, alcohol,
count(placeID) 
from chefmozparking join geoplaces2
using (placeID)
group by parking_lot, alcohol
order by parking_lot;

#Question 2.4 -Also take out the percentage of different cuisine in each alcohol type.
select *,round(t.count_cui/sum(t.count_cui) over(partition by t.alcohol),2)*100 as  percentage_of_different_cuisine
from
(select g.placeid,alcohol,rcuisine,count(g.placeid) count_cui
from geoplaces2 g join chefmozcuisine c
where g.placeID=c.placeID
group by rcuisine,alcohol
order by alcohol) t;

#Questions 2.5 - let’s take out the average rating of each state
select state, avg(rating) 
from geoplaces2 join rating_final r
using (placeID)
group by state
having state!="?";

#Questions 2.6 'Tamaulipas' Is the lowest average rated state. 
#Quantify the reason why it is the lowest rated by providing the summary on the basis of 
#State, alcohol, and Cuisine.

select state,placeID, alcohol, rcuisine 
from geoplaces2 join chefmozcuisine
using (placeID)
group by placeID
having state="Tamaulipas";

#Question 2.7  - Find the average weight, food rating, and service rating of the customers 
#who have visited KFC and tried Mexican or Italian types of cuisine, and also their budget 
#level is low. We encourage you to give it a try by not using joins.
select  (select avg(weight) from userprofile) avg_weight,avg(t.food_rating) avg_food_rating,avg(t.service_rating) avg_service_rating
from
(select * from rating_final
where placeID =(select placeid from geoplaces2 where name like '%kfc%')
and userid in(select userid from usercuisine where Rcuisine IN ("ITALIAN","MEXICAN"))
and userid in(select userid from userprofile where budget='low')) as t
group by placeID;

#part 3
create table student_details(
student_id int,
student_name varchar(20),
mail_id varchar(50),
mobile_no varchar(10));

create table student_details_backup(
student_id int,
student_name varchar(20),
mail_id varchar(50),
mobile_no varchar(10));


insert into student_details
values(1,'ash','ashwin.manoharan','9382225858');

CREATE TRIGGER del_backup
    BEFORE delete ON student_details
    FOR EACH ROW 
 INSERT INTO student_details_backup
 SET student_id = old.student_id,
     student_name = OLD.student_name,
     mail_id = OLD.mail_id,
     mobile_no = old.mobile_no;
     
delete from student_details where student_id=1;
     
select * from student_details_backup;
select * from student_details;