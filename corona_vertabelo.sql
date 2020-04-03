
#########################################confirmed #######################################
select min(date) from confirmed_covid;
select country,province_state,date,confirmed_day from confirmed_covid where country in ('China') order by country, province_state;

#usual group by - simple syntax to calculate total number o confirmed cases per country and province_state
select country,province_state,sum(confirmed_day) as total_confirmed from confirmed_covid  group by country,province_state;
select *, sum(confirmed_day) OVER(PARTITION by country,province_state order by date) as running_total from confirmed_covid where country ='Croatia';


select country,province_state,sum(deaths_day) from deaths_covid group by country,province_state;


#you can use rollup to see totals - for example this can help to see total number of confirmed cases inn country China 
select country,province_state,sum(confirmed_day) from confirmed_covid group by country,province_state with ROLLUP;

#cummulative sum per each country by using window function in mysql
select *, sum(confirmed_day) OVER(PARTITION by country,province_state order by date) as cumulative_total from confirmed_covid;


#increase or decrease of confirmed case per day
#for this I need data from previous day - lets use WF lag function and store a result in a temporary table

WITH confirmed_lag as 
(select *, lag(confirmed_day) OVER(PARTITION by country,province_state order by date) as confirmed_previous_day from confirmed_covid),
confirmed_percent_change as (select *,COALESCE(round((confirmed_day - confirmed_previous_day)/confirmed_previous_day *100),0) as percent_change from confirmed_lag )
select *, CASE WHEN percent_change>0 then 'increase'
               WHEN percent_change=0 then 'no change' else 'decrease' end  trend from confirmed_percent_change where country='Croatia';



#ranking

with highest_no_of_confirmed as 
(select *, rank() OVER(PARTITION by date order by confirmed_day desc) as highest_no_confirmed from confirmed_covid)
select * from highest_no_of_confirmed where highest_no_confirmed=1 and date between '2020-03-20' and '2020-03-30' ;









