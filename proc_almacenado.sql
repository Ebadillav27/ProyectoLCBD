
create procedure select_treks_mayores_a @a�o int
as 
select * from production.products where model_year > @a�o and product_name like 'Trek%' 

exec select_treks_mayores_a 2015