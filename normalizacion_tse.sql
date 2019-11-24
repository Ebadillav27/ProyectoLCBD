--select * from PADRON_COMPLETO; 
--Cedula, codelec, sexo, fechacaduc_cedula, junta_de_votos, nombre_S, apellido1, apellido2 
/* 
	^^cambiar esto por: 
		cedula, codigo_distrito, sexo, fechacaduc_cedula, junta_de_votos, nombre1, nombre2, apellido1, apellido2 

*/ 
--CODELEC: 1,23,456
-- CODELEC: [1 provincia][23 canton][456 distrito]

-- select * from Distelec; 
--CODELE, prrovincia(texto), canton(texto), distrito(texto)
/* 
	^^cambiar esto por varias tablas 
-- tabla provincias: 
	codigo, nombre 
-- tabla cantones: 
	codigo, codigo_provincia, nombre 
-- tabla distritos: --> de aquí saldrían los códigos que reemplazarían el codelec 
	codigo, codigo_canton, nombre 
*/






















/*
drop table Personas;
drop table Distritos; 
drop table Cantones; 
drop table Provincias; 
*/


create table Provincias (
	ID_Provincia	int			not null, 
	Nombre			varchar(50)	not null, 
	Primary key (ID_Provincia)
)

create table Cantones (
	ID_Canton		int			not null, 
	ID_Provincia	int			not null, 
	Primary key (ID_Canton), 
	constraint fk_id_provCan	foreign key(ID_Provincia) references Provincias(ID_Provincia)	
)

create table Distritos (
	ID_Distrito		int			not null,
	ID_Canton		int			not null, 
	
	Primary key (ID_Distrito), 
	constraint fk_id_CantonDis	foreign key(ID_Canton) references Cantones(ID_Canton), 
	
)


create table Personas (
--cedula, codigo_distrito, sexo, fechacaduc_cedula, junta_de_votos, nombre1, nombre2, apellido1, apellido2 
cedula				int			not null, 
codigo_distrito		int			not null, 
sexo				int			not null, 
fechacaduc			date		not null, 
junta_votos			int			not null, 
nombre1				varchar(50)	not null, 
nombre2				varchar(50)			,
apellido1			varchar(50)	not null, 
apellido2			varchar(50)	not null, 

Primary key (cedula),
constraint fk_distPer	foreign key(codigo_distrito) references Distritos(ID_Distrito)

)








 
-- insert into Provincias
--values (
-- select distinct [column 1] from distelec
-- select * from distelec
-- select distinct [column 1], [Column 2] from distelec 


-- order by [column 1]

 
-- select * from PADRON_COMPLETO; 