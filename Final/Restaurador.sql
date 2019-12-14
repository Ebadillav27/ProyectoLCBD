-- RESTAURADOR --

ALTER SCHEMA dbo TRANSFER OBJECT::Telefonos.Telefonos_General
ALTER SCHEMA dbo TRANSFER OBJECT::TSE.Distelec 
ALTER SCHEMA dbo TRANSFER OBJECT::TSE.PADRON_COMPLETO 

drop table IF EXISTS TSE.Personas
drop table IF EXISTS TSE.Distritos
drop table IF EXISTS TSE.Cantones
drop table IF EXISTS TSE.Provincias 
drop table IF EXISTS Telefonos.Telefonos_General_V2;
DROP TABLE IF EXISTS Academia.Presentacion
DROP TABLE IF EXISTS Academia.Matriculacion   
DROP TABLE IF EXISTS Academia.Factura
DROP TABLE IF EXISTS Academia.Curso
DROP TABLE IF EXISTS Academia.Profesor
DROP TABLE IF EXISTS Academia.Administrativo      
DROP TABLE IF EXISTS Academia.Estudiante	
DROP TABLE IF EXISTS Academia.Aula   	
DROP TABLE IF EXISTS Academia.Inventario
DROP TABLE IF EXISTS Academia.Proveedor   	 	
DROP TABLE IF EXISTS Academia.Tipo_Beca   
DROP TABLE IF EXISTS Academia.Arte

DROP SCHEMA IF EXISTS Telefonos 
DROP SCHEMA IF EXISTS TSE 
DROP SCHEMA IF EXISTS Academia 

drop procedure if exists AcademiaCompleto 
drop procedure if exists TelfonosCompleto 
drop procedure if exists TSECompleto 
