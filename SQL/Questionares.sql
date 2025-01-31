
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