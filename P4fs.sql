-- Project 4 --
-- partA

#4.1	Import the csv file to a table in the database.
use supply_chain;
desc `icc test batting figures`;

#4.2	Remove the column 'Player Profile' from the table.
alter table `icc test batting figures` drop column `player profile`;

#4.3	Extract the country name and player names from the given data and 
#store it in separate columns for further usage.
select * from `icc test batting figures`;
alter table `icc test batting figures` add column Player_Name varchar(20);
alter table `icc test batting figures` modify player_name varchar(40);
alter table `icc test batting figures` add column country varchar(20);
update `icc test batting figures` set player_name= substring_index(Player, "(",1);
update `icc test batting figures` set country= trim(")" from substring_index(Player, "(",-1));

#4.4	From the column 'Span' extract the start_year and end_year and 
#store them in separate columns for further usage.
alter table `icc test batting figures` add column start_year int;
alter table `icc test batting figures` add column end_year int;
update `icc test batting figures` set start_year=substring_index(span,"-",1);
update `icc test batting figures` set end_year=substring_index(span,"-",-1);

#4.5	The column 'HS' has the highest score scored by the player so far in any given match.
 #The column also has details if the player had completed the match in a NOT OUT status.
 #Extract the data and store the highest runs and the NOT OUT status in different columns.
 
select player,replace(hs,'*',''),
case
when instr(hs,'*')=0 then 'out'
else 'not-out'
end
from `icc test batting figures`;

#4.6	Using the data given, considering the players who were 
#active in the year of 2019, create a set of batting order of best 6 players 
#using the selection criteria of those who have a good average score across all 
#matches for India.
select * from `icc test batting figures`
where end_year>=2019 and Country like "%Ind%"
order by avg desc limit 6;

#4.7	Using the data given, considering the players who were active in 
#the year of 2019, create a set of batting order of best 6 players using the 
#selection criteria of those who have the highest number of 100s across all matches 
#for India.
select * from `icc test batting figures`
where end_year>=2019 and Country like "%Ind%"
order by `100` desc limit 6;

#4.8	Using the data given, considering the players who were active in the year 
#of 2019, create a set of batting order of best 6 players using 2 selection 
#criteria of your own for India.
select * from `icc test batting figures`
where end_year>=2019 and Country like "%Ind%"
order by Runs desc, Inn desc limit 6;

#4.9	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, 
#considering the players who were active in the year of 2019, create a set of 
#batting order of best 6 players using the selection criteria of those who have a 
#good average score across all matches for South Africa
create view Batting_order_GoodAvgScorers_SA as
select * from `icc test batting figures`
where end_year>=2019 and Country like "%SA%"
order by Avg desc limit 6;
select * from batting_order_goodavgscorers_sa;

#4.10	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, 
#considering the players who were active in the year of 2019, create a set of batting order 
#of best 6 players using the selection criteria of those who have highest number of 100s across
# all matches for South Africa.
#create view Batting_Order_HighestCenturyScorers_SA as
select * from `icc test batting figures`
where end_year>=2019 and Country like "%SA%"
order by `100`desc limit 6;
select * from Batting_Order_HighestCenturyScorers_SA;

#4.11 Using the data given, Give the number of player_played for each country.
select country, count(player) cnt from `icc test batting figures`
group by country
order by cnt desc;

#4.12 Using the data given, Give the number of player_played for Asian and Non-Asian continent
select category, count(distinct pLayer_name) from 
(select *, 
case
when country like "%India%" then "Asian"
when country like "%Bdesh%" then "Asian"
when country like "%SL%" then "Asian"
when country like "%Pak%" then "Asian"
else "Non-Asian"
end category
from `icc test batting figures`)T
group by category;


#Part – B

select * from customer;
select * from orderitem;
select * from orders;
select * from product;
select * from supplier;

#4.1	Company sells the product at different discounted rates. Refer actual product price in 
#product table and selling price in the order item table. Write a query to find out total amount
# saved in each order then display the orders from highest to lowest amount saved. 
select orderID,sum(o.UnitPrice*Quantity) discountedPrice, sum(p.UnitPrice*Quantity) OriginalPrice,
sum(p.UnitPrice*Quantity)-sum(o.UnitPrice*Quantity) Total_saved
from orderitem o join product p
on o.ProductId=p.id
group by orderID
order by Total_saved desc
;

#4.2	Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference.
# Help him to pick: 
#a. List few products that he should choose based on demand.
#b. Who will be the competitors for him for the products suggested in above questions.

select oi.productid,p.productname,count(oi.productid),supplierid,companyname
from orderitem oi join product p
on oi.productid=p.id
join supplier s
on s.id=p.supplierid
group by productid
order by sum(quantity) desc;

#4.3	Create a combined list to display customers and suppliers details considering the 
#following criteria 
#●	Both customer and supplier belong to the same country
#●	Customer who does not have supplier in their country
#●	Supplier who does not have customer in their country

select c.FirstName customername, c.Country customercountry,  s.ContactName suppliername,s.Country suppliercountry
from customer c join supplier s
on c.country=s.country;

select s.companyname,s.contactname,s.country as suppcountry
from supplier s
left join customer c on c.Country=s.country
order by s.country;

select c.firstname,c.lastname,c.country as customercountry
from customer c
left join supplier s on c.Country=s.country
order by c.country;


#4.4	Every supplier supplies specific products to the customers. Create a view of suppliers and 
#total sales made by their products and write a query on this view to find out top 2 suppliers 
#(using windows function) in each country by total sales done by the products.
create view total_sales_supplier as
select s.id supplierID, s.contactname suppliername,s.country, sum(o.unitprice*quantity) sales
from orderitem o join product p
on p.Id=o.ProductId
join supplier s
on s.id=p.supplierid
group by ContactName
order by sales desc;

select * from (select *, rank() over(partition by country order by sales desc) rnk from total_sales_supplier)T
where rnk<=2;


#4.5	Find out for which products, UK is dependent on other countries for the supply. 
#List the countries which are supplying these products in the same list.
select p.productName, s.companyname, s.country 
from customer c join orders o
on c.id=o.customerid
join orderitem oi
on oi.orderid=o.id
join product p
on p.id=oi.productID
join supplier s
on s.id=p.supplierID
where c.country="UK" and s.country<>"UK";


