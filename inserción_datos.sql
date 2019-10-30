use Store;

insert into Customers
values('VINET', 'Paul', 'Henriot');

insert into Products
values(11, 'Queso Cabrales', 14);

insert into Employees
values(5, 'Steven', 'Buchanan');

insert into Orders
values(10248, '1996-07-04', 'VINET', 5, 11, 12, 0, 168); 
--falta el discount entre el 12 y el 168 (es un 0)

