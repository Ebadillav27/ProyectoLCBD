--drop proc if exists TSE_COMPLETO
---
create proc TSE_COMPLETO
AS 
	drop table IF EXISTS Personas
	drop table IF EXISTS Distritos
	drop table IF EXISTS Cantones
	drop table IF EXISTS Provincias 

	create table Provincias (
		ID_Provincia	int			IDENTITY(1,1),  
		Nombre			varchar(50)	not null, 
		Primary key (ID_Provincia)
	)

	create table Cantones (
		ID_Canton		int			not null, 
		ID_Provincia	int			not null, 
		Nombre			varchar(50) not null,
		Primary key (ID_Canton), 
		constraint fk_id_provCan	foreign key(ID_Provincia) references Provincias(ID_Provincia)	
	)

	create table Distritos (
		ID_Distrito		int			not null,
		ID_Canton		int			not null, 
		Nombre			varchar(50) not null,
	
		Primary key (ID_Distrito), 
		constraint fk_id_CantonDis	foreign key(ID_Canton) references Cantones(ID_Canton), 
	
	)

	create table Personas (	
	cedula				int			not null, 
	codigo_distrito		int			, --not null, 
	sexo				int			, --not null, 
	fechacaduc			date		, --not null, 
	junta_votos			int			, --not null, 
	nombre				varchar(50)	not null, 
	apellido1			varchar(50)	not null, 
	apellido2			varchar(50)	not null, 

	Primary key (cedula) ,
	constraint fk_distPer	foreign key(codigo_distrito) references Distritos(ID_Distrito)

	)

	-- INSERCION 
	INSERT INTO Provincias (Nombre) VALUES ('San Jose')
	INSERT INTO Provincias (Nombre) VALUES ('Alajuela')
	INSERT INTO Provincias (Nombre) VALUES ('Cartago')
	INSERT INTO Provincias (Nombre) VALUES ('Heredia')
	INSERT INTO Provincias (Nombre) VALUES ('Guanacaste')
	INSERT INTO Provincias (Nombre) VALUES ('Puntarenas')
	INSERT INTO Provincias (Nombre) VALUES ('Limon')
	INSERT INTO Provincias (Nombre) VALUES ('CONSULADO')

	INSERT INTO Cantones (ID_Canton, ID_Provincia, Nombre)  SELECT distinct CONVERT(int, SUBSTRING(Codigo, 1,3)), CONVERT(int, SUBSTRING(Codigo, 1, 1)), Canton from Distelec 


	INSERT INTO Distritos (ID_Distrito, ID_Canton, Nombre) SELECT distinct CONVERT(int, Codigo), CONVERT(int, SUBSTRING(Codigo, 1, 3)), Distrito from Distelec 

	INSERT INTO Personas(cedula, codigo_distrito, sexo, fechacaduc, junta_votos, nombre, apellido1, apellido2)
		SELECT CONVERT(nvarchar(15),cedula), CONVERT(int, codigo_distrito), CONVERT(tinyint,sexo), CONVERT(date, fecha_caduc), CONVERT(int,junta_votos), CONVERT(varchar(50),nombre),CONVERT(varchar(30),apellido1),CONVERT(varchar(30),apellido2) FROM dbo.PADRON_COMPLETO;
GO

--exec TSE_COMPLETO