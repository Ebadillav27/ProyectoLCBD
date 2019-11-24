
create procedure select_treks_mayores_a @año int
as 
select * from production.products where model_year > @año and product_name like 'Trek%' 

exec select_treks_mayores_a 2015