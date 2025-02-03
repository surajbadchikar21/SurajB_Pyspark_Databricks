--joins start

--find all the records from Production , Production control,Executive 
--and having birth date more than 1970
-- display first name , add details , job title and dep 

select d.Name,
	   e.BirthDate,
	   (select firstname from Person.Person p 
	   where  p.BusinessEntityID=e.BusinessEntityID) FirstName 
from HumanResources.EmployeeDepartmentHistory ed,HumanResources.Department d,HumanResources.Employee e 
where ed.BusinessEntityID=e.BusinessEntityID and 
ed.DepartmentID=d.DepartmentID
and BirthDate >='01-01-1970'
and d.name in('Production' , 'Production control','Executive');

-- join : one to many relationship , Multiple condition on the columns in  one where , multiple columns 
-- sub query - one to one , when i want to fetch only small number of records 

--start with : 
--tables , do the join in where , and execute the query 
--implement 2nd conditioon 
--then other condition 
-- then select columns 

--3) display Product name and Product review
select p.Name,
	   pr.Comments
from Production.Product p ,
	 Production.ProductReview pr
where p.ProductID=pr.ProductID;



-- display national id , job title , phone number for employee

select * from HumanResources.Employee;


select e.NationalIDNumber,
	   e.JobTitle,
	   pp.PhoneNumber
from HumanResources.Employee e ,
	 Person.PersonPhone pp
where e.BusinessEntityID=pp.BusinessEntityID

-- better method sub query as i dont need to fetch entire table in this only selected columns 

select e.NationalIDNumber,
	   e.JobTitle,
	   (select pp.PhoneNumber
	   from Person.PersonPhone pp 
	   where pp.BusinessEntityID=e.BusinessEntityID)
from HumanResources.Employee e


-- group by

--find all product id SCRAPPED MORE 
-- find most frequent PURCHASED PRODUCT

select * from Production.WorkOrder
--select * from Production.ScrapReason

select p.ProductID,
	   p.Name, 
	   count(wr.ScrapReasonID) as Scrap_Count
from 
	 Production.WorkOrder wr,
	 Production.Product p 
where p.ProductID=wr.ProductID
group by p.ProductID,p.Name
having count(wr.ScrapReasonID) >0
order by count(wr.ScrapReasonID) desc

--find the most frequent product name 
select top 1 p.ProductID,p.Name,sum(od.OrderQty) as OrderQuan
from Purchasing.PurchaseOrderDetail od,
	 Production.Product p
where p.ProductID=od.ProductID
group by p.ProductID,p.Name
order by sum(od.OrderQty) desc

--which product requires more inventory 
select * from Production.ProductInventory

select top 1 percent pi.ProductID ,p.Name,sum(pi.Quantity) spaceReq
from Production.ProductInventory pi,
	 Production.Product p 
where pi.ProductID=p.ProductID
group by Pi.ProductID,p.Name
order by spaceReq desc

-- most used ship mode 

select * from Purchasing.ShipMethod

select soh.ShipMethodID,count(*),sm.Name
from Sales.SalesOrderHeader soh,
	 Purchasing.ShipMethod sm
where soh.ShipMethodID=sm.ShipMethodID
group by soh.ShipMethodID,sm.Name


select soh.ShipMethodID,count(*),sm.Name
from Purchasing.PurchaseOrderHeader soh,
	 Purchasing.ShipMethod sm
where soh.ShipMethodID=sm.ShipMethodID
group by soh.ShipMethodID,sm.Name
order by count(*) desc


--which currency conversion is more average End of date rate 
select * from Sales.Currency;
select * from Sales.CurrencyRate;

select top 1 cr.FromCurrencyCode,cr.ToCurrencyCode,avg(cr.EndOfDayRate) as average
from Sales.CurrencyRate cr
group by  cr.FromCurrencyCode,cr.ToCurrencyCode
order by average desc

--which currency conversion has max value End of date rate 
select top 1 cr.FromCurrencyCode,cr.ToCurrencyCode,max(cr.EndOfDayRate) as max_conversion
from Sales.CurrencyRate cr
group by  cr.FromCurrencyCode,cr.ToCurrencyCode
order by max_conversion desc

--which currency conversion has least value End of date rate 
select top 1 cr.FromCurrencyCode,cr.ToCurrencyCode,max(cr.EndOfDayRate) as least_conversion
from Sales.CurrencyRate cr
group by  cr.FromCurrencyCode,cr.ToCurrencyCode
order by least_conversion asc


--which special order has more duration 
select * from Sales.SpecialOffer
select * from Sales.SpecialOfferProduct

-- which are those products having more specialOfferproduct

select sfp.ProductID ,count(sf.SpecialOfferID) product_with_most_offers,p.Name
from Sales.SpecialOffer sf,
	 Sales.SpecialOfferProduct sfp,
	 Production.Product p
where sf.SpecialOfferID=sfp.SpecialOfferID and
	  sfp.ProductID=p.ProductID
group by sfp.ProductID,p.Name
order by product_with_most_offers desc
