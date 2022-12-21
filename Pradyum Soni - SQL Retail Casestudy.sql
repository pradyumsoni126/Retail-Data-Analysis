-- For Reference
-- create database retail_data_analysis
-- select * from dbo.Customer
-- select * from dbo.prod_cat_info
-- select * from dbo.Transactions
-- alter table [dbo].[Customer]
-- alter column [customer_Id] int not null
-- alter table [dbo].[Transactions]
-- alter column [total_amt] float
-- alter table customer
-- add primary key (customer_id)

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- DATA PREPARATION AND UNDERSTANDING --

-- 1.What is the total no. of rows in each of the 3 tables in the database ?

-- Answer.1
select sum(Total) as Total from
(select count(*) as Total from [dbo].[Customer]
union all
select count(*) as Total from [dbo].[prod_cat_info]
union all
select count(*) as Total from [dbo].[Transactions])a

-- 2.What is the total no. of transactions that have been return ?

-- Answer.2
select count(transaction_id) - count(distinct(transaction_id)) as Total from [dbo].[Transactions]

-- 3.As you would have noticed,the dates provided across the datasets are  not in correct format. As first steps, please convert the first varialbes into date formats before proceeding ahead ?

-- Answer.3
select *, convert(varchar,[DOB],103) as DOB from [dbo].[Customer]

-- 4. What is the range of the transaction data avaiable for analysis? Show the outputs in number of days,months and years simultaneously in different columns ?

-- Answer.4
select datediff(yyyy, min([tran_date]),max([tran_date])) as range_in_year,
       datediff(mm, min([tran_date]),max([tran_date])) as range_in_month,
       datediff(dd, min([tran_date]),max([tran_date])) as range_in_days
from [dbo].[Transactions]
 
-- 5. Which product category does the sub category 'DIY' belongs to ?

-- Answer.5
select [prod_cat] from [dbo].[prod_cat_info]
where [prod_subcat]='DIY'

-- DATA ANALYSIS --

-- 1. Which channel is most used for the transaction ?

-- Answer.1
select top 1 [Store_type], count([transaction_id]) from [dbo].[Transactions]
group by [Store_type]
order by count([Store_type]) desc

-- 2. What is the count of male and female customers in the database ?

-- Answer.2
select [Gender], count([Gender]) as Total_Count_Gender from [dbo].[Customer]
where [Gender]='F' or [Gender]='M'
group by [Gender]

-- 3. From which city do we have the maximum number of customers and how many ?

-- Answer.3
select top 1 [city_code], count([city_code]) as Numb_Persons
from [dbo].[Customer]
group by [city_code]
order by count([city_code]) desc

-- 4. How many sub categories are there under the books category ?

-- Answer.4
select [prod_cat], count([prod_subcat]) as Sub_Categories
from [dbo].[prod_cat_info]
group by [prod_cat]
having [prod_cat] = 'Books'

-- 5. What is the maximum quantity of products ever ordered ?

-- Answer.5
select max([Qty]) as Max_Orders
from [dbo].[Transactions]
where [Qty]>0

-- 6. What is the net total revenue is generated in categories electronics and books ?

-- Answer.6
select [prod_cat], round(sum([total_amt]),2) as Total_Revenue
from [dbo].[Transactions] inner join [dbo].[prod_cat_info] on [dbo].[Transactions].[prod_cat_code] = [dbo].[prod_cat_info].[prod_cat_code]
and [dbo].[Transactions].[prod_subcat_code] = [dbo].[prod_cat_info].[prod_sub_cat_code]
where ([prod_cat] in ('Electronics', 'Books')) group by [prod_cat]

-- 7. How many customers have > 10 transactions with us, excluding returns ?

-- Answer.7
select [cust_id], count([transaction_id]) as Total_Customers from [dbo].[Transactions]
where [cust_id] not in (select [cust_id] from [dbo].[Transactions] where [Qty]<0)
group by [cust_id]
having count([transaction_id])>10

-- 8. What is the combined revenue earned from the electronics and clothing categories from flagship store ?

-- Answer.8
select round(sum([total_amt]), 2) as Total_Revenue from [dbo].[Transactions]
inner join [dbo].[prod_cat_info] on [dbo].[Transactions].[prod_cat_code] = [dbo].[prod_cat_info].[prod_cat_code]
and [dbo].[Transactions].[prod_subcat_code] = [dbo].[prod_cat_info].[prod_sub_cat_code]
where [prod_cat] in ('Electronics', 'Clothing') and [Store_type] = 'Flagship Store'

-- 9. What is the total revenue generated from the male customers from the electronics category? Output should display total revenue by prod sub-cat ?

-- Answer.9
select round(sum([total_amt]), 2) as 'Total Revenue Generated By Male Customers ' from [dbo].[Customer]
inner join [dbo].[Transactions] on [customer_Id] = [cust_id]
inner join [dbo].[prod_cat_info] on [dbo].[Transactions].[prod_cat_code] = [dbo].[prod_cat_info].[prod_cat_code]
and [dbo].[Transactions].[prod_subcat_code] = [dbo].[prod_cat_info].[prod_sub_cat_code]
where [prod_cat] = 'Electronics' and [Gender] = 'M'

-- 10. What is the percentage of sales and returns by the prod sub category; display on top 5 sub categories in terms of sales ?

-- Answer.10
select top 5
P.[prod_subcat] [Subcategory] ,
((round(sum(cast( case when T.[Qty] < 0 then T.[Qty]  else 0 end as float)),2))/
(round(sum(cast( case when T.[Qty] > 0 then T.[Qty] else 0 end as float)),2) 
- round(sum(cast( case when T.[Qty] < 0 then T.[Qty]   else 0 end as float)),2)))*100[%_Returs],
((round(sum(cast( case when T.[Qty] > 0 then T.[Qty]  else 0 end as float)),2))/
(round(sum(cast( case when T.[Qty] > 0 then T.[Qty] else 0 end as float)),2)
- round(sum(cast( case when T.[Qty] < 0 then T.[Qty]   else 0 end as float)),2)))*100[%_sales]
from [dbo].[Transactions] as T
inner join [dbo].[prod_cat_info] as P ON T.[prod_subcat_code] = P.[prod_sub_cat_code]
group by P.[prod_subcat]
order by [%_sales] desc

-- 11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these customers in last 30 days of transactions from max transaction date available in the data ?

-- Answer.11
select [customer_Id], [Gender], [DOB], round(sum([total_amt]), 2) as Revenue from [dbo].[Customer]
inner join [dbo].[Transactions] on [customer_Id] = [cust_id]
where [tran_date] between (select dateadd(day, -30, (select max([tran_date])
from [dbo].[Transactions])))
and (select max([tran_date]) from [dbo].[Transactions])
and [DOB] between (select dateadd(year, -35, (select max([tran_date]) from [dbo].[Transactions])))
and (select dateadd(year, -25, (select max([tran_date]) from [dbo].[Transactions])))
group by [customer_Id], [Gender], [DOB]

-- 12. Which product category has seen the max values of returns in the last 3 months of transaction ?

-- Answer.12
select top 1 [prod_cat], round(sum([total_amt]), 2) as Max_Value_of_Returns from [dbo].[Transactions] inner join [dbo].[prod_cat_info]
on [dbo].[Transactions].[prod_cat_code] = [dbo].[prod_cat_info].[prod_cat_code] and [dbo].[Transactions].[prod_subcat_code] = [dbo].[prod_cat_info].[prod_sub_cat_code]
where [total_amt]<0 and [tran_date] between (select dateadd(month, -3, (select max([tran_date]) from [dbo].[Transactions])))
and (select max([tran_date]) from [dbo].[Transactions]) group by [prod_cat] order by sum([total_amt])

-- 13. Which store-type sells the maximum products, by value of sales amount and quantity sold ?

-- Answer.13
select top 1 * from (select [Store_type], sum([Qty]) as Qty_Sold ,round(sum([total_amt]), 2) as Sales_Amt from [dbo].[Transactions] 
where [Qty]>0 and [total_amt]>0
group by  [Store_type] ) A1 Order by [Qty_Sold] desc, [Sales_Amt] desc

-- 14. What are the categories for which average revenue is above the overall average ?

-- Answer.14
select [dbo].[prod_cat_info].[prod_cat], round(avg([total_amt]),2) as Avg_Rev from [dbo].[Transactions] inner join [dbo].[prod_cat_info]
on [dbo].[Transactions].[prod_cat_code] = [dbo].[prod_cat_info].[prod_cat_code]  and [dbo].[Transactions].[prod_subcat_code] = [dbo].[prod_cat_info].[prod_sub_cat_code]
group by [dbo].[prod_cat_info].[prod_cat] 
having round(avg([total_amt]),2)>(select round(avg([total_amt]),2) from [dbo].[Transactions])

-- 15. Find the average and total revenue by each sub category from the categories qwhich are amongs top 5 categories in terms of quantity sold ?

-- Answer.15
select [dbo].[prod_cat_info].[prod_subcat], round(avg([total_amt]),2) as Average, round(sum([total_amt]),2) as Revenue from [dbo].[Transactions]
inner join [dbo].[prod_cat_info] on [dbo].[Transactions].[prod_cat_code] = [dbo].[prod_cat_info].[prod_cat_code]
and [dbo].[Transactions].[prod_subcat_code] = [dbo].[prod_cat_info].[prod_sub_cat_code] 
where [dbo].[prod_cat_info].[prod_cat] in (select [prod_cat] from (select top 5 [prod_cat] ,sum([Qty]) [QTY] from [dbo].[Transactions] 
inner join [dbo].[prod_cat_info] on [dbo].[Transactions].[prod_cat_code] = [dbo].[prod_cat_info].[prod_cat_code]
and [dbo].[Transactions].[prod_subcat_code] = [dbo].[prod_cat_info].[prod_sub_cat_code]
where [Qty]>0 group by [prod_cat] order by [QTY] desc)A2)
group by [dbo].[prod_cat_info].[prod_subcat]