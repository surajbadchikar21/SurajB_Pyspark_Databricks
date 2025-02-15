use AdventureWorks2022
--1

SELECT sp.BusinessEntityID, 
       CONCAT_WS(' ', p.FirstName, p.MiddleName, p.LastName) AS Full_Name
FROM Sales.SalesPerson sp
JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
JOIN Sales.Store s ON sp.BusinessEntityID = s.BusinessEntityID;



--.A.  Find first 20 employees who joined very early in the company

select * from HumanResources.Employee

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


--B. Find all employees name , job title, card details whose credit card expired in the month 9 and year as 2009
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
    WHERE c.ExpMonth = 9 AND c.ExpYear = 2009)

-- C. Find the store address and contact number based on tables store and Business entity  check if any other table is required.

select * from Sales.Store  --bussiness entity id,nameofstore,salespersonid
select * from sales.vStoreWithAddresses --bussinessentiity id,addressline 1
select * from Sales.vStoreWithContacts --bussiensseentiid,phonenumber

select s.Name,sa.AddressLine1,sc.PhoneNumber from sales.store s,sales.vStoreWithAddresses sa,Sales.vStoreWithContacts sc where
s.BusinessEntityID=sa.BusinessEntityID and sa.BusinessEntityID=sc.BusinessEntityID

	  


-- D.  check if any employee from job candidate table is having any payment revisions

select * from HumanResources.JobCandidate

select ph.BusinessEntityID,count(*) RevisedTimes ,p.FirstName
from HumanResources.EmployeePayHistory ph,
	 Person.Person p,
	 HumanResources.JobCandidate jc
where ph.BusinessEntityID=p.BusinessEntityID and 
	  ph.BusinessEntityID=jc.BusinessEntityID
group by ph.BusinessEntityID,p.FirstName


--E. check colour wise standard cost

-- I have ordered it in desc order for better analysis 
select * from Production.Product

select p.Color,avg(p.StandardCost) avg_standard_cost
from Production.Product p
where p.Color is not null
group by p.Color
order by avg(p.StandardCost) desc

-- F. Which product is purchased more? (purchase order details)

select * from Purchasing.PurchaseOrderDetail

select top 1 pod.ProductID,p.Name,sum(pod.OrderQty) purchase_count
from Purchasing.PurchaseOrderDetail pod,
	 Production.Product p
where pod.ProductID=p.ProductID
group by p.Name,pod.ProductID
order by sum(pod.OrderQty) desc

-- G.  Find the total values for line total product having maximum order

	select * from Production.Product

select top 1 p.ProductLine,sum(pod.OrderQty) maximum_orders
from Purchasing.PurchaseOrderDetail pod,
	 Production.Product p
where pod.ProductID=p.ProductID and 
	p.ProductLine is not null
group by p.ProductLine
order by sum(pod.OrderQty) desc

--H.  Which product is the oldest product as on the date (refer  the product sell start date)

-- the below query will suffice to get the oldest product
select top 1 ProductID,Name,SellStartDate from Production.Product
order by SellStartDate desc

-- but there are multiple products whose sell Start date is same so to get all of them 
select * from (
select ProductID,
			 Name,
			 SellStartDate,
			 RANK() over(order by SellStartDate desc) _rank
from Production.Product ) t
where t._rank =1


--I. Find all the employees whose salary is more than the average salary

	select * from HumanResources.EmployeePayHistory

	select * from 
	(select eph.BusinessEntityID,eph.Rate,
	avg(eph.Rate) over() avg_rate,
	rank() over(partition by eph.BusinessEntityID order by eph.Rate desc) _rank
	from HumanResources.EmployeePayHistory eph) t
	where t.Rate>t.avg_rate 
	and t._rank=1


	
	

--J. Display country region code, group average sales quota based on territory id 

select * from Sales.SalesPerson
select * from Sales.SalesTerritory

select distinct st.CountryRegionCode,st.TerritoryID,
	   avg(sp.SalesQuota) over(partition by st.TerritoryID) avg_sales_quota
from Sales.SalesPerson sp,
	 Sales.SalesTerritory st
where sp.TerritoryID=st.TerritoryID

-- K Find the average age of male and female

	select * from HumanResources.Employee

	select e.Gender,
	avg(DATEDIFF(year,e.BirthDate,GETDATE())) avg_age
	from HumanResources.Employee e
	group by e.Gender

--L. Which territory is having more stores 

select * from Sales.Customer;

select top 1 c.TerritoryID,st.Name,count(*) count_of_stores
from Sales.Customer c , 
	 Sales.SalesTerritory st
where c.TerritoryID=st.TerritoryID
group by c.TerritoryID,st.Name
order by count(*) desc

--M. Check for sales person details  which are working in Stores (find the sales person ID)

select*from Sales.Store
select*from sales.SalesPerson
select*from sales.SalesOrderHeader

select distinct s.BusinessEntityID,s.Name from
Sales.Store s
join sales.SalesOrderHeader o
on o.SalesPersonID=s.SalesPersonID
join sales.SalesPerson p
on p.TerritoryID=o.TerritoryID
group by s.BusinessEntityID,s.Name

--N.  display the product name and product price and count of product cost revised (productcost history)

select * from Production.ProductCostHistory

select distinct pch.ProductID,p.Name,count(*) revised_times
from Production.Product p ,
	 Production.ProductCostHistory pch
where p.ProductID=pch.ProductID
group by p.Name,pch.ProductID

--O.  check the department having more salary revision

select * from HumanResources.EmployeePayHistory;
select * from  HumanResources.EmployeeDepartmentHistory;

select top 1 edh.DepartmentID,d.Name,count(*) RevisedTimes
from HumanResources.EmployeePayHistory ph,
	 HumanResources.EmployeeDepartmentHistory edh,
	 HumanResources.Department d
where ph.BusinessEntityID=edh.BusinessEntityID and
	  edh.DepartmentID = d.DepartmentID
group by edh.DepartmentID,d.Name
order by count(*) desc
