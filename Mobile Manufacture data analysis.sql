----------------------------------------------------------------------------------------------------------------------------------
										--MOBILE MANUFACTURER DATA ANALYSIS--
----------------------------------------------------------------------------------------------------------------------------------

/************************************************************************************************
1.List all the states in which we have customers who have bought cellphones from 2005 till today. 
************************************************************************************************/

select Distinct State
from (
		select T.IDCustomer,T.Date,L.State,T.Quantity,T.TotalPrice from FACT_TRANSACTIONS T
		inner join DIM_LOCATION L
		on T.IDLocation=L.IDLocation
		where YEAR(T.Date) between 2005 and (select max(year(date)) from FACT_TRANSACTIONS)
) as x;


/************************************************************************************************
2. Which state in the US is buying the most 'Samsung' cell phones? 
************************************************************************************************/

select top 1 State,SUM(Quantity) as  Qty
from DIM_MANUFACTURER as MR
inner join DIM_MODEL as M
ON MR.IDManufacturer=M.IDManufacturer
inner join FACT_TRANSACTIONS as T
ON M.IDMODEL=T.IDModel
inner join DIM_LOCATION as L
ON T.IDLocation=L.IDLocation
where L.Country='US' and Manufacturer_Name = 'SAMSUNG'
Group by State
order by Qty DESC;


/************************************************************************************************
3. Number of transactions for each model per zip code per state. 
************************************************************************************************/

select T.IDModel, M.Model_Name, L.State,L.ZipCode, count(T.IDModel) Total_Transactions
from DIM_MODEL M
inner join FACT_TRANSACTIONS T 
on M.IDModel=T.IDModel
inner join DIM_LOCATION L
on T.IDLocation=L.IDLocation
Group by T.IDModel, M.Model_Name, L.State,L.ZipCode
Order by L.State,L.ZipCode;


/************************************************************************************************
4. Show the cheapest cellphone (Output should contain the price also)
************************************************************************************************/

select distinct top 1 IDModel, Model_Name, Unit_price 
from DIM_MODEL M
Order by Unit_price; 

/************************************************************************************************
5. Average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
************************************************************************************************/	

--METHOD 1

 select IDModel,Model_Name,IDManufacturer,AVG(Unit_Price) as AvgPrice
 from DIM_MODEL
 where IDManufacturer in ( 
							 select top 5 M.IDManufacturer
							 from DIM_MODEL M
							 inner join FACT_TRANSACTIONS T 
							 on M.IDModel=T.IDModel
							 group by M.IDManufacturer
							 order by sum(T.Quantity) desc
							 ) 
group by IDModel,Model_Name, IDManufacturer
order by AvgPrice ;

--METHOD 2  Using CTE

With Top_5_Mnf
as ( select top 5 M.IDManufacturer,sum(T.Quantity) as AvgQty
	 from DIM_MODEL M
	 inner join FACT_TRANSACTIONS T 
	 on M.IDModel=T.IDModel
	 group by M.IDManufacturer
	 order by AvgQty desc
	)
 select M.IDModel, MF.Manufacturer_Name, M.Model_Name, M.IDManufacturer,AVG(M.Unit_Price) as AvgPrice
 from DIM_MODEL M
 inner join DIM_MANUFACTURER MF
 on M.IDManufacturer=MF.IDManufacturer
 where M.IDManufacturer in (SELECT IDManufacturer FROM Top_5_Mnf)
 group by M.IDModel, MF.Manufacturer_Name, M.Model_Name, M.IDManufacturer
 order by AvgPrice ;
				
				
/************************************************************************************************
6. Names of the customers and the average amount spent in 2009,where the average is higher than 500
************************************************************************************************/

 select c.IDCustomer,C.Customer_Name,Avg(T.TotalPrice) as Avg_Amt from DIM_CUSTOMER C
 inner join FACT_TRANSACTIONS T
 on c.IDCustomer=T.IDCustomer
 where Year(T.Date)=2009
 group by c.IDCustomer,C.Customer_Name
 having avg(T.TotalPrice)>500;
 

/************************************************************************************************
7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
*************************************************************************************************/

--Method 1

select M.Model_Name, M.IDModel
from DIM_MODEL M
where M.IDModel IN (
     select IDModel from (
        select top 5 T.IDModel
        from  FACT_TRANSACTIONS T
        where YEAR(T.Date) = 2008
        Group BY T.IDModel
        Order BY SUM(T.Quantity) DESC
    ) as A

    INTERSECT

   select IDModel from (
        select top 5 T.IDModel
        from  FACT_TRANSACTIONS T
        where YEAR(T.Date) = 2009
        Group BY T.IDModel
        Order BY SUM(T.Quantity) DESC
    ) AS B

    INTERSECT

    select IDModel from (
        select top 5 T.IDModel
        from  FACT_TRANSACTIONS T
        where YEAR(T.Date) = 2010
        Group BY T.IDModel
        Order BY SUM(T.Quantity) DESC
    ) AS C
);

--METHOD 2

 with RankModels
 as (
	  select  YEAR(T.Date) as [Year],M.IDModel,M.Model_Name,sum(T.Quantity) as TotalQty,
			  Dense_Rank() over(partition by YEAR(T.Date) order by sum(T.Quantity) desc) as [Rank] 
      from DIM_MODEL M
      inner join FACT_TRANSACTIONS T 
      on M.IDModel=T.IDModel
      where Year(T.Date) in (2008,2009,2010)
      group by YEAR(T.Date),M.IDModel,M.Model_Name
	   ) ,
Top_5_Models
as (
     select * from RankModels
	 where [Rank] <=5
	 )
select IDModel,Model_Name,count(distinct Year) as freq
from Top_5_Models
group by IDModel,Model_Name
having count(distinct Year)=3;
--NOte: we can also use RANK() window fucntion in qbove query but it will skip the consequetive ranks in case of tie or duplicates,
--here so when we use Dense Rank Result may vary 


/************************************************************************************************
8. Manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
************************************************************************************************/

--METHOD 1

select *
from (
	    select M.IDManufacturer,MNF.Manufacturer_Name,Year(T.Date) as [Year], sum(T.TotalPrice) as TotalSales,
		DENSE_RANK() over( partition by Year(T.Date) order by sum(T.TotalPrice) desc) as Rank
	    from DIM_MODEL  M
	    inner join FACT_TRANSACTIONS T
	    on M.IDModel=T.IDModel
		inner join DIM_MANUFACTURER MNF
		on M.IDManufacturer=MNF.IDManufacturer
	    where Year(T.Date) in (2009,2010)
		group by M.IDManufacturer,MNF.Manufacturer_Name,Year(T.Date)  
     ) as x
where rank = 2;     --here we used subquery because we can't use window fucntion and any aggregate function and alias names inside where 


--Method 2

With Mnfc_by_Sales
as (   
		select M.IDManufacturer,MNF.Manufacturer_Name,Year(T.Date) as [Year], sum(T.TotalPrice) as TotalSales
	    from DIM_MODEL  M
	    inner join FACT_TRANSACTIONS T
	    on M.IDModel=T.IDModel
		inner join DIM_MANUFACTURER MNF
		on M.IDManufacturer=MNF.IDManufacturer
	    where Year(T.Date) in (2009,2010)
		group by M.IDManufacturer,MNF.Manufacturer_Name,Year(T.Date) 
		) ,
Rank_mnfc
as ( 
		select *,DENSE_RANK() over( partition by [Year] order by TotalSales desc) as Rank
		from Mnfc_by_Sales
		)
select * from Rank_mnfc
where Rank = 2;
 
 
/************************************************************************************************
9.Manufacturers that sold cellphones in 2010 but did not in 2009.
************************************************************************************************/

--METHOD 1

select distinct MR.IDManufacturer, Manufacturer_Name
from DIM_MANUFACTURER as MR
inner join DIM_MODEL as M
on MR.IDManufacturer=M.IDManufacturer
inner join FACT_TRANSACTIONS as T
ON M.IDModel=T.IDModel
WHERE YEAR(DATE)=2010 
Except
select distinct MR.IDManufacturer, Manufacturer_Name
from DIM_MANUFACTURER as MR
inner join DIM_MODEL as M
on MR.IDManufacturer=M.IDManufacturer
inner join FACT_TRANSACTIONS as T
ON M.IDModel=T.IDModel
WHERE YEAR(DATE)=2009 ;


--METHOD 2

select Distinct M.IDManufacturer,MNF.Manufacturer_Name 
		 from DIM_MODEL  M
		 inner join FACT_TRANSACTIONS T
		 on M.IDModel=T.IDModel
		 inner join DIM_MANUFACTURER MNF
		 on M.IDManufacturer=MNF.IDManufacturer
		 where Year(T.Date) in (2010) 
		            and 
		 M.IDManufacturer not in ( select M.IDManufacturer 
								   from DIM_MODEL  M
								   inner join FACT_TRANSACTIONS T
								   on M.IDModel=T.IDModel
								   where Year(T.Date) in (2009)
								   );
										

/************************************************************************************************
10. Top 100 customers and their average spend, average quantity by each year and the percentage of change in their spend.
*************************************************************************************************/

 
 with Top100
 as (
		select Top 100 T.IDCustomer, Sum(T.Quantity *M.Unit_price ) as TotalSpend
		from DIM_MODEL M
		inner Join FACT_TRANSACTIONS T
		on M.IDModel=T.IDModel
		Group by T.IDCustomer
		) ,
Yearly_Spend
as (
		select T.IDCustomer, YEAR(T.Date) as [Year], AVG(T.Quantity *M.Unit_price ) as AvgSpend, 
		Avg(T.Quantity) as AvgQty,Sum(T.Quantity *M.Unit_price ) as TotalSpend
		from DIM_MODEL M
		inner Join FACT_TRANSACTIONS T
		on M.IDModel=T.IDModel
		where T.IDCustomer in (select IDCustomer from Top100)
		Group by T.IDCustomer,YEAR(T.Date)	 
   ),
Previous_Spend
as (
		select *, LAG(TotalSpend,1) over(Partition by IdCustomer Order by [Year]) as Prev_Spend
		from Yearly_Spend
		)

select  *, round(
					case 
					    when Prev_Spend IS Null THEN Null
					    ELSE ((TotalSpend - Prev_Spend) / NULLIF(Prev_Spend, 0)) * 100 
					END, 2 ) AS Percentage_Change
from Previous_Spend;

 





  

 