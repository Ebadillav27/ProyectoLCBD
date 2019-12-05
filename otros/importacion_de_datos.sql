use master;
GO
DROP DATABASE IF EXISTS ProyectoFinal; 
CREATE DATABASE ProyectoFinal; 
use ProyectoFinal; 
GO 
------------------------
CREATE SCHEMA Telefonos; 
GO
------------------------
CREATE SCHEMA Academia; 
GO
------------------------
CREATE SCHEMA TSE; 
GO 
------------------------
DROP TABLE IF EXISTS Telefonos.Telefonos_General
create table Telefonos.Telefonos_General (
	Telefono		varchar(50), 
	Cedula			varchar(50), 
	Nombre_Cliente	varchar(50)
)

DROP TABLE IF EXISTS TSE.Distelec
create table TSE.Distelec (
	Codigo			varchar(50), 
	Provincia		varchar(50), 
	Canton			varchar(50), 
	Distrito		varchar(50)
) 
DROP TABLE IF EXISTS TSE.PADRON_COMPLETO

create table TSE.PADRON_COMPLETO (
	cedula				varchar(50),
	codigo_distrito		varchar(50), 
	sexo				varchar(50), 
	fecha_caduc			varchar(50), 
	junta_votos			varchar(50), 
	nombre				varchar(50), 
	apellido1			varchar(50), 
	apellido2			varchar(50)
)


INSERT INTO Telefonos.Telefonos_General 
SELECT * from [Telefonos].[dbo].[Telefonos_General]


INSERT INTO TSE.Distelec 
SELECT * FROM [TSE].[dbo].[Distelec]

INSERT INTO TSE.PADRON_COMPLETO 
SELECT * FROM [TSE].[dbo].[PADRON_COMPLETO]
