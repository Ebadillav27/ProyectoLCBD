select count(*) From Telefonos_General_V2 where Nombre is not null 

select top (10) Cedula, count(Cedula) as numeros from Telefonos_General group by Cedula 
order by count(Cedula) DESC

select Telefonos from Telefonos_General_V2 where Cedula = '401470598'