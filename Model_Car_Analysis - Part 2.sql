use modelcarsdb ;
show tables ;

-- Task_1.1 

select count(employeenumber) from employees;

-- Task_1.2 

select employeenumber,firstName,lastName,email,jobTitle from employees;

-- Task_1.3 

select jobTitle,count(jobtitle) as count from employees
group by jobtitle ;

--  Task_1.4 
 
 select employeeNumber, firstName, lastName from employees 
 where reportsto is null ;
 
 -- Task_1.5
 
select e.employeeNumber, e.firstName, e.lastName, SUM(od.quantityOrdered) AS TotalSalesAmount
from employees e
join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o ON c.customerNumber = o.customerNumber
join orderdetails od ON o.orderNumber = od.orderNumber
group by  e.employeeNumber, e.firstName, e.lastName;

-- Task_1.6 

select e.firstName, e.lastName, SUM(od.quantityOrdered) AS totalSalesAmount
from employees e
join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by  e.employeeNumber
order by  totalSalesAmount desc  ;

-- Task_1.7

select e.firstName, e.lastName
from employees e
join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by  e.officeCode, e.employeeNumber
having sum(od.quantityOrdered ) > 
(
    select avg(officeSales)
    from (
        select e2.officeCode, SUM(od2.quantityOrdered) as officeSales
        from employees e2
        join customers c2 on e2.employeeNumber = c2.salesRepEmployeeNumber
        join orders o2 on c2.customerNumber = o2.customerNumber
        join orderdetails od2 on o2.orderNumber = od2.orderNumber
        group by  e2.officeCode, e2.employeeNumber
		) as officeAverages
    where officeAverages.officeCode = e.officeCode -- null values
);

-- Task_2.1

select c.customerNumber, c.customerName, avg (od.quantityOrdered) AS averageOrderAmount
from customers c
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by   c.customerNumber, c.customerName;

-- Task_2.2

select month(orderDate) as orderMonth, count(*) AS orderCount
from orders
group by  orderMonth;

-- Task_2.3

select * from orders 
WHERE status = 'In process';

-- Task_2.4

select o.orderNumber,o.orderDate,c.customerNumber,c.customerName,c.contactFirstName,c.contactLastName
from orders o
join customers c ON o.customerNumber = c.customerNumber;

-- Task_2.5

select * from orders
order by  orderDate desc ;  

-- Task_2.6

select  o.orderNumber,sum(od.quantityOrdered ) AS totalSales
from orders o
join orderdetails od ON o.orderNumber = od.orderNumber
group by  o.orderNumber;

-- Task_2.7

select orderNumber, sum(quantityOrdered) AS totalSales
from orderdetails
group by  orderNumber
order by  totalSales desc;

-- Task_2.8

select o.orderNumber,o.orderDate,o.status,c.customerName,od.productCode,p.productName,od.quantityOrdered,od.priceEach
from orders o
join customers c on o.customerNumber = c.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
join products p on od.productCode = p.productCode;

-- Task_2.9

select p.productName, COUNT(od.productCode) as orderCount
from orderdetails od
join products p on od.productCode = p.productCode
group by  p.productCode
order by  orderCount desc;

-- Task_2.10

select  o.orderNumber,sum(od.quantityOrdered ) as totalRevenue
from orders o
join orderdetails od on o.orderNumber = od.orderNumber
group by o.orderNumber;

-- Task_2.11

select o.orderNumber, sum(od.quantityOrdered ) AS totalRevenue
from orders o
join orderdetails od on o.orderNumber = od.orderNumber
group by  o.orderNumber
order by totalRevenue desc ;

-- Task_2.12

select o.orderNumber,o.orderDate,c.customerName,p.productName,p.productLine,p.productScale,p.productVendor,
    p.productDescription,od.quantityOrdered,od.priceEach
from orders o
join customers c ON o.customerNumber = c.customerNumber
join orderdetails od ON o.orderNumber = od.orderNumber
join products p ON od.productCode = p.productCode;  

-- Task_2.13

select * from orders
where shippedDate > requiredDate;

-- Task_2.14

select od1.productCode as product1,od2.productCode as product2,COUNT(*) as combinationCount
from orderdetails od1
join orderdetails od2 ON od1.orderNumber = od2.orderNumber AND od1.productCode < od2.productCode
group by product1, product2
order by  combinationCount DESC;

-- Task_2.15

select o.orderNumber, SUM(od.quantityOrdered ) as totalRevenue
from orders o
join orderdetails od on o.orderNumber = od.orderNumber
group by  o.orderNumber
order by  totalRevenue desc ;

-- Task_2.16

delimiter //
create trigger update_credit_limit 
after insert on orders
for each row 
begin
  update customers 
  set creditLimit = creditLimit - (select SUM(quantityOrdered ) 
  from orderdetails where orderNumber = NEW.orderNumber)
  where customerNumber = NEW.customerNumber;
end //
delimiter ;

insert into orders (orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber)
VALUES (10426,  CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY),  NULL,  
'In Process', 'New order for customer 103',  103 );

-- Task_2.17

delimiter //
create trigger log_product_quantity_change
after insert on orderdetails
for each row 
begin
   
    insert into product_quantity_log (productCode, orderNumber, changeDate, quantityChange, changeType)
    values (NEW.productCode, NEW.orderNumber, NOW(), NEW.quantityOrdered, 'INSERT');
	
    update products
    set quantityInStock = quantityInStock - NEW.quantityOrdered
    where productCode = NEW.productCode;
end //

create trigger log_product_quantity_update
after update on orderdetails
for each row 
begin

    insert into  product_quantity_log (productCode, orderNumber, changeDate, quantityChange, changeType)
    values (NEW.productCode, NEW.orderNumber, NOW(), NEW.quantityOrdered - OLD.quantityOrdered, 'UPDATE');

    update products
    set quantityInStock = quantityInStock + OLD.quantityOrdered - NEW.quantityOrdered
    where productCode = NEW.productCode;
end //

delimiter ;

insert into orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
values (10427, 'S18_1749', 5, 100.00, 1  );

update orderdetails
set quantityOrdered = 10
where orderNumber = 10427 and productCode = 'S18_1749';  







