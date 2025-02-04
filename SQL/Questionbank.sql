use AdventureWorks2022
--list tables
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'Production' 
AND TABLE_TYPE = 'BASE TABLE';

--list tables and their columns 
SELECT 
    t.TABLE_NAME,
    STRING_AGG(c.COLUMN_NAME, ', ') AS Columns
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN INFORMATION_SCHEMA.TABLES t 
    ON c.TABLE_NAME = t.TABLE_NAME 
    AND c.TABLE_SCHEMA = t.TABLE_SCHEMA
WHERE c.COLUMN_NAME='CultureId'
GROUP BY t.TABLE_NAME
ORDER BY t.TABLE_NAME;

-- 1)find the average currency rate conversion from USD to Algerian Dinar  
--and Australian Doller  
select * from Sales.Currency;
select * from Sales.CurrencyRate cr;

select cr.FromCurrencyCode , cr.ToCurrencyCode,avg(cr.AverageRate) Avg_Rate
from Sales.CurrencyRate cr 
where cr.FromCurrencyCode='USD' and cr.ToCurrencyCode in ('AUD','DZD')
group by cr.FromCurrencyCode , cr.ToCurrencyCode

--2) Find the products having offer on it and display product name , safety Stock Level, Listprice,  and product model id, type of discount,  percentage of discount,  offer start date and offer end date 

select p.Name,
	   p.SafetyStockLevel,
	   p.ListPrice,
	   p.ProductModelID,
	   so.Type,
	   so.DiscountPct,
	   so.StartDate,
	   so.EndDate
from Production.Product p,
	 Sales.SpecialOffer so,
	 Sales.SpecialOfferProduct sp
where so.SpecialOfferID=sp.SpecialOfferID and
	  p.ProductID=sp.ProductID
	  

--Q3 
create view ProductReview1 as
SELECT p.Name,r.Comments
FROM Production.Product p
JOIN Production.ProductReview r ON p.ProductID = r.ProductID;

select * from ProductReviews1


--Q4  find out the vendor for product   paint, Adjustable Race and blade

select* from Production.Product

select pv.BusinessEntityID,
	(select v.Name 
	from Purchasing.Vendor v 
	where v.BusinessEntityID=pv.BusinessEntityID) 
	VendorName,
	(select p.Name
	from Production.Product p 
	where pv.ProductID=p.ProductID) 
	ProductName
from Purchasing.ProductVendor pv
where pv.ProductID in 
(select p.ProductID 
from  Production.Product p 
where p.Name like '%paint%' or 
	  p.Name like '%Blade%' or 
	  p.Name ='Adjustable Race')



--Q5 - find product details shipped through ZY - EXPRESS 

select * from Production.Product;

select soh.ShipMethodID from Sales.SalesOrderHeader soh where soh.ShipMethodID=2

--SalesOrderHeader 
select * 
from Production.Product p ,
	 Sales.SalesOrderHeader soh,
	 Purchasing.ShipMethod sm,
	 Sales.SalesOrderDetail sod
where sod.SalesOrderID=soh.SalesOrderID and
	  p.ProductID=sod.ProductID and 
	  sm.ShipMethodID=soh.ShipMethodID and 
	  sm.Name = 'ZY-EXPRESS'

--PurchaseOrder Header

select p.Name,
	   p.ProductID,
	   p.ListPrice,
	   sm.Name,
	   poh.ShipMethodID
from Production.Product p ,
	 Purchasing.PurchaseOrderHeader poh,
	 Purchasing.ShipMethod sm,
	 Purchasing.PurchaseOrderDetail pod
where pod.PurchaseOrderID=poh.PurchaseOrderID and
	  p.ProductID=pod.ProductID and 
	  sm.ShipMethodID=poh.ShipMethodID and 
	  sm.Name = 'ZY - EXPRESS'
group by p.Name,
	   p.ProductID,
	   p.ListPrice,
	   sm.Name,
	   poh.ShipMethodID

--Q6- find the tax amt for products where order date and ship date are on the same day 

select 
(select p.Name from Production.Product p where p.ProductID=pd.ProductID)as ProductName,
ph.TaxAmt as Tax_Amount
from Purchasing.PurchaseOrderDetail pd
join Purchasing.PurchaseOrderHeader ph 
on pd.PurchaseOrderID = ph.PurchaseOrderID
where day(ph.OrderDate)=day(ph.ShipDate)

--Q7 -  find the average days required to ship the product based on shipment type. 


--Q8--  find the name of employees working in day shift 

select edh.BusinessEntityID,
	(select concat_ws(' ',p.FirstName,p.MiddleName,p.LastName) 
	from Person.Person p
	where p.BusinessEntityID= edh.BusinessEntityID) FullName ,
	(select s.Name from HumanResources.Shift s 
	where s.ShiftID=edh.ShiftID) Shift
from HumanResources.EmployeeDepartmentHistory edh
where edh.ShiftID in 
					(select s.ShiftID 
					from HumanResources.Shift s
					where s.Name='Day')

-- Q9 -  based on product and product cost history find the name , service provider time and average Standardcost   
select DATEDIFF_BIG(DAY,StartDate,EndDate) from Production.ProductCostHistory


SELECT 
    ch.ProductID,
    p.Name AS ProdName,
    AVG(ch.StandardCost) AS avg_stdCost,
    DATEDIFF_BIG(day, min(ch.StartDate), max(ch.EndDate)) ServiceTime
FROM Production.ProductCostHistory ch,
 Production.Product p 
    where ch.ProductID = p.ProductID
GROUP BY ch.ProductID, p.Name;
--doubt why service time is null 

--Q10 - prod with average cost more than 500
SELECT 
    ch.ProductID,
    p.Name AS ProdName,
    AVG(ch.StandardCost) AS avg_stdCost
FROM Production.ProductCostHistory ch,
	Production.Product p 
where ch.ProductID = p.ProductID
GROUP BY ch.ProductID, p.Name
HAVING AVG(ch.StandardCost) >500

 --Q11 find the employee who worked in multiple territory 

select e.BusinessEntityID,
		(select concat_ws(' ',p.FirstName,p.MiddleName,p.LastName) from Person.Person p 
		where p.BusinessEntityID=e.BusinessEntityID) FullName, 
		count(st.TerritoryID) Territorycnt
from HumanResources.Employee e,
	 Sales.SalesTerritoryHistory st
where e.BusinessEntityID=st.BusinessEntityID 
group by  e.BusinessEntityID
having count(st.TerritoryID) >1


--Q12  find out the Product model name,  product description for culture as Arabic 

select* from Production.ProductModel
select* from Production.ProductDescription
select* from Production.Culture
select* from Production.ProductModelProductDescriptionCulture
--1
select pm.Name as Product_Model_Name,
pd.Description as Product_Description
from Production.ProductModel pm
join Production.ProductModelProductDescriptionCulture pdc
on pm.ProductModelID=pdc.ProductModelID
join Production.ProductDescription pd
on pd.ProductDescriptionID=pd.ProductDescriptionID
join Production.Culture pc
on pc.CultureID=pdc.CultureID
where pc.Name like 'Arabic'
group by pm.Name,pd.Description

--2
select p.Name,
	   pd.Description
from Production.Product p ,
	 Production.ProductModelProductDescriptionCulture m,
	 Production.ProductDescription pd
where p.ProductModelID=m.ProductModelID and 
	  pd.ProductDescriptionID=m.ProductDescriptionID and
m.ProductModelID in (select n.ProductModelID 
					from Production.ProductModelProductDescriptionCulture n
					where n.CultureID='ar')
group by p.Name,pd.Description



	--13)display Empname ,Territory name ,group ,saleslastyear SalesQuota,bonus

	select sp.BusinessEntityID,sp.Bonus,sp.SalesQuota,sp.TerritoryID,sp.SalesLastYear,
	(select p.FirstName
		   from Person.Person p
		   where p.BusinessEntityID=sp.BusinessEntityID) FirstName,
	(select st.[Group]
	from Sales.SalesTerritory st
	where st.TerritoryID=sp.TerritoryID
	) TerritoryGrp ,
	(select st.Name
	from Sales.SalesTerritory st
	where st.TerritoryID=sp.TerritoryID
	) Territory
	from Sales.SalesPerson sp

	--14)display Empname ,Territory name ,group ,saleslastyear SalesQuota,bonus in germany and united kingdom

select sp.BusinessEntityID,sp.Bonus,sp.SalesQuota,sp.TerritoryID,sp.SalesLastYear,
	(select p.FirstName
		   from Person.Person p
		   where p.BusinessEntityID=sp.BusinessEntityID) FirstName,
	(select st.[Group]
	from Sales.SalesTerritory st
	where st.TerritoryID=sp.TerritoryID
	) TerritoryGrp ,
	(select st.Name
	from Sales.SalesTerritory st
	where st.TerritoryID=sp.TerritoryID
	) Territory
	from Sales.SalesPerson sp
	where sp.TerritoryID in 
	(select st.TerritoryID 
	from Sales.SalesTerritory st 
	where st.Name='Germany' or st.Name='United Kingdom')

	
--15) Find all employees who worked in all North America territory
select sp.BusinessEntityID,
	(select p.FirstName
		   from Person.Person p
		   where p.BusinessEntityID=sp.BusinessEntityID) FirstName,
	(select st.Name
	from Sales.SalesTerritory st
	where st.TerritoryID=sp.TerritoryID
	) Territory
	from Sales.SalesPerson sp
	where sp.TerritoryID in 
	(select st.TerritoryID 
	from Sales.SalesTerritory st 
	where st.[Group]='North America')


--16) find all products in the cart

--a
select *,
	(select p.Name 
		from Production.Product p
		where p.ProductID=c.ProductID) ProductName 
from Sales.ShoppingCartItem c

--b
select * 
from Production.Product p
where p.ProductID in 
	(select c.ProductId 
	from Sales.ShoppingCartItem c)

--17) find all the products with special offer

select p.ProductID,p.Name
from Production.Product p
where p.ProductID in 
	(select c.ProductId 
	from Sales.SpecialOfferProduct c)

--18) find all employees name , job title, card details whose credit card expired in the month 11 and year as 2008
select pc.BusinessEntityID,
		pc.CreditCardID,
		(select p.FirstName 
		from Person.Person p
		where p.BusinessEntityID=pc.BusinessEntityID) FirstName ,
		(select e.JobTitle
		from HumanResources.Employee e
		where e.BusinessEntityID=pc.BusinessEntityID) JobTitle,
		(select c.CardType
		from Sales.CreditCard c where c.CreditCardID=pc.CreditCardID) CardType
 from Sales.PersonCreditCard pc 
 WHERE pc.CreditCardID IN (
    SELECT c.CreditCardID 
    FROM Sales.CreditCard c 
    WHERE c.ExpMonth = 11 AND c.ExpYear = 2008)

--