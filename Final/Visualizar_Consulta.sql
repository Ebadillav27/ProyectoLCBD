CREATE VIEW Visualizar_Consulta AS

select TSE.Personas.*, Telefonos.Telefonos_General_V2.Cantidad_Telefonos, TSE.Provincias.Nombre as Provincia  
from TSE.Personas 
inner join Telefonos.Telefonos_General_V2 
	on TSE.Personas.Cedula = Telefonos.Telefonos_General_V2.Cedula and TSE.Personas.sexo = 1

inner join TSE.Distritos 
	on TSE.Personas.codigo_distrito = TSe.Distritos.ID_Distrito 

inner join TSE.Cantones 
	on TSe.Distritos.ID_Canton = TSE.Cantones.ID_Canton 

inner join TSE.Provincias on TSe.Cantones.ID_Provincia = TSE.Provincias.ID_Provincia and TSE.Provincias.ID_Provincia = 3 
go 

select top (100) * from Visualizar_Consulta