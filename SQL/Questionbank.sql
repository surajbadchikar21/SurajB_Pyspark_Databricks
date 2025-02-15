-----------------
--DDl
create database questionBank
use questionBank
--DDL
/*1.	Create a customer table having following column with suitable data type
Cust_id  (automatically incremented primary key)
Customer name (only characters must be there)
Aadhar card (unique per customer)
Mobile number (unique per customer)
Date of birth (check if the customer is having age more than15)
Address
Address type code (B- business, H- HOME, O-office and should not accept any other)
State code ( MH – Maharashtra, KA for Karnataka)*/

create schema ddl

create table ddl.customer(
cust_id int identity(1,1) primary key,
customerName  varchar(20) not null check(customerName not like '%[^A-za-z]%') ,
AadharCard varchar(10) unique,
mobileNumber varchar(10) unique,
dob datetime not null check(datediff(year,dob,getdate())>15) ,
Address varchar(150),
AddressType char(1) not null check(AddressType in ('B', 'H', 'O')) ,
StateCode varchar(2) not null check(StateCode in ('MH', 'KA' )) 
);


/*Create another table for Address type which is having
Address type code must accept only (B,H,O)
Address type  having the information as  (B- business, H- HOME, O-office)*/


create table ddl.addressType(
AddressType char(1) not null check(AddressType in ('B', 'H', 'O')) ,
AddressInfo varchar(20) not null
);

insert into ddl.addressType values('B','Business');
insert into ddl.addressType values('H','Home');
insert into ddl.addressType values('O','Office');

select * from ddl.addressType;

/*Create table state_info having columns as  
State_id  primary unique
State name 
Country_code char(2)*/

create table ddl.state_info(
StateCode varchar(2) primary key, 
stateName varchar(20),
countryCode varchar(2)
);

-- as the referenced colum must be a primary key - 
ALTER TABLE ddl.addressType
ADD CONSTRAINT pk_addressType 
PRIMARY KEY (AddressType);

--Alter tables to link all tables based on suitable columns and foreign keys.
ALTER TABLE ddl.customer
ADD CONSTRAINT fk_customer_addressType
FOREIGN KEY (AddressType) REFERENCES ddl.addressType(AddressType);

alter table ddl.customer
add constraint fk_customer_state_id
foreign key (StateCode) references ddl.state_info(StateCode)

--Change the column name from customer table customer name as c_name


ALTER TABLE ddl.customer DROP CONSTRAINT CK__customer__custom__398D8EEE;
EXEC sp_rename 'ddl.customer.customerName', 'c_name', 'COLUMN';

ALTER TABLE ddl.customer
ADD CONSTRAINT CK_customer_c_name CHECK (c_name NOT LIKE '%[^A-Za-z]%');


--Insert the suitable records into the respective tables

INSERT INTO ddl.state_info (StateCode, stateName, countryCode) VALUES
('MH', 'Maharashtra', 'IN'),
('KA', 'Karnataka', 'IN'),
('GJ', 'Gujarat', 'IN'),
('DL', 'Delhi', 'IN');


INSERT INTO ddl.customer  VALUES
('abc', '1234567890', '9876543210', '2000-05-15', '123, MG Road, Pune', 'H', 'MH'),
('xyz', '2234567891', '8876543211', '1995-08-20', '456, Brigade Road, Bangalore', 'O', 'KA'),
('axy', '3234567892', '7876543212', '1990-12-10', '789, FC Road, Pune', 'B', 'MH'),
('yab', '4234567893', '6876543213', '1997-03-25', '101, JP Nagar, Bangalore', 'H', 'KA');

--Change the data type of  country_code to varchar(3)

ALTER TABLE ddl.state_info
ALTER COLUMN countryCode VARCHAR(3);








------------------------------
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
WHERE c.COLUMN_NAME='TerritoryID'
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
select* from Purchasing.ShipMethod
select* from Production.Product
select* from Purchasing.PurchaseOrderHeader
select* from Purchasing.PurchaseOrderDetail

select 
    ps.Name as Shipment_Type, 
    avg(datediff(day, ph.OrderDate, ph.ShipDate)) as Avg_Shipping_Days
from Purchasing.PurchaseOrderHeader ph
join Purchasing.ShipMethod ps 
    on ph.ShipMethodID = ps.ShipMethodID
where ph.ShipDate is not null
group by ps.Name
order by Avg_Shipping_Days desc;

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
					where s.Name='Day') and 
					edh.EndDate is null

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


--13.	 Find first 20 employees who joined very early in the company

--method 1
select top 20 e.BusinessEntityID,e.HireDate
from HumanResources.Employee e
order by e.HireDate 

--method 2 
select top 20 * from(
select e.BusinessEntityID,e.HireDate,
DENSE_RANK() over(order by e.HireDate) _dense_rank
from HumanResources.Employee e) t
where t._dense_rank<=20

--14.Find most trending product based on sales and purchase.

select*from Production.Product
select*from sales.SalesOrderDetail
select*from Purchasing.PurchaseOrderDetail

select top 1 p.name as productname, 
sum(sod.orderqty) + sum(pod.orderqty) as trendscore
from production.product p
left join sales.salesorderdetail sod on p.productid = sod.productid
left join purchasing.purchaseorderdetail pod on p.productid = pod.productid
group by p.name
order by trendscore desc;
	--15)display Empname ,Territory name ,group ,saleslastyear SalesQuota,bonus

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

--16)display Empname ,Territory name ,group ,saleslastyear SalesQuota,bonus in germany and united kingdom

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

	
--17) Find all employees who worked in all North America territory
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


--18) find all products in the cart

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

--19) find all the products with special offer

select p.ProductID,p.Name
from Production.Product p
where p.ProductID in 
	(select c.ProductId 
	from Sales.SpecialOfferProduct c)

--20) find all employees name , job title, card details whose credit card expired in the month 11 and year as 2008
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

	--Q21 Find the employee whose payment might be revised  (Hint : Employee payment history) 
	select 
    (select concat_ws(' ',p.FirstName,p.LastName) from Person.Person p where p.BusinessEntityID = e.BusinessEntityID) as EmployeeName,
    e.BusinessEntityID,
    (select count(RateChangeDate) 
     from HumanResources.EmployeePayHistory eph 
     where eph.BusinessEntityID = e.BusinessEntityID) as PayRevisions
from HumanResources.Employee e
where (select count(RateChangeDate) 
       from HumanResources.EmployeePayHistory eph 
       where eph.BusinessEntityID = e.BusinessEntityID) > 1

	--Q22 Find total standard cost for the active Product. (Product cost history)

	select * from Production.ProductCostHistory

	select sum(t.StandardCost)  total_active_product_standard_cost from (
	select pch.ProductID,pch.StandardCost
	from Production.ProductCostHistory pch) t

-- Q23 - Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type) 

select * from Person.Person;
select * from Person.Address;
select * from Person.AddressType;
select * from Person.BusinessEntityAddress;

select p.BusinessEntityID,
	   p.FirstName,
	   p.LastName,
	   bea.AddressTypeID,
	   a.AddressLine1,
	   a.AddressLine2,
	   a.City,
	   at.Name
from Person.BusinessEntityAddress bea,
	 Person.Address a,
	 Person.AddressType at,
	 Person.Person p 
where bea.BusinessEntityID=p.BusinessEntityID and 
	  bea.AddressTypeID=at.AddressTypeID and 
	  bea.AddressID=a.AddressID

select count(*) from Person.Address
select count(*) from Person.Person
select count(*) from Person.BusinessEntityAddress

-- Q24 --  Find the name of employees working in group of North America territory 

select * from Sales.SalesTerritory; --territory id ,Group
select * from Sales.SalesTerritoryHistory;--business entity id , territory id 
select * from HumanResources.Employee;--business entity id
select * from Person.Person;--business entity id

select distinct e.BusinessEntityID, p.FirstName,p.LastName,st.[Group]
from Sales.SalesTerritory st,
	 Sales.SalesTerritoryHistory sth,
	 HumanResources.Employee e,
	 Person.Person p
where p.BusinessEntityID=e.BusinessEntityID and 
	  st.TerritoryID=sth.TerritoryID and
	  sth.BusinessEntityID=e.BusinessEntityID and 
	  st.[Group]='North America'


--Q25- Find the employee whose payment is revised for more than once   

--Find the employee whose payment is revised for more than once
select ph.BusinessEntityID,count(*) from HumanResources.EmployeePayHistory ph
group by ph.BusinessEntityID
having count(*)>1


--Q26-  display the personal details of  employee whose payment is revised for more than once. 

select ph.BusinessEntityID,count(*) RevisedTimes ,p.FirstName
from HumanResources.EmployeePayHistory ph,
	 Person.Person p
where ph.BusinessEntityID=p.BusinessEntityID
group by ph.BusinessEntityID,p.FirstName
having count(*)>1


--27.	Which shelf is having maximum quantity (product inventory)
use AdventureWorks2022
select * from Production.ProductInventory

select top 1 p.Shelf,sum(p.Quantity) quantity
from Production.ProductInventory p
group by p.Shelf
order by sum(p.Quantity) desc



 --28.	Which shelf is using maximum bin(product inventory)

 select top 1 p.Shelf,sum(p.Bin) bin
from Production.ProductInventory p
group by p.Shelf
order by sum(p.Bin) desc

--2 
SELECT TOP 1 p.Shelf, COUNT(DISTINCT p.Bin) AS BinCount
FROM Production.ProductInventory p
GROUP BY p.Shelf
ORDER BY BinCount DESC;


--29.	Which location is having minimum bin (product inventory)
select * from Production.ProductInventory

select top 1 p.LocationID,sum(p.Bin) bin
from Production.ProductInventory p
group by p.LocationID
order by sum(p.Bin) 

--2
SELECT TOP 1 p.LocationID, COUNT(DISTINCT p.Bin) AS BinCount
FROM Production.ProductInventory p
GROUP BY p.LocationID
ORDER BY BinCount;

--30.	Find out the product available in most of the locations (product inventory)
use AdventureWorks2022

SELECT TOP 1 
    p.Name AS ProductName,
    pi.ProductID,
    COUNT(DISTINCT pi.LocationID) AS LocationCount
FROM Production.ProductInventory pi
JOIN Production.Product p ON pi.ProductID = p.ProductID
GROUP BY pi.ProductID, p.Name
ORDER BY LocationCount DESC;


--31.	Which sales order is having most order qualtity.

SELECT TOP 1 
    sod.SalesOrderID,
    SUM(sod.OrderQty) AS TotalOrderQuantity
FROM Sales.SalesOrderDetail sod
GROUP BY sod.SalesOrderID
ORDER BY TotalOrderQuantity DESC;


--Q32 - 
/*32.	 find the duration of payment revision on every interval  (inline view) Output must be as given format
## revised time – count of revised salries
## duration – last duration of revision e.g there are two revision date 01-01-2022 and revised in 01-01-2024   so duration here is 2years  */


SELECT 
    d.BusinessEntityID,
    DATEDIFF_BIG(MONTH, d.Penultimate, d.Ultimate) AS MonthDifference
FROM ( 
    SELECT 
        t.BusinessEntityID,
        (SELECT RateChangeDate 
         FROM (SELECT BusinessEntityID, RateChangeDate, ROW_NUMBER() OVER (PARTITION BY BusinessEntityID ORDER BY RateChangeDate DESC) AS rankNumber
               FROM HumanResources.EmployeePayHistory) AS sub
         WHERE sub.rankNumber = 1 AND sub.BusinessEntityID = t.BusinessEntityID
        ) AS Ultimate,
        (SELECT RateChangeDate 
         FROM (SELECT BusinessEntityID, RateChangeDate, ROW_NUMBER() OVER (PARTITION BY BusinessEntityID ORDER BY RateChangeDate DESC) AS rankNumber
               FROM HumanResources.EmployeePayHistory) AS sub
         WHERE sub.rankNumber = 2 AND sub.BusinessEntityID = t.BusinessEntityID
        ) AS Penultimate
    FROM (SELECT DISTINCT BusinessEntityID FROM HumanResources.EmployeePayHistory) AS t
) AS d  
WHERE d.Penultimate IS NOT NULL;


--  Q33 check if any employee from jobcandidate table is having any payment revisions 

	select * from HumanResources.JobCandidate jc-- job canddidate id , business entity id 

select ph.BusinessEntityID,count(*) RevisedTimes ,p.FirstName
from HumanResources.EmployeePayHistory ph,
	 Person.Person p,
	 HumanResources.JobCandidate jc
where ph.BusinessEntityID=p.BusinessEntityID and 
	  ph.BusinessEntityID=jc.BusinessEntityID
group by ph.BusinessEntityID,p.FirstName


--Q34 - check the department having more salary revision 

select * from HumanResources.Department
select * from HumanResources.EmployeeDepartmentHistory

select top 1 jc.DepartmentID,d.Name,count(*) RevisedTimes
from HumanResources.EmployeePayHistory ph,
	 HumanResources.EmployeeDepartmentHistory jc,
	 HumanResources.Department d
where ph.BusinessEntityID=jc.BusinessEntityID and
	  jc.DepartmentID = d.DepartmentID
group by jc.DepartmentID,d.Name
order by count(*) desc

-- Q35 -  check the employee whose payment is not yet revised 
select e.BusinessEntityID
from HumanResources.Employee e 
where e.BusinessEntityID 
not in (
select ph.BusinessEntityID from HumanResources.EmployeePayHistory ph
)


--Q36-  find the job title having more revised payments 

select top 1 e.JobTitle,count(*)
from HumanResources.Employee e,
	 HumanResources.EmployeePayHistory eph
where e.BusinessEntityID=eph.BusinessEntityID
group by e.JobTitle
order by count(*) desc

--37 find the employee whose payment is revised in shortest duration (inline view) 
select * from HumanResources.EmployeePayHistory

SELECT TOP 1 *
FROM (
    SELECT 
        eph.BusinessEntityID, 
        eph.RateChangeDate, 
        eph.Rate, 
        LAG(eph.RateChangeDate) OVER (PARTITION BY eph.BusinessEntityID ORDER BY eph.RateChangeDate) AS PrevRateChangeDate,
        DATEDIFF(DAY, LAG(eph.RateChangeDate) OVER (PARTITION BY eph.BusinessEntityID ORDER BY eph.RateChangeDate), eph.RateChangeDate) AS Duration
    FROM HumanResources.EmployeePayHistory eph
) AS PayHistory
WHERE PrevRateChangeDate IS NOT NULL
ORDER BY Duration ASC;


--Q38 -  find the colour wise count of the product (tbl: product) 

	select * from Production.Product

	select  p.Color,count(*)
	from Production.Product p
	group by p.Color


--Q39 -  find out the product who are not in position to sell (hint: check the sell start and end date) 

select * from Production.Product

select p.Name,p.ProductID
from Production.Product p
where p.SellEndDate is not null 
--and p.SellEndDate > GETDATE()


--Q40 - find the class wise, style wise average standard cost 

select p.Class,p.Style,avg(p.StandardCost) avg_std_cost
from Production.Product p
group by  p.Class,p.Style

select p.Class,p.Style,avg(p.StandardCost) avg_std_cost
from Production.Product p
where p.Class is not null or p.Style is not null
group by  p.Class,p.Style

select p.Class,p.Style,avg(p.StandardCost) avg_std_cost
from Production.Product p
where p.Class is not null and p.Style is not null
group by  p.Class,p.Style

--Q41 -  check colour wise standard cost 

	select  p.Color,avg(p.StandardCost) avg_std_cost
	from Production.Product p
	where color is not null
	group by p.Color

--	Q42 -  find the product line wise standard cost 

select * from Production.Product

	select  p.ProductLine,avg(p.StandardCost) avg_std_cost
	from Production.Product p
	group by p.ProductLine

	select  p.ProductLine,avg(p.StandardCost) avg_std_cost
	from Production.Product p
	where p.ProductLine is not null
	group by p.ProductLine

--Q43 - Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince) 

select * from Sales.SalesTaxRate
select * from  Person.StateProvince

select  st.StateProvinceID,sp.Name,avg(st.TaxRate) avg_tax_rate
from Sales.SalesTaxRate st,
	 Person.StateProvince sp
where st.StateProvinceID=sp.StateProvinceID
group by  st.StateProvinceID,sp.Name


--Q44 -Find the department wise count of employees 

select * from HumanResources.EmployeeDepartmentHistory

select edh.DepartmentID,count(*) count_of_employees
from HumanResources.EmployeeDepartmentHistory edh
group by edh.DepartmentID

--Q45 -Find the department which is having more employees 

select top 1 edh.DepartmentID,count(*) count_of_employees
from HumanResources.EmployeeDepartmentHistory edh
group by edh.DepartmentID
order by count(*) desc

--Q46 Find the job title having more employees 

select * from HumanResources.Employee

select e.JobTitle ,count(*) no_of_emp
from HumanResources.Employee e
group by e.JobTitle

--Q47 -Check if there is mass hiring of employees on single day 
select * from HumanResources.Employee

select top 1  e.HireDate ,count(*) no_of_emp
from HumanResources.Employee e
group by e.HireDate
order by count(*) desc

--Q48  - Which product is purchased more? (purchase order details) 

select * from Purchasing.PurchaseOrderDetail

select top 1 pod.ProductID,count(*) purchase_count
from Purchasing.PurchaseOrderDetail pod
group by pod.ProductID
order by count(*) desc


--49.	Find the territory wise customers count   (hint: customer)

SELECT TerritoryID, COUNT(CustomerID) AS CustomerCount
FROM Sales.Customer
GROUP BY TerritoryID
ORDER BY CustomerCount DESC;

--50.	Which territory is having more customers (hint: customer)


SELECT TerritoryID, COUNT(CustomerID) AS CustomerCount
FROM Sales.Customer
GROUP BY TerritoryID
HAVING COUNT(CustomerID) = (
    SELECT MAX(CustomerCount)
    FROM (
        SELECT TerritoryID, COUNT(CustomerID) AS CustomerCount
        FROM Sales.Customer
        GROUP BY TerritoryID
    ) AS CustomerCounts
);

--51.	Which territory is having more stores (hint: customer)
USE AdventureWorks2022;

SELECT TerritoryID, COUNT(CustomerID) AS StoreCount
FROM Sales.Customer
WHERE PersonID IS NULL  -- Stores have NULL PersonID
GROUP BY TerritoryID
HAVING COUNT(CustomerID) = (
    SELECT MAX(StoreCount)
    FROM (
        SELECT TerritoryID, COUNT(CustomerID) AS StoreCount
        FROM Sales.Customer
        WHERE PersonID IS NULL
        GROUP BY TerritoryID
    ) AS StoreCounts
);

--52.	 Is there any person having more than one credit card (hint: PersonCreditCard)

select pc.BusinessEntityID,count(*) card_count
from Sales.PersonCreditCard pc
group by pc.BusinessEntityID
having count(*)>1

--53.	Find the product wise sale price (sales order details)

SELECT ProductID, AVG(UnitPrice) AS AvgSalePrice
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY AvgSalePrice DESC;

--54.	Find the total values for line total product having maximum order


SELECT ProductID, SUM(LineTotal) AS TotalLineValue
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) = (
    SELECT MAX(OrderCount)
    FROM (
        SELECT ProductID, COUNT(*) AS OrderCount
        FROM Sales.SalesOrderDetail
        GROUP BY ProductID
    ) AS ProductOrders
);

--Date Queries 
--55. Calculate the age of employees
use AdventureWorks2022
select * from HumanResources.Employee

select e.BusinessEntityID,DATEDIFF(year,e.BirthDate,GETDATE()) age
from HumanResources.Employee e

--56. Calculate the year of experience of the employee based on hire date

	select e.BusinessEntityID,DATEDIFF(year,e.HireDate,GETDATE()) age
	from HumanResources.Employee e

--57. Find the age of employee at the time of joining

select e.BusinessEntityID,DATEDIFF(year,e.BirthDate,e.HireDate) age
from HumanResources.Employee e

--58. Find the average age of male and female
select e.Gender,avg(DATEDIFF(year,e.BirthDate,GETDATE())) age
from HumanResources.Employee e
group by e.Gender

--59. Which product is the oldest product as on the date (refer the product sell start date)

select top 1 ProductID,Name,SellStartDate from Production.Product
order by SellStartDate asc


-- but there are multiple products whose sell Start date is same so to get all of them 
select * from (
select ProductID,
			 Name,
			 SellStartDate,
			 RANK() over(order by SellStartDate) _rank
from Production.Product ) t
where t._rank =1

--60. Display the product name, standard cost, and time duration for the same cost. (Product cost history)

select * from Production.ProductCostHistory

SELECT 
    p.Name AS ProductName,
    pch.StandardCost,
    pch.StartDate,
    ISNULL(pch.EndDate, GETDATE()) AS EndDate,
    DATEDIFF(DAY, pch.StartDate, ISNULL(pch.EndDate, GETDATE())) AS CostDurationDays
FROM Production.ProductCostHistory pch
JOIN Production.Product p ON p.ProductID = pch.ProductID
ORDER BY p.Name, pch.StartDate;


--61. Find the purchase id where shipment is done 1 month later of order date

select * from Purchasing.PurchaseOrderHeader

select t.PurchaseOrderID from 
(select poh.*,
	   DATEADD(month,1,poh.OrderDate)as month_add 
from Purchasing.PurchaseOrderHeader poh) t
where t.ShipDate>=t.month_add

--method 2 but some doubts 
select PurchaseOrderID 
 from Purchasing.PurchaseOrderHeader where datediff(MONTH,OrderDate,ShipDate)=1

--62. Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)

select sum(t.TotalDue) as total_due_sum from 
(select poh.*,
	   DATEADD(day,10,poh.OrderDate)as month_add 
from Purchasing.PurchaseOrderHeader poh) t
where t.ShipDate>=t.month_add



--63. Find the average difference in due date and ship date based on online order flag

SELECT 
    OnlineOrderFlag,
    AVG(DATEDIFF(DAY, ShipDate, DueDate)) AS AvgDateDifference
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag;

select * from Sales.SalesOrderHeader

--Window Functions - 

--64.	Display business entity id, marital status, gender, vacationhr, average vacation based on marital status
SELECT e.BusinessEntityID, e.MaritalStatus, e.Gender, e.VacationHours,
       AVG(e.VacationHours) OVER(PARTITION BY e.MaritalStatus) AS average_by_maritial_status
FROM HumanResources.Employee e;


--65.	Display business entity id, marital status, gender, vacationhr, average vacation based on gender

SELECT e.BusinessEntityID, e.MaritalStatus, e.Gender, e.VacationHours,
       AVG(e.VacationHours) OVER(PARTITION BY e.Gender) AS average_by_gender
FROM HumanResources.Employee e;


--66.	Display business entity id, marital status, gender, vacationhr, average vacation based on organizational level

SELECT e.BusinessEntityID, e.MaritalStatus, e.Gender, e.VacationHours, e.OrganizationLevel,
       AVG(e.VacationHours) OVER(PARTITION BY e.OrganizationLevel) AS average_by_org_level
FROM HumanResources.Employee e;


--67.	Display entity id, hire date, department name and department wise count of employee and count based on organizational level in each dept
SELECT e.BusinessEntityID, e.HireDate, d.Name AS DepartmentName,
       COUNT(e.BusinessEntityID) OVER (PARTITION BY d.DepartmentID) AS EmployeeCountByDept,
       COUNT(e.BusinessEntityID) OVER (PARTITION BY d.DepartmentID, e.OrganizationLevel) AS EmployeeCountByOrgLevel
FROM HumanResources.Employee e
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID;

--68.	Display department name, average sick leave and sick leave per department
select distinct d.Name,d.DepartmentID,
		(select avg(SickLeaveHours) from HumanResources.Employee e) avg_sickleave,
		avg(SickLeaveHours) over (partition by d.DepartmentID )  sickLeaveHrs_per_dept
from HumanResources.Employee e,
	 HumanResources.Department d,
	 HumanResources.EmployeeDepartmentHistory edh
where e.BusinessEntityID=edh.BusinessEntityID and 
	  edh.DepartmentID=d.DepartmentID

--69.	Display the employee details first name, last name,  with total count of various shift done by the person and shifts count per department
SELECT p.FirstName, p.LastName, s.Name AS ShiftName,
       COUNT(s.ShiftID) OVER (PARTITION BY e.BusinessEntityID) AS TotalShiftsByEmployee,
       COUNT(s.ShiftID) OVER (PARTITION BY d.DepartmentID) AS TotalShiftsByDepartment
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
JOIN HumanResources.Shift s ON edh.ShiftID = s.ShiftID;

--70.	Display country region code, group average sales quota based on territory id

select * from Sales.SalesTerritory
select * from Sales.SalesPerson

select distinct st.CountryRegionCode,st.[Group],st.TerritoryID,st.Name,
		avg(sp.SalesQuota) over (partition by st.TerritoryID) avg_sales_quota
from Sales.SalesTerritory st , 
	Sales.SalesPerson sp
where st.TerritoryID=sp.TerritoryID

--71.	Display special offer description, category and avg(discount pct) per the category
select sp.Description,sp.Category,
	   avg(DiscountPct) over(partition by sp.Category ) _avgdiscountpct
from Sales.SpecialOffer sp

--72.	Display special offer description, category and avg(discount pct) per the month

select * from Sales.SpecialOffer

select sp.Description,sp.Category,month(sp.StartDate) _month,
	   avg(DiscountPct) over(partition by month(sp.StartDate) ) _avgdiscountpct
from Sales.SpecialOffer sp

select t.Description,t.Category,avg(t.DiscountPct),t._month from
(select sf.SpecialOfferID,
	   sf.Description,
	   sf.Category,
	   sf.DiscountPct,
	   month(sf.StartDate) _month
from Sales.SpecialOffer sf) as t 
group by t.Description,t.Category,t._month

--73.	Display special offer description, category and avg(discount pct) per the year
SELECT sp.Description, sp.Category, YEAR(sp.StartDate) _year,
       AVG(sp.DiscountPct) OVER (PARTITION BY YEAR(sp.StartDate)) _avgdiscountpct
FROM Sales.SpecialOffer sp;


select t.Description,t.Category,avg(t.DiscountPct),t._month from
(select sf.SpecialOfferID,
	   sf.Description,
	   sf.Category,
	   sf.DiscountPct,
	   year(sf.StartDate) _month
from Sales.SpecialOffer sf) as t 
group by t.Description,t.Category,t._month



--74.	Display special offer description, category and avg(discount pct) per the type
SELECT sp.Description, sp.Category, sp.Type,
       AVG(sp.DiscountPct) OVER (PARTITION BY sp.Type) _avgdiscountpct
FROM Sales.SpecialOffer sp;




--75.	Using rank and dense rank find territory wise top sales person

SELECT s.BusinessEntityID, st.TerritoryID, s.SalesYTD,
       RANK() OVER (PARTITION BY st.TerritoryID ORDER BY s.SalesYTD DESC) AS SalesRank,
       DENSE_RANK() OVER (PARTITION BY st.TerritoryID ORDER BY s.SalesYTD DESC) AS DenseSalesRank
FROM Sales.SalesPerson s
JOIN Sales.SalesTerritory st ON s.TerritoryID = st.TerritoryID;


--rank
select * from(
select sp.BusinessEntityID,sp.SalesLastYear,
rank() over(order by sp.SalesLastYear desc) _rank
from Sales.SalesPerson sp) t

--dense_rank 

select * from(
select sp.BusinessEntityID,sp.SalesLastYear,
dense_rank() over(order by sp.SalesLastYear desc) _rank
from Sales.SalesPerson sp) t
where t._rank=1