drop table IF EXISTS Telefonos_General_V2;

create table Telefonos_General_V2
(
	Cedula				varchar(50)			not null, 	
	Cantidad_Telefonos	int,				
	Telefonos			varchar(100),	
	
	primary key (Cedula)
)

INSERT INTO Telefonos_General_V2 (Cedula)
SELECT distinct Cedula from Telefonos_General 
ORDER BY Cedula

update Telefonos_General_V2 
set Cantidad_Telefonos = 0

update Telefonos_General_V2 
set Telefonos = ''

