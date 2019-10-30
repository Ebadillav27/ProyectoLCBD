/****** Script for SelectTopNRows command from SSMS  ******/
-- select * from sales.staffs where email like 'f%'
-- SELECT * FROM sales.staffs WHERE manager_id = 1
-- SELECT first_name + + ' ' + last_name as nombre_completo from sales.staffs
-- SELECT CONCAT(first_name, ' ', last_name) AS nombre_completo FROM sales.staffs
-- SELECT production.products.product_id, production.products.product_name, production.brands.brand_name, production.products.model_year, production.products.list_price from production.products inner join production.brands ON production.products.brand_id = production.products.brand_id
SELECT production.products.product_id, production.products.product_name, production.brands.brand_name, production.categories.category_name, production.products.model_year, production.products.list_price from production.products 
INNER JOIN production.brands ON production.products.brand_id = production.products.brand_id
INNER JOIN production.categories ON production.products.category_id = production.categories.category_id
-- lab: operadores numéricos y funciones básicas
