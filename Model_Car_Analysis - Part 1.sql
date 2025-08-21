use modelcarsdb ;

show tables ;
select * from customers;

-- Task_1.1
select customername,creditlimit  from customers 
order by creditlimit limit 10 ;


-- Task_1.2
select country,avg(creditlimit) as avg_credit_limit from customers group by country ;

-- Task_1.3
select * from customers;

select state ,count(customername) as no_of_customers from customers 
group by state  ;

-- Task_1.4

select *  from customers;
select * from orders;
select * from orderdetails;

select c.customernumber,c.customername from customers c
left join orders o  on c.customernumber = o.customernumber
where o.ordernumber is null ;

-- Task_1.5
	
    select c.customernumber,c.customername, sum(od.quantityordered) as totalsales 
    from customers c 
    left join orders o  on c.customernumber = o.customernumber
    left join orderdetails od on o.ordernumber = od.ordernumber
    group by c.customernumber,c.customername ;
    

-- Task_1.6

select * from employees;
select * from customers;

select e.employeenumber as sales_Rep_employee_number ,e.firstname as sales_Rep_firstname,e.lastname as sales_Rep_lastname, c.customername from employees e
left join customers c on e.employeenumber = c.salesrepemployeenumber ;

-- Task_1.7

select * from customers;
select * from payments;

select c.customername,p.checknumber,p.paymentdate,p.amount from customers c
left join payments p on c.customernumber = p.customernumber;

-- Task_1.8

select * from customers;
select * from orders;
select * from orderdetails;

select c.customername,c.creditlimit, sum(od.quantityordered * od.priceeach) as Total_amount 
from customers c 
left join orders o on c.customernumber = o.customernumber
left join orderdetails od on o.ordernumber = od.ordernumber 
group by c.customername,c.creditlimit 
having Total_amount > c.creditlimit  ;

-- Task_1.9

select * from customers;
select * from orders;
select * from orderdetails;
select * from products;
select * from productlines;

select c.customername, pl.productline 
from customers c
left join orders o on c.customernumber = o.customernumber
left join orderdetails od on o.ordernumber = od.ordernumber
left join products p on od.productcode = p.productcode
left join productlines pl on p.productline = pl.productline
group by c.customername,pl.productline ;

-- Task_1.10

select * from orders;
select * from orderdetails;

select c.customerName
from customers c
left join orders o ON c.customerNumber = o.customerNumber
left join orderdetails od ON o.orderNumber = od.orderNumber
where od.productCode = (
    select productCode
    from products
    order by productCode desc LIMIT 1);
    
    -- Task_2.1
    
    select o.city as employees_in_each_office,count(e.employeenumber) as number_of_employees 
    from employees e
    left join offices o on o.officecode = e.officecode 
    group by o.city  ;
    
    -- Task_2.2
    
	select o.city as employees_in_each_office,count(e.employeenumber) as number_of_employees 
    from employees e
    left join offices o on o.officecode = e.officecode 
    group by  o.city 
    having count(e.employeenumber) < 5 ;
    
    -- Task_2.3
    
	select officecode,city,territory from offices ;
    
    -- Task_2.4
    
    select city  from offices o
   left join employees e  on o.officecode = e.officecode 
   where e.employeenumber  is null ;
   
   -- Task_2.5
   
	select  o.officecode,o.city,sum(p.amount) as Total_sales from offices o
    left join employees e on o.officecode = e.officecode  
    left join customers c ON e.employeeNumber = c.salesRepEmployeeNumber
	left join payments p ON c.customerNumber = p.customerNumber
    group by o.officeCode, o.city 
    order by Total_sales desc limit 1 ;
    
    -- Task_2.6 
    
    select o.officecode,o.city,count(e.employeenumber) as highest_employees from offices o 
    left join employees e on o.officecode = e.officecode 
    group by o.officecode,o.city 
    order by highest_employees desc limit 1 ;
    
    -- Task_2.7
  
    select o.officecode,o.city as offices,c.customername,avg(c.creditlimit) as credit_limit_each_customer 
    from offices o 
    left join employees e on o.officecode = e.officecode
    left join customers c on e.employeenumber = c.salesrepemployeenumber 
    group by o.officecode,o.city,c.customername
    order by credit_limit_each_customer  desc ;
    
    -- Task_2.8
    
    select * from offices ;
    
    select country,count(city) as offices_each_country from offices
    group by country ;
    
    -- Task_3.1 
    
    select * from productlines;
    select * from products;
    
    select productline,count(*) as Product_Count from products 
    group by productline ;
    
    -- Task_3.2
    
select productLine 
from products
group by productLine
order by  avg(buyPrice) DESC limit 1 ;

-- Task_3.3

select  MSRP from products
where MSRP between 50 and 100 
order by MSRP asc ;

-- Task_3.4

select p.productLine, SUM(od.quantityOrdered * od.priceEach) AS totalSalesAmount
from products p
join orderdetails od on p.productCode = od.productCode
group by p.productLine;

-- Task_3.5 

select productCode, productName, quantityInStock
from products
where quantityInStock < 10 ;

-- Task_3.6

select * from products
order by  MSRP desc limit 1 ;

-- Task_3.7

select p.productCode, p.productName, SUM(od.quantityOrdered * od.priceEach) AS totalSalesAmount
from products p
join orderdetails od ON p.productCode = od.productCode
group by p.productCode, p.productName ;

-- Task_3.8

delimiter //
create procedure GetTopSellingProducts(IN topN INT)
begin
    select p.productCode, p.productName, SUM(od.quantityOrdered) AS totalQuantityOrdered
    from products p
    join orderdetails od on p.productCode = od.productCode
    group by  p.productCode, p.productName
    order by totalQuantityOrdered desc
    limit topN;
end //
delimiter ;

CALL GetTopSellingProducts(5);

-- Task_3.9 

select productCode, productName, quantityInStock
from products
where quantityInStock < 2
and productLine in ('Classic Cars', 'Motorcycles'); -- null values

-- Task_3.10

select p.productName 
from products p
join orderdetails od ON p.productCode = od.productCode
group by  p.productCode
having count(distinct od.orderNumber) > 10 ;

-- Task_3.11

select p.productName
from products p
left join  orderdetails od on p.productCode = od.productCode
group by  p.productLine, p.productName
having count(od.orderNumber) > 
(select avg(orderCount)
    from (
        select p2.productLine, count(od2.orderNumber) as orderCount
        from products p2
        join orderdetails od2 on p2.productCode = od2.productCode
        group by  p2.productLine, p2.productCode
		) as lineAverages
    where lineAverages.productLine = p.productLine);







    
    
 
    
    

