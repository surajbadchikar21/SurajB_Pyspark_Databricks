use AdventureWorks2022

--A Find Employee having Highest rate or highest pay frequency 

select * from HumanResources.EmployeePayHistory

select top 1 eph.BusinessEntityID,max(eph.Rate) max_rate
from  HumanResources.EmployeePayHistory eph
group by eph.BusinessEntityID
order by max(eph.Rate) desc


--B - Analyze the inventory based on the shelf wise count of the product and their quantity 

select * from Production.ProductInventory

select inv.Shelf,
	   count(*) _count,sum(inv.Quantity) _quantity
from Production.ProductInventory inv
group by inv.Shelf

--C- find the personal details with address and address type 

select * from Person.Address
select * from Person.AddressType
select * from Person.BusinessEntityAddress

select p.BusinessEntityID,
	   CONCAT_WS(p.FirstName,p.MiddleName,p.LastName),
	   at.Name,
	   CONCAT_WS(' ',a.AddressLine1,a.AddressLine2 ) address_
from Person.BusinessEntityAddress bea,
	 Person.Address a,
	 Person.AddressType at,
	 Person.Person p
where p.BusinessEntityID=bea.BusinessEntityID and 
	  bea.AddressID = a.AddressID and 
	  bea.AddressTypeID=at.AddressTypeID

--D find the job title having more revised payments 

select * 
from HumanResources.EmployeePayHistory

select * from HumanResources.Employee

select top 1 e.JobTitle,count(*)
from HumanResources.EmployeePayHistory eph,
	 HumanResources.Employee e
where e.BusinessEntityID=eph.BusinessEntityID
group by e.JobTitle
order by count(*) desc;

--E. Display special offer description , category  and avg(discount pct) per the month

select * from Sales.SpecialOffer

select t.Description,t.Category,avg(t.DiscountPct),t._month from
(select sf.SpecialOfferID,
	   sf.Description,
	   sf.Category,
	   sf.DiscountPct,
	   month(sf.StartDate) _month
from Sales.SpecialOffer sf) as t 
group by t.Description,t.Category,t._month

-- alternate method using partition by 


--F. Display special offer description , category  and avg(discount pct) per year

select t.Description,t.Category,avg(t.DiscountPct),t._month from
(select sf.SpecialOfferID,
	   sf.Description,
	   sf.Category,
	   sf.DiscountPct,
	   year(sf.StartDate) _month
from Sales.SpecialOffer sf) as t 
group by t.Description,t.Category,t._month

--G . Using rank and dense rank find territory wise top sales person

select * from Sales.SalesPerson

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

--H . Calculate total years of experience of the employee and find out employees those who serve for more than 20 years 

select * from HumanResources.Employee

select e.BusinessEntityID,DATEDIFF(YEAR,e.HireDate,GETDATE()) Experience
from HumanResources.Employee e
where DATEDIFF(YEAR,e.HireDate,GETDATE()) >20

-- I Find the Employee who is having more vacations than average vacations taken by all employees 
select * from HumanResources.Employee

select * from(
select e.BusinessEntityID,
	   e.VacationHours,
	   avg(e.VacationHours) over() avg_vacation_hr
from HumanResources.Employee e) t
where t.VacationHours>t.avg_vacation_hr

--K find the department having more employees 
select * from HumanResources.EmployeeDepartmentHistory 

select top 1 edh.DepartmentID,count(*) no_of_emp
from HumanResources.EmployeeDepartmentHistory edh
where edh.EndDate is null
group by edh.DepartmentID
order by count(*) desc

--L is there any person having more than one credit card (person credit card)

select pc.BusinessEntityID,count(*) card_count
from Sales.PersonCreditCard pc
group by pc.BusinessEntityID
having count(*)>1

--M. How many subcategories are available per product (product sub category)

select * from Production.ProductSubcategory

select psc.ProductCategoryID,count(*) countofsubcategory
from Production.ProductSubcategory psc
group by psc.ProductCategoryID

--N Find total standard cost for the active product where end date is not updated (Productr cost history )

select * from Production.ProductCostHistory

select sum(t.StandardCost)  total_active_product_standard_cost from (
select pch.ProductID,pch.StandardCost
from Production.ProductCostHistory pch) t

--O Which territory is having more customes

select * from Sales.Customer

select top 1 c.TerritoryID,count(*)
from Sales.Customer c
group by c.TerritoryID
order by count(*) desc
where pch.EndDate is null







