
-- project 3--
use project;

#3.1 Display the product details as per the following criteria and sort them in descending order of category:
   #a.  If the category is 2050, increase the price by 2000
   #b.  If the category is 2051, increase the price by 500
   #c.  If the category is 2052, increase the price by 600
select * from product;
use casestudy;
select product_id,product_desc,product_class_code,
case
when product_class_code=2050 then product_price+2000
when product_class_code=2051 then PRODUCT_PRICE+500
when PRODUCT_CLASS_CODE=2052 then PRODUCT_PRICE+600
else PRODUCT_PRICE
end as new_price
from product
order by new_price desc;


#3.2 List the product description, class description and price of all products which are shipped. 
select * from order_header;
select p.product_desc,pc.product_class_desc,p.product_price,order_status
from product p join product_class pc
on p.PRODUCT_CLASS_CODE=pc.PRODUCT_CLASS_CODE
join order_items oi
on oi.product_id=p.product_id
join order_header oh
on oh.ORDER_ID=oi.order_id
where ORDER_STATUS='shipped'
;


#3.3 Show inventory status of products as below as per their available quantity:
#a. For Electronics and Computer categories, if available quantity is < 10, show 'Low stock', 11 < qty < 30, show 'In stock', > 31, show 'Enough stock'
#b. For Stationery and Clothes categories, if qty < 20, show 'Low stock', 21 < qty < 80, show 'In stock', > 81, show 'Enough stock'
#c. Rest of the categories, if qty < 15 – 'Low Stock', 16 < qty < 50 – 'In Stock', > 51 – 'Enough stock'
#For all categories, if available quantity is 0, show 'Out of stock'.

select * from product;
select * from product_class;

select product_id,product_desc,PRODUCT_CLASS_DESC,product_quantity_avail,
case
when PRODUCT_CLASS_DESC='electronics' then case when product_quantity_avail <=10 then 'low stock' when product_quantity_avail between 11 and 30 then 'in stock' when product_quantity_avail >31 then 'enough stock' end
when PRODUCT_CLASS_DESC in ('stationery','clothes') then case when product_quantity_avail <=20 then 'low stock' when product_quantity_avail between 21 and 80 then 'in stock' when product_quantity_avail >81 then 'enough stock' end
when PRODUCT_CLASS_DESC not in('electronics','stationery','clothes') then case when product_quantity_avail <=15 then 'low stock' when product_quantity_avail between 16 and 50 then 'in stock' when product_quantity_avail >51 then 'enough stock' end
end as stock_review
from product p join product_class pc
on p.product_class_code=pc.product_class_code;


#3.4 List customers from outside Karnataka who haven’t bought any toys or books
select * from address;
select * from online_customer;
select * from product_class;


select  distinct oc.customer_id 
from online_customer oc join order_header oh
on oc.CUSTOMER_ID=oh.CUSTOMER_ID
join address a 
on a.ADDRESS_ID=oc.ADDRESS_ID
join order_items oi
on oh.ORDER_ID=oi.ORDER_ID
join product p
on p.PRODUCT_ID=oi.PRODUCT_ID
join product_class pc
on pc.PRODUCT_CLASS_CODE=p.PRODUCT_CLASS_CODE
where state!='karnataka' and PRODUCT_CLASS_DESC not in ('books','toys')
;


-- part B
#3.1 Create DataBase BANK and Write SQL query to create above schema with constraints

create table branch_mstr
(
branch_no int not null primary key,
name varchar(50) not null
 );

desc branch_mstr;

create table employee
(
emp_no int not null,
branch_no int ,
fname varchar(20),
mname varchar(20),
lname varchar(20),
dept varchar(20),
desig varchar(10),
mngr_no int not null,
foreign key(branch_no)references branch_mstr(branch_no));

desc employee;

create table customer
(
custid int not null primary key,
fname varchar(30),
mname varchar(30),
lname varchar(30),
occupation varchar(10),
dob date);

desc customer;

create table account
(
acnumber int not null primary key,
custid int not null,
bid int not null,
curbal int,
atype varchar(10),
opendt date,
astatus varchar(10),
foreign key(custid)references customer(custid),
foreign key(bid)references branch_mstr(branch_no));

desc account;

#3.2	Inserting Records into created tables

insert into branch_mstr values(
1,'delhi');
insert into branch_mstr values(
2,'mumbai');

insert into customer values
(1,'ramesh','chandra','sharma','service','1976-12-06');
insert into customer values
(2,'avinash','sunder','minha','business','1974-10-16');

insert into account values
(1,1,1,10000,'saving','2012-12-15','active');
insert into account values
(2,2,2,5000,'saving','2012-06-12','active');

insert into employee values
(1,1,'mark','steve','lara','account','accountant',2);
insert into employee values
(2,2,'bella','james','ronald','loan','manager',1);

#3.3	Select unique occupation from customer table
select distinct occupation from customer;

#3.4	Sort accounts according to current balance 
select acnumber,curbal from account
order by curbal desc;

#3.5	Find the Date of Birth of customer name ‘Ramesh’
select dob from customer where fname='ramesh';

#3.6	Add column city to branch table 
alter table branch_mstr add column city varchar(15);

#3.7	Update the mname and lname of employee ‘Bella’ and set to ‘Karan’, ‘Singh’ 
update  employee set mname='karan',lname='singh' where fname='bella';

select * from employee;

#3.8	Select accounts opened between '2012-07-01' AND '2013-01-01'
select acnumber from account where opendt between '2012-07-01' and '2013-01-01';

#3.9	List the names of customers having ‘a’ as the second letter in their names 
select fname from customer where fname like'_a%';

# 3.10	Find the lowest balance from customer and account table
select min(curbal) as s from account join customer
using (custid);

# 3.11	Give the count of customer for each occupation
select occupation,count(custid) from customer
group by occupation;

# 3.12	Write a query to find the name (first_name, last_name) of the employees who are managers.
select concat(Fname,' ',Lname) as name from employee
where Desig='Manager';

# 3.13	List name of all employees whose name ends with a
select * from employee where fname like '%a';

# 3.14	Select the details of the employee who work either for department ‘loan’ or ‘credit’
select * from employee where Dept in ('loan','credit');

# 3.15	Write a query to display the customer number, customer firstname, account number for the 
select custid,fname,acnumber from customer join account
using (custid);

# 3.16	Write a query to display the customer’s number, customer’s firstname, branch id and balance amount for people using JOIN.
select custid,fname,acnumber,curbal,bid from customer join account
using (custid);

#3.17 Create a virtual table to store the customers who are having the accounts in the same city as they live
alter table customer add column city varchar(20);
alter table account add column city varchar(20);
update customer set city= case custid when 1 then 'Delhi' else 'Mumbai' end;
update account set city=case acnumber when 1 then 'Delhi' else 'Chennai' end;
create view samecity as
select a.custid,c.fname 
from customer c 
join account a 
on a.custid=c.custid
where a.city=c.city;
select * from samecity;

#3.19Write a query to display the details of customer with second highest balance 
select c.custid,c.fname,c.mname,c.lname,c.occup,c.dob,c.city, a.curbal from customer c 
join account a 
on a.custid=c.custid
order by a.curbal desc limit 2 offset 1;