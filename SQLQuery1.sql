
CREATE TABLE sales_store (
TRANSACTION_ID VARCHAR(15),
CUSTOMER_ID VARCHAR(15),
CUSTOMER_NAME VARCHAR(15),
CUSTOMER_AGE INT,
GENDER VARCHAR(15),
PRODUCT_ID VARCHAR(15),
PRODUCT_NAME VARCHAR(15),
PRODUCT_CATEGORY VARCHAR(15),
QUANTIY INT,
PRCE FLOAT,
PAYMENT_MODE VARCHAR(15),
PURCHASE_DATE DATE,
TIME_OF_PURCHASE TIME,
STATUS VARCHAR(15),
);

ALTER TABLE sales_store
ALTER COLUMN CUSTOMER_NAME VARCHAR(100);


select * from sales_store

-- Insert csv file into server --
SET DATEFORMAT dmy
BULK INSERT sales_store
FROM 'C:\Users\bodap\OneDrive\Desktop\Jobaaj\projects\SQL\Sales_store\sales.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR =',',
		ROWTERMINATOR = '\n'
	 );

-- Copying datset into another table-- 

select * from sales_store

select * into sales from sales_store

select * from sales

--DATA CLEANING--
--step1 :- check for duplicates--

select transaction_id,count(*)
from sales
group by TRANSACTION_ID
having count(transaction_id) > 1

with cte as (
select *,
	ROW_NUMBER() over(partition by transaction_id order by transaction_id)  as Row_num
from sales
)

--deleting the duplicate rows

delete from cte
where row_num = 2

--step 2 :- Correction of Headers

EXEC sp_rename 'sales.quantity','QUANTITY','column'

EXEC sp_rename 'sales.price','PRICE','column'

--Step 3 :- To check datatype

select column_name, data_type
from information_schema.columns
where TABLE_NAME = 'sales'

--step 4 :- To check Null values

--To check Null count

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
	'select ''' + column_name + ''' as columnname, count(*) as Nullcount
	 from ' + QUOTENAME(table_schema) + '.sales
	 where ' + QUOTENAME(column_name) + ' IS NULL',  ' UNION ALL '
)

 WITHIN GROUP (ORDER BY COLUMN_NAME )
 FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_NAME = 'sales';


-- Execute the generated SQL
EXEC sp_executesql @SQL;

-- Treating null values

select *
from sales
where TRANSACTION_ID is null
or
customer_id is null
or 
CUSTOMER_NAME is null
or 
CUSTOMER_AGE is null
or
GENDER is null
or
product_id is null
or
product_name is null
or
PRODUCT_CATEGORY is null
or
quantity is null
or
PAYMENT_MODE is null
or
PURCHASE_DATE is null
or
status is null
or
price is null

DELETE FROM SALES
WHERE TRANSACTION_ID IS NULL

SELECT *
FROM SALES
WHERE CUSTOMER_NAME = 'Ehsaan Ram'

UPDATE SALES
SET CUSTOMER_ID = 'CUST9494'
WHERE TRANSACTION_ID = 'TXN977900'

SELECT *
FROM SALES
WHERE CUSTOMER_NAME = 'Damini Raju'

UPDATE SALES
SET CUSTOMER_ID = 'CUST1401'
WHERE TRANSACTION_ID = 'TXN985663'

SELECT *
FROM SALES
WHERE CUSTOMER_ID = 'CUST1003'

UPDATE SALES
SET CUSTOMER_NAME = 'Mahika Saini',CUSTOMER_AGE = 35,GENDER='MALE'
WHERE TRANSACTION_ID = 'TXN432798'

--STEP 5 :- DATA CLEANING
select distinct gender
from sales

update sales
set gender= 'M'
where gender = 'Male'

update sales
set gender= 'F'
where gender = 'FeMale'


select distinct PAYMENT_MODE
from sales

update sales
set PAYMENT_MODE= 'Credit Card'
where PAYMENT_MODE = 'CC'

--Data Analysis

select *
from sales

--1 . What are the top 5  most selling products by quantity?

select Top 5 product_name, sum(quantity) as Total_Quantity_Sold
from sales
where status = 'delivered'
Group by PRODUCT_NAME
order by Total_Quantity_Sold desc

--Business problem  solved : we don't know which products are most in demand

--Business Impact : Helps to  prioritize stock and boost sales through targeted promotions

--------------------------------------------------------------------------------------------------------------------------------------------------

---2. Which products are most frequently cancelled?

select Top 5 product_name, count(*) as Total_cancelled
from sales
where status = 'cancelled'
group by PRODUCT_NAME
order by Total_cancelled desc

-- Business  problem solved : Frequent cancellation affect revenue and customer trust

--Business Impact : Identify poor performing products to improve quality  or remove from catalog

-------------------------------------------------------------------------------------------------------------------------------------------------------

---3.What time of the day has the highest number of purchases?

select
	case 
		when DATEPART(hour,time_of_purchase) between 0 and  5 then 'Night'
		when DATEPART(hour,time_of_purchase) between 6 and  11 then 'Morning'
		when DATEPART(hour,time_of_purchase) between 12 and  17 then 'Afternoon'
		when DATEPART(hour,time_of_purchase) between 18 and  23 then 'Evening'
	End as Time_of_day,
	count(*) as total_order

from sales
group by 
	case 
		when DATEPART(hour,time_of_purchase) between 0 and  5 then 'Night'
		when DATEPART(hour,time_of_purchase) between 6 and  11 then 'Morning'
		when DATEPART(hour,time_of_purchase) between 12 and  17 then 'Afternoon'
		when DATEPART(hour,time_of_purchase) between 18 and  23 then 'Evening'
	End
order by total_order desc

--Business problem solved : Find peak sales times

--Business Impact :  optimize staffing, promotions, and server loads

---------------------------------------------------------------------------------------------------------------------------

--4. Who are the top 5 highest spending customers?

select top 5  customer_name, Format(sum(price*quantity),'C0','en-IN') as total_spend
from sales
group  by CUSTOMER_NAME
order by sum(price*quantity) desc

--Business problem solved : Identify VIP Customers

--Business Impact : Personalized Offers, loyalty rewards, and retention

------------------------------------------------------------------------------------------------------------------------------

---5. Which product categories  generate the higheat revenue?

select distinct product_category
from sales

select Top 5 product_category, Format(sum(quantity*price),'c0','en-IN') as Total_Revenue
from sales
group by PRODUCT_CATEGORY
order by sum(quantity*price) desc

--Business Problem  solved: Identify Top performing product categories

--Business Impact : Refine product strategy , supply chain  and promotions.
--Allowing the business to invest more in high margin or high demand categories

--------------------------------------------------------------------------------------------------------------------------------------

----6. what is the return/cancellation rate per product category?

select * from sales

--Cancellation Rate

select product_category, Format(count( case when status = 'cancelled' then 1 end) * 100.0/count(*),'N3')+' %' as cancelled_percent
from sales
group by PRODUCT_CATEGORY
order by cancelled_percent desc

--Return Rate
select product_category, Format(count( case when status = 'returned' then 1 end) * 100.0/count(*),'N3')+' %' as Returned_percent
from sales
group by PRODUCT_CATEGORY
order by Returned_percent desc


--Business Problem solved : Monitor dissatisfaction trends per category
--Business Impact : Reduce Returns, improve product descriptions/expectations
--Helps identify and fix product or logistiscs issues

---------------------------------------------------------------------------------------------------------------------------------------------

---7. what is the most preferred payment mode?

select * from sales

select payment_mode, count(PAYMENT_MODE) as total_count
from sales
group by PAYMENT_MODE
order by  total_count desc


--Business problem solved : know which payment options customer prefer
--Business Impact : streamline payment processing, prioritize popular mode

------------------------------------------------------------------------------------------------------------------------------------------

---8. How does age group affect purchasing behavior?

select * from sales

select 
	case
		when customer_age between 18 and 25 then '18-25'
		when customer_age between 26 and 35 then '26-35'
		when customer_age between 36 and 50 then '36-50'
		else '51+'
	End as customer_behaviour,
	format(sum(price * quantity),'c0','en-in') as total_purchase
from sales
group by 
	case
		when customer_age between 18 and 25 then '18-25'
		when customer_age between 26 and 35 then '26-35'
		when customer_age between 36 and 50 then '36-50'
		else '51+'
	End
order by sum(price * quantity)  desc

--Busines problem solved : Understand customer demographics
--Business Impact : Targeted Marketing and product recommendations by age group

--------------------------------------------------------------------------------------------------------------------------------------------------

--9.what is  the  monthly sales trend?

select * from sales
----Method 1
select format(purchase_date,'yyyy-MM') as Year_Month, format(sum(price*quantity),'c0','en-in')as Total_sales,sum(quantity) as Total_quantity
from sales
group by format(purchase_date,'yyyy-MM')

--Method 2

select 
	year(purchase_date) as Years,
	month(purchase_date) as Months,
	format(sum(price*quantity),'c0','en-in')as Total_sales,
	sum(quantity) as Total_quantity
from sales
group by year(purchase_date),month(purchase_date) 
order by months 

--Business problem solved  : sales fluctuations go unnoticed

--Business Impact : plan inventory and marketing according to seasonal trends

---------------------------------------------------------------------------------------------------------------------------------------

---10. Are certain genders buying more specific product categories?

----------Method 1
select gender, PRODUCT_CATEGORY, count(PRODUCT_CATEGORY) as Total_count
from sales
group by gender,PRODUCT_CATEGORY
order by GENDER


------------Method 2

select *
from ( 
	  select gender,product_category
	  from sales
	  ) as source_table

pivot (
		count(gender)
		for gender in ([M],[F])
      ) as pivot_table
order by PRODUCT_CATEGORY


-----Business problem solved : Gender - based product preferences.

-----Business Impact : Personalized ads, gender-focused campaigns.





		



