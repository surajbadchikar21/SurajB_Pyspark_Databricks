

create database supply_chain

use supply_chain

create schema biz;
create schema vendor;

create table biz.stores(
	storeId int identity,
	storeNumber Varchar(10),
	phoneNumber CHAR(14),
	email Varchar(50),
	address Varchar(120),
	city Varchar(40),
	state Varchar(10));




create table vendor.vdetails(
	vendorid int,
	vnamer varchar(30),
	phoneNumber CHAR(14),
	email Varchar(50),
	address Varchar(120),
	city Varchar(40),
	state Varchar(10)
);

alter table biz.stores add vendorId int;
alter table biz.stores drop column state;
alter table vendor.vdetails drop column state;
alter table biz.stores drop column address;
alter table vendor.vdetails drop column address;

exec sp_rename 'biz.stores.phoneNumber','mobile','column'

--exec sp_renamedb

exec sp_rename 'biz.stores','dealer','object'

alter table biz.stores alter column email varchar(80);

-- when you will be running query on the table use only those columns in where that have an index 

--create index id_storeid_col1_col2_ -- for composite index 

create index id_storeid on biz.dealer(storeId);

--create unique index index_name on tablename(col1,col2)

create table biz.regions(
rid int primary key identity(1,1), -- start with 1 and increment by 1 
rname varchar(40) unique,
conti_name varchar(40),
modified_date datetime default getdate(),
mod_user varchar(10));

insert into biz.regions values('East Asia','Asia','abcd');
--insert into biz.regions(col names) values('East Asia','Asia',GETDATE(),'abcd');
insert into biz.regions(rname,conti_name,mod_user) values('West Asia','Asia','abcd');

select * from biz.regions;

alter table biz.dealer add constraint uniq unique(storeNumber);
-- constraint name to identify 

--alter table tbname add constraint cname foreign key(col_name) refrernces tbl2(col_name);


-- for every table there must be a  modified_date and modified_user 



-- dosent bring constraints along with it , wont work if table already exists 
-- used to create the table 
-- cannot use * here need to put values 
SELECT rid, rname, conti_name
INTO biz.xyz
FROM biz.regions
where 1=0;

--where 1=0 - copy cols , add constraints then add index the add data in it 

select * from biz.regions;
select * from biz.xyz;

truncate table biz.xyz;

-- need to creaate the table 1st  
--common format used in ETL 
insert into biz.xyz(rname,conti_name) 
select 'Wea Asia','Asa'
from biz.regions
where rid=4



-- joins 

--apna normally karne wale inner join hora he 

use AdventureWorks2022

select count(*) from 
Person.Person p  
join HumanResources.Employee e
on(p.BusinessEntityID=e.BusinessEntityID)


select count(*) from 
Person.Person p  
full join HumanResources.Employee e
on(p.BusinessEntityID=e.BusinessEntityID)

select count(*) from 
Person.Person p  
right join HumanResources.Employee e
on(p.BusinessEntityID=e.BusinessEntityID)

select count(*) from 
Person.Person p  
left join HumanResources.Employee e
on(p.BusinessEntityID=e.BusinessEntityID)


-- window functions 

--over 
--partition by 


select FirstName,
	   MiddleName,
	   LastName,
	   (select avg(eph.Rate) from HumanResources.EmployeePayHistory eph
	   where eph.BusinessEntityID=p.BusinessEntityID) avg_rate_per_employee
from Person.Person p , HumanResources.Employee e
where p.BusinessEntityID=e.BusinessEntityID


select e.BusinessEntityID,e.JobTitle,
	   avg(Rate) over(partition by e.JobTitle)
from HumanResources.Employee e,
HumanResources.EmployeePayHistory eph
where e.BusinessEntityID= eph.BusinessEntityID

--find the year wise average standard cost 

select year(Startdate) Year ,sum(StandardCost) StandardCost_sum
from Production.ProductCostHistory
group by year(StartDate)

select year(Startdate) Year ,sum(StandardCost) StandardCost_sum
from Production.ProductCostHistory
where ProductID=707
group by year(StartDate)

select ProductID,year(Startdate) Year ,StandardCost,sum(StandardCost) StandardCost_sum
from Production.ProductCostHistory
where ProductID=707
group by ProductID,year(StartDate),StandardCost


select pch.ProductID , year(pch.startdate) yr, StandardCost ,
sum(pch.StandardCost) over(partition by  pch.ProductID)
from Production.ProductCostHistory pch


-- stituation - 

select e.BusinessEntityID,e.MaritalStatus,e.Gender,e.VacationHours,
	   avg(e.VacationHours) over(partition by e.MaritalStatus) average_by_maritial_status
from HumanResources.Employee e


select e.BusinessEntityID,e.MaritalStatus,e.Gender,e.VacationHours,e.OrganizationLevel,
	   avg(e.VacationHours) over(partition by e.OrganizationLevel) average_by_org_level
from HumanResources.Employee e


select * from HumanResources.EmployeeDepartmentHistory

--display entityId, hire , e.BusinessEntityID,e.HireDate,d.Name,e.OrganizationLevel,
--dept wise count of emp and 
-- count based on org level in each dept 

select  e.BusinessEntityID,e.HireDate,d.Name,
e.OrganizationLevel,
count(e.BusinessEntityID) over(partition by d.DepartmentID) average_by_department,
count(e.OrganizationLevel) over(partition by d.DepartmentID, e.OrganizationLevel) average_by_org_level
from HumanResources.Employee e , 
	 HumanResources.EmployeeDepartmentHistory edh,
	 HumanResources.Department d
	 where e.BusinessEntityID=edh.BusinessEntityID and 
	 edh.DepartmentID=d.DepartmentID


use AdventureWorks2022

--display department name , average sick leave and sick leave per department 

select distinct d.Name,d.DepartmentID,
		(select avg(SickLeaveHours) from HumanResources.Employee e) avg_sickleave,
		avg(SickLeaveHours) over (partition by d.DepartmentID )  sickLeaveHrs_per_dept
from HumanResources.Employee e,
	 HumanResources.Department d,
	 HumanResources.EmployeeDepartmentHistory edh
where e.BusinessEntityID=edh.BusinessEntityID and 
	  edh.DepartmentID=d.DepartmentID

--display department name , count based on gender 

select distinct d.Name,e.Gender,
		count(*) over(partition by e.Gender,d.departmentID) Gender_Count
from HumanResources.Employee e,
	 HumanResources.Department d,
	 HumanResources.EmployeeDepartmentHistory edh
where e.BusinessEntityID=edh.BusinessEntityID and 
	  edh.DepartmentID=d.DepartmentID  
	  and edh.EndDate is null


	  -- check the person details with total count of various shifts working per dept 
	  -- this is wrong
	  select t.BusinessEntityID , t.FirstName,t.LastName,COUNT(*) totalshifts
	  from 
	  (select  p.BusinessEntityID ,p.FirstName,p.LastName,
	  count(*) over(partition by d.departmentID) counts
	  from Person.Person p , 
		   HumanResources.EmployeeDepartmentHistory edh ,
		   HumanResources.Department d
		where p.BusinessEntityID=edh.BusinessEntityID and 
			 edh.DepartmentID=d.DepartmentID )as t
		group by t.BusinessEntityID, t.FirstName,t.LastName

select DepartmentID, count(distinct ShiftID), count(distinct BusinessEntityID)
from HumanResources.EmployeeDepartmentHistory
group by DepartmentID

select * from HumanResources.EmployeeDepartmentHistory
where DepartmentID = 7



select * from HumanResources.EmployeeDepartmentHistory where BusinessEntityID=4

select t.DepartmentID ,count(*)from
(select ed.DepartmentID,ed.ShiftID from HumanResources.EmployeeDepartmentHistory ed group by ed.DepartmentID,ed.ShiftID) as t
group by t.DepartmentID

select edh.DepartmentID,count(distinct ShiftID)
from HumanResources.EmployeeDepartmentHistory edh
group by edh.DepartmentID


-- display country region code , group , average sales quota based on territory id 

select * from Sales.SalesTerritory
select * from Sales.SalesPerson

select distinct st.CountryRegionCode,st.[Group],st.TerritoryID,st.Name,
		avg(sp.SalesQuota) over (partition by st.TerritoryID) avg_sales_quota
from Sales.SalesTerritory st , 
	Sales.SalesPerson sp
where st.TerritoryID=sp.TerritoryID

--display special offer description,category and avg 
--discount pct per the category 

select * from Sales.SpecialOffer

select sp.Description,sp.Category,
	   avg(DiscountPct) over(partition by sp.Category ) _avgdiscountpct
from Sales.SpecialOffer sp



--display special offer description,category and avg 
--discount pct as per the month
use AdventureWorks2022

select * from Sales.SpecialOffer

select sp.Description,sp.Category,month(sp.StartDate) _month,
	   avg(DiscountPct) over(partition by month(sp.StartDate) ) _avgdiscountpct
from Sales.SpecialOffer sp


select top 10 e.BusinessEntityID,
e.NationalIDNumber,
max(e.VacationHours) over (order by e.VacationHours desc) max_vacation_hrs
from HumanResources.Employee e


--unbound preceding and unbound following 


select top 10 e.BusinessEntityID,
e.NationalIDNumber,
max(e.VacationHours) over (order by e.VacationHours desc) max_vacation_hrs,
avg(e.vacationHours) over (order by e.VacationHours rows between unbounded preceding and unbounded following)
from HumanResources.Employee e


select top 10 e.BusinessEntityID,
e.NationalIDNumber,
max(e.VacationHours) over (order by e.VacationHours desc) max_vacation_hrs,
--sum(e.vacationHours) over (order by e.VacationHours rows between 1 preceding and 1 following),
max(e.vacationHours) over (partition by gender order by e.VacationHours rows between 1 preceding and 1 following)max_foll,
max(e.vacationHours) over (partition by gender order by e.VacationHours rows between unbounded preceding and current row )max_foll,  
rank() over (order by vacationhours),
dense_rank() over (order by vacationhours)
from HumanResources.Employee e
--lead lag , row number 

-- if order by not in categorical values it will  do running avg - eg order by businessEntityId
--col ->group by values -> and then aggregate values  

--update - 

select * from HumanResources.Employee 
where BusinessEntityID=1

update HumanResources.Employee 
set VacationHours = 99,
	MaritalStatus= 'M'
where BusinessEntityID=1;

update HumanResources.Employee 
set VacationHours = (select col fromtbl where cond)
	MaritalStatus= 'M'
where BusinessEntityID=1
and col() in
;
create view abc 
as
select * from HumanResources.Employee

use supply_chain

create table biz.names(
name varchar(20)
)

select * from biz.names

select count(*) from biz.names where name ='Suraj' ;