-- ----------Project SQL--------- --
-- Project 1 --

use project1;
#1.1 how the percentage of wins of each bidder in the order of highest to lowest percentage.

select bdr_dt.bidder_id 'Bidder ID', bdr_dt.bidder_name 'Bidder Name', 
(select count(*) from ipl_bidding_details bid_dt 
where bid_dt.bid_status = 'won' and bid_dt.bidder_id = bdr_dt.bidder_id) / 
(select no_of_bids from ipl_bidder_points bdr_pt 
where bdr_pt.bidder_id = bdr_dt.bidder_id)*100 as 'Percentage of Wins (%)'
from ipl_bidder_details bdr_dt order by 3 desc;

#1.2	Display the number of matches conducted at each stadium with the stadium name and city
select i_s.stadium_name,i_s.city,
(select count(ips.match_id) from ipl_match_schedule ips
where ips.stadium_id=i_s.stadium_id) as num_of_matches
from ipl_stadium i_s;

#1.3	In a given stadium, what is the percentage of wins by a team which has won the toss?
select stadium_id , stadium_name ,
(select count(*) from ipl_match m join ipl_match_schedule ms on m.match_id = ms.match_id
where ms.stadium_id = s.stadium_id and (toss_winner = match_winner)) /
(select count(*) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id) * 100 
as 'Percentage of Wins by teams who won the toss (%)'
from ipl_stadium s;

#1.4	Show the total bids along with the bid team and team name
select ipd.bid_team,it.team_name,count(ipd.bidder_id) as total_bids from
ipl_bidding_details  ipd join ipl_team it on
ipd.bid_team=it.TEAM_ID
group by ipd.BID_TEAM;

#1.5	Show the team id who won the match as per the win details.
with subquery as(
select case match_winner when 1 then TEAM_ID1
else TEAM_ID2
end
winner,WIN_DETAILS from ipl_match )
select  it.team_id,it.team_name,s.*
from ipl_team it join subquery s on 
it.team_id=s.WINNER ;


#1.6	Display total matches played, total matches won and total matches lost by the team along with its team name.
select it.team_id,it.team_name,sum(its.matches_played) total_matches_played ,sum(its.matches_won) matches_won,
sum(its.matches_lost) matches_lost,sum(its.no_result) NRR from ipl_team it join ipl_team_standings its
on its.team_id=it.team_id group by its.team_id;

#1.7	Display the bowlers for the Mumbai Indians team.
select it.team_id,it.team_name, itp.player_id,ip.player_name
from ipl_team it join  ipl_team_players itp on
 itp.team_id=it.team_id join ipl_player ip on ip.player_id=itp.PLAYER_ID
 where it.team_name='mumbai indians' and itp.player_role='bowler' ;

#1.8	How many all-rounders are there in each team, Display the teams with more than 4 
# all-rounders in descending order.
select it.team_id,it.team_name,
(select count(itp.player_id) from ipl_team_players itp  
where it.team_id=itp.TEAM_ID and itp.PLAYER_ROLE='all-rounder' ) as no_players
from ipl_team it 
group by it.team_id
having no_players > 4 
order by no_players desc;

#1.9 Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
# Note the total bidders’ points in descending order and the year is bidding year.
#               Display columns: bidding status, bid date as year, total bidder’s points

select ibd.bidder_id,ims.STADIUM_ID,year(ibd.bid_date) year_,ibd.bid_status,ibp.total_points from ipl_bidding_details ibd
join ipl_bidder_points ibp on ibd.BIDDER_ID=ibp.BIDDER_ID join ipl_match_schedule ims on
ibd.SCHEDULE_ID=ims.SCHEDULE_ID join ipl_match im on
im.match_id=ims.MATCH_ID 
where (im.WIN_DETAILS like '%csk%') and (ims.STADIUM_ID=7) and (ibd.bid_status='won')
order by TOTAL_POINTS desc;

#1.10	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
# 1. use the performance_dtls column from ipl_player to get the total number of wickets
# 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
# 3.	Do not use joins in any cases.
# 4.	Display the following columns teamn_name, player_name, and player_role.

with sub as(
with subquery as(
select PLAYER_ROLE,PLAYER_NAME, cast((substring_index(substring_index(substring_index(PERFORMANCE_DTLS,' ',3),' ',-1),'-',-1)) AS float) as wickets
from ipl_team_players itp,ipl_player ip
where  itp.PLAYER_ID=ip.PLAYER_ID and (PLAYER_ROLE like '%bowl%' or PLAYER_ROLE like '%all%'))
select *, dense_rank()over(order by wickets desc ) as rnk from subquery)
select * from sub where rnk<6;

#1.11	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
select ibd.bidder_id,((select count(*) from ipl_match im where ibd.bid_team=im.toss_winner)/
(select count(*) from ipl_match im)) * 100 as percentage_of_tosswin
from ipl_bidding_details ibd join ipl_match_schedule ims
using(schedule_id)
join ipl_match im
using(match_id)
group by ibd.bidder_id;

with subquery as(
select case toss_winner when 1 then TEAM_ID1
else TEAM_ID2
end
TOSSWIN_DETAILS from ipl_match )
select ibd.bidder_id,ibd.bid_team,s.tosswin_details,((select count(*) from subquery where ibd.bid_team=s.tosswin_details)/
(select count(*) from ipl_match im)) * 100 as percentage_of_tosswin
from ipl_bidding_details ibd join ipl_match_schedule ims
using(schedule_id)
join ipl_match im
using(match_id) join subquery s on ibd.BID_TEAM=s.tosswin_details
group by ibd.BIDDER_ID;


#1.12 find the IPL season which has min duration and max duration.
# Output columns should be like the below:
# Tournment_ID, Tourment_name, Duration column, Duration
select * from ipl_tournament;
WITH SUB AS(
with subquery as(
select TOURNMT_ID,TOURNMT_NAME,datediff(TO_DATE,FROM_DATE) as Duration_days
from ipl_tournament)
select *,dense_rank()over(order by duration_days desc) rnk from subquery )
select *, case when rnk<3 then 'Max_duration'  else 'Min_duration' end AS Duration FROM SUB  where rnk<=1 or rnk>=5;

# 1.13 Write a query to display to calculate the total points month-wise for the 2017 bid year. 
# sort the results based on total points in descending order and month-wise in ascending order.
# Note: Display the following columns:
# 1. Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
# Only use joins for the above query queries.

select bp.bidder_id,bidder_name,year(bid_date) year,month(bid_date) month,sum(total_points) total_points
from ipl_bidder_details bd join ipl_bidder_points bp
on bd.BIDDER_ID=bp.BIDDER_ID
join ipl_bidding_details ipd
on ipd.BIDDER_ID=bp.BIDDER_ID
where year(bid_date)=2017
group by bidder_id,month(bid_date)
order by month,TOTAL_POINTS desc;

# 1.14	Write a query for the above question using sub queries by having the same constraints as the above question.

with sub as
(select bp.bidder_id,bidder_name,year(bid_date) year,month(bid_date) month,sum(total_points) total_points
from ipl_bidder_details bd join ipl_bidder_points bp
on bd.BIDDER_ID=bp.BIDDER_ID
join ipl_bidding_details ipd
on ipd.BIDDER_ID=bp.BIDDER_ID
group by bidder_id,month(bid_date)
order by month,TOTAL_POINTS desc)
select * from sub where year=2017;

# 1.15 Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
# Output columns should be:
# like:
# Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;

select * from ipl_bidder_points;
select * from ipl_bidding_details;

with subquery as(
select sub.* from(
select BIDDER_ID,sum(TOTAL_POINTS) as t,BIDDER_NAME,
row_number()over(order by sum(TOTAL_POINTS) desc) as rnk1,
row_number()over(order by sum(TOTAL_POINTS) ) as rnk2
from ipl_bidder_points ibp join ipl_bidding_details ibd
using(BIDDER_ID)
join ipl_bidder_details
using (BIDDER_ID)
where year(BID_DATE)=2018
group by BIDDER_ID) sub
where rnk1<=3 or rnk2<=3)
select BIDDER_ID,t as total_point ,BIDDER_NAME from subquery
order by rnk2 desc;


# 1.16	Create two tables called Student_details and Student_details_backup.alter.

create table Student_details
(
student_id int not null primary key,
student_name varchar(30) not null,
mail_id   varchar(50) not null,
mobile_no varchar(15) not null
);

create table Student_details_backup
(
student_id int not null,
student_name varchar(30) not null,
mail_id   varchar(50) not null,
mobile_no varchar(15) not null
);

create trigger new_details1
after insert on student_details
for each row
INSERT INTO student_details_backup
set student_id=new.student_id,
student_name=new.student_name,
mail_id=new.mail_id,
mobile_no=new.mobile_no;

create trigger UPDATE_details
after UPDATE ON student_details
for each row
update student_details_backup
SET student_name=new.student_name,
student_name=new.student_name,
mail_id=new.mail_id,
mobile_no=new.mobile_no;

insert into Student_details values
(1,'Ram','ram@gamil.com','9456464647');

select * from student_details;
select * from student_details_backup;