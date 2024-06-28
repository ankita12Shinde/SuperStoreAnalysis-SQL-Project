
  --DATA CLEANING--

--Establish the relationship between the tables as per the ER diagram.

ALTER TABLE ORDERSLIST
ADD CONSTRAINT pk_orderid 
PRIMARY KEY(ORDERID)

ALTER TABLE ORDERSLIST
ALTER COLUMN OrderID nvarchar(255) NOT NULL

ALTER TABLE EachOrderBreakdown
ALTER COLUMN ORDERID nVARCHAR(255) NOT NULL

ALTER TABLE EachOrderBreakdown
ADD CONSTRAINT fk_orderid
FOREIGN KEY (Orderid) REFERENCES OrdersList(orderid)

--Split City State Country into 3 individual columns namely 'city','state','country'

 ALTER TABLE ORDERSLIST
 ADD City nvarchar(255),
      State nvarchar(255),
	  country nvarchar(255)


Update OrdersList
set city=PARSENAME(REPLACE([City State Country],',','.'),3),
    State=PARSENAME(REPLACE([City State Country],',','.'),2),
	Country =PARSENAME(REPLACE([City State Country],',','.'),1);

ALTER TABLE ORDERSLIST
DROP COLUMN [City State Country]; 

select * from OrdersList


--Add a new Category Column using the following mapping as per the first 3 characters in the product name column
 --TEC -Technology
 --OFS - Office Supplies
 --Fur - Furniture

ALTER TABLE EachOrderBreakdown
ADD Category nvarchar(255)

update EachOrderBreakdown
SET Category = CASE WHEN LEFT(ProductName,3)='OFS' THEN 'Office Supplies'
                     WHEN LEFT (ProductName,3)='TEC' THEN 'Technology'
					 WHEN LEFT(ProductName,3)='FUR' THEN 'Furniture'
					 END;

select * from EachOrderBreakdown


--Delete the first 4 characters from the productName column.


UPDATE EachOrderBreakdown
SET ProductName= SUBSTRING(productname,5,LEN(Productname)-4)

--Remove duplicate rows from EachOrderBreakdown table,if all column values are matching.
WITH CTE AS(
select *,ROW_NUMBER() OVER(PARTITION BY OrderID,productname,Discount,Sales,profit,quantity,subCategory,category order by orderid) 
as rn
from EachOrderBreakdown
)
DELETE  FROM CTE 
where rn>1


--Replace blank with NA in OrderPriority Column in OrderList table

select * from OrdersList

UPDATE OrdersList 
SET OrderPriority='NA'
WHERE OrderPriority IS NULL;


--DATA EXPLORATION--
--List the top orders with the highest sales from the EACHOrderBreakdown table.

select TOP 10 * 
from EachOrderBreakdown
order by Sales desc

--Show the number of orders for each product category in the EachOrderBreakDown table

Select Category, count(*) as NumberOfOrders
from EachOrderBreakdown
group by Category

--Identify the customer with the highest total sales acropss all orders

select TOP 1 CustomerName,SUM(Sales) as TotalSales
from OrdersList ol
join EachOrderBreakdown ob
on ol.OrderID= ob.OrderID
group by CustomerName
order by TotalSales desc


-- Find the month with the highest average sales in the OrderList table.

select TOP 1 MONTH(orderDate) as month,Avg(sales) as AverageSales
from OrdersList ol
join EachOrderBreakdown ob
on ol.OrderID=ob.OrderID
Group by MONTH(orderDate)
order by AverageSales desc


--Find out the average quantity ordered by customers whose first name start with an alphabet 's'?

select Avg(Quantity) as AverageQuantity
from OrdersList ol
join EachOrderBreakdown ob
on ol.OrderID=ob.OrderID
where LEFT(CustomerName,1)='s'

--Find out how many new customer were acquired in the year 2014?
 
 select count(*) as NumberOfNewCustomers From (
 select CustomerName,Min(OrderDate) AS FirstOrderDate
 from OrdersList
 group by CustomerName
 Having Year(Min(OrderDate))='2014' )As CustWithFirstOrder2014


 --Calculate the percentage of total profit contributed by each sub-category to the overall profit.

 select SubCategory,sum(profit) AS SubCategoryProfit,
 SUM(Profit)/(select sum(profit) from EachOrderBreakdown) * 100 as PercentageOfToralContribution
 FROM EachOrderBreakdown
 Group by SubCategory

 --Find the average sales per customer,considering only customers who have more than one order.
 
 WITH CustomerAvgSales AS(
 select customerName,Count(DISTINCT ol.orderid) as NumberOfOrders, Avg(Sales) as AverageSale
 from orderslist ol
 join eachOrderBreakdown ob
 on ol.orderid=ob.orderid
 group by CustomerName
 )
 SELECT CustomerName,AverageSale 
 FROM CustomerAvgSales
 WHERE NumberOfOrders>10


 --Identify the top-performing subcategory in each category based on total sales. 
 --Include the sub category name, total sales,and a ranking of sub category within each category .
  
  WITH topsubcategory AS(
  SELECT Category,SubCategory,SUM(Sales) as TotalSales,
  RANK() OVER(PARTITION BY Category ORDER BY SUM(Sales) DESC) AS SubcategoryRank
  FROM EachOrderBreakdown
  GROUP BY Category,SubCategory
  )
  SELECT * 
  FROM topsubcategory 
  WHERE SubCategoryRank=1





























