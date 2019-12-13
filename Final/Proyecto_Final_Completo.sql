﻿use ProyectoFinal; 
GO 
-------------------------------------------
DROP SCHEMA IF EXISTS Telefonos; 
GO
CREATE SCHEMA Telefonos; 
GO
-------------------------------------------
DROP SCHEMA IF EXISTS Academia; 
GO
CREATE SCHEMA Academia; 
GO
-------------------------------------------
DROP SCHEMA IF EXISTS TSE; 
GO
CREATE SCHEMA TSE; 
GO 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
ALTER SCHEMA Telefonos TRANSFER OBJECT::dbo.Telefonos_General
ALTER SCHEMA TSE TRANSFER OBJECT::dbo.Distelec 
ALTER SCHEMA TSE TRANSFER OBJECT::dbo.PADRON_COMPLETO 

/*
DROP TABLE IF EXISTS Telefonos.Telefonos_General
create table Telefonos.Telefonos_General (
	Telefono		varchar(50), 
	Cedula			varchar(50), 
	Nombre_Cliente	varchar(50)
)
*/ 
/* 
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
*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*INSERT INTO Telefonos.Telefonos_General 
SELECT * from Telefonos_General_temp 

INSERT INTO TSE.Distelec 
SELECT * FROM Distelec_temp

INSERT INTO TSE.PADRON_COMPLETO 
SELECT * FROM PADRON_COMPLETO_temp
*/
GO

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
create or alter proc TSE_COMPLETO
AS 
	drop table IF EXISTS TSE.Personas
	drop table IF EXISTS TSE.Distritos
	drop table IF EXISTS TSE.Cantones
	drop table IF EXISTS TSE.Provincias 

	create table TSE.Provincias (
		ID_Provincia	int			IDENTITY(1,1),  
		Nombre			varchar(50)	not null, 
		Primary key (ID_Provincia)
	)

	create table TSE.Cantones (
		ID_Canton		int			not null, 
		ID_Provincia	int			not null, 
		Nombre			varchar(50) not null,
		Primary key (ID_Canton), 
		constraint fk_id_provCan	foreign key(ID_Provincia) references TSE.Provincias(ID_Provincia)	
	)

	create table TSE.Distritos (
		ID_Distrito		int			not null,
		ID_Canton		int			not null, 
		Nombre			varchar(50) not null,
	
		Primary key (ID_Distrito), 
		constraint fk_id_CantonDis	foreign key(ID_Canton) references TSE.Cantones(ID_Canton), 
	
	)

	create table TSE.Personas (	
	cedula				int			not null, 
	codigo_distrito		int			, --not null, 
	sexo				int			, --not null, 
	fechacaduc			date		, --not null, 
	junta_votos			int			, --not null, 
	nombre				varchar(50)	not null, 
	apellido1			varchar(50)	not null, 
	apellido2			varchar(50)	not null, 

	Primary key (cedula) ,
	constraint fk_distPer	foreign key(codigo_distrito) references TSE.Distritos(ID_Distrito)

	)

	-- INSERCION 
	INSERT INTO TSE.Provincias (Nombre) VALUES ('San Jose')
	INSERT INTO TSE.Provincias (Nombre) VALUES ('Alajuela')
	INSERT INTO TSE.Provincias (Nombre) VALUES ('Cartago')
	INSERT INTO TSE.Provincias (Nombre) VALUES ('Heredia')
	INSERT INTO TSE.Provincias (Nombre) VALUES ('Guanacaste')
	INSERT INTO TSE.Provincias (Nombre) VALUES ('Puntarenas')
	INSERT INTO TSE.Provincias (Nombre) VALUES ('Limon')
	INSERT INTO TSE.Provincias (Nombre) VALUES ('CONSULADO')

	INSERT INTO TSE.Cantones (ID_Canton, ID_Provincia, Nombre)  SELECT distinct CONVERT(int, SUBSTRING(Codigo, 1,3)), CONVERT(int, SUBSTRING(Codigo, 1, 1)), Canton from TSE.Distelec 


	INSERT INTO TSE.Distritos (ID_Distrito, ID_Canton, Nombre) SELECT distinct CONVERT(int, Codigo), CONVERT(int, SUBSTRING(Codigo, 1, 3)), Distrito from TSE.Distelec 

	INSERT INTO TSE.Personas(cedula, codigo_distrito, sexo, fechacaduc, junta_votos, nombre, apellido1, apellido2)
		SELECT CONVERT(nvarchar(15),cedula), CONVERT(int, codigo_distrito), CONVERT(tinyint,sexo), CONVERT(date, fecha_caduc), CONVERT(int,junta_votos), CONVERT(varchar(50),nombre),CONVERT(varchar(30),apellido1),CONVERT(varchar(30),apellido2) FROM TSE.PADRON_COMPLETO;

GO
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
create or alter proc Creador_Telefonos 
as 

drop table IF EXISTS Telefonos.Telefonos_General_V2;

create table Telefonos.Telefonos_General_V2
(
	Cedula				varchar(50)	not null,
	Nombre				varchar(50), 
	Cantidad_Telefonos	int,				
	Telefonos			varchar(max),	
	
	primary key (Cedula)
)

INSERT INTO Telefonos.Telefonos_General_V2 (Cedula)
SELECT distinct Cedula from Telefonos.Telefonos_General 
ORDER BY Cedula

update Telefonos.Telefonos_General_V2 
set Cantidad_Telefonos = 0 

update Telefonos.Telefonos_General_V2 
set Telefonos = ''

--- CURSOR 





DECLARE @telefono_Tabla_Vieja	varchar(50), 
		@Cedula_Tabla_Vieja		varchar(50),
		@Nombre					varchar(50),
		@Telefono_temporal		varchar(50) 

DECLARE cursor_telefonos CURSOR FOR 
	SELECT Telefono, Cedula, Nombre_Cliente FROM Telefonos.Telefonos_General 

OPEN cursor_telefonos 
FETCH NEXT FROM cursor_telefonos INTO @telefono_Tabla_Vieja, @Cedula_Tabla_Vieja, @Nombre

WHILE @@FETCH_STATUS = 0
BEGIN -- INICIO CICLO

		IF (SELECT Telefonos from Telefonos.Telefonos_General_V2 where Cedula = @Cedula_Tabla_Vieja) like ''
	
		BEGIN -- COMIENZA EL IF 
			SET @Telefono_temporal = @telefono_Tabla_Vieja
		END	  -- TERMINA EL IF 	
		
		ELSE 
			
		BEGIN -- COMIENZA EL ELSE 		
			SET @Telefono_temporal = ', ' + @telefono_Tabla_Vieja

		END	  -- TERMINA EL ELSE 

		UPDATE Telefonos.Telefonos_General_V2
			set Cantidad_Telefonos += 1 
			WHERE Cedula = @Cedula_Tabla_Vieja

		UPDATE Telefonos.Telefonos_General_V2 
			set Telefonos += @telefono_temporal 
			WHERE Cedula = @Cedula_Tabla_Vieja  
				

		UPDATE Telefonos.Telefonos_General_V2 
			Set Nombre = @Nombre WHERE Cedula = @Cedula_Tabla_Vieja and Nombre is Null 
		 
	
	
	FETCH NEXT FROM cursor_telefonos 
		INTO @telefono_Tabla_Vieja, @Cedula_Tabla_Vieja, @Nombre	

END; -- FIN CICLO
CLOSE cursor_telefonos
DEALLOCATE cursor_telefonos

GO
------------------------------------------------------------------------
------------------------------------------------------------------------


CREATE OR ALTER PROC AcademiaCompleto
 AS
	
	
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
	
 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
 
create table Academia.Tipo_Beca
(--Listo
	ID_Beca				int				not null,
  	Valor				decimal			not null,
	Primary key(ID_Beca)
)
 

create table Academia.Estudiante 
(--Listo
	ID_Estudiante		int				not null,
	Nombre				varchar(50)		not null, 
	Apellido1			varchar(50)		not null, 
	Apellido2			varchar(50)		not null, 
	Direccion			varchar(100)	not null, 
	Numero_telefono		int				not null, 
	fecha_nacimiento	date			not null, 
	Fecha_ingreso		date			not null, 
	ID_Beca				int				not null,
	primary key(ID_Estudiante), 
	constraint fk_tipo_beca_estudiante	foreign key(ID_Beca) references Academia.Tipo_Beca(ID_Beca)
	
)

create table Academia.Profesor 
(--Listo
	ID_Profesor			int				not null,
	Nombre				varchar(50)		not null, 
	Apellido1			varchar(50)		not null, 
	Apellido2			varchar(50)		not null, 
	Numero_telefono		int				not null, 
	fecha_nacimiento	date			not null, 
	Fecha_ingreso		date			not null, 

	primary key(ID_Profesor)	
)

create table Academia.Administrativo
(
	ID_Administrativo	int				not null,
	Nombre				varchar(50)		not null, 
	Apellido1			varchar(50)		not null, 
	Apellido2			varchar(50)		not null, 
	Direccion			varchar(100)	not null, 
	Numero_telefono		int				not null, 
	Fecha_nacimiento	date			not null,
	Fecha_ingreso		date			not null, 	 

	primary key(ID_Administrativo)
)
 

create table Academia.Aula
(
	ID_Aula				int				not null, 
	Capacidad_maxima	int				not null,

	Primary key(ID_Aula)
)

create table Academia.Arte
(
	ID_Arte				int				not null,
	Nombre				varchar(50)		not null,

	Primary key(ID_Arte)
)
create table Academia.Curso 
(
	ID_Curso			int				not null, 
	Nombre				varchar(50)		not null, 
	ID_Arte				int				not null, 
	ID_Profesor			int				not null, 
	Costo				int				not null,
	Dia					varchar(10)		not null,
	Hora				time			not null,
	ID_Aula				int				not null, 

	Primary key(ID_Curso), 
	constraint fk_id_profesor_cursos	foreign key(ID_Profesor)	references Academia.Profesor(ID_Profesor), 
	constraint fk_id_aula_cursos		foreign key(ID_Aula)		references Academia.Aula(ID_Aula),
	constraint fk_id_arte_cursos		foreign key(ID_Arte)		references Academia.Arte(ID_Arte)
)

create table Academia.Matriculacion
(
	ID_Matriculacion	int				not null,
	ID_Curso			int				not null, 
	ID_Estudiante		int				not null,
	ID_Administrativo	int				not null, 
	--Total				int				not null, -- estos datos se generan multiplicando el costo del Academia.Curso por la beca del estudainte (Valor en Becas)

	primary key(ID_Matriculacion),
	constraint fk_id_curso_matric		foreign key(ID_Curso)		references Academia.Curso(ID_Curso),
	constraint fk_id_estudiante_matric	foreign key(ID_Estudiante)	references Academia.Estudiante(ID_Estudiante),
	constraint fk_id_admin_matric		foreign key(ID_Administrativo) references Academia.Administrativo(ID_Administrativo)
	
)

create table Academia.Factura 
(
	ID_Factura			int				not null, 
	ID_Estudiante		int				not null, 
	ID_Administrativo	int 			not null,
	--Total_Pagado		int				not null, -- Generada a partir de la suma de los datos de Academia.Matriculacion segun Academia.Estudiante	
  	Fecha_pago			date			not null, 

	Primary key(ID_Factura), 
	constraint fk_ID_Estudiante_factura	foreign key(ID_Estudiante)		references Academia.Estudiante(ID_Estudiante),
	constraint fk_ID_admin_factura		foreign key(ID_Administrativo)	references Academia.Administrativo(ID_Administrativo)
) 

create table Academia.Proveedor
(
	ID_Proveedor		int				not null,
	Nombre_Empresa		varchar(50)		not null,
	Telefono			int				not null,

	Primary key(ID_Proveedor)
)

create table Academia.Presentacion
(
	ID_Presentacion		int				not null,
	Titulo				varchar(50)		not null, 

	ID_Profesor			int				not null,
	ID_Arte				int				not null,
	Fecha_presentacion	date			not null,
	Duracion			time			not null,
	Lugar				varchar(50)		not null,

	Primary key(ID_Presentacion),

	constraint fk_ID_profe_pres		foreign key(ID_Profesor)		references Academia.Profesor(ID_Profesor),
	constraint fk_ID_arte_pres			foreign key(ID_Arte)		references Academia.Arte(ID_Arte)
)

create table Academia.Inventario
(
	ID_Material			int				not null,
	Nombre_Material		varchar(50)		not null,
	ID_Proveedor		int				not null,
	Cantidad			int				not null,
	ID_Arte				int				not null,

	Primary key(ID_Material),
	constraint fk_id_proveedor_inv		foreign key(ID_Proveedor)	references Academia.Proveedor(ID_Proveedor),
	constraint fk_ID_arte_inv			foreign key(ID_Arte)		references Academia.Arte(ID_Arte)
	)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- insercion en Becas 
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (0, 1);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (25, 0.75);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (50, 0.50);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (100, 0.0);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (2, 0.28);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (3, 0.38);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (4, 0.48);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (5, 0.58);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (6, 0.68);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (7, 0.98);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (8, 0.88);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (9, 0.98);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (10, 0.10);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (11, 0.11);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (12, 0.12);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (13, 0.13);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (14, 0.14);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (15, 0.15);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (16, 0.16);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (17, 0.17);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (18, 0.18);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (19, 0.19);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (20, 0.20);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (21, 0.21);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (22, 0.22);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (23, 0.23);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (24, 0.24);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (26, 0.26);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (27, 0.27);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (28, 0.28);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (29, 0.29);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (30, 0.30);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (31, 0.31);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (32, 0.32);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (33, 0.33);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (34, 0.34);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (35, 0.35);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (36, 0.36);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (37, 0.37);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (38, 0.38);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (39, 0.39);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (40, 0.40);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (41, 0.41);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (42, 0.42);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (43, 0.43);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (44, 0.44);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (45, 0.45);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (46, 0.46);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (47, 0.47);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (48, 0.48);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (49, 0.49);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (51, 0.51);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (52, 0.52);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (53, 0.53);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (54, 0.54);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (55, 0.55);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (56, 0.56);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (57, 0.57);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (58, 0.58);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (59, 0.59);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (60, 0.60);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (61, 0.61);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (62, 0.62);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (63, 0.63);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (64, 0.64);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (65, 0.65);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (66, 0.66);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (67, 0.67);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (68, 0.68);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (69, 0.69);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (70, 0.70);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (71, 0.71);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (72, 0.72);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (73, 0.73);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (74, 0.74);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (75, 0.75);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (76, 0.76);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (77, 0.77);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (78, 0.78);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (79, 0.79);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (80, 0.80);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (81, 0.81);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (82, 0.82);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (83, 0.83);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (84, 0.84);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (85, 0.85);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (86, 0.86);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (87, 0.87);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (88, 0.88);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (89, 0.89);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (90, 0.90);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (91, 0.91);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (92, 0.92);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (93, 0.93);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (94, 0.94);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (95, 0.95);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (96, 0.96);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (97, 0.97);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (98, 0.98);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (99, 0.99);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (101, 0.81);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (102, 0.71);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (103, 0.45);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (104, 0.32);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (105, 0.46);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (106, 0.81);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (107, 0.91);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (108, 0.17);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (109, 0.17);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (110, 0.73);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (111, 0.74);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (112, 0.37);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (113, 0.42);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (114, 0.28);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (115, 0.04);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (116, 0.06);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (117, 0.39);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (118, 0.97);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (119, 0.53);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (120, 0.85);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (121, 0.74);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (122, 0.96);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (123, 0.12);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (124, 0.43);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (125, 0.04);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (126, 0.65);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (127, 0.87);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (128, 0.9);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (129, 0.64);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (130, 0.95);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (131, 0.85);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (132, 0.98);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (133, 0.06);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (134, 0.44);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (135, 0.84);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (136, 0.95);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (137, 0.78);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (138, 0.4);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (139, 0.76);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (140, 0.46);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (141, 0.96);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (142, 0.8);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (143, 0.54);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (144, 0.61);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (145, 0.48);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (146, 0.87);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (147, 0.11);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (148, 0.27);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (149, 0.39);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (150, 0.94);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (151, 0.61);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (152, 0.46);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (153, 0.16);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (154, 0.12);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (155, 0.89);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (156, 0.28);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (157, 0.64);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (158, 0.57);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (159, 0.4);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (160, 0.03);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (161, 0.13);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (162, 0.5);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (163, 0.12);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (164, 0.11);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (165, 0.28);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (166, 0.86);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (167, 0.15);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (168, 0.19);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (169, 0.42);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (170, 0.68);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (171, 0.03);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (172, 0.29);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (173, 0.94);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (174, 0.07);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (175, 0.06);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (176, 0.06);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (177, 0.15);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (178, 0.08);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (179, 0.72);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (180, 0.14);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (181, 0.67);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (182, 0.49);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (183, 0.9);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (184, 0.18);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (185, 0.76);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (186, 0.93);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (187, 0.27);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (188, 0.66);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (189, 0.5);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (190, 0.46);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (191, 0.56);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (192, 0.2);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (193, 0.15);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (194, 0.19);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (195, 0.78);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (196, 0.46);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (197, 0.09);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (198, 0.51);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (199, 0.02);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (200, 0.44);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (201, 0.97);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (202, 0.65);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (203, 0.95);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (204, 0.68);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (205, 0.59);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (206, 0.95);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (207, 0.2);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (208, 0.17);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (209, 0.06);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (210, 0.73);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (211, 0.04);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (212, 0.56);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (213, 0.37);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (214, 0.15);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (215, 0.65);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (216, 0.95);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (217, 0.76);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (218, 0.44);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (219, 0.03);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (220, 0.59);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (221, 0.87);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (222, 0.37);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (223, 0.82);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (224, 0.36);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (225, 0.31);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (226, 0.44);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (227, 0.85);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (228, 0.86);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (229, 0.76);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (230, 0.69);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (231, 0.08);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (232, 0.44);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (233, 0.88);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (234, 0.96);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (235, 0.6);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (236, 0.44);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (237, 0.08);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (238, 0.95);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (239, 0.92);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (240, 0.7);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (241, 0.26);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (242, 0.45);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (243, 0.77);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (244, 0.23);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (245, 0.87);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (246, 0.08);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (247, 0.28);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (248, 0.73);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (249, 0.54);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (250, 0.49);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (251, 0.08);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (252, 0.8);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (253, 0.88);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (254, 0.44);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (255, 0.48);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (256, 0.26);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (257, 0.68);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (258, 0.33);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (259, 0.35);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (260, 0.45);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (261, 0.41);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (262, 0.62);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (263, 0.25);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (264, 0.5);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (265, 0.03);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (266, 0.86);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (267, 0.91);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (268, 0.94);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (269, 0.33);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (270, 0.13);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (271, 0.19);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (272, 0.04);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (273, 0.63);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (274, 0.67);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (275, 0.46);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (276, 0.27);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (277, 0.21);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (278, 0.51);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (279, 0.84);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (280, 0.39);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (281, 0.98);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (282, 0.08);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (283, 0.76);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (284, 0.77);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (285, 0.65);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (286, 0.11);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (287, 0.7);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (288, 0.38);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (289, 0.64);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (290, 0.68);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (291, 0.57);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (292, 0.08);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (293, 0.39);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (294, 0.45);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (295, 0.55);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (296, 0.86);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (297, 0.14);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (298, 0.66);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (299, 0.32);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (300, 0.02);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (301, 0.84);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (302, 0.46);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (303, 0.73);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (304, 0.85);
insert into Academia.Tipo_Beca (ID_Beca, Valor) values (305, 0.97);

-- insercion en Academia.Estudiante
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (402398434, 'Christian', 'Rosellini', 'Paskins', '481 Esch Hill', 89311312, '2006/07/07', '2018/03/27', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (449869350, 'Drucill', 'Perrin', 'Thorington', '33261 Dorton Road', 89842839, '1996/12/10', '2016/02/20', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (505445806, 'Jemmie', 'Gillani', 'Campanelli', '9 Ludington Point', 87812209, '1997/09/22', '2019/08/12', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (419386689, 'Denis', 'Lunnon', 'Bolam', '01 Grover Terrace', 87482898, '2003/05/22', '2015/01/14', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (407842323, 'Linnea', 'O''Heffernan', 'Keats', '08341 Anzinger Alley', 86249789, '2007/08/12', '2019/11/12', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (579167277, 'Gwendolen', 'Giacomello', 'Terzi', '92479 Merrick Street', 86389794, '2002/02/05', '2018/06/19', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (567290097, 'Emmett', 'L''Hommee', 'McQuirk', '42894 Drewry Hill', 86598119, '2007/08/19', '2016/04/18', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (578548772, 'Peirce', 'Hoyle', 'Handrik', '91926 Eagan Lane', 89480062, '1998/03/02', '2017/12/27', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (526834867, 'Celle', 'Dobrowlski', 'Serotsky', '1 Bayside Circle', 88511650, '2001/05/30', '2015/08/12', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (529770583, 'Davie', 'Sisneros', 'Gauche', '986 Dennis Alley', 86033159, '1999/10/14', '2017/08/11', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (435229275, 'Arturo', 'Fairbeard', 'Blancowe', '3 Donald Trail', 88809422, '2005/04/04', '2015/08/23', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (510422495, 'Imogene', 'Patershall', 'Frogley', '10 East Pass', 86083053, '2006/09/19', '2016/05/16', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (529840745, 'Erinn', 'Kernoghan', 'Harral', '925 Donald Road', 89328154, '2005/12/06', '2015/11/10', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (522161642, 'Kamila', 'Behnke', 'McGawn', '0819 Knutson Street', 88384091, '2001/03/26', '2018/02/12', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (584506376, 'Tally', 'Prigg', 'Gentry', '46 Lakewood Gardens Circle', 89724751, '2000/09/23', '2016/10/23', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (574023080, 'Mada', 'McIlwain', 'Peirazzi', '7 Ridge Oak Street', 86041608, '2000/08/06', '2018/12/03', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (587825067, 'Erminia', 'Linnemann', 'Deaton', '42525 Northland Plaza', 86410495, '1998/09/15', '2018/07/29', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (508918810, 'Valery', 'Grumell', 'Lukasik', '90 Anniversary Hill', 87738687, '2008/03/26', '2017/09/23', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (496982654, 'Leanor', 'Scyner', 'Shimuk', '81 Village Green Point', 87305348, '1996/07/19', '2018/06/20', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (508514244, 'Elicia', 'Fyers', 'Butner', '2 Pennsylvania Terrace', 88416723, '2002/01/21', '2016/06/23', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (486304788, 'Augy', 'Radbourn', 'Geram', '69 Drewry Crossing', 87163574, '2006/03/13', '2015/11/24', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (525676501, 'Danika', 'Vasentsov', 'Brunstan', '60 Pine View Park', 86236181, '2009/03/25', '2019/01/01', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (429589645, 'Udale', 'Dametti', 'Zuan', '718 Mallard Parkway', 89478490, '1999/02/27', '2018/06/22', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (575080902, 'Laurene', 'Clouston', 'Duker', '3 Lukken Center', 88669670, '2002/11/02', '2019/10/10', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (456626514, 'Sidney', 'Mc Caughen', 'Hearthfield', '6 Myrtle Circle', 89716952, '2000/05/24', '2019/02/25', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (430303943, 'Derril', 'Zack', 'Meyrick', '68988 Bartillon Terrace', 88848596, '1995/02/02', '2017/11/12', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (580301256, 'Pen', 'Simoneton', 'Soar', '998 Birchwood Park', 89097419, '2002/07/08', '2017/07/28', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (461655156, 'Harwilll', 'Derye-Barrett', 'Yeats', '9 Warbler Center', 87109351, '2003/04/30', '2017/02/14', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (538978663, 'Sibelle', 'Elster', 'Strangeways', '49 Cherokee Avenue', 88807124, '2005/05/19', '2015/03/25', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (465933986, 'Torrey', 'Corpe', 'Gullan', '0 Ludington Plaza', 89596413, '2009/06/04', '2019/02/06', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (414705038, 'Francesca', 'Hawking', 'Wisam', '9792 Kensington Hill', 86900758, '1997/03/09', '2018/01/27', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (597680429, 'Krystle', 'Ower', 'Sweeten', '2 Utah Alley', 87149707, '2003/04/23', '2016/11/15', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (459051505, 'Denni', 'Dugdale', 'Dahler', '5 Jackson Place', 88027882, '2008/02/14', '2015/02/19', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (503567885, 'Berni', 'Saddleton', 'Wyper', '88043 Harbort Terrace', 87547645, '2007/04/28', '2017/09/24', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (555165737, 'Gaby', 'Hamman', 'Poller', '870 Roxbury Trail', 87707400, '1996/05/14', '2018/10/12', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (445107208, 'Uriel', 'Peeke-Vout', 'Auger', '37397 Lake View Trail', 87551661, '2003/01/16', '2017/09/02', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (427462965, 'Tyrus', 'Rolance', 'Conre', '67627 Kipling Pass', 89321425, '1996/11/05', '2017/03/19', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (493133024, 'Steven', 'Crossgrove', 'Moulster', '325 Cherokee Place', 86591235, '2007/05/27', '2016/09/14', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (447305380, 'Maud', 'Codron', 'Fibben', '688 Waywood Center', 86198072, '2004/10/19', '2017/09/25', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (500424678, 'Amerigo', 'Yter', 'Kelley', '47436 Hauk Trail', 88133622, '1996/04/20', '2017/08/14', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (484345321, 'Sela', 'Klos', 'MacFie', '0 South Hill', 88970734, '1998/09/06', '2019/10/21', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (518272214, 'Jacintha', 'von Hagt', 'Chmiel', '89 Russell Avenue', 89325409, '2003/02/06', '2016/12/17', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (449815894, 'Jermaine', 'Luxon', 'Milsap', '02007 Green Ridge Drive', 88593960, '2007/04/08', '2016/06/27', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (513953424, 'Mollie', 'McCracken', 'Comar', '4 Lakeland Hill', 89841100, '1997/07/13', '2017/11/23', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (497445354, 'Jarad', 'Spinelli', 'Byway', '873 Carey Point', 87273318, '2005/10/25', '2016/03/31', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (555311479, 'Jordain', 'McGreary', 'Haslock', '99129 Leroy Circle', 88884171, '2008/07/20', '2019/01/03', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (563191190, 'Marcos', 'Sambiedge', 'Hanaford', '67 Colorado Center', 88384476, '2004/08/23', '2018/09/20', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (513466373, 'Sheba', 'Edyson', 'Delleschi', '41 Duke Circle', 89956034, '1999/10/06', '2018/03/15', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (488539221, 'Yule', 'Blyden', 'Ivachyov', '53236 Magdeline Place', 86766971, '2002/03/04', '2019/09/29', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (563293235, 'Arvin', 'Pietraszek', 'Water', '95580 International Place', 86204326, '1996/04/05', '2016/06/30', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (421735525, 'Barnard', 'Kordes', 'Sich', '9 Summerview Trail', 89960833, '2005/11/08', '2017/12/02', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (509089676, 'Perry', 'Bohlsen', 'Scatchar', '21 Schurz Street', 87701795, '1997/11/06', '2017/03/10', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (504571215, 'Janene', 'Spinello', 'Leggin', '98246 4th Plaza', 87433366, '2008/11/10', '2015/01/27', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (568098553, 'Freedman', 'Brychan', 'Whatley', '865 Warner Lane', 86072545, '1995/08/01', '2018/03/13', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (423105660, 'Brian', 'Blowes', 'Stouther', '66 Hanover Alley', 87934212, '1995/02/04', '2018/09/12', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (568595463, 'Llewellyn', 'Guesford', 'Cornwell', '2 Everett Junction', 89965919, '2000/11/22', '2016/11/14', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (445150484, 'Lloyd', 'Silcock', 'Baynham', '3 4th Street', 87815185, '2002/12/17', '2016/10/20', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (599488915, 'Cathi', 'Baseke', 'Smithen', '64 Dryden Junction', 87079568, '2006/03/18', '2015/10/20', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (446692691, 'Shaylynn', 'Powrie', 'Durbann', '3 Arapahoe Lane', 89545913, '2001/07/07', '2017/08/10', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (465654756, 'Jefferson', 'Dauney', 'Thorneley', '4599 Almo Hill', 89477008, '2002/04/19', '2016/07/30', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (438250729, 'Ashla', 'Wintour', 'O''Dulchonta', '3 Kropf Park', 87222739, '1996/12/07', '2016/09/09', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (425014403, 'Mel', 'Mollindinia', 'Mawer', '5713 Eastlawn Crossing', 88256027, '2006/12/16', '2018/10/19', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (516861115, 'Marlene', 'Byre', 'Sellens', '9663 Hoard Place', 86718867, '2006/02/22', '2015/03/31', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (447074431, 'Renee', 'Clibbery', 'Ferminger', '43899 Morrow Junction', 89451318, '1997/07/20', '2017/12/30', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (591592509, 'Ewen', 'Lebbon', 'Chapling', '533 Fordem Court', 88779340, '1996/07/02', '2016/10/10', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (508348419, 'Modesty', 'Buckles', 'Harfoot', '53 Gerald Place', 86340083, '2005/10/11', '2019/09/08', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (452505707, 'Dot', 'Tremonte', 'Campsall', '21910 Arizona Parkway', 87910978, '1997/04/18', '2016/02/20', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (435836651, 'Hardy', 'Dillingham', 'Meecher', '06 Esch Parkway', 88626578, '2005/09/15', '2016/02/03', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (550416526, 'Esma', 'Floch', 'Springate', '843 3rd Plaza', 88358221, '2002/05/22', '2015/03/05', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (567003998, 'Wallas', 'Reddy', 'Clifford', '7 Thompson Court', 87878596, '2000/09/05', '2017/05/09', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (466058196, 'Tiffi', 'Claricoats', 'Hopkins', '0 Messerschmidt Avenue', 87652054, '1999/06/04', '2019/08/29', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (582330184, 'Lisetta', 'Cisar', 'Sloegrave', '59 Summit Terrace', 87221675, '1996/05/23', '2018/07/16', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (418654202, 'Darius', 'Faulkner', 'Woodhams', '497 Pine View Park', 89611799, '2000/03/18', '2019/02/20', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (598302772, 'Beth', 'Acres', 'Drew-Clifton', '7 Forster Way', 89381873, '2006/08/15', '2016/07/07', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (561010588, 'Bianka', 'Anmore', 'Dellow', '3 Schmedeman Junction', 88881192, '1996/12/08', '2019/03/26', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (407470722, 'Erminia', 'D''Agostino', 'Banaszkiewicz', '8 Ridge Oak Pass', 88053890, '2005/06/05', '2019/06/04', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (489109932, 'Ric', 'Dimmack', 'Anstiss', '94 Green Ridge Point', 86973102, '1997/04/26', '2019/10/14', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (409226698, 'Jarid', 'Rielly', 'Sijmons', '87385 Helena Park', 89745911, '1997/09/12', '2016/10/30', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (450433297, 'Elnore', 'Barbisch', 'Uridge', '8 Coolidge Way', 89993459, '2005/08/31', '2016/04/26', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (533595562, 'Arv', 'Teal', 'Decruse', '486 Oxford Court', 86614310, '1998/02/15', '2017/04/12', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (577845043, 'Isabelle', 'Petters', 'Criple', '059 Express Point', 87840166, '1996/10/11', '2016/01/29', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (569397183, 'Rani', 'Kolin', 'Gonsalvo', '47614 Stuart Center', 89266397, '1995/09/22', '2017/01/12', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (435079384, 'Tiebout', 'Garritley', 'Heartfield', '4691 Manley Trail', 89411732, '2002/10/18', '2019/06/03', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (419663606, 'Maud', 'Fullwood', 'Thackray', '9683 Nelson Street', 89029354, '2005/03/30', '2018/12/31', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (403086097, 'Saxon', 'Redparth', 'Hembry', '57 Coolidge Avenue', 87078120, '2001/01/07', '2015/06/25', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (474910143, 'Bronny', 'Jennemann', 'Coudray', '38384 Redwing Crossing', 87542805, '2001/06/20', '2015/12/19', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (402742839, 'Maris', 'Walsham', 'Bradshaw', '560 Hooker Junction', 88532095, '2004/08/15', '2019/05/18', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (589702232, 'Farand', 'Tenniswood', 'Dodgson', '0039 Luster Park', 86188261, '2007/04/20', '2018/06/01', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (589827294, 'Cristy', 'Woollacott', 'Marishenko', '7 Dawn Terrace', 88491807, '2009/08/12', '2018/12/03', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (507970901, 'Ferdinanda', 'Scedall', 'Pennino', '44 Thompson Park', 88540905, '2000/02/22', '2018/07/05', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (405326461, 'Lynnea', 'Skey', 'Rozzier', '253 Amoth Park', 88070723, '2004/09/13', '2017/08/27', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (576575322, 'Irvin', 'Dalloway', 'Moon', '789 Granby Hill', 86710795, '2006/10/25', '2017/02/20', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (431281159, 'Ealasaid', 'Dunhill', 'Gurney', '57345 Hauk Road', 88620221, '1995/09/09', '2019/05/16', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (562184267, 'Corty', 'Corlett', 'Aizikovich', '8 Upham Court', 86498988, '2008/08/03', '2018/01/23', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (556651838, 'Mellisent', 'Henner', 'Fearne', '3 Mifflin Circle', 87803611, '1998/03/13', '2015/05/05', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (519947902, 'Phedra', 'Richmont', 'Cattermoul', '3139 Manitowish Plaza', 89664221, '2007/07/24', '2016/09/27', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (494713494, 'Roselin', 'Vear', 'Lannen', '8134 Corscot Drive', 87139929, '2008/05/17', '2016/12/09', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (579513452, 'Natalee', 'Westoll', 'Lawrenz', '7884 David Court', 89728782, '2006/09/23', '2015/06/30', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (432690252, 'Freddy', 'Baptista', 'Harsum', '46720 Northland Alley', 87859034, '2007/01/23', '2016/07/06', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (433840649, 'Sande', 'McIlveen', 'McElvine', '371 Homewood Drive', 86466021, '1999/04/27', '2018/05/10', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (547164605, 'Jerrold', 'Gertz', 'Ives', '498 Spenser Point', 88483040, '2001/09/22', '2016/05/22', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (554951303, 'Omar', 'Houdhury', 'Newick', '48564 Fuller Lane', 89313348, '2005/02/11', '2019/02/23', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (598903284, 'Lynett', 'Brownjohn', 'Bausmann', '08 Saint Paul Circle', 89023554, '2008/08/03', '2017/11/25', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (444512538, 'Donia', 'Neeson', 'Stapylton', '93606 Superior Lane', 86073202, '2001/05/07', '2018/12/26', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (509425987, 'Tamara', 'Aspinell', 'Charopen', '141 Fisk Point', 88099104, '2004/07/20', '2018/04/15', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (539265787, 'Giana', 'Van de Castele', 'Baalham', '4366 Scofield Way', 87235254, '2007/06/01', '2019/07/09', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (439219990, 'Lorin', 'Cringle', 'Sillitoe', '85 Algoma Court', 86334704, '2007/09/15', '2019/08/12', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (404991663, 'Micheline', 'Feacham', 'Hinsch', '0 Upham Road', 87960752, '2003/12/03', '2017/11/12', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (523780328, 'Dehlia', 'Darke', 'Romans', '2527 Grim Court', 89179440, '1996/01/19', '2015/10/16', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (525779924, 'Humfrey', 'Speed', 'Baskeyfield', '6 Menomonie Trail', 88998918, '2003/01/02', '2015/04/13', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (485116205, 'Duncan', 'Moulson', 'De La Haye', '3803 Elmside Terrace', 87598064, '2005/10/10', '2015/11/14', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (501864030, 'Joelle', 'Knightly', 'Garey', '376 Service Plaza', 86018734, '2003/11/22', '2017/03/02', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (478523633, 'Rozella', 'Warnock', 'Bonnette', '277 Shasta Plaza', 89144341, '2005/12/25', '2017/06/24', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (538274042, 'Nissie', 'Sawdy', 'Stockport', '2 Lukken Point', 87044102, '2006/09/26', '2017/12/31', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (575762554, 'Daphne', 'Itzkovitch', 'Antat', '89403 Springview Point', 86219643, '2005/02/13', '2017/10/09', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (568322641, 'Darelle', 'Kauffman', 'O''Loughlin', '50 Mitchell Road', 89478564, '2009/11/28', '2018/11/28', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (563317856, 'Colene', 'Carle', 'Worton', '8910 Vahlen Way', 87323239, '1996/02/19', '2018/08/17', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (506248771, 'Phyllida', 'Eilhart', 'Sedgefield', '5310 Corben Alley', 86089834, '2005/07/26', '2015/10/10', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (589260175, 'Jasmine', 'Haverty', 'Carmont', '8 Ilene Center', 86706774, '2002/08/15', '2017/09/19', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (421361707, 'Dane', 'Mushett', 'Orbine', '9127 Mandrake Alley', 87144133, '2005/12/27', '2019/06/06', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (521091815, 'Rosalinde', 'Clampton', 'Corkitt', '3824 Donald Drive', 86258328, '2000/03/20', '2017/02/04', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (427128439, 'Merridie', 'Lightfoot', 'Mc Coughan', '39 Kenwood Circle', 88033731, '2009/05/03', '2016/10/19', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (595340698, 'Minta', 'Huett', 'Ripping', '9986 Hoffman Circle', 89167412, '2001/10/17', '2017/03/11', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (529414843, 'Patricio', 'Wollers', 'Grix', '199 Maple Wood Center', 86505191, '2002/11/22', '2016/02/22', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (411575308, 'Wit', 'Philippart', 'Fronczak', '58998 Anzinger Plaza', 88502748, '1998/11/26', '2019/05/18', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (493004584, 'Skelly', 'O''Leahy', 'MacAndie', '85833 Warbler Way', 87123566, '1996/04/08', '2019/11/04', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (594111184, 'Annamaria', 'Briereton', 'McEllen', '6 Union Park', 87445016, '2009/12/02', '2018/02/23', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (514927160, 'Valentine', 'Lissenden', 'Connaughton', '48152 Kenwood Street', 86089602, '1995/08/13', '2018/12/26', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (573679341, 'Giustino', 'Anstis', 'Martusewicz', '365 Roth Drive', 86690940, '2002/08/21', '2015/04/12', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (514185822, 'Cheryl', 'Mowbray', 'Warboy', '09 Morrow Street', 89489258, '1997/01/31', '2019/04/29', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (590121482, 'Shurlocke', 'Housbie', 'Wayt', '55750 Memorial Crossing', 87564274, '2009/10/21', '2017/04/08', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (472319783, 'Mirilla', 'Mein', 'Bratchell', '484 Sunfield Center', 87041704, '2006/02/15', '2015/12/31', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (421790485, 'Bili', 'Simko', 'Gozzard', '41 Dawn Avenue', 88382133, '1998/06/08', '2015/04/01', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (445342912, 'Eolande', 'Filippone', 'Vankov', '3634 Red Cloud Street', 89281913, '2009/04/11', '2015/01/13', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (405564018, 'Coleman', 'Garnar', 'Engel', '744 Goodland Crossing', 86731264, '1995/01/09', '2019/03/17', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (419527802, 'Bettye', 'Hogbourne', 'Gowans', '54463 Ridge Oak Parkway', 86767641, '2004/04/10', '2018/06/20', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (510463995, 'Rozele', 'Sivill', 'Chestnutt', '3685 Spenser Trail', 86806756, '1998/12/13', '2018/12/26', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (412917739, 'Ivette', 'Routh', 'Sermin', '8314 Tony Crossing', 86151469, '2000/04/26', '2015/10/29', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (554018249, 'Leslie', 'Wisniowski', 'Mil', '59 Eagan Lane', 87794821, '1996/04/27', '2017/08/07', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (418363852, 'Cy', 'Carne', 'Stancer', '8378 Aberg Hill', 87698245, '2000/05/28', '2018/05/13', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (537711907, 'Valentin', 'Daborne', 'Leckenby', '486 Sugar Street', 87503720, '2004/02/25', '2017/02/23', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (544779738, 'Kassey', 'Bridgement', 'Buessen', '7 Lerdahl Parkway', 87443925, '2004/12/14', '2018/11/16', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (454924854, 'Filippo', 'Jakes', 'Penk', '95320 Straubel Trail', 88355634, '1997/02/02', '2015/10/06', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (519649977, 'Kriste', 'Catcheside', 'Murra', '30 Shoshone Junction', 88144059, '1995/05/18', '2018/05/25', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (486145757, 'Krista', 'Mettericke', 'Belham', '9466 Marquette Alley', 89093627, '2004/11/07', '2015/12/14', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (427092922, 'Hoyt', 'Doale', 'Carlens', '28906 Pankratz Plaza', 87264040, '1998/03/27', '2017/09/29', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (556743029, 'Ilaire', 'Fost', 'Darleston', '7484 Chinook Trail', 88216984, '2002/01/12', '2018/03/11', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (416309475, 'Addie', 'Muddiman', 'Sibille', '11 Scoville Crossing', 88699329, '1995/09/26', '2019/10/28', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (596297032, 'Umeko', 'Renshell', 'Murr', '1 Columbus Hill', 89552107, '1995/04/29', '2018/08/14', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (447966346, 'Fredra', 'Prati', 'Chessill', '35380 Division Circle', 87556036, '2001/07/24', '2015/03/10', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (460388547, 'Aurthur', 'Server', 'Tayt', '62 Melvin Drive', 86000065, '2002/05/04', '2015/06/22', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (545709910, 'Guillaume', 'Hendin', 'Szabo', '282 Kennedy Trail', 88266610, '2009/04/21', '2019/06/26', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (504556890, 'Sosanna', 'Enever', 'Tolan', '1 Bluejay Pass', 86580985, '1997/03/30', '2019/02/19', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (500112407, 'Willow', 'Bourthoumieux', 'Bocking', '021 Fuller Drive', 88694208, '2009/05/10', '2016/02/07', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (580518988, 'Hubey', 'Pembry', 'Gowry', '9857 Bobwhite Drive', 89700476, '2004/08/05', '2017/05/16', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (534058241, 'Nollie', 'Burman', 'Murrish', '3185 Hoard Trail', 87476747, '1996/07/01', '2017/12/25', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (490266925, 'Liv', 'Dominighi', 'Schlagh', '83425 Hagan Road', 89561863, '2004/03/24', '2016/01/17', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (540347622, 'Gwynne', 'Hardwell', 'Chrstine', '3 Heath Road', 87744147, '2007/10/18', '2016/03/06', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (589372665, 'Winni', 'Girke', 'Bassingden', '0 Moulton Junction', 86799962, '2004/07/11', '2015/12/17', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (502035110, 'Andie', 'Tofpik', 'Choake', '516 Meadow Valley Point', 86761910, '2007/05/26', '2016/06/09', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (468570851, 'Kenon', 'Cicccitti', 'Spradbrow', '75 Birchwood Place', 88443765, '2000/12/06', '2015/12/18', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (550477897, 'Arabele', 'Hollingshead', 'Gierth', '55150 Dennis Court', 86552457, '2008/11/27', '2018/10/02', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (536307432, 'Celeste', 'Molan', 'Daunay', '8 Valley Edge Junction', 88758132, '2004/03/31', '2017/05/24', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (538919462, 'Mora', 'Grcic', 'Acland', '441 Doe Crossing Alley', 86193272, '1999/03/25', '2017/07/06', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (508707665, 'Valera', 'Coat', 'Brenneke', '75 Sunbrook Terrace', 87363790, '2002/08/05', '2015/07/13', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (568486069, 'Redford', 'Hatherley', 'Lynch', '71387 Sugar Lane', 86071555, '2000/03/20', '2015/10/23', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (556920922, 'Jakie', 'Darke', 'Vinden', '79 Warbler Park', 86892494, '2009/11/21', '2016/05/14', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (580629791, 'Antone', 'Maker', 'Schlagman', '6 Namekagon Center', 89566760, '1997/09/06', '2017/03/14', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (472094158, 'Beckie', 'Boylin', 'Vize', '0 Fordem Place', 86922552, '2006/12/11', '2019/10/03', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (540753194, 'Valaree', 'Badman', 'Rudeyeard', '31 Village Trail', 88687348, '2007/04/11', '2017/10/15', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (540794871, 'Freeland', 'Weich', 'Ropcke', '49911 La Follette Center', 88044516, '2001/12/31', '2019/03/18', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (533508573, 'Brit', 'O''Brallaghan', 'Batting', '977 Sachs Place', 89445949, '2003/03/19', '2018/10/25', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (514139577, 'Christabella', 'Membry', 'Giller', '1863 Artisan Junction', 87125845, '2003/11/18', '2015/07/28', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (479421774, 'Andonis', 'Coldrick', 'Ashfull', '43 Hauk Terrace', 87127136, '2008/06/06', '2016/02/22', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (452563213, 'Coletta', 'Bishop', 'Aukland', '90 Cardinal Drive', 87899693, '2003/06/07', '2018/03/04', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (487296410, 'Cathleen', 'Ondra', 'Primak', '31 Norway Maple Plaza', 86821267, '1998/11/27', '2018/06/28', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (461781823, 'Esma', 'Putton', 'Lamdin', '0640 Nancy Center', 87655728, '1999/10/11', '2016/10/23', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (538098983, 'Eliot', 'Robberts', 'Bilovsky', '84470 Melrose Junction', 86737488, '2001/06/14', '2019/08/27', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (436613687, 'Muhammad', 'McAviy', 'Franceschi', '2198 Fisk Parkway', 89182967, '1996/07/23', '2019/01/14', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (432365501, 'Aridatha', 'Creane', 'Van De Cappelle', '26863 Hoepker Way', 86562357, '1996/03/14', '2019/03/06', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (568188359, 'Dorothea', 'O''Brogan', 'Lakes', '3197 Blaine Park', 89053490, '1995/03/26', '2019/09/18', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (559764077, 'Dame', 'Gorham', 'Vereker', '0 Victoria Crossing', 88114082, '2007/08/18', '2018/01/26', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (507145151, 'Faith', 'Bamfield', 'Elsmore', '7 Delaware Place', 87590349, '1998/12/13', '2019/10/21', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (524557120, 'Idelle', 'Doret', 'Gallehock', '35 Declaration Way', 88116020, '1999/02/17', '2016/05/24', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (461738972, 'Danit', 'Stradling', 'Worgen', '836 Lotheville Parkway', 87350401, '1999/10/17', '2018/09/05', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (434397940, 'Somerset', 'Twomey', 'Blackesland', '75 Annamark Crossing', 88169079, '1995/07/09', '2017/03/14', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (595030261, 'Tucker', 'Overell', 'Shallow', '3118 Michigan Alley', 88299943, '1996/07/04', '2019/02/23', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (592274905, 'Tessi', 'Hollyard', 'Frankema', '33 Fairfield Drive', 86403782, '1998/10/19', '2018/10/16', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (570356681, 'Allina', 'Gerler', 'Marrow', '98512 Florence Court', 88111297, '2004/11/15', '2019/10/06', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (437945612, 'Jane', 'Ygo', 'Gadney', '3922 Barby Alley', 89231372, '1997/03/31', '2018/08/14', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (580827134, 'Shannon', 'Hawkridge', 'Lars', '410 Grasskamp Circle', 89122447, '1999/09/25', '2018/03/26', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (589864859, 'Correy', 'Averay', 'Sieghard', '55316 Ridge Oak Place', 87921054, '2008/12/12', '2018/05/13', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (548021085, 'Jessamine', 'Norledge', 'Sellors', '888 Shelley Circle', 87742625, '1996/12/20', '2018/12/01', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (463344439, 'Jerrilyn', 'Gibbin', 'Jersh', '8 Dottie Point', 88011491, '2000/01/15', '2018/02/04', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (408210170, 'Lorene', 'Dummer', 'Turfus', '77 Clemons Crossing', 89613358, '1998/02/28', '2015/08/20', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (550443966, 'Agatha', 'Dwerryhouse', 'Hiner', '713 Waxwing Road', 87307172, '1996/03/22', '2017/01/16', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (596068939, 'Adara', 'Buney', 'Fockes', '90095 Lukken Crossing', 87074375, '1995/04/01', '2015/09/30', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (434604417, 'Gunter', 'Tournay', 'Champneys', '0 Rutledge Road', 88857204, '2006/12/14', '2015/08/19', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (480223573, 'Kania', 'Courtenay', 'Attwood', '37331 Buell Junction', 89344313, '2003/04/29', '2016/06/12', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (475123259, 'Winfred', 'Sharma', 'Splevin', '43795 Chive Circle', 88666545, '2001/02/28', '2018/02/02', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (571333617, 'Grantham', 'Davitashvili', 'Guiver', '114 Caliangt Terrace', 88097010, '1996/05/15', '2019/03/07', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (502226228, 'Rici', 'Skoughman', 'Harback', '40361 Westport Hill', 86569184, '2009/04/14', '2015/03/23', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (436072383, 'Tan', 'Larne', 'Sunshine', '925 Pearson Way', 87066009, '2004/05/25', '2018/09/23', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (450079504, 'Desdemona', 'Kirimaa', 'Genicke', '0912 Ronald Regan Place', 89467747, '2000/10/26', '2015/02/26', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (450395110, 'Basilius', 'Hoogendorp', 'Sibbering', '933 Northland Terrace', 86286112, '1995/12/31', '2017/05/03', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (481269933, 'Cello', 'Wilbore', 'Khomishin', '92 Tennyson Junction', 87559934, '2000/07/15', '2016/04/10', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (430887037, 'Lula', 'Normansell', 'Cahey', '92 Becker Center', 87333498, '1999/10/02', '2015/01/10', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (589568448, 'Jorrie', 'Killingbeck', 'McGillivray', '451 Waywood Junction', 89409656, '2004/08/11', '2017/04/25', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (443549387, 'Shawna', 'Hempshall', 'Gritten', '0192 Calypso Circle', 86220125, '1999/06/06', '2016/01/13', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (431929623, 'Kylie', 'Tattershall', 'Caccavale', '32 Pankratz Point', 86173470, '2003/08/30', '2016/02/26', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (533402227, 'Milton', 'Bysshe', 'Berrey', '8009 New Castle Plaza', 86931004, '2001/05/25', '2019/02/05', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (569356596, 'Erskine', 'Knox', 'Pengilly', '36 Mosinee Alley', 87946050, '2004/03/11', '2015/12/12', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (553774185, 'Rossie', 'McPhelim', 'Fern', '05 Dixon Alley', 86183420, '2009/07/22', '2019/10/25', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (439225820, 'Allen', 'Drewry', 'Hinckes', '99 Mayer Terrace', 89563483, '2008/04/27', '2015/09/02', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (549482652, 'Carmela', 'Tolputt', 'Boag', '737 Rutledge Terrace', 86991453, '1998/08/20', '2017/03/04', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (488482141, 'Andres', 'Macieja', 'Soppit', '233 Ridgeview Drive', 88974236, '2007/10/06', '2018/09/13', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (421985559, 'Ingunna', 'Morsom', 'Luesley', '485 Aberg Hill', 86456290, '1999/03/18', '2017/11/09', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (592575653, 'Ginnie', 'Horder', 'Breward', '86502 Stephen Pass', 87830022, '1997/11/18', '2019/07/30', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (465695214, 'Rozella', 'Burd', 'Wales', '9341 Sycamore Alley', 86444020, '2006/07/23', '2015/12/26', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (467103822, 'Hildy', 'Loton', 'Kremer', '36768 Eagle Crest Parkway', 89285921, '2008/12/03', '2016/11/06', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (522272955, 'Jonas', 'Parkman', 'Romagosa', '256 Carberry Place', 86823785, '2005/04/04', '2018/11/27', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (552332853, 'Lark', 'Simko', 'Dyott', '08365 Sachtjen Drive', 87113909, '2004/02/12', '2016/01/28', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (429716271, 'Rosco', 'Bickerton', 'Ishchenko', '4 Garrison Parkway', 88292212, '2006/05/26', '2018/07/16', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (552379565, 'Cassie', 'Durno', 'Moth', '7 Maryland Trail', 89735268, '2004/02/18', '2015/06/15', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (454114370, 'Seline', 'Salzburg', 'Wohlers', '9955 Amoth Parkway', 87185481, '2002/06/06', '2016/12/26', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (489589046, 'Gaspard', 'Nanni', 'Allnatt', '359 Continental Point', 86068251, '2000/01/21', '2017/09/28', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (544094325, 'Dusty', 'Giral', 'Filipczak', '6341 Arkansas Crossing', 88768855, '1997/04/14', '2019/05/15', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (501152797, 'Kaylil', 'Ricold', 'Tilliard', '69916 Linden Trail', 86844050, '1997/03/28', '2015/04/07', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (535362198, 'Slade', 'Eskriett', 'De Ambrosis', '985 Thackeray Street', 89652529, '2006/04/24', '2019/06/29', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (512617651, 'Travus', 'Kehri', 'Deeson', '21287 Mifflin Avenue', 86479365, '2009/09/30', '2019/04/12', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (597028450, 'Horatio', 'Garett', 'Wolfe', '41 Clemons Park', 87467718, '2007/11/22', '2016/10/06', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (579247160, 'Fabe', 'Barts', 'Lawford', '6059 Florence Way', 88804657, '1995/06/14', '2018/08/01', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (410260297, 'Dorey', 'Gaiford', 'Lidgard', '64155 Hazelcrest Drive', 87812904, '1997/08/31', '2018/10/15', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (537134975, 'Teodora', 'Earey', 'Beverage', '17148 Darwin Drive', 89415823, '1996/06/21', '2017/11/02', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (598863510, 'Renato', 'Whilder', 'Camies', '8 Susan Hill', 86890970, '2003/12/06', '2017/08/27', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (425854548, 'Maurine', 'McLaine', 'Dyte', '42974 Johnson Court', 87058761, '2006/01/17', '2019/01/20', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (470924449, 'Oliver', 'Troni', 'Venney', '86643 Kensington Trail', 88246512, '2008/05/11', '2019/02/14', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (593540659, 'Lyndsey', 'Sayce', 'Dedman', '7398 Village Green Crossing', 86576235, '2005/09/16', '2017/10/17', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (459690067, 'Bengt', 'Aimable', 'Larret', '9343 Clarendon Pass', 89802994, '1996/02/14', '2019/04/10', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (440311020, 'Lind', 'Bellard', 'Burgin', '3 Jenifer Point', 88704076, '2009/03/20', '2018/11/15', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (561934328, 'Donia', 'Tuson', 'Titley', '9693 Elmside Street', 88603225, '2000/02/29', '2019/04/01', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (401066240, 'Kiel', 'Atwell', 'Flea', '42657 Claremont Drive', 88354409, '1999/06/18', '2019/04/12', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (590437043, 'Bradan', 'John', 'Izzard', '26494 Randy Parkway', 89480609, '1997/09/30', '2016/05/24', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (513514128, 'Camala', 'Corderoy', 'Saltmarsh', '73621 Warner Junction', 89500693, '1996/12/04', '2015/01/25', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (444661895, 'Boigie', 'Pycock', 'Feast', '94 Autumn Leaf Court', 86586872, '2001/06/27', '2017/04/02', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (474466784, 'Durant', 'Santello', 'Cobbold', '537 Vera Street', 87703551, '2003/08/04', '2018/11/30', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (500002283, 'Tabby', 'Howison', 'Messingham', '71312 Prairieview Trail', 89847775, '2000/10/31', '2016/11/21', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (522419749, 'Anetta', 'Flindall', 'Gerred', '69 Harper Circle', 88754709, '2007/04/06', '2015/10/02', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (428202103, 'Nettle', 'Josovitz', 'Farquarson', '3 Warbler Hill', 89299456, '2006/12/27', '2015/12/11', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (437512471, 'Erskine', 'Maciejak', 'Minithorpe', '9748 Nancy Road', 88410252, '1995/04/21', '2018/04/01', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (493419824, 'Ryley', 'Foker', 'Bembrigg', '6345 Texas Lane', 87969173, '1997/07/04', '2015/07/08', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (533501273, 'Danice', 'Stealey', 'Penn', '54675 Riverside Place', 86837350, '2003/05/08', '2016/10/20', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (473303251, 'Irene', 'Suscens', 'Tockell', '2 Northridge Avenue', 88487546, '2003/08/15', '2018/07/05', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (582359114, 'Janessa', 'McEneny', 'Heatherington', '514 Southridge Trail', 88474392, '2008/01/03', '2015/09/02', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (428603463, 'Mitchael', 'Wapple', 'Alderwick', '9 Weeping Birch Circle', 86269686, '2002/03/31', '2016/11/12', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (442700691, 'Earvin', 'Fanshawe', 'Corssen', '29 Hauk Lane', 86613480, '1997/01/21', '2017/07/11', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (497063050, 'Paulette', 'Langthorne', 'Simm', '50556 Oak Park', 86707109, '2006/06/23', '2017/03/12', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (504192389, 'Juliane', 'O''Codihie', 'Surgen', '0 Springs Place', 86539112, '1998/08/11', '2015/08/06', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (415347207, 'Toiboid', 'Molohan', 'Mohammad', '6 Packers Lane', 89106775, '2007/06/24', '2017/09/16', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (546241043, 'Linn', 'Brymner', 'MacLure', '867 Kedzie Lane', 89165689, '1996/05/06', '2015/08/18', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (457597547, 'Tedman', 'Joubert', 'Venditti', '0299 Schlimgen Point', 89117832, '2003/12/19', '2017/11/23', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (463253871, 'Tanitansy', 'Wildin', 'Warby', '8515 6th Place', 87265969, '1999/07/07', '2018/02/19', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (509042691, 'Dore', 'Blagden', 'Derby', '636 Miller Junction', 86928676, '2006/07/12', '2018/09/21', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (564586108, 'Abbie', 'Caitlin', 'Biasotti', '0985 Onsgard Way', 87778037, '1995/05/19', '2017/05/16', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (400049106, 'Emalee', 'Fydo', 'Rayment', '36920 Browning Plaza', 86966635, '2004/06/20', '2016/07/19', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (486835971, 'Beck', 'Henzley', 'Paulig', '28 Waxwing Way', 89698020, '2005/04/29', '2019/09/06', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (519954008, 'Jerrine', 'Muller', 'Banville', '44 Washington Alley', 89285891, '2002/11/23', '2019/04/06', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (529125051, 'Lari', 'Wileman', 'Barnham', '2 Superior Court', 86211238, '2009/04/04', '2016/10/27', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (508204941, 'Clementius', 'Geraud', 'Cundy', '091 Washington Court', 87655447, '1999/11/27', '2015/07/22', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (400120982, 'Carissa', 'Bampkin', 'Dawidman', '8123 Sunbrook Road', 89698594, '2007/11/30', '2018/01/28', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (411324381, 'Natalya', 'Jaggers', 'Winks', '41 Pawling Center', 88266011, '1998/08/20', '2018/08/28', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (584683032, 'Valma', 'Gray', 'McArt', '901 Evergreen Junction', 86573119, '1998/05/25', '2018/01/27', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (479289060, 'Emiline', 'Bresson', 'Pleasants', '05 Bowman Hill', 89439194, '2007/11/04', '2018/07/17', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (524170408, 'Lenci', 'McGuffie', 'Whayman', '864 Roth Trail', 86853833, '2009/09/17', '2019/03/22', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (594181138, 'Sissy', 'Bamlet', 'Pepye', '3338 Burning Wood Hill', 89785561, '2002/10/16', '2018/08/31', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (523944707, 'Niles', 'Skerritt', 'Hansemann', '85 New Castle Park', 89840941, '1998/12/10', '2019/10/24', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (407631440, 'Estele', 'Waplington', 'Brok', '387 Johnson Court', 89780066, '1998/06/16', '2016/03/29', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (544883776, 'Jean', 'Leyzell', 'Menure', '8974 Shasta Parkway', 88260252, '1998/12/22', '2019/04/03', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (535302666, 'Jaquith', 'Coppledike', 'Glazzard', '940 Killdeer Point', 89732510, '2000/10/25', '2018/08/05', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (550748168, 'Micheal', 'Sinnett', 'Baron', '80882 Rutledge Center', 86087220, '2000/07/27', '2016/12/23', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (583638137, 'Erda', 'Meegin', 'Cranna', '93 Westport Point', 87772101, '2007/07/22', '2017/08/10', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (529609475, 'Casey', 'Roskrug', 'Floyde', '6352 Park Meadow Way', 89759127, '2005/05/27', '2016/03/12', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (436491612, 'Celia', 'Blaksley', 'Matysik', '242 Laurel Place', 87411821, '2006/03/29', '2017/05/10', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (494659812, 'Andrey', 'Wigzell', 'Ferreiro', '2 Victoria Street', 86885006, '2000/02/28', '2017/09/28', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (475724876, 'Arnuad', 'Perris', 'Lilly', '04 Claremont Park', 88733561, '1996/01/24', '2016/08/13', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (472582197, 'Lucian', 'Rubury', 'Boncoeur', '1791 Duke Trail', 86446123, '2002/12/21', '2017/11/27', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (490402294, 'Jordain', 'Leverage', 'Gourlay', '25556 Delladonna Road', 88721763, '2007/03/16', '2017/05/26', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (458465426, 'Adelice', 'Bysh', 'Cuncarr', '23 Sachtjen Alley', 86303761, '2001/11/12', '2019/07/19', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (586485572, 'Seward', 'McRuvie', 'Plimmer', '7375 Fuller Parkway', 88203801, '2002/07/15', '2017/07/28', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (550018739, 'Geri', 'Yukhnev', 'Kitcherside', '44877 Aberg Crossing', 88721730, '1996/02/27', '2019/11/05', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (476955167, 'Jobey', 'Nichol', 'De Caroli', '5 Loomis Alley', 86378046, '2006/01/27', '2016/10/18', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (526719297, 'Xymenes', 'Kuhl', 'Ruggs', '1 Mcbride Avenue', 89132464, '2003/06/16', '2018/01/14', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (474095871, 'Yule', 'Ingleton', 'Argente', '5510 Eggendart Plaza', 88593925, '1997/08/16', '2015/03/29', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (485680187, 'Elga', 'Alexandrou', 'Doolan', '3486 Summerview Pass', 86365042, '1995/12/05', '2019/01/22', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (454469909, 'Dasi', 'Barnewell', 'Hryniewicki', '0380 Autumn Leaf Trail', 89099211, '2005/08/24', '2017/11/02', 0);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (425039174, 'Tine', 'Larkworthy', 'Bradtke', '4237 Buena Vista Alley', 87717033, '2006/12/11', '2017/11/18', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (543254370, 'Franciska', 'Goodhall', 'Attenbrough', '702 Elgar Pass', 87172843, '1995/05/11', '2018/08/14', 25);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (527069687, 'Eleanore', 'Mattaus', 'Ghio', '10 Reindahl Avenue', 86224553, '1999/08/14', '2017/08/19', 50);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (582409502, 'Harriett', 'Heminsley', 'Chalfont', '7558 Cascade Terrace', 86696191, '1997/12/31', '2018/09/08', 100);
insert into Academia.Estudiante (ID_Estudiante, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, fecha_nacimiento, Fecha_ingreso, ID_Beca) values (419838642, 'Chrotoem', 'Clendinning', 'Saltman', '10550 Hermina Park', 89071919, '2004/07/02', '2019/01/30', 0);

-- insercion en Academia.Profesor
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247026125, 'Thorsten', 'Lacase', 'Keyden', 81484257, '1989-09-19', '2015-10-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (113813522, 'Dorice', 'Warnock', 'Cafe', 80079908, '1992-05-26', '2018-06-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (315946337, 'Kristoforo', 'Edgcombe', 'Giovannoni', 81797191, '1994-08-25', '2019-03-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (301522332, 'Becka', 'Gilbane', 'Lyvon', 85238126, '1980-06-01', '2017-10-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (106907301, 'Osmund', 'Banasiak', 'McReidy', 82735769, '1992-10-27', '2017-04-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (156176699, 'Munroe', 'Agerskow', 'Bartlett', 80815163, '1985-09-10', '2015-01-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (120224652, 'Barney', 'Pargent', 'Orvis', 84965605, '1991-01-18', '2018-05-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (357448920, 'Randal', 'Brim', 'Ghidoli', 85537320, '1990-01-23', '2018-01-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (365760523, 'Xerxes', 'Gronno', 'Fernant', 84031572, '1984-05-13', '2016-12-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (234192453, 'Annadiane', 'Master', 'Newman', 85164760, '2000-01-23', '2016-01-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (264139487, 'Garnette', 'Gaitley', 'Rizzardi', 81122665, '1994-01-31', '2018-09-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (243370119, 'Jemie', 'Kitteman', 'Peasgood', 85043725, '1994-07-10', '2015-12-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (386972047, 'Debora', 'Burnip', 'Jerke', 84706716, '1983-08-02', '2017-07-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (100619454, 'Gordon', 'Ridings', 'Follows', 82860954, '1991-12-15', '2015-04-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (130439755, 'Freddy', 'Langtree', 'Foulser', 80919586, '1985-04-10', '2018-10-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (264087727, 'Alidia', 'Jervoise', 'Jope', 80441183, '1988-01-16', '2016-12-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (352417810, 'Rudd', 'Mattiussi', 'Furlong', 80419649, '1992-07-20', '2017-05-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (285816849, 'Glenda', 'Thornthwaite', 'Hatchell', 82188308, '1997-07-27', '2016-03-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (323362381, 'Cesaro', 'Delagnes', 'Kondratenko', 82073703, '1991-05-13', '2017-06-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (106002320, 'Jsandye', 'Jendrassik', 'O''Hannay', 84920904, '1981-07-06', '2017-10-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (260718317, 'Lizzie', 'Killcross', 'Espadas', 85404361, '1998-04-13', '2018-02-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (334810152, 'Agretha', 'Santen', 'Iacovo', 83216561, '1993-02-25', '2016-10-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (210042740, 'Shae', 'Hylands', 'Kimmince', 84768296, '1995-10-20', '2016-02-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (199352857, 'Adena', 'Grigson', 'Goulden', 85478874, '1997-03-24', '2019-04-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (105487629, 'Demetrius', 'Kemish', 'Bidwell', 80081393, '1983-03-21', '2016-03-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (150934264, 'Shalom', 'O''Brallaghan', 'Frenzel;', 84368031, '1987-05-18', '2017-05-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (168218957, 'Gabriela', 'Wardhough', 'Bennison', 82814781, '1989-06-15', '2016-01-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (253971842, 'Corilla', 'Wehden', 'Masic', 82173122, '1992-03-30', '2018-12-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (104641932, 'Fair', 'Gellett', 'Stean', 82033784, '1983-01-07', '2015-11-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (228120947, 'Cynthy', 'Vernay', 'Leggis', 85175758, '1990-07-26', '2018-08-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (295618934, 'Emeline', 'Baldazzi', 'Kennion', 80008092, '1986-01-19', '2015-02-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (102729955, 'Booth', 'Wardrop', 'Jepp', 83361913, '1992-02-23', '2015-04-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (350886493, 'Llewellyn', 'Morfey', 'Harbor', 82423463, '1981-05-02', '2019-03-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (184483026, 'Dyane', 'Stidworthy', 'Haversum', 83676999, '1998-11-08', '2019-09-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (191502979, 'Toby', 'Riediger', 'Riggulsford', 83400853, '1980-12-13', '2019-10-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (289400621, 'Jonas', 'Delacoste', 'Tie', 83673656, '1991-07-13', '2017-10-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (262620497, 'Emyle', 'Vaughten', 'Ector', 80816850, '1999-01-05', '2018-02-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (307524848, 'Rosalind', 'Healings', 'Lehrian', 82494054, '1995-02-10', '2017-01-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (114285774, 'Michal', 'Samsonsen', 'Letts', 80077063, '1983-02-13', '2018-09-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (363909247, 'Lemar', 'Maddie', 'Smail', 85516355, '1988-09-28', '2017-11-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (296932497, 'Ethel', 'Fillgate', 'Grogor', 83639070, '1988-11-24', '2016-06-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (327683848, 'Norbie', 'Brabham', 'Physic', 80460641, '1987-09-22', '2018-12-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (314966917, 'Nicko', 'De Ruel', 'Fontes', 81095052, '1991-12-25', '2016-01-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (219884202, 'Leila', 'Donkersley', 'Longo', 80166460, '1996-06-30', '2019-04-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (153380782, 'Shirlee', 'Serotsky', 'Pagin', 84605198, '1997-08-09', '2017-11-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (279829788, 'Cher', 'Cossem', 'Boller', 85117937, '1993-12-30', '2016-08-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (221081795, 'Loraine', 'Bertelmot', 'Thrower', 84322318, '1995-07-10', '2015-07-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (310690124, 'Stefan', 'Seifert', 'Graalmans', 84846404, '1990-10-27', '2016-01-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (358303662, 'Fredric', 'Mayhou', 'Edess', 84659920, '1995-11-16', '2015-06-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (393351831, 'Lynnette', 'Hucks', 'Eddy', 80899583, '1987-10-04', '2018-12-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (145437363, 'Ethelbert', 'Cristoforetti', 'Teall', 81744002, '1982-12-19', '2017-10-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (209255508, 'Selestina', 'Curless', 'Ferfulle', 84076696, '1999-12-15', '2016-09-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (219698545, 'Antonie', 'Skett', 'Scandrick', 85437352, '1984-01-12', '2017-04-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (176949149, 'Roselin', 'Cremin', 'Postins', 83106690, '1998-07-25', '2018-03-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (235043685, 'Tibold', 'Stanlick', 'Saward', 84581830, '1983-01-19', '2015-04-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (263460002, 'Linzy', 'Gibbon', 'Fenne', 84892173, '1993-11-11', '2019-08-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (294141522, 'Wallie', 'Breznovic', 'Darlison', 81356924, '1993-09-14', '2019-01-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (359496097, 'Alan', 'Bedham', 'Leist', 85150743, '1997-03-01', '2015-01-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (118699405, 'Nickolaus', 'Morling', 'Meredith', 83568567, '1990-11-09', '2018-05-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247013279, 'Ernst', 'Rodder', 'McGarrie', 84543509, '1983-04-22', '2017-03-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (372735077, 'Nike', 'Addinall', 'O''Shevlin', 80106922, '1998-02-08', '2019-10-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (214826274, 'Lyndsie', 'Seville', 'Wildbore', 83610890, '1986-11-29', '2017-04-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (241888095, 'Karlyn', 'Corington', 'Smedmoor', 85285490, '1989-04-03', '2015-01-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (158350931, 'Richmound', 'Beelby', 'Connichie', 80439059, '1983-07-18', '2018-02-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (103402630, 'Benny', 'Domelow', 'Klugel', 82914756, '1998-09-18', '2019-09-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (155518006, 'Hart', 'McKirdy', 'Blonfield', 85283363, '1998-07-27', '2017-11-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (241268874, 'Heidie', 'Lathleiff', 'Suggett', 84253366, '1992-02-17', '2019-02-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (370331852, 'Shell', 'Hutton', 'Reside', 84867962, '1995-11-14', '2018-03-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (262112605, 'Johnathon', 'Mains', 'Rowesby', 85309012, '1987-05-14', '2016-08-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (335293775, 'Joell', 'Forsyth', 'Tremmil', 84809789, '1986-09-21', '2016-01-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (389816961, 'Joice', 'Curnokk', 'Albin', 85245831, '1991-08-05', '2017-06-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (226393924, 'Donielle', 'Patmore', 'Macellar', 83795467, '1990-06-01', '2019-07-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (196936895, 'Boycie', 'Alenichicov', 'Burnup', 81500966, '1992-04-24', '2019-04-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (236728002, 'Linc', 'Deare', 'Possek', 84673762, '1985-07-28', '2016-09-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (262712006, 'Octavia', 'Buckley', 'Beams', 82036780, '1988-04-05', '2018-07-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (163398848, 'Foss', 'Unsworth', 'Facher', 83035265, '1993-01-24', '2018-04-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (321247596, 'Mellisent', 'Lyman', 'Abberley', 81014246, '1995-06-07', '2016-05-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (214952216, 'Walliw', 'Cadell', 'Schneidar', 85381684, '1984-03-11', '2019-02-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (139385640, 'Cyndia', 'Benitti', 'Fullilove', 81954580, '1988-08-29', '2017-11-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (150866140, 'Elizabeth', 'Dibley', 'Sabie', 80524091, '1994-01-22', '2015-04-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (320131504, 'Griff', 'Nanuccioi', 'Rodliff', 80352023, '1992-07-19', '2017-08-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (361365081, 'Dian', 'Trendle', 'Westcar', 84994618, '1984-11-14', '2018-02-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (363107071, 'Brantley', 'Paulich', 'Arnfield', 80493371, '1981-06-16', '2017-10-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (297803917, 'Kennedy', 'Denes', 'Constantine', 83741489, '1982-04-27', '2018-07-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (290618583, 'Theresa', 'Fulton', 'Melhuish', 83617596, '1997-01-17', '2016-05-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (114362017, 'Chris', 'Poppleston', 'Greengrass', 82490012, '1995-10-07', '2019-04-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (232842413, 'Portie', 'Bredgeland', 'Moston', 82355413, '1990-10-12', '2015-06-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (142723461, 'Aubert', 'Galiero', 'Sheahan', 84050773, '1983-01-23', '2018-10-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (151310999, 'Sully', 'Vicarey', 'Yakebovich', 81189354, '1987-04-13', '2018-04-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (379780558, 'Kaine', 'Rubartelli', 'Guyer', 84783241, '1983-03-31', '2018-03-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (158352977, 'Tabbatha', 'Rapps', 'Gosnay', 83265608, '1986-05-17', '2018-10-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (387966897, 'Bibi', 'Luter', 'Cupper', 84816804, '1995-11-20', '2018-03-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (207362296, 'Rodrique', 'McAlarney', 'Benz', 83384219, '1993-09-28', '2016-05-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (220848233, 'Corie', 'Redparth', 'Gregson', 82177621, '1995-04-17', '2017-12-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (173762012, 'Talia', 'Soigne', 'Haps', 80165246, '1994-03-12', '2017-06-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (183511365, 'Bonnee', 'Bortolomei', 'Rosendahl', 80650246, '1986-09-28', '2018-01-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (358307426, 'Sebastiano', 'Sommerly', 'Suller', 82443411, '1988-09-18', '2018-08-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (301972143, 'Georgeanne', 'Mohun', 'Sibthorp', 85049839, '1994-10-02', '2019-03-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (225804131, 'Andromache', 'Bispo', 'Ackenson', 83522808, '1986-05-24', '2016-04-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (226075955, 'Jodee', 'Caro', 'Huxley', 81835510, '1988-03-12', '2017-07-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (374638517, 'Ted', 'Wintringham', 'Benini', 85100481, '1983-09-11', '2018-09-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (347566663, 'Kalina', 'Kither', 'Passingham', 84547915, '1993-12-22', '2016-09-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (361803536, 'Katalin', 'Pirrey', 'Knobell', 81915371, '1983-08-11', '2015-08-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (216523268, 'Redd', 'Kacheler', 'Linkin', 81420759, '1982-07-16', '2017-03-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (163488325, 'Aland', 'Zoane', 'Golly', 80723495, '1999-03-02', '2018-07-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (262828240, 'Freddy', 'Andersen', 'Jozsef', 83374425, '1991-07-12', '2017-06-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (261158923, 'Matt', 'Raspin', 'Serjeantson', 82895754, '1993-05-04', '2017-12-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (267511538, 'Betta', 'Maystone', 'Musla', 82623694, '1980-04-29', '2017-06-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (236450369, 'Lian', 'Redemile', 'Mizzen', 81620656, '1981-12-09', '2019-09-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (316612559, 'Coop', 'Livoir', 'Laurenty', 84516329, '1983-12-02', '2019-09-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (364740385, 'Ellary', 'Rumming', 'Balfe', 84353938, '1984-06-06', '2016-01-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (376038885, 'Flora', 'Kempshall', 'Loynes', 82374753, '1987-05-10', '2015-12-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (204618797, 'Caro', 'Bresnahan', 'Mc Pake', 83526140, '2000-02-22', '2018-10-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (283001445, 'Brandy', 'Pepall', 'Kaszper', 82929648, '1999-03-20', '2016-02-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (388035767, 'Angeli', 'Linnock', 'Andre', 84507649, '1994-01-07', '2019-10-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (343956278, 'Zena', 'Brame', 'Mugleston', 84226344, '1995-04-13', '2016-12-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (266799794, 'Erik', 'Wyeth', 'Seagar', 80080812, '1995-10-01', '2017-05-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (105009229, 'Nonnah', 'Battany', 'Shatliffe', 82271666, '1992-06-27', '2017-08-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (272004020, 'Vale', 'Itzhaiek', 'Barok', 80894497, '1993-02-01', '2019-10-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (394149675, 'Kellia', 'Erratt', 'Havik', 82390145, '1988-12-20', '2018-03-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (264859030, 'Cleavland', 'Handlin', 'Kidwell', 83329687, '1989-09-13', '2018-08-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (279834897, 'Caddric', 'Passo', 'Charon', 84043992, '1997-04-17', '2018-05-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (348785865, 'Kenn', 'Duckerin', 'Marden', 84203907, '1983-10-18', '2018-11-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (180757368, 'Angelita', 'Driutti', 'Kerrigan', 81622987, '1984-10-08', '2016-03-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (232123300, 'Chelsea', 'Sumption', 'Artis', 81844812, '1989-04-24', '2018-06-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (294529284, 'Emilia', 'Suarez', 'Crowdson', 84484082, '1983-02-09', '2017-11-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (300099233, 'Nissy', 'Bischop', 'Phoenix', 81465126, '1997-11-28', '2015-04-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (172076935, 'Theobald', 'Duffill', 'Orys', 83567015, '1990-07-16', '2017-07-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (211035872, 'Hermann', 'Moscrop', 'Sertin', 83624965, '1994-07-10', '2017-09-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (376432999, 'Lolly', 'Hanbridge', 'Sculley', 83452631, '1990-08-08', '2015-05-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (378804658, 'Benny', 'Elton', 'Colebourne', 85088032, '1993-07-25', '2016-09-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (105274784, 'Joanne', 'Hounsome', 'Whettleton', 80416717, '1983-05-02', '2015-03-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (105389462, 'Jobi', 'Duff', 'Boyce', 81823544, '1984-04-26', '2017-01-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (208367961, 'Sherlock', 'Trewhela', 'Zarfai', 84664916, '1987-09-10', '2019-01-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (162921452, 'Misty', 'Worsnup', 'Uttermare', 81391480, '1990-12-26', '2018-08-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (312441778, 'Wendell', 'Oles', 'Joicey', 84037989, '1992-06-29', '2017-05-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (129252585, 'Stormie', 'Rowler', 'Cumo', 80502283, '1989-03-10', '2017-08-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (352151427, 'Johnna', 'Lynnett', 'Maffy', 84282730, '1999-04-04', '2016-12-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (118864403, 'Cortney', 'Yellowlee', 'Laker', 80293478, '1985-05-07', '2019-01-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (116002895, 'Eddy', 'Delepine', 'Pouck', 80056461, '1988-11-23', '2016-08-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (300224713, 'Brucie', 'Labeuil', 'Boxill', 84440737, '2000-05-25', '2015-10-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (264802275, 'Suzanne', 'Ransbury', 'Shreenan', 85056688, '1984-03-16', '2019-07-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (191551661, 'Noelyn', 'Markos', 'Bernon', 84220290, '1983-08-27', '2015-09-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (111683329, 'Babbette', 'Ceschi', 'Sneesby', 83757038, '1994-07-26', '2015-02-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (384351674, 'Addi', 'Pawelczyk', 'Raeside', 81011139, '1997-09-07', '2018-05-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (193270775, 'Riccardo', 'Cuthbert', 'Tiesman', 81594851, '1991-04-24', '2015-12-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (289918882, 'Raine', 'Hellicar', 'Sibson', 84977407, '1995-06-03', '2015-01-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (182763923, 'Camila', 'Macklam', 'MacComiskey', 81459551, '1980-12-13', '2017-08-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (206429965, 'Wittie', 'Tyler', 'Calley', 83717031, '1991-10-23', '2016-03-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247388280, 'Hamel', 'Leith', 'Tierny', 82597592, '1982-02-03', '2017-05-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (366764912, 'Ogden', 'Nunan', 'Conti', 83711964, '1995-12-02', '2018-04-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (341054256, 'Mimi', 'Dyball', 'Brownsill', 80933760, '1987-11-12', '2017-11-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (182204119, 'Artemis', 'Lomaz', 'Sauvain', 81048472, '1982-06-10', '2018-04-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (107146460, 'Maighdiln', 'Titchard', 'Lindbergh', 82909227, '2000-09-21', '2016-03-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (260191724, 'Danit', 'Fisk', 'Gadie', 82438717, '1997-07-07', '2017-02-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (397784596, 'Leeanne', 'Leblanc', 'Chastan', 81333076, '1990-12-19', '2019-02-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (306920910, 'Conny', 'Del Checolo', 'Blaxland', 85551307, '1996-01-08', '2019-11-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (395900176, 'Marla', 'Seeney', 'Whatley', 80874495, '1990-10-16', '2018-04-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (128223376, 'Consuela', 'Mould', 'Uccello', 80011760, '1998-04-12', '2017-04-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (148955189, 'Alexina', 'Altoft', 'Pashen', 84441073, '2000-07-12', '2018-10-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (376513747, 'Brittani', 'Westnedge', 'Timperley', 82344911, '1992-06-03', '2016-04-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (356736737, 'Jordan', 'Gulland', 'Cheatle', 84882011, '1995-01-07', '2018-12-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (346097387, 'Stacy', 'Emberson', 'Corballis', 81770413, '1999-06-08', '2018-07-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (227657280, 'Sylvester', 'Fossett', 'Gilchrest', 84917701, '1983-02-06', '2016-07-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (374539930, 'Dela', 'Farnan', 'Balducci', 80582287, '1993-01-14', '2019-05-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (248027150, 'Nicola', 'Grimsey', 'Balasini', 82835769, '1985-08-31', '2015-01-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (225907939, 'Judah', 'Ianittello', 'Renwick', 83433149, '1986-10-31', '2018-06-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (234152375, 'Morrie', 'Dunnan', 'Jacquemard', 80994013, '1987-03-05', '2019-03-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (284907580, 'Knox', 'Goskar', 'Mellish', 82143546, '1990-06-01', '2018-08-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (159048695, 'Roberto', 'Coldtart', 'Marke', 85375989, '1982-01-01', '2015-01-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (106882486, 'Mitch', 'Werrilow', 'Dewicke', 85306364, '1991-01-20', '2015-12-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (260884920, 'Catlee', 'Sharrock', 'Collyer', 80984410, '1990-04-30', '2017-03-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (312770446, 'Genni', 'Birkmyre', 'Bedbury', 81003680, '1989-02-18', '2016-01-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (153571545, 'Tobye', 'Simounet', 'Klezmski', 83970705, '1998-10-23', '2018-10-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (398693617, 'Chucho', 'Minerdo', 'Strangeway', 81905636, '1983-09-21', '2017-12-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (284604890, 'Jaimie', 'Rosenwald', 'Ranstead', 84968483, '1994-04-30', '2018-04-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (209955616, 'Dore', 'Crockett', 'Zamora', 82015301, '1989-05-14', '2019-08-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (218796073, 'Hughie', 'MacGinley', 'Goodlake', 82380139, '1981-02-11', '2016-04-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (308502448, 'Roze', 'Smitheram', 'De Ruggiero', 83272100, '2000-01-14', '2016-10-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (305486733, 'Hale', 'Ginnaly', 'Crosfeld', 84364961, '2000-06-06', '2017-05-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (195041214, 'Ali', 'Channing', 'Bain', 82357966, '1996-08-18', '2017-04-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (154247675, 'Virginia', 'Aldersey', 'Dargue', 80096666, '1997-07-31', '2018-09-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (141025201, 'Elane', 'Geer', 'Fraczek', 81120108, '1987-12-15', '2015-11-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (185204878, 'Joann', 'Wisdish', 'Shears', 81698613, '1983-05-07', '2015-02-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (287724922, 'Hans', 'Stroyan', 'Daniello', 81969990, '1999-09-08', '2016-04-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (220287003, 'Davin', 'D''Cruze', 'Kelwick', 83866822, '1997-12-14', '2019-08-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (319857089, 'Catlee', 'Weson', 'Scupham', 85447095, '1986-07-05', '2016-05-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (104919551, 'Herbert', 'Tettley', 'Dallison', 83545026, '1982-11-19', '2016-01-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (173903292, 'Marissa', 'Gever', 'Argont', 80490557, '1997-09-10', '2015-06-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (179879907, 'Isis', 'Elloway', 'Boughey', 81295701, '1985-07-05', '2015-07-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (200915483, 'Ody', 'Wagge', 'Hitschke', 83299977, '1997-11-18', '2015-08-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (188904707, 'Carena', 'Lockwood', 'Firidolfi', 82091046, '1997-01-15', '2018-06-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (322568604, 'Brooks', 'Tuxill', 'Mechan', 81501746, '1994-01-06', '2018-11-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (375259483, 'Iver', 'Mobberley', 'Ebsworth', 83300441, '1995-07-30', '2015-01-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (304341946, 'Ivett', 'Andrus', 'Stede', 80203207, '1998-07-06', '2017-08-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (282801934, 'Leon', 'Lurriman', 'Poad', 83732758, '1994-08-24', '2015-03-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (360059144, 'Cale', 'Giacomoni', 'Jobb', 85298317, '1980-10-26', '2018-06-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (114713952, 'Winifred', 'Milier', 'Andriolli', 82115906, '1982-09-08', '2015-04-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (221835504, 'Brittany', 'Geydon', 'Somerfield', 83321577, '1981-05-02', '2015-02-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (180330934, 'Clevey', 'Figge', 'Hearty', 81784279, '1983-02-06', '2015-09-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (147671156, 'Karina', 'Northin', 'Gordge', 81398644, '1982-04-25', '2017-05-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (354508460, 'Rita', 'Abramowsky', 'Garter', 84219995, '1995-12-17', '2017-04-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (206079508, 'Prudi', 'Ballantine', 'Nice', 83184282, '1989-06-18', '2019-10-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (339616287, 'Karlie', 'Alasdair', 'Gooch', 85237315, '1987-11-05', '2018-07-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (256564148, 'Rosina', 'Howard - Gater', 'Richardon', 81616680, '1993-07-28', '2018-05-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (344269056, 'Belita', 'Disbrow', 'Jailler', 83899636, '1981-06-11', '2019-09-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (245480171, 'Delaney', 'Humpatch', 'Bravington', 83394784, '1996-10-30', '2015-02-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (364135975, 'Leonore', 'Braden', 'Rowlings', 83277773, '1995-07-04', '2016-12-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (201127354, 'Jozef', 'Ramsell', 'Wippermann', 82561434, '1989-08-04', '2018-09-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (203745304, 'Flory', 'Kliemke', 'Bootton', 80252862, '1984-11-19', '2017-06-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (250299438, 'Trude', 'Fendlow', 'Lemmers', 83998626, '1992-07-04', '2019-06-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (104212474, 'Armstrong', 'Delue', 'Arnefield', 80503579, '1985-10-03', '2019-02-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (197255647, 'Carol-jean', 'Guerry', 'Ollivierre', 83206215, '1996-12-27', '2016-11-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (162364444, 'Elladine', 'Kienl', 'Udell', 83213032, '1996-05-15', '2019-02-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (132191388, 'Maddalena', 'McVey', 'Ronnay', 80253779, '1985-01-21', '2016-05-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (203291791, 'Shaylynn', 'Ciobotaro', 'Veracruysse', 80792189, '1995-10-21', '2015-03-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (138468508, 'Gabriellia', 'Breach', 'Makepeace', 83621348, '1989-09-25', '2019-10-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (286587512, 'Chantalle', 'Splevin', 'Jansen', 84058355, '1989-01-31', '2019-07-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (339164793, 'Celine', 'McKeney', 'Grinter', 81785130, '1987-09-26', '2015-06-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (274809028, 'Shae', 'Morgon', 'Fenners', 82399245, '1989-09-16', '2016-03-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (146639998, 'Rea', 'De La Cote', 'Welch', 80667008, '1996-02-25', '2015-08-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (378861592, 'Patton', 'Thackeray', 'Mafham', 85420865, '2000-02-08', '2019-02-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (332018412, 'Bartholomeus', 'Lapsley', 'Carnduff', 80558737, '1982-01-21', '2016-09-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (225617543, 'Jeremie', 'Hellcat', 'Bart', 80195903, '1984-04-27', '2015-04-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (287565353, 'Granger', 'Vankov', 'Orteu', 83401269, '2000-07-18', '2016-09-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (146278407, 'Benedicta', 'Grayshan', 'Eich', 82211869, '1984-10-01', '2016-11-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (270283119, 'Silvanus', 'Rushmare', 'Allsep', 84126519, '1993-10-23', '2016-12-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (329726682, 'Karna', 'Oylett', 'Gomez', 82883060, '1993-05-29', '2015-08-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (346595298, 'Andromache', 'Saundercock', 'McElwee', 81093467, '1998-02-16', '2018-08-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (101859501, 'Hildegaard', 'Christmas', 'McGreil', 81048229, '1998-08-27', '2019-09-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (388586432, 'Nonna', 'Iacomelli', 'Haxley', 81684532, '1990-07-12', '2018-03-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (193513800, 'Osbert', 'Tadman', 'Robard', 80955296, '1983-04-04', '2019-02-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (289932703, 'Shirley', 'Ricioppo', 'Doohey', 81773874, '1988-08-10', '2017-10-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (387835798, 'Sarene', 'Berisford', 'Deplacido', 81490509, '1994-01-21', '2019-04-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (138941792, 'Estel', 'Wigmore', 'Persitt', 85431003, '1997-02-02', '2019-09-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (324332563, 'Rheta', 'Blazewski', 'Denning', 83579110, '1997-04-29', '2016-08-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (397631797, 'Tomaso', 'Merman', 'Oaks', 82334736, '1993-01-24', '2017-03-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (348656650, 'Maurita', 'Burton', 'Lambarton', 83980230, '1980-05-26', '2016-04-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (249214880, 'Evin', 'Swadon', 'McFarlan', 82748796, '1982-12-21', '2017-09-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (190952798, 'Simone', 'Hyde-Chambers', 'Longhirst', 81007924, '1988-10-25', '2016-01-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (390908619, 'Walton', 'Mourant', 'Alasdair', 85496251, '1995-01-28', '2018-08-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (347675178, 'Sallee', 'Rhodus', 'D''Ambrogi', 84015794, '1994-08-13', '2019-05-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (305884139, 'Jeramey', 'Hehir', 'Velti', 81793032, '1989-10-26', '2016-08-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (351013331, 'Alanson', 'Loutheane', 'Brumham', 81914076, '1999-04-02', '2017-01-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (394210456, 'Ranee', 'Hedde', 'Shirland', 85025180, '1988-08-30', '2018-04-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (329873721, 'Jelene', 'Curley', 'Eouzan', 84314382, '1986-12-03', '2019-11-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (128434338, 'Demetri', 'Colgan', 'Trewhela', 82969782, '1986-05-26', '2019-04-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (221153686, 'Milton', 'Bills', 'Raulston', 85343298, '1988-07-15', '2019-07-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (285943123, 'Kahlil', 'Clemensen', 'Fountain', 80878380, '1997-06-02', '2018-02-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (204637218, 'Francis', 'Guenther', 'Bellenie', 80617306, '1992-08-28', '2017-04-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (328849726, 'Aristotle', 'Solesbury', 'Arnoll', 83993259, '1998-08-08', '2018-07-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (371407546, 'Feliks', 'Dafter', 'Gallemore', 84889018, '1995-01-20', '2015-02-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (306100000, 'Bennie', 'Thirwell', 'Bouldon', 81319190, '1981-05-03', '2017-08-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (202030510, 'Serge', 'Dowthwaite', 'Nacci', 82442104, '1981-01-12', '2017-12-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (187651630, 'Mathew', 'Waymont', 'Dowbiggin', 84324476, '1991-05-12', '2015-01-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (295794549, 'Bettine', 'Dochon', 'Hucker', 83944213, '1995-03-16', '2019-03-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (273298264, 'Tann', 'Stevani', 'Chadderton', 82865164, '1997-08-31', '2019-09-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (188922764, 'Abelard', 'Holwell', 'Caulcott', 84274829, '1993-03-20', '2018-10-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (377488273, 'Hernando', 'Beggini', 'Duny', 84662594, '1989-03-24', '2018-01-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (389305641, 'Jarred', 'Blair', 'Neeves', 81928297, '1997-10-02', '2015-01-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (346364630, 'Amil', 'Brazer', 'Bare', 85045046, '1994-07-06', '2015-08-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (386209117, 'Maighdiln', 'Havock', 'Bartholin', 84550444, '2000-04-29', '2017-10-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (141830653, 'Filippo', 'Robarts', 'Cringle', 81725998, '1998-07-30', '2019-07-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (211735564, 'Gaelan', 'Szachniewicz', 'Guirardin', 81979747, '1988-01-04', '2016-02-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (244843706, 'Elicia', 'Stollwerk', 'Ridulfo', 84448567, '1998-03-25', '2016-01-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (161536800, 'Courtney', 'de Broke', 'Dee', 83886610, '1994-09-10', '2018-08-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (269166831, 'Waldon', 'Parlour', 'Niesegen', 82265023, '1981-09-02', '2016-12-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (172738808, 'Sheela', 'Caplis', 'Walkling', 84024713, '1983-01-05', '2017-10-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (108852757, 'Corine', 'Izaks', 'Rother', 83964124, '1990-05-29', '2018-03-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (255576190, 'Justus', 'Park', 'Coppard', 81389989, '1982-06-07', '2019-06-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (342818967, 'Dyanne', 'Ilyuchyov', 'Podd', 80277945, '2000-06-21', '2015-05-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (287258766, 'Aile', 'Keitley', 'Pollard', 83163111, '1993-07-14', '2019-05-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (393984769, 'Gianina', 'Walthall', 'Prazor', 81425773, '1996-07-30', '2016-05-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (341500937, 'Gerek', 'Toe', 'Rama', 83955624, '1995-12-21', '2018-04-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (397719650, 'Dian', 'Lewington', 'Vogele', 83164785, '1998-06-11', '2018-09-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (141606966, 'Coleen', 'Butterfint', 'Vanin', 83256647, '1999-11-22', '2017-12-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (258595524, 'Madelon', 'Henlon', 'Blatcher', 82815721, '1993-04-13', '2018-05-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (236400937, 'Hastie', 'Langmead', 'Birchall', 83205222, '1980-07-25', '2018-11-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (163141147, 'Brena', 'Vigours', 'Rikel', 81255955, '1993-03-10', '2017-12-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (217943184, 'Massimiliano', 'Spadari', 'Pinshon', 84021187, '1993-02-04', '2015-04-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (229527891, 'Dal', 'Cammiemile', 'Rubinovitsch', 83897742, '1994-05-16', '2018-06-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (137544443, 'Durward', 'McQuode', 'Silliman', 83767241, '1994-07-03', '2018-12-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (267068820, 'Hughie', 'Sauven', 'Rayne', 84937626, '1993-09-27', '2015-12-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (343294935, 'Howard', 'Wycliff', 'Sculley', 85410320, '1995-03-23', '2018-08-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (193745092, 'Rafael', 'Bwye', 'Gravy', 81884192, '1984-06-06', '2015-03-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (258122831, 'Nicolette', 'Ellgood', 'Grew', 80407780, '1992-07-05', '2016-04-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (305944695, 'Margi', 'Phelipeaux', 'Cleary', 81540595, '1990-10-06', '2018-02-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (359133971, 'Heather', 'Kristof', 'McNiven', 82320946, '1989-01-31', '2015-12-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (171732266, 'Lauree', 'Cheese', 'McIllroy', 80768387, '1992-06-11', '2015-06-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (382837379, 'Cyb', 'Van de Velde', 'Crozier', 85436296, '1999-05-28', '2019-06-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (161053233, 'Gabbi', 'Lashmar', 'Berthe', 82929648, '1984-01-07', '2017-06-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (324389398, 'Marietta', 'Checchetelli', 'Coste', 83518556, '1992-08-25', '2019-09-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (396245134, 'Vito', 'Maudlen', 'Skehan', 80203933, '1980-08-22', '2015-02-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (181482798, 'Garwood', 'Scatchard', 'Tincey', 84927801, '1995-08-16', '2016-08-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (289781586, 'Bee', 'O''Sharry', 'Fullun', 81465942, '1992-01-05', '2017-11-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (318500127, 'Beckie', 'Ivanishin', 'Longea', 85243448, '1985-11-21', '2018-09-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (278454807, 'Dinah', 'Costar', 'Broadey', 83064638, '1989-11-17', '2016-08-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (294584290, 'Eulalie', 'Cowley', 'McLauchlin', 82600875, '1995-05-27', '2019-04-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (293339718, 'Rock', 'Roscam', 'Skunes', 82771921, '1993-09-29', '2017-07-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (103982585, 'Meg', 'Myner', 'Aldred', 84322891, '1993-09-27', '2017-07-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (270337535, 'Ingmar', 'Vasyunichev', 'Awdry', 82416987, '1992-03-06', '2016-10-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (191672017, 'Worthington', 'Jeandet', 'Ovendale', 80379686, '1987-09-01', '2018-09-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (348543128, 'Melony', 'Mullord', 'Benaine', 80854524, '1987-06-07', '2019-01-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (209765633, 'Danyette', 'Skipworth', 'Maddyson', 83442517, '1980-03-23', '2016-02-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (231371861, 'Bar', 'Frede', 'Dougary', 85365082, '1980-06-28', '2015-08-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (387050819, 'Rorie', 'Housden', 'Billingham', 80621872, '1980-02-15', '2016-11-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (357326202, 'Evy', 'Chess', 'Daughton', 82570898, '1989-04-02', '2019-10-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (306736899, 'Salomone', 'Kilbourn', 'Copp', 81210817, '1996-08-15', '2015-10-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (206273133, 'Brit', 'Clausson', 'Kempstone', 81846459, '1993-08-21', '2017-12-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (128730628, 'Penny', 'Naismith', 'Lennox', 82571284, '1985-02-06', '2018-06-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (347936693, 'Trish', 'Swannell', 'Burberye', 83998827, '1989-05-14', '2016-06-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (121767500, 'Gerard', 'Shorthill', 'Camell', 81097701, '1990-03-12', '2015-12-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (104328369, 'Kirsten', 'Eckhard', 'Petracci', 82553906, '1980-07-16', '2016-12-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (287771529, 'Olympia', 'Oliphard', 'Sipson', 83224481, '1996-03-05', '2018-01-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (315543029, 'Gae', 'Brogioni', 'Norcott', 85274773, '1998-11-30', '2015-09-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (120342852, 'Jasmin', 'De Filippo', 'Tewes', 85446109, '1995-06-24', '2016-11-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (263817726, 'Lief', 'Rentoll', 'McNellis', 82518919, '1989-12-04', '2018-08-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (373630890, 'Donaugh', 'Crossthwaite', 'Watkiss', 83464647, '1986-01-05', '2019-07-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (343846163, 'Lissa', 'Creevy', 'Freyne', 81109317, '1999-05-03', '2015-03-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (153589694, 'Devin', 'Menear', 'Romand', 82458137, '1985-08-15', '2016-10-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (229676718, 'Jessamine', 'Slevin', 'Stanger', 84460288, '1992-03-31', '2016-10-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (191083984, 'Stefano', 'Shelbourne', 'Gabbatt', 81517205, '1993-08-23', '2015-06-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (170251411, 'Townie', 'Eliet', 'Shermore', 83840212, '1983-07-14', '2016-06-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (116912425, 'Patricia', 'Potts', 'Scrowston', 84863488, '1993-03-26', '2018-08-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (295200345, 'Amanda', 'Jenicke', 'Waren', 81433871, '1992-05-23', '2016-12-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (274164142, 'Stan', 'Byron', 'Marner', 82592001, '1991-04-01', '2018-12-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (348222205, 'Leon', 'Collecott', 'Jantet', 83237624, '1988-11-07', '2015-06-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (164562533, 'Davita', 'Greguol', 'Kennefick', 84246730, '1991-09-25', '2015-01-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (163703671, 'Fancie', 'O''Connel', 'Skevington', 82913791, '1991-04-04', '2017-01-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (228287801, 'Patin', 'Sabater', 'Bedinn', 80453809, '1982-04-30', '2016-02-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (303283382, 'Harlan', 'Visco', 'Dorot', 85117486, '1999-12-24', '2015-10-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (114067969, 'Marty', 'Lansley', 'Kydde', 83409155, '1983-04-30', '2019-02-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (118820226, 'Kingston', 'Hugh', 'Gandar', 83339397, '1985-06-28', '2017-03-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (371423217, 'Penny', 'Crosbie', 'Fowler', 82350994, '1992-01-10', '2016-10-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (282615375, 'Brit', 'Kaysor', 'Room', 85027039, '1997-01-31', '2015-11-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (238988519, 'Caron', 'Jays', 'Batt', 81738317, '1988-11-13', '2017-04-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (124044599, 'Gusella', 'Napper', 'Outram', 84190519, '1987-09-25', '2019-07-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (338433070, 'Ursulina', 'Axby', 'Raper', 80162641, '1987-11-01', '2017-03-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (254888476, 'Celinka', 'Landre', 'Honsch', 80657681, '1994-08-29', '2016-04-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (253460243, 'Jerri', 'Helder', 'Simmers', 83888250, '1992-12-24', '2019-10-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (132437169, 'Der', 'Pearton', 'Keays', 84512901, '1992-02-21', '2016-06-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (349337618, 'Ali', 'Cosans', 'Le Blond', 83473388, '1983-03-25', '2016-01-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (191827750, 'Dale', 'Keedy', 'Murden', 84795257, '1999-12-10', '2019-10-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (160158682, 'Bevvy', 'Friberg', 'Dunbleton', 85246036, '1993-02-15', '2017-06-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (373878148, 'Leo', 'Erricker', 'Dorgan', 84677410, '1984-03-22', '2016-01-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (161808305, 'Merry', 'Mazonowicz', 'Ciardo', 81877218, '1999-05-05', '2017-02-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (275021020, 'Eziechiele', 'Langfitt', 'Lemon', 84055183, '1997-04-25', '2016-03-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (224921147, 'Kathe', 'Vedeshkin', 'O''Hollegan', 84355072, '1980-01-21', '2016-06-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (382912541, 'Katina', 'MacKellar', 'Waring', 83728192, '1995-11-11', '2015-09-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (185383002, 'Giavani', 'Colvine', 'Wandrach', 81636969, '1992-10-15', '2018-12-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (318774479, 'Bastian', 'Scopes', 'Pike', 81410878, '1987-10-18', '2018-01-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (185166843, 'Cathe', 'Beardsell', 'Graeser', 80074771, '1981-10-07', '2018-05-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (148912337, 'Davie', 'De Robertis', 'Adolphine', 82215642, '1980-10-26', '2015-04-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (277457081, 'Elihu', 'Rawet', 'Balsdone', 85042119, '1983-07-29', '2018-11-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (384285793, 'Fraze', 'Wilkie', 'Sizeland', 83696623, '1998-10-01', '2016-05-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (223899819, 'Barbi', 'Madgett', 'Langelay', 84416078, '1995-07-28', '2017-01-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (365732310, 'Merrill', 'Pulhoster', 'Brandolini', 83919385, '1995-10-15', '2015-08-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (292363371, 'Algernon', 'Freddi', 'Ashfold', 84261327, '1993-05-21', '2017-08-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (251991891, 'Deonne', 'Crickmer', 'Shasnan', 81693067, '1981-11-11', '2017-09-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (144760086, 'Lonni', 'Ailsbury', 'Scay', 82168211, '1996-07-25', '2017-04-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (139194997, 'Rickey', 'Cliss', 'Purvis', 80333955, '1998-10-31', '2017-09-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (334478899, 'Ramon', 'Killich', 'Edgecumbe', 85365096, '1998-05-11', '2018-12-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (329555623, 'Abby', 'Kinde', 'Della', 81311125, '1982-07-05', '2018-09-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (208002819, 'Maurie', 'Lamcken', 'Wingeat', 85246560, '1998-08-21', '2015-03-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (225647422, 'Kariotta', 'Boshere', 'Legg', 81167008, '1998-10-30', '2016-06-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (165026554, 'Lorrie', 'MacNamara', 'Lake', 80896884, '1997-03-09', '2019-01-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (155477802, 'Lindsey', 'Goulthorp', 'Dispencer', 84550519, '1993-11-15', '2018-07-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (103135023, 'Virgil', 'Bunney', 'Losseljong', 83889958, '1992-01-30', '2015-03-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (213078082, 'Bondie', 'Newcomen', 'Mathys', 80898761, '1983-07-06', '2015-08-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (337939918, 'Glynis', 'Swaby', 'Gumb', 82966014, '1993-01-13', '2017-07-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (160252041, 'Bellanca', 'Kindall', 'Delafoy', 85104842, '1980-10-14', '2016-04-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (180159208, 'Morse', 'Lapley', 'Doughtery', 81157245, '1983-07-24', '2015-09-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (324029847, 'Jenifer', 'Billes', 'Reder', 83982171, '1990-04-16', '2016-09-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (367384799, 'Charita', 'Vogelein', 'Osan', 80098690, '1985-09-07', '2019-06-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (363608328, 'Horten', 'Baigent', 'Thew', 80428364, '1986-01-24', '2019-06-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (336197079, 'Lynette', 'Santino', 'Fountain', 82429897, '1984-01-26', '2018-08-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (339896041, 'Viole', 'Yaxley', 'MacAlester', 82232116, '1999-04-20', '2018-09-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (281728603, 'Joaquin', 'Hallad', 'Caesmans', 82207170, '1999-07-01', '2017-05-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (262847005, 'Marianna', 'Snooks', 'Lidgate', 81305206, '1994-10-07', '2018-06-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (168974259, 'Ossie', 'Harcus', 'Golton', 80239030, '1989-08-07', '2015-03-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (281299301, 'Crysta', 'Stennett', 'Sarrell', 84353549, '1985-07-16', '2018-04-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247747515, 'Edna', 'Huncoot', 'Wistance', 81229793, '1990-06-23', '2016-11-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (271037859, 'Micheil', 'Chevers', 'Saulter', 82564998, '1995-10-12', '2016-12-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (386757787, 'Barbi', 'Conrad', 'Haythornthwaite', 82303958, '1995-11-09', '2015-10-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (342114761, 'Franny', 'Hiskey', 'Wille', 82300031, '1992-03-29', '2016-07-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (191597145, 'Cicily', 'Livermore', 'Mohring', 84815293, '1982-01-28', '2015-08-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (127574199, 'Camilla', 'Dunsmuir', 'Mayhead', 83571078, '1992-04-05', '2015-12-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (329393383, 'Viviyan', 'Dodds', 'Hardway', 80574057, '1996-05-13', '2018-11-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (181447183, 'Banky', 'Dumbleton', 'Rubee', 80100611, '1991-02-16', '2019-06-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (272238880, 'Danielle', 'Isard', 'Fanstone', 81303089, '1986-10-19', '2017-04-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (272785076, 'Herta', 'Dollar', 'Oldridge', 81026922, '1995-07-15', '2016-09-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (229032866, 'Theresa', 'Hamstead', 'Scramage', 85340496, '1983-07-02', '2015-09-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (329708174, 'Panchito', 'Tallow', 'Shale', 80209709, '1980-03-12', '2017-02-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (372315861, 'Erick', 'Mapplebeck', 'Primrose', 80112009, '1989-11-06', '2019-08-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (308741871, 'Celie', 'Kayley', 'Hammand', 83079034, '1993-02-08', '2019-04-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (265563964, 'Caritta', 'Borge', 'Hallewell', 85044482, '1985-09-01', '2016-06-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (382755724, 'Redd', 'Hintzer', 'Dulanty', 84226725, '2000-09-10', '2018-10-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (209835390, 'Elizabeth', 'Madison', 'Gozney', 81957021, '1989-10-16', '2017-06-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (292824948, 'Jenn', 'Sigward', 'Todeo', 80850824, '1991-10-03', '2015-10-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (189379920, 'Julio', 'Doumerc', 'Stockell', 85114730, '1999-04-10', '2017-12-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (122979984, 'Ruthe', 'Dowles', 'MacGillreich', 81523259, '1980-07-21', '2015-10-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (193861405, 'Shandy', 'Copozio', 'Harper', 84081968, '1996-05-24', '2017-04-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (166692165, 'Auberta', 'Grimston', 'Sturgeon', 82504134, '1995-10-23', '2018-04-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (260777372, 'Willard', 'Ogles', 'Strothers', 80559028, '1998-01-23', '2018-11-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (219444286, 'Marielle', 'Wolland', 'Purdom', 82852579, '1993-03-24', '2019-01-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (265728059, 'Dolley', 'Tansey', 'Lanbertoni', 85045206, '1998-08-08', '2018-03-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (285349790, 'Kathy', 'Cominoli', 'Pretti', 83702254, '1990-06-07', '2019-10-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (157665259, 'Nerty', 'Pouck', 'Fellgate', 82050860, '1987-09-24', '2016-01-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (130250997, 'Belva', 'Sallans', 'Hupe', 85455720, '1997-03-18', '2017-03-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (209490257, 'Jordan', 'Cordie', 'Colnett', 83668732, '1988-07-11', '2018-02-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (377399954, 'Merle', 'Meadley', 'Benedito', 84681232, '1997-05-10', '2016-09-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (323787106, 'Quinn', 'McDade', 'Matteotti', 83612880, '1980-06-02', '2016-10-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (303844426, 'Farlay', 'de Savery', 'Jurgenson', 82063394, '1984-06-23', '2018-12-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (214418267, 'Jamie', 'Crusham', 'Stonehewer', 83312604, '1982-02-17', '2018-11-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (216112249, 'Lynnell', 'Kingsnod', 'Lafflina', 82941815, '1980-01-30', '2019-11-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (138531299, 'Lazarus', 'Meriguet', 'Chatelot', 84101874, '1995-01-28', '2019-01-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (226233617, 'Launce', 'Fydoe', 'Essam', 84597131, '1999-11-03', '2015-01-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (109741008, 'Iain', 'Osgerby', 'Lynnett', 85391975, '1987-05-22', '2019-07-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (223174323, 'Aeriell', 'Wiltshear', 'Innott', 84175779, '1982-12-21', '2018-04-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (226611748, 'Raymund', 'Stickley', 'MacNally', 81476257, '1982-07-21', '2018-03-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (112913857, 'Alfie', 'Romans', 'Rossbrook', 80782396, '1996-08-06', '2018-04-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (241442467, 'Heinrick', 'Lacheze', 'Deas', 82471639, '1981-02-13', '2015-03-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (391252205, 'Penni', 'Alderson', 'Varns', 83802296, '1980-05-09', '2017-08-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (390037867, 'Putnam', 'Muat', 'Crippen', 82819386, '1995-03-03', '2018-03-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (183104271, 'Leshia', 'Pengelly', 'Venable', 84543378, '1992-12-08', '2015-11-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (110611280, 'Cinda', 'Petroulis', 'Vasiliu', 83702970, '1984-05-13', '2018-03-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (120901295, 'Enrichetta', 'Brunt', 'Faiers', 83008395, '1982-11-24', '2016-06-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (292930733, 'Charla', 'Tock', 'Macewan', 85222347, '1988-04-14', '2016-05-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (375203645, 'Ellery', 'Spry', 'Gaylord', 81326262, '1982-09-28', '2015-08-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (148870434, 'Verla', 'Lund', 'Markey', 80800854, '1998-01-10', '2017-03-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (326713025, 'Minnaminnie', 'Angel', 'Nicholls', 80126024, '1991-11-14', '2018-10-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (194452616, 'Sammy', 'Lammert', 'Learmont', 83542656, '1986-03-21', '2019-01-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (197894941, 'Brittne', 'Gravells', 'Sherrett', 83445253, '1984-10-31', '2019-01-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (214041096, 'Rubia', 'Meachan', 'Neild', 85033904, '1999-10-30', '2016-10-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (309390775, 'Charissa', 'Mailes', 'Sekulla', 82600044, '1994-04-11', '2019-08-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (166398782, 'Letitia', 'Winkett', 'Ludwig', 84106048, '1988-07-29', '2017-09-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (318261659, 'Emilia', 'Kerfod', 'Rousel', 84913779, '1982-03-16', '2015-02-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (123153812, 'Marne', 'Hiscoke', 'Alves', 82088617, '1991-04-09', '2018-02-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (268065652, 'Linnell', 'Becken', 'Fery', 83312274, '1988-10-13', '2015-08-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (149998513, 'Yance', 'Breedy', 'Webber', 84120250, '1984-05-30', '2018-03-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (378471065, 'Sergeant', 'Prettyjohns', 'Arrighetti', 82066241, '1983-12-31', '2019-02-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (216591675, 'Kirsteni', 'Soggee', 'McGlaughn', 82022023, '1993-07-14', '2015-06-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (227789951, 'Sydel', 'Gallear', 'Pinson', 84615479, '2000-05-10', '2015-03-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (333824066, 'Shaylynn', 'Callaby', 'Armitt', 82497229, '2000-11-10', '2017-11-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (231560300, 'Mitchell', 'Curtoys', 'Mccaull', 82805655, '1983-05-29', '2015-06-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (231150100, 'Bobine', 'Le Provost', 'Busswell', 80769172, '1999-11-22', '2017-02-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (230630117, 'Brodie', 'Hansed', 'McTurley', 82404808, '1991-01-10', '2015-10-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (158294821, 'Mariann', 'Matysiak', 'Bengal', 84528186, '1996-06-22', '2016-01-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (344865206, 'Kore', 'Cyseley', 'Huonic', 84996298, '1986-03-31', '2017-05-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (307152006, 'Ogdon', 'Hustings', 'Olivier', 84177705, '1982-09-23', '2015-11-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (171408410, 'Ev', 'Lorkings', 'Kenneford', 84690122, '1985-12-06', '2016-07-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (186959006, 'Harriot', 'Villaron', 'Whittle', 82796999, '1998-10-07', '2018-05-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (236035982, 'Eloise', 'Vallerine', 'Ryce', 81511625, '1988-11-02', '2018-02-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (382550315, 'Cyrille', 'Gittose', 'Hazelhurst', 83990545, '1992-09-19', '2018-02-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (391709327, 'Alice', 'Norcott', 'Ebbin', 80885838, '1988-10-29', '2016-04-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (316853743, 'Byrom', 'Veronique', 'Cruse', 84849916, '1990-01-12', '2017-03-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (279653446, 'Uriah', 'Elmar', 'Fleischer', 80777300, '1993-01-30', '2018-03-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (163310390, 'Happy', 'Ruffey', 'Pobjoy', 80304250, '1988-06-01', '2018-12-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (287500000, 'Nial', 'Brockherst', 'Randleson', 81903537, '1988-12-18', '2018-01-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (304980769, 'Saba', 'de Savery', 'Hatterslay', 83923486, '1987-11-09', '2017-10-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (374302643, 'Will', 'Goodreid', 'Behninck', 82428284, '1996-11-15', '2017-07-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (270666019, 'Roberta', 'Mountford', 'Schule', 85012187, '1986-09-13', '2015-07-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (381134444, 'Hughie', 'Mendez', 'Gobel', 83341562, '1986-05-03', '2017-03-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (143871859, 'Clarisse', 'Veracruysse', 'Coddrington', 82709542, '1994-07-20', '2015-07-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (305373396, 'Cecilio', 'Demangel', 'Clampe', 84637798, '1996-05-18', '2016-11-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (163411942, 'Matilde', 'Karpenko', 'Welbourn', 82511053, '1986-03-08', '2015-05-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (241695427, 'Calli', 'Abramino', 'Heyburn', 82175285, '1986-12-19', '2018-05-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (104027123, 'Pammy', 'Taffs', 'Medway', 82774233, '1981-11-12', '2018-04-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (143483170, 'Minette', 'Sadgrove', 'Dwire', 83986867, '1990-01-21', '2018-12-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (381880734, 'Reilly', 'Garrand', 'Scougal', 84949761, '1984-02-08', '2018-12-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (135621981, 'Shandra', 'Hubeaux', 'Shovelin', 84937967, '1997-06-21', '2017-11-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (367072372, 'Haily', 'Capinetti', 'Hatherley', 83011060, '1998-08-01', '2015-10-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (192247874, 'Nora', 'Langdridge', 'Flewan', 80694457, '1994-04-09', '2017-03-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (376708324, 'Parker', 'Bilofsky', 'Dixson', 82456343, '1999-07-02', '2018-12-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (245275063, 'Kristo', 'Wycliffe', 'Annetts', 83178569, '1995-11-05', '2017-07-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (160924858, 'Horst', 'Millhill', 'Seakings', 83407404, '1993-11-16', '2016-08-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (391099403, 'Barbey', 'Queen', 'Winsley', 84248724, '1983-05-28', '2016-02-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (296627165, 'Gawain', 'Wankel', 'Durnill', 83846709, '1993-05-12', '2018-11-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (137977140, 'Corbin', 'Bellon', 'Mullins', 80280573, '1983-01-14', '2015-02-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (232676779, 'Killian', 'Ducham', 'Tankin', 83407591, '1980-12-25', '2017-12-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (358783383, 'Graham', 'Wegener', 'Stranieri', 84319019, '1992-09-25', '2017-12-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (195239544, 'Haley', 'Enterlein', 'Gheorghie', 85258187, '1998-11-07', '2019-09-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (130525987, 'Thia', 'Templar', 'Shark', 83007412, '1998-05-03', '2016-11-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (104699674, 'Emmott', 'Purvey', 'Vynehall', 81691357, '1998-03-11', '2015-06-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (112347457, 'Arlin', 'Chomicki', 'Tollfree', 83269215, '1988-06-30', '2019-07-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (185438226, 'Katti', 'Burhill', 'Dyka', 81410366, '1999-07-29', '2016-03-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (300312777, 'Jack', 'Tombleson', 'Threadkell', 83958361, '1996-11-01', '2018-04-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (366622027, 'Essy', 'Mulcaster', 'Melley', 80456756, '1988-12-21', '2017-12-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (338367155, 'Cletis', 'Urwin', 'Camerana', 80818267, '1999-04-16', '2017-01-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (150472940, 'Trenton', 'Segge', 'Vines', 83955457, '1984-06-21', '2015-11-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (294185984, 'Blake', 'Brands', 'Dowgill', 84190664, '1989-10-20', '2016-12-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (119102034, 'Rabbi', 'Agostini', 'Brickham', 81839704, '1993-09-29', '2015-03-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (117265255, 'Allin', 'Fitt', 'Yapp', 83966633, '2000-08-14', '2015-05-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (391313799, 'Kary', 'Wooland', 'Stuchberry', 80999776, '1998-12-11', '2016-05-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (294745657, 'Korie', 'Boxer', 'Shevlane', 85260170, '1982-10-23', '2018-02-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (353619001, 'Clari', 'Cowans', 'Bisset', 83472649, '1984-11-09', '2018-12-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (381016551, 'Jeannie', 'Kinnaird', 'Degue', 83249205, '1999-02-11', '2017-12-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (252851427, 'Jessie', 'Wyborn', 'Steynor', 82476219, '1987-05-16', '2017-02-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (194321003, 'Else', 'Sammes', 'Noe', 80612724, '1994-09-17', '2019-01-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (270608625, 'Gui', 'Medwell', 'Yegorkov', 82633246, '1985-09-06', '2015-08-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (380994161, 'Herculie', 'Stilliard', 'Fattorini', 85383733, '1994-12-20', '2015-09-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (148319832, 'Kriste', 'Jest', 'Swindells', 84738621, '1987-09-17', '2019-02-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (330633252, 'Marwin', 'Cale', 'Ruffy', 82090066, '1981-09-24', '2019-03-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (281621797, 'Matthieu', 'Daynter', 'Jochanany', 84930377, '1996-02-17', '2016-05-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (275057305, 'Elnora', 'Peggram', 'Grooby', 82819795, '1981-02-11', '2015-09-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (379541331, 'Archibaldo', 'Bowkett', 'Domnick', 83090852, '1980-10-27', '2015-03-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (384669577, 'Becky', 'Balding', 'Caton', 83857561, '1997-11-21', '2018-11-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (381690292, 'Donalt', 'Defew', 'Kleinlerer', 83337030, '1990-06-08', '2015-12-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (326516798, 'Ravi', 'Grogor', 'Dibbs', 81947930, '1990-05-07', '2016-11-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (321859392, 'Griz', 'Cookley', 'Zanolli', 84831892, '1993-11-19', '2018-07-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (241592622, 'Kurt', 'Sokale', 'McBean', 80831670, '1984-06-16', '2015-05-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (141795342, 'Erek', 'Bedow', 'Fritche', 83733679, '1995-01-06', '2017-11-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (123040131, 'Law', 'Chamberlain', 'Brandenberg', 83563950, '1996-10-11', '2016-05-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (100787151, 'Sydney', 'Mathew', 'Cobbe', 84461910, '1982-10-23', '2019-01-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (182659711, 'Annelise', 'Shevill', 'Tomisch', 80169131, '1997-07-12', '2016-09-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (153756296, 'Jackie', 'Ducastel', 'McParlin', 82934108, '1986-08-24', '2015-10-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (177419649, 'Dela', 'Ost', 'Evreux', 80950450, '1990-04-18', '2019-07-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (216328795, 'Adelaide', 'Torres', 'Danels', 80265246, '1997-03-02', '2017-06-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (367809169, 'Jessie', 'Hysom', 'Greenland', 85371311, '1985-03-29', '2015-07-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (248877346, 'Nevil', 'Gildersleaves', 'Summerly', 80328742, '1995-05-17', '2017-09-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (146436060, 'Clarie', 'Bradburne', 'Matzke', 82553914, '1989-08-12', '2016-10-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (377054171, 'Rhianon', 'Jaquest', 'Adcock', 85475713, '1990-11-03', '2015-04-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (298566804, 'Philomena', 'Benkhe', 'Beedie', 82037618, '2000-09-04', '2016-02-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (396947979, 'Maribelle', 'Cuzen', 'MacTrusty', 83430298, '1990-07-30', '2016-07-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (384641946, 'Roy', 'Eckford', 'Waghorn', 82463838, '1998-12-14', '2017-05-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (258714630, 'Abran', 'Shrieves', 'Dalbey', 80624987, '1996-07-26', '2018-02-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (124738817, 'Even', 'Faldoe', 'Burch', 80013487, '1985-12-20', '2018-08-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (178536750, 'Alano', 'Fanthom', 'Billyard', 84287610, '1988-03-17', '2015-08-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (339924836, 'Johnathan', 'Gilston', 'Vasile', 83223112, '1981-04-17', '2016-03-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (149176915, 'Eileen', 'Trevillion', 'Ling', 81353393, '1988-08-01', '2015-08-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (234920175, 'Flint', 'Tackley', 'Adamini', 80280107, '1983-06-01', '2016-02-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (362454089, 'Thomasa', 'Pratty', 'Fullerton', 82373986, '1999-03-02', '2018-03-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (303918441, 'Shirley', 'Siggens', 'Edgehill', 81399985, '1988-06-25', '2018-04-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (197827029, 'Sherwin', 'Kacheler', 'Sargint', 82369764, '1983-05-12', '2018-11-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (133612467, 'Edmund', 'Stanwix', 'Cudbird', 85041739, '2000-04-01', '2017-09-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (396923253, 'Markos', 'Ragbourn', 'Golley', 81296750, '1984-10-09', '2018-10-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (394610898, 'Umeko', 'Maysor', 'Melmoth', 81542334, '1984-04-30', '2019-10-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (268592305, 'Meridith', 'Deplacido', 'Horley', 80959485, '1991-08-19', '2017-11-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (314364792, 'Faustine', 'Steen', 'Rosenhaus', 82996500, '1982-08-05', '2018-06-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (373291421, 'Barby', 'Platt', 'Milnthorpe', 83022134, '1984-05-19', '2018-07-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (284125403, 'Etti', 'Goodrum', 'Matteucci', 85291757, '1985-10-01', '2017-05-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (211142494, 'Ninette', 'Semrad', 'Matteoli', 83697392, '1981-12-22', '2017-12-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (242097801, 'Sheena', 'Guard', 'Allridge', 80217449, '1993-06-16', '2015-02-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (141823095, 'Kimberlyn', 'Bowmen', 'Dory', 81574497, '1995-09-08', '2018-06-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (305247739, 'Gilli', 'Drakes', 'Kettell', 82575205, '1984-04-28', '2019-10-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (203257936, 'Gerry', 'Benne', 'Muzzollo', 81291878, '1987-04-07', '2016-07-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (196285673, 'Linoel', 'Hardes', 'Davey', 81524426, '1985-04-21', '2018-05-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (100472315, 'Kai', 'Hawler', 'Swaile', 84966263, '1980-12-10', '2019-07-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (269193978, 'Dominique', 'Glavis', 'Scruton', 84805565, '1986-01-18', '2019-06-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (157528816, 'Kerri', 'Harle', 'Kenyam', 84663969, '1993-11-04', '2019-02-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (288510895, 'Wylma', 'Becerra', 'Lutsch', 80411880, '1985-11-08', '2016-06-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (123733203, 'Rosetta', 'Ledgeway', 'Souter', 80394177, '1992-05-29', '2017-06-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (298420105, 'Johnathon', 'Chaldecott', 'Addey', 82184701, '1997-12-03', '2015-02-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (364646380, 'Stanton', 'Constantine', 'Balcock', 81920993, '1980-11-26', '2018-07-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (136408218, 'Zarah', 'Arton', 'Bennett', 81109164, '1999-04-17', '2016-02-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (214245715, 'Gabby', 'Bellamy', 'Loughlin', 82400592, '1990-03-30', '2019-08-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (265602353, 'Rica', 'Mair', 'Grantham', 80531855, '1999-07-20', '2019-02-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (374417201, 'Goldy', 'Peal', 'Brettel', 82798747, '1997-10-12', '2018-02-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (218243557, 'Othella', 'Kitson', 'Heaney', 83017619, '1997-02-05', '2019-03-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (236335035, 'Wanda', 'Eldrid', 'Sturges', 82760362, '1985-07-23', '2018-04-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (244748266, 'Keefe', 'Marushak', 'Mickan', 81695364, '1985-10-15', '2018-10-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (284983338, 'Rodolph', 'Babb', 'Harold', 82953122, '1991-07-15', '2017-07-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (273069583, 'Abramo', 'Menichelli', 'Gyurkovics', 82197213, '1993-05-15', '2019-06-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (357004092, 'Pearl', 'Cryer', 'Hollow', 82594806, '1999-03-03', '2017-04-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (341329693, 'Eugene', 'Bashford', 'Stainer', 81562100, '1988-01-18', '2019-10-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (196129356, 'Breena', 'Attle', 'Bispo', 84089536, '1987-08-20', '2015-09-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (256910627, 'Philippine', 'Bess', 'Vigneron', 84601589, '1993-08-05', '2015-07-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (131068683, 'Nickolai', 'Conant', 'Stollenhof', 85440970, '1981-09-17', '2019-03-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (143882683, 'Leslie', 'Emmanueli', 'Zarfat', 84970800, '1982-01-13', '2017-12-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (152213432, 'Flynn', 'Biaggelli', 'Preto', 85243897, '1984-06-29', '2016-10-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (353849928, 'Ashil', 'Fost', 'Lancett', 84176950, '1992-12-03', '2015-12-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (360290846, 'Korry', 'Hearson', 'Mickan', 83075652, '1980-09-28', '2018-08-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (245583263, 'Kylila', 'Stores', 'Wheildon', 83557777, '1987-10-19', '2015-03-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (344189972, 'Nicola', 'Pierri', 'McErlaine', 84892176, '1994-12-19', '2019-05-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247034960, 'Ragnar', 'Jozefczak', 'Baldini', 83880376, '1998-08-30', '2017-04-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (322605147, 'Abbey', 'Roffe', 'Crichmere', 82922006, '1981-10-31', '2016-01-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (198423033, 'Goldia', 'Guerreiro', 'Spensley', 82390098, '1994-10-27', '2015-01-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (271058394, 'Adrea', 'Le Marquis', 'Briatt', 81032309, '2000-07-06', '2018-09-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (257598407, 'Milzie', 'Belderson', 'Busen', 85099044, '2000-04-05', '2019-04-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (181257087, 'Mattie', 'Harbison', 'Gallaher', 84557427, '1996-09-03', '2016-10-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (285546359, 'Nicolai', 'Probart', 'Whiting', 80896176, '1981-09-03', '2017-05-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (203955647, 'Chloe', 'Westbrook', 'Mackieson', 82771187, '1987-09-12', '2018-04-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (221518561, 'Elwin', 'Gerckens', 'Copland', 80965116, '1991-04-11', '2015-01-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (172938389, 'Ernestine', 'Hulme', 'Shimwall', 82745510, '1983-11-25', '2015-08-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (385152999, 'Raymond', 'Forlonge', 'Wordsley', 83418003, '1983-09-06', '2017-06-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (106275339, 'Burke', 'Thistleton', 'Pucknell', 85432143, '1989-12-28', '2018-07-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (396582862, 'Kayley', 'Hurling', 'Kittoe', 85066845, '1997-11-25', '2015-04-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (317766471, 'Torie', 'Oakeby', 'Pilsworth', 83258973, '1995-09-27', '2017-12-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (113125275, 'Ollie', 'Woolfoot', 'Wolfenden', 80507177, '1991-08-14', '2017-02-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (389751590, 'Terrie', 'Spiring', 'Eyden', 83993923, '1985-09-07', '2017-02-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (199675285, 'Keir', 'Springle', 'Romanetti', 80270828, '1984-08-06', '2015-02-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (305064951, 'Rudyard', 'Gundrey', 'Willbraham', 81994473, '1994-07-22', '2015-06-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (129604345, 'Kinsley', 'Ketts', 'Josey', 81285162, '1984-07-21', '2017-02-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (175231998, 'Tab', 'Cowperthwaite', 'Eede', 80022745, '1997-09-02', '2017-02-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (375408381, 'Goldie', 'Henken', 'Charrington', 81129054, '1995-09-29', '2015-06-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (137872099, 'Ozzie', 'Boundley', 'Casetti', 82323528, '1985-05-18', '2016-06-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (159683539, 'Lorena', 'Hinrich', 'Limeburner', 84088685, '1995-01-24', '2016-05-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (263247922, 'Oliy', 'Gaskarth', 'Coope', 82079582, '1994-06-26', '2018-07-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (367019316, 'Conan', 'Menendez', 'Armer', 83616260, '1992-11-19', '2018-09-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (353518542, 'Georgina', 'Nisco', 'Oldall', 81489568, '1988-07-15', '2015-11-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (395983134, 'Cristobal', 'Jelly', 'Skeel', 80034963, '1992-05-13', '2018-01-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (109909702, 'Gwenneth', 'Noah', 'Theurer', 82926576, '1983-09-02', '2016-10-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (148242524, 'Robenia', 'McLagain', 'O''Neal', 84203847, '1986-01-08', '2015-07-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (157307969, 'Ichabod', 'Snoddin', 'Brazel', 83187801, '1984-12-21', '2015-04-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (346728102, 'Willy', 'Longfut', 'Leneve', 81415480, '1994-05-31', '2016-12-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (136924361, 'Goldi', 'Laird', 'Cool', 83289986, '1994-07-02', '2017-07-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (276723093, 'Lonni', 'Choake', 'Dermott', 82532790, '1998-05-07', '2017-07-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (278279769, 'Elka', 'Richings', 'Bielfelt', 83178149, '1985-07-08', '2019-10-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (286339224, 'Vanda', 'Surcomb', 'Lobell', 84563548, '1993-08-23', '2017-08-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (150629591, 'Sadie', 'Choulerton', 'Woodvine', 81897539, '1998-03-10', '2016-05-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (279863020, 'Gavin', 'Hanshawe', 'Poff', 81352738, '1989-01-03', '2017-11-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (140957638, 'Kandace', 'Lashford', 'Guirau', 83362012, '1984-08-15', '2019-11-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (210920240, 'Arnaldo', 'Barcke', 'Dunstall', 81906090, '2000-08-01', '2017-12-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (144001022, 'Baron', 'Durbyn', 'Trehearne', 80532418, '1981-03-03', '2018-01-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (217989763, 'Bailey', 'Rattrie', 'Lissenden', 84099362, '1980-10-16', '2018-08-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (167081146, 'Kristine', 'Shorbrook', 'Vallender', 83619755, '1999-10-23', '2017-02-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (319317512, 'Nathanial', 'Matveiko', 'Stanton', 85414783, '1990-12-10', '2019-09-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (308331202, 'Avis', 'Mackrell', 'Nanuccioi', 83315739, '1994-08-14', '2019-01-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (296304794, 'Lucien', 'Aggas', 'Sagerson', 82611175, '1998-11-23', '2015-09-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (139861113, 'Quintilla', 'Hawkett', 'Gladwish', 80059020, '1990-06-22', '2018-03-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (168787079, 'Brandice', 'Antwis', 'Harbard', 83640431, '1992-01-03', '2019-07-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (205595117, 'Aubry', 'Pfeiffer', 'Goodricke', 83758601, '1996-09-21', '2017-11-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (329243654, 'Jasmine', 'Pead', 'Murrum', 82528440, '1998-06-02', '2016-05-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (243722354, 'Elvis', 'Sattin', 'Orum', 82234294, '1999-09-08', '2016-09-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (351052646, 'Celesta', 'Brolly', 'Wanek', 83630578, '1995-12-29', '2019-03-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (257054391, 'Tam', 'McMorland', 'Doorly', 82150376, '2000-10-16', '2018-02-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (100212894, 'Lynnett', 'Purcer', 'Legen', 82723992, '1999-06-19', '2019-02-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (267438427, 'Finley', 'Attoe', 'Yukhnev', 81140899, '1987-10-30', '2018-08-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (159894752, 'Jacintha', 'Parkhouse', 'Haughey', 84275349, '1985-12-16', '2017-07-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (210040540, 'Wilburt', 'Melsome', 'Robottham', 83428666, '1998-01-09', '2017-11-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (199904023, 'Tuesday', 'Dummett', 'Balloch', 82349045, '1996-07-10', '2016-09-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (242697212, 'Emelen', 'Davidovicz', 'Klimkovich', 84948584, '1993-06-26', '2017-12-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (378015440, 'Gabie', 'Shackelton', 'Huitson', 81819796, '1982-05-01', '2018-01-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (310193562, 'Jeanine', 'Tolussi', 'Churm', 82383684, '1998-01-17', '2015-11-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (394172676, 'Janel', 'Syme', 'Elwyn', 82359499, '1995-04-20', '2017-10-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (326196671, 'Beryle', 'Bode', 'Orrocks', 85390466, '1987-05-18', '2018-01-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (368136586, 'Hazel', 'McFarlane', 'Aristide', 80007741, '2000-08-08', '2019-08-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (369335853, 'Marley', 'Girardetti', 'Nann', 80773625, '1990-08-03', '2016-05-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (147169564, 'Ilysa', 'Dressel', 'Fortun', 81907202, '1980-11-14', '2016-05-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (276185448, 'Beitris', 'Dulwich', 'Weed', 81991645, '1996-02-06', '2017-09-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (323629564, 'Aubrey', 'Laterza', 'Glyn', 85493623, '1995-02-27', '2017-01-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (304765387, 'Catherine', 'Roberto', 'Corcoran', 80726918, '1995-08-15', '2016-11-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (119818640, 'Ginni', 'Kinker', 'Huyhton', 82755215, '1981-11-12', '2018-07-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (186282303, 'Timoteo', 'Snap', 'Greves', 84761119, '1982-01-02', '2016-10-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (136654992, 'Tandi', 'Ogilvie', 'Mellenby', 82087018, '1988-08-23', '2016-01-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (296037604, 'Bernadine', 'Jahnel', 'Burgane', 82420807, '1987-02-04', '2016-09-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (234642222, 'Sophronia', 'McBay', 'Comfort', 83863427, '1992-07-03', '2016-03-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (339069704, 'Carlen', 'Cratere', 'Esilmon', 82335046, '1980-02-05', '2017-07-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (129953642, 'Gerek', 'Castellino', 'Cordeix', 84979705, '1991-09-02', '2019-04-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (354703691, 'Rosalia', 'Antonescu', 'Obern', 83547431, '1998-03-23', '2015-05-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (314025308, 'Magdalene', 'Cossem', 'McKendry', 85219070, '1984-05-16', '2015-02-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (234227311, 'Zsazsa', 'Watmough', 'Skittrall', 82611114, '1988-03-24', '2018-12-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (104773746, 'Beatrice', 'Vickarman', 'Freddi', 81398606, '1990-06-18', '2017-10-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (172101099, 'Lancelot', 'Kinnard', 'Chennells', 81962908, '1989-09-18', '2018-01-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (334963570, 'Joannes', 'Portinari', 'Floweth', 83193196, '1996-09-05', '2016-06-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (229572398, 'Breena', 'Biggs', 'Calcutt', 81223047, '1995-09-01', '2017-07-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (209134624, 'Jorry', 'Quantrill', 'Bradden', 84270295, '1985-02-23', '2015-06-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (309946916, 'Stephanus', 'McTurley', 'Aisman', 83937067, '1982-04-06', '2019-07-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (259391846, 'Keri', 'Wretham', 'Tite', 80945277, '1995-06-10', '2017-12-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (385561713, 'Umberto', 'Holtham', 'Raddenbury', 82097593, '2000-10-28', '2017-05-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (383767710, 'Eleanore', 'Hrynczyk', 'Garrand', 80489735, '1994-08-10', '2019-01-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (332094910, 'Kirby', 'Skeldon', 'Chipchase', 85485832, '1998-05-06', '2017-09-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (372115723, 'Livvy', 'Dukesbury', 'Kembry', 83288010, '1996-02-24', '2015-10-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247190730, 'Garry', 'Terron', 'Lile', 85048321, '1982-05-30', '2016-02-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (399949391, 'Salli', 'Dumbelton', 'Swetman', 83711714, '1996-04-21', '2017-12-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (175575484, 'Jerald', 'Hyams', 'McNiven', 82911031, '1994-05-01', '2017-09-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (326931323, 'Davon', 'Esherwood', 'Clarridge', 83996271, '1990-09-03', '2015-02-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (397700920, 'Sophronia', 'Magnay', 'Beggio', 82679712, '1997-01-12', '2015-11-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (297062015, 'Vere', 'Mordacai', 'Petrollo', 82278422, '1990-01-05', '2019-10-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (224656933, 'Tandi', 'Siddle', 'Arblaster', 85258496, '1998-06-16', '2015-11-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (170986858, 'Elsa', 'Vincent', 'De Lacey', 85115584, '1996-07-14', '2018-01-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (322077891, 'Ted', 'Anthonies', 'Gomm', 83145132, '1990-04-26', '2018-01-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (190442383, 'Constantia', 'Kewish', 'MacGoun', 83432237, '1980-01-01', '2016-09-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (344052595, 'Alyson', 'Paris', 'Tudor', 84329389, '1986-02-26', '2015-07-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (387897739, 'Lion', 'Fitchett', 'Cutajar', 81541442, '1988-04-21', '2016-05-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (264321585, 'Catharine', 'Feldmesser', 'Reily', 83750675, '1985-08-13', '2016-06-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (238978629, 'Baillie', 'Wanka', 'Couvert', 84043560, '2000-03-18', '2016-10-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (203615276, 'Godwin', 'Hedney', 'Justham', 80677585, '1991-02-19', '2016-03-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (269661212, 'Fianna', 'Coolson', 'Adamoli', 82617297, '1993-07-03', '2018-10-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (239410988, 'Cecilia', 'De Cruz', 'Chittie', 81022814, '1992-02-01', '2015-01-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (274525308, 'Jaymie', 'Yukhnini', 'Demcak', 85272452, '1985-11-14', '2017-04-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (249109960, 'Cordell', 'McDool', 'Holcroft', 83929575, '1983-05-25', '2019-06-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (188972922, 'Mufinella', 'Lehr', 'Nisco', 82102694, '1982-06-30', '2018-11-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (312776799, 'Annalise', 'Isworth', 'Habbert', 81408676, '1986-02-23', '2016-02-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (267089773, 'Alfredo', 'Brizland', 'Stillwell', 81606860, '1980-03-16', '2019-02-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (394751995, 'Estell', 'Younie', 'Pendleton', 84415915, '1993-06-19', '2017-06-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (379434798, 'Marigold', 'Zmitrichenko', 'Mathiot', 84972597, '1998-09-07', '2018-12-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (285678272, 'Marsh', 'Spat', 'Redmond', 80850882, '1991-12-19', '2015-12-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (274529036, 'Johanna', 'Jenks', 'Bradnum', 80382362, '1985-08-31', '2018-12-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (351427371, 'Karia', 'Scyner', 'Worvell', 83625677, '1997-06-15', '2016-11-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (131225618, 'Keen', 'D''Adda', 'Andreichik', 84906346, '1990-05-25', '2018-12-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (337470748, 'Joey', 'Kleinmintz', 'Giraths', 82308475, '1988-05-05', '2016-12-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (103708103, 'Lavena', 'Heibel', 'Parkman', 82614529, '1980-04-12', '2015-12-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (193196459, 'Woodrow', 'Faraker', 'Everitt', 80694444, '1996-11-07', '2016-03-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (366880233, 'Sherri', 'Wakeford', 'Albrecht', 83281065, '1990-11-02', '2018-08-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (350400639, 'Nan', 'Larchier', 'Orred', 83166716, '1983-01-23', '2016-03-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (216812680, 'Barney', 'Gentery', 'Tetther', 83935393, '1984-07-07', '2018-03-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (347997877, 'Flossy', 'Orred', 'Seabrocke', 84705926, '1987-11-27', '2017-04-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (382306602, 'Camey', 'Pitkaithly', 'Thresh', 82974906, '1980-07-19', '2017-12-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (166633937, 'Marlane', 'Pregal', 'Laing', 83235549, '1985-12-25', '2015-10-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (134237454, 'Kennedy', 'Davidowich', 'Thieme', 84844819, '1990-05-29', '2015-02-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (293163661, 'Manuel', 'Moyler', 'Filipczak', 82454961, '1995-03-17', '2018-12-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (168375658, 'Elene', 'Roylance', 'Petrou', 80394085, '1984-09-29', '2018-02-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (270989134, 'Waly', 'Manser', 'Spicer', 85352760, '1989-06-15', '2015-09-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (377303619, 'Paxton', 'Lys', 'Bottini', 84472915, '1993-01-02', '2015-01-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (303478253, 'Wade', 'Casado', 'Bonnett', 84123717, '1987-12-01', '2019-10-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (296851079, 'Rance', 'Notton', 'Dumbreck', 82038887, '1992-08-20', '2017-06-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (352076343, 'Florencia', 'Pagan', 'Shemming', 82533265, '1983-12-31', '2017-02-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (264981845, 'Roxine', 'Spurett', 'Starkie', 82462051, '1992-01-17', '2019-10-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (366323251, 'Raina', 'Dallin', 'Guisot', 81453158, '1991-07-26', '2017-07-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (125769632, 'Cleveland', 'Elfe', 'Kinningley', 81620853, '1984-02-01', '2017-11-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (185774485, 'Tina', 'Inkles', 'Hammatt', 85280451, '1995-05-21', '2016-04-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (384988648, 'Fredia', 'Wolstencroft', 'Pressland', 82476949, '1981-04-01', '2016-01-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (201674885, 'Suki', 'Dreye', 'Neubigin', 84856668, '1984-11-28', '2016-02-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (159995653, 'Tildie', 'Brammall', 'Gocke', 82395330, '1993-07-14', '2017-11-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (330562996, 'Cassaundra', 'Saxby', 'Bartlett', 80940441, '1995-11-22', '2015-03-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (290212541, 'Henry', 'Kunkler', 'Foden', 83623919, '1999-11-06', '2017-01-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (124887089, 'Lance', 'Cox', 'Sharp', 83592997, '1992-08-27', '2015-09-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (391142143, 'Shell', 'Lain', 'Sille', 81848750, '1998-04-13', '2015-04-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (179845749, 'Cassaundra', 'Bariball', 'Pipes', 83706919, '1991-10-08', '2015-07-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (138746204, 'Miquela', 'Connar', 'De Gregario', 80308800, '2000-01-14', '2016-02-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (199045057, 'Leontine', 'Usborn', 'Jandourek', 84409061, '1993-01-21', '2016-03-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (379214165, 'Lorraine', 'Moreinu', 'Livoir', 83379553, '1989-05-08', '2017-05-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (206372296, 'Cassy', 'Grills', 'Chestney', 83025933, '1996-09-12', '2016-09-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (224994755, 'Katina', 'Rembrandt', 'Brinicombe', 82238106, '1997-05-11', '2018-11-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (199851023, 'Sammy', 'Patrone', 'Peckham', 83461595, '1990-05-10', '2015-08-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (151209236, 'Amabelle', 'Springle', 'Scullion', 82698380, '1994-12-05', '2018-01-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (139147900, 'Sydney', 'Pighills', 'Maggi', 80573242, '1997-07-20', '2017-01-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (302313854, 'Katharyn', 'Paler', 'Grolmann', 84058833, '1994-04-04', '2016-09-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (157727333, 'Antonietta', 'Draayer', 'Winridge', 83501868, '1993-02-22', '2017-11-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (330337734, 'Kevan', 'Kynoch', 'Wickie', 84090948, '2000-05-03', '2018-05-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (190522004, 'Ruben', 'Legier', 'Varty', 83107248, '1984-12-18', '2019-10-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247253468, 'Hy', 'McElrath', 'Anning', 80136311, '1989-02-20', '2018-02-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (249237873, 'Pepi', 'Piaggia', 'Grut', 81723228, '1998-10-13', '2015-06-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (115558226, 'Wilhelm', 'Fortune', 'Shoubridge', 82274049, '1992-03-12', '2016-01-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247694536, 'Les', 'Cordier', 'Franken', 80855310, '2000-10-03', '2017-04-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (252214499, 'Hannie', 'Lothean', 'Corkett', 84176534, '1997-07-18', '2016-11-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (291994310, 'Malina', 'Waleworke', 'Ather', 83458908, '1993-04-30', '2016-07-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (244437734, 'Herb', 'Kitchen', 'Clewlowe', 84387597, '1984-11-08', '2019-10-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (239427912, 'Cherey', 'Decreuze', 'Folder', 85152753, '1988-09-07', '2018-01-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (384921645, 'Janeczka', 'Widdicombe', 'Blaise', 80882432, '1995-03-09', '2015-01-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (166651945, 'Charla', 'Lytlle', 'Milleton', 82152607, '1992-09-04', '2016-01-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (300124321, 'Dorise', 'Sleep', 'Bamlett', 83927784, '1987-08-31', '2017-11-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (272481270, 'Ailey', 'Sexon', 'Glanvill', 84414012, '1980-09-17', '2018-10-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (296510271, 'Bill', 'McClymont', 'Passfield', 83453678, '1994-08-04', '2019-03-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (297606507, 'Clywd', 'Hegden', 'Oliveira', 83078890, '1981-06-14', '2019-10-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (243624279, 'Ameline', 'Bridges', 'Towey', 83817780, '1991-11-09', '2017-11-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (327491750, 'Mabel', 'Snepp', 'Callam', 84811622, '1983-10-01', '2015-12-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (237854553, 'Lynnelle', 'Hemphall', 'Gorman', 82128542, '1993-05-19', '2015-06-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (370897599, 'Bernita', 'Battersby', 'Colston', 80068888, '1983-05-15', '2018-09-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (151628751, 'Khalil', 'Robberecht', 'Gatlin', 84473561, '1980-06-18', '2018-11-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (122334271, 'Vannie', 'Strutz', 'Piggot', 81106540, '1999-10-07', '2016-11-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (255315762, 'Bettye', 'Edess', 'Clayill', 84546386, '1996-03-25', '2018-09-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (166779306, 'Casper', 'Allchorne', 'Ishaki', 83822040, '1981-12-25', '2015-02-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (385016585, 'Granville', 'Bennedsen', 'Vigietti', 81754250, '1980-12-10', '2017-09-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (171000672, 'Drusy', 'Corness', 'Rother', 84285337, '2000-08-09', '2018-03-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (129743622, 'Doy', 'Farmar', 'Capnor', 81435494, '2000-11-06', '2017-08-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (158796431, 'Coletta', 'Pudsey', 'Franzettoini', 81486411, '1993-03-15', '2018-09-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (302364939, 'Kirstin', 'Sleeford', 'Winmill', 83240489, '1986-04-04', '2017-05-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (216181984, 'Teddi', 'Tambling', 'Shires', 84835218, '1986-05-27', '2016-07-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (186138487, 'Rawley', 'Blundon', 'Elvey', 80730455, '1984-10-27', '2016-09-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (287722672, 'Carma', 'Chinnick', 'Wagenen', 85254618, '1985-06-15', '2015-06-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (181348789, 'Victor', 'Valentino', 'McClune', 85548270, '1991-04-30', '2019-03-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (176391533, 'Abraham', 'de Wilde', 'Scintsbury', 81637443, '1981-09-04', '2016-09-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (381742422, 'Vikky', 'Bricham', 'Stanlake', 85010710, '1982-06-08', '2017-06-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (219868717, 'Brok', 'Cleveland', 'Stidston', 82405466, '1993-12-22', '2016-08-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (267097133, 'Brook', 'Draycott', 'Diggar', 80854703, '1984-06-10', '2015-08-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (355157553, 'Fitzgerald', 'Pieper', 'Shipsey', 80593338, '1991-10-01', '2017-09-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (265650562, 'Donaugh', 'Jacquot', 'Kaming', 82981331, '1988-02-21', '2015-01-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (181373628, 'Isa', 'Ledrane', 'Ussher', 81674832, '1987-06-24', '2015-12-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (292736906, 'Catie', 'Lingard', 'Dulwich', 83411667, '1993-07-29', '2017-04-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (164247607, 'Kizzee', 'Gensavage', 'Goalley', 81094213, '2000-03-13', '2015-05-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (187874687, 'Amitie', 'Dusey', 'Itzcovich', 83838150, '1990-10-11', '2016-09-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (144494573, 'Kassey', 'Battram', 'Shrigley', 84418703, '1989-02-25', '2015-05-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (333217292, 'Lockwood', 'Yourell', 'Bowler', 80663915, '1991-10-17', '2017-01-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (360305691, 'Kilian', 'Streatfeild', 'Birdsey', 81459417, '1997-03-16', '2017-11-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (221655028, 'Min', 'Jellis', 'Shervington', 81979856, '1992-04-26', '2015-09-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (362412967, 'Emmalynne', 'Burth', 'O''Donoghue', 85208656, '1998-12-10', '2017-04-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (129139937, 'Rasia', 'Rydings', 'Mertsching', 83861940, '1985-11-03', '2016-06-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (173778216, 'Winn', 'Chataignier', 'Gauvin', 83852212, '1992-08-08', '2016-08-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (114992368, 'Domenico', 'Prestidge', 'Huckel', 80551919, '1988-03-26', '2017-06-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (293672979, 'Ola', 'Cosley', 'Bridgement', 80234731, '1996-03-19', '2016-11-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (172249002, 'Stacey', 'Rusbridge', 'Wakelam', 83416486, '1991-09-06', '2019-05-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (266167945, 'Grove', 'Hengoed', 'Vasse', 83444288, '2000-06-29', '2018-03-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (240365929, 'Thurston', 'De Bernardi', 'Thrush', 84770318, '1989-05-08', '2015-07-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (238563305, 'Jolynn', 'Hinstridge', 'Hannan', 82105404, '1988-07-22', '2015-05-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (283288385, 'Ingaberg', 'Eckery', 'Riteley', 81505682, '1991-06-25', '2018-07-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (223762708, 'Theda', 'Kahler', 'Breslin', 80706840, '2000-05-14', '2017-04-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (128815953, 'Christyna', 'Grafhom', 'Duling', 85257587, '1985-03-28', '2019-03-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (117492767, 'Audrey', 'Gratton', 'Chubb', 82708701, '1994-05-10', '2016-06-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (341773893, 'Alina', 'Purdy', 'Blissitt', 81419817, '1984-03-19', '2016-11-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (391620613, 'Gilemette', 'Newbery', 'Lindeman', 83412725, '1991-02-16', '2019-05-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (351542820, 'Elset', 'Kleeborn', 'Wimpey', 84448676, '1998-08-14', '2019-07-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (266320632, 'Hamel', 'Desborough', 'Clempton', 81396942, '1996-04-05', '2017-11-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (123010063, 'Berke', 'Ohms', 'Bonnick', 83952840, '2000-03-21', '2017-03-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (240794129, 'Reagan', 'Sprules', 'Stockey', 83981279, '1996-10-23', '2017-03-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (294428177, 'Prince', 'McCall', 'Caldecourt', 82250017, '1985-02-01', '2015-05-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (369720292, 'Nils', 'Parrington', 'Hysom', 82740560, '1986-12-04', '2018-06-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (189221034, 'Deeyn', 'Gleder', 'Yglesias', 82571227, '1982-01-08', '2015-06-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (301306142, 'Damita', 'Dornin', 'Booler', 84215619, '1993-05-12', '2015-03-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (318294865, 'Bern', 'Farthing', 'Stevings', 80532852, '1980-06-23', '2016-09-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (158555250, 'Shelby', 'Leigh', 'Bullcock', 84039643, '1998-02-27', '2016-02-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (103091537, 'Micky', 'Stredder', 'Ayto', 84785692, '1995-05-27', '2016-12-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (203124150, 'Vin', 'Peppard', 'McCathay', 84066128, '1997-12-02', '2015-10-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (336625626, 'Shay', 'Sugar', 'Riccetti', 82000337, '2000-07-22', '2015-07-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (136851735, 'Fifine', 'Ashman', 'Ruben', 80899060, '1994-06-20', '2019-04-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (388871223, 'Amanda', 'Burnes', 'Haggidon', 81317594, '1983-11-08', '2017-07-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (240360677, 'Kai', 'Rowcliffe', 'Yaneev', 83104617, '1996-10-18', '2017-10-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (300318351, 'Dorisa', 'Bullivent', 'Cowx', 80119290, '1988-11-30', '2018-06-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (265563468, 'Jobie', 'Wickstead', 'Geistmann', 84229530, '1984-10-29', '2017-04-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (179653494, 'Erastus', 'Starbeck', 'Branni', 83409895, '1982-08-24', '2016-06-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (226436196, 'Carter', 'De Giorgis', 'Cootes', 82604386, '1996-10-13', '2019-03-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (115539357, 'Gannie', 'Bengough', 'Brougham', 81802092, '1982-05-16', '2017-08-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (399139519, 'Maximo', 'Cammoile', 'Couvert', 80443236, '1994-12-23', '2017-08-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (259315366, 'Vitoria', 'McGinnell', 'Cavil', 84363877, '1980-10-28', '2015-08-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (134951187, 'Olympie', 'Guihen', 'Avraham', 83904306, '1982-08-27', '2016-11-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (161459886, 'Cherianne', 'Elgee', 'Foch', 84876446, '1986-04-11', '2019-04-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (223426882, 'Annmaria', 'Dunseith', 'Butts', 83553764, '1996-10-29', '2018-03-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (169685516, 'Christiano', 'Talmadge', 'Gewer', 81756239, '2000-10-21', '2017-05-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (284098213, 'Valentin', 'Tolefree', 'Yarr', 84581643, '1980-04-15', '2016-10-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (256834828, 'Vanna', 'Mary', 'Caldaro', 85145031, '1998-08-20', '2018-07-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (391057367, 'Tybi', 'Viger', 'Brewse', 83230995, '1993-02-20', '2016-06-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (341165077, 'Trude', 'Crocetti', 'Wattinham', 83509597, '1985-11-07', '2015-03-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (205071938, 'Randa', 'Di Frisco', 'Ferroli', 81198484, '1992-12-01', '2015-02-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (154153638, 'Holden', 'Bevington', 'Pickerin', 84229021, '2000-01-23', '2016-10-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (307547558, 'Andeee', 'Rentz', 'Malafe', 83378445, '1982-06-16', '2019-05-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (221969842, 'Idette', 'Braven', 'Jennemann', 82619867, '1994-10-17', '2016-04-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (163132691, 'Erastus', 'Dewdney', 'Feathersby', 83238183, '1989-05-06', '2018-05-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (366608143, 'Cathryn', 'Whitlaw', 'Raiment', 80586117, '1988-02-12', '2017-08-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (396671564, 'Kimble', 'Zmitruk', 'Ronci', 82867300, '1987-04-04', '2017-07-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (112845132, 'Kyrstin', 'M''cowis', 'McCarly', 80154688, '1991-03-14', '2015-10-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (251039881, 'Carlie', 'Kenan', 'Bastian', 82157321, '1986-12-17', '2019-04-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (249241870, 'Panchito', 'Cattini', 'Renihan', 81832158, '1991-01-31', '2016-12-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (348834200, 'Von', 'De Beauchemp', 'Crips', 83006407, '1998-12-18', '2015-06-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (145602776, 'Janka', 'Brendel', 'Jurisch', 81452014, '1984-05-21', '2015-10-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (131639847, 'Odele', 'MacCartair', 'Borne', 84511956, '1988-09-11', '2016-06-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (391740486, 'Hyacinth', 'Obey', 'Tassell', 81798178, '1998-01-17', '2019-11-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (189713209, 'Hans', 'Beach', 'Liepins', 82088276, '1985-01-08', '2016-03-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (171906999, 'Westley', 'Greenhow', 'Lembrick', 83318176, '2000-11-05', '2019-06-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (154246285, 'Maurise', 'Vearnals', 'Clissett', 81324390, '1993-11-22', '2016-04-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (363882255, 'Dari', 'Pentecost', 'Belf', 80721004, '1985-11-14', '2017-08-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (303579178, 'Crin', 'Feares', 'Kirkby', 83612977, '1997-12-20', '2017-06-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (390452360, 'Emmi', 'Fassmann', 'Witham', 85438709, '1980-07-25', '2018-11-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (325811251, 'Xymenes', 'Shalloe', 'Worham', 80774420, '1983-11-15', '2016-04-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (248094530, 'Phyllis', 'Fishpoole', 'Simons', 84315839, '1990-09-23', '2017-04-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (380588642, 'Alwyn', 'Zellner', 'Ioannidis', 82013007, '1986-01-26', '2017-06-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (346399366, 'Antone', 'Kapelhof', 'Norwich', 81846184, '1986-09-21', '2018-09-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (278050606, 'Neal', 'Neathway', 'Thomasson', 84114597, '1987-10-19', '2015-04-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (202375994, 'Prince', 'Tsarovic', 'Maisey', 83754110, '1990-08-20', '2015-12-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (275447103, 'Hugh', 'Leversha', 'Gorgen', 85330809, '2000-08-27', '2019-02-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (180061224, 'Latrina', 'Barthelmes', 'Wilding', 85248041, '1984-03-23', '2018-11-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (386149823, 'Lizzie', 'Winham', 'Coplestone', 83449381, '1988-04-26', '2018-07-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (397190298, 'Diane-marie', 'Tolfrey', 'Yakebowitch', 82228165, '1983-01-25', '2018-10-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (367544710, 'Tierney', 'Maass', 'Vasilik', 82131864, '1987-07-08', '2019-05-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (399970438, 'Paten', 'Funcheon', 'Pattini', 80101211, '1995-07-14', '2018-07-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (155051139, 'Catie', 'Youings', 'Blaxill', 80886516, '1991-08-01', '2016-05-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (102472468, 'Sybilla', 'Sybry', 'Hame', 83534423, '1996-10-20', '2019-02-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (294973134, 'Paxton', 'Currington', 'Kingsnode', 84608527, '1991-08-23', '2019-05-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (329920545, 'Ibrahim', 'Cawkwell', 'Winslade', 83751112, '1991-08-25', '2018-10-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (255442868, 'Helaine', 'Thorouggood', 'Santello', 80943485, '1998-12-10', '2019-06-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (173895048, 'Maire', 'Sweedland', 'Stenton', 80582461, '1986-02-28', '2015-11-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (372930186, 'Dionisio', 'Danovich', 'Trusdale', 82373465, '1985-04-09', '2015-05-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (226770777, 'Hamish', 'Ferriman', 'Twitching', 84874619, '1980-01-04', '2017-06-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (109813662, 'Thaxter', 'Nettles', 'Hayen', 83090716, '1980-04-19', '2018-02-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (339784880, 'Florance', 'Mutton', 'Ackeroyd', 81013534, '1998-05-12', '2015-08-24');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (353028134, 'Monty', 'Tailour', 'Sanbroke', 83024785, '1997-01-14', '2019-01-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (192583879, 'Gaston', 'Rounding', 'Ovington', 82227373, '1999-11-17', '2018-12-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (381008888, 'Olga', 'Wincer', 'Garahan', 83783319, '1985-11-18', '2019-06-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (242269585, 'Stewart', 'Winfindale', 'Golton', 83260965, '1980-04-26', '2019-03-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (318565368, 'Gordie', 'Kezar', 'Guerra', 83497211, '1999-11-19', '2015-08-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (278856212, 'Ivy', 'Buttrum', 'Klemenz', 84504989, '1986-03-31', '2015-05-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (264164885, 'Edik', 'Eborall', 'Gasticke', 80207529, '1982-09-18', '2016-11-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (384303079, 'Marena', 'Gulk', 'Wildman', 83198884, '1988-04-15', '2016-03-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (268635875, 'Franchot', 'Trenoweth', 'Bilbey', 82475540, '1990-10-17', '2015-10-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (349291340, 'Deanna', 'Lantiff', 'MacFaul', 80507313, '1984-04-21', '2017-01-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (228172917, 'Tatiania', 'Fawcitt', 'Oates', 82129847, '1994-10-21', '2018-11-19');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (192068701, 'Karlene', 'Olphert', 'Crummie', 83185183, '1992-05-22', '2016-04-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (281019425, 'Cynde', 'Bumby', 'Deroche', 84886485, '1995-10-23', '2018-07-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (243762072, 'Fionna', 'Alderton', 'Rawes', 85023926, '1980-04-02', '2019-03-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (296468777, 'Reade', 'Coatsworth', 'Aisman', 82227891, '2000-04-21', '2016-11-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (184463065, 'Keriann', 'Easter', 'Goldsby', 85251366, '1988-02-24', '2017-12-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247899320, 'Katheryn', 'Goshawk', 'Hooks', 82270091, '1989-02-28', '2019-02-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (298435322, 'Corbie', 'Reeder', 'Hegel', 80267655, '1982-12-19', '2016-05-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (334441311, 'Mella', 'Zima', 'Ruppert', 80585010, '1988-09-13', '2017-01-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (260734066, 'Shawn', 'Catherine', 'Swatten', 80114100, '1993-07-29', '2016-09-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (234671247, 'Nonie', 'Spehr', 'Aggio', 81668257, '1983-09-05', '2017-01-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (355770030, 'Phillipe', 'Ramsdale', 'Rubee', 83760532, '1986-09-27', '2015-08-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (160241014, 'Noelani', 'Laidlow', 'Ramme', 83664983, '1998-07-22', '2015-01-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (336509783, 'Laney', 'Jermin', 'Jann', 82766608, '1985-12-04', '2017-12-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (254704647, 'Melvin', 'Vaskov', 'Solomon', 80357400, '1992-05-09', '2019-10-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (137450198, 'Randolf', 'Dimberline', 'Salsberg', 81998145, '1981-04-12', '2017-04-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (312638845, 'Rolf', 'Mayell', 'Grafham', 81574943, '1985-12-16', '2018-11-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (360982079, 'Darryl', 'Cremins', 'Ullrich', 80104824, '1999-09-20', '2015-10-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (316265747, 'Lennie', 'Gotthard.sf', 'Lorne', 85140565, '1990-07-15', '2015-09-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (125629299, 'Farrah', 'Attersoll', 'Gosnall', 80713072, '1986-03-09', '2015-11-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (266960232, 'Stephine', 'Conningham', 'Studart', 85139733, '1984-09-25', '2015-02-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (161256610, 'Abram', 'Glitherow', 'Essberger', 80790283, '1993-03-30', '2017-10-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (195518343, 'Hedvig', 'Dalziel', 'Zuan', 84621736, '1993-03-09', '2018-05-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (296254334, 'Wakefield', 'Gilchriest', 'Durnill', 81487859, '1987-07-29', '2019-04-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (131561079, 'Evaleen', 'Vedyashkin', 'Cavanaugh', 84840864, '1990-01-25', '2019-08-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (398609286, 'Rozanne', 'Jefferd', 'Locker', 83601838, '1987-01-14', '2019-03-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (256262442, 'Gayelord', 'Castiblanco', 'Briar', 82101478, '1981-08-25', '2017-09-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247452244, 'Sloane', 'Cordery', 'Hall', 81892265, '1995-06-08', '2018-06-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (280405118, 'Nannie', 'Gallen', 'Mountain', 82871703, '1995-03-02', '2018-05-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (302909388, 'Cori', 'Gasken', 'Flattman', 83074913, '1984-10-17', '2019-01-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (168099298, 'Debera', 'Sabati', 'Whipple', 81396071, '1984-01-13', '2017-04-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (247813370, 'Tova', 'Stonebridge', 'Lennie', 82773495, '1981-05-19', '2019-02-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (289112224, 'Lexi', 'Milius', 'Aukland', 83565214, '1982-09-01', '2016-02-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (347499927, 'Gregoor', 'Bellhouse', 'Mardling', 84436034, '1986-04-06', '2018-01-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (207336529, 'Cos', 'Ralph', 'Waldren', 80936898, '1980-02-05', '2015-07-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (155565985, 'Horatia', 'Pike', 'Marcos', 82168954, '1984-10-24', '2017-07-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (284128617, 'Sax', 'Wordsworth', 'Quadling', 82559564, '1989-07-20', '2016-08-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (256932410, 'Muffin', 'Murgatroyd', 'Aronowitz', 81964216, '1985-08-25', '2015-07-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (114272587, 'Cornie', 'Stienton', 'Paver', 83565757, '1993-01-13', '2019-05-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (284173224, 'Carol-jean', 'Bredbury', 'Kynaston', 81304269, '1983-08-15', '2018-10-09');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (162625897, 'Eunice', 'Mauser', 'Artist', 82363671, '1986-01-09', '2016-04-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (207965981, 'Neille', 'Bercher', 'Baitson', 84222509, '1987-01-25', '2017-06-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (341852634, 'Othella', 'Rohlfing', 'Cains', 84345563, '1988-12-11', '2018-01-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (259759811, 'Hoyt', 'Kundt', 'Insworth', 81870198, '1999-08-08', '2016-08-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (103637782, 'Leif', 'Garwill', 'Carnie', 81248032, '1992-11-20', '2016-07-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (390100616, 'Maighdiln', 'Fullick', 'Eliot', 83378224, '1996-07-07', '2017-06-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (327101624, 'Shellysheldon', 'Dansey', 'Thorburn', 83225658, '2000-07-04', '2016-02-22');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (115719239, 'Willey', 'Endon', 'Hoodlass', 83069326, '1996-05-09', '2018-09-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (315784710, 'Jocelin', 'Fonzone', 'Beddoe', 83050434, '1988-02-09', '2018-01-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (116901446, 'Madison', 'Kilner', 'Botley', 84489187, '1998-09-21', '2019-09-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (109444204, 'Izak', 'Blake', 'Oiller', 81180115, '1996-08-28', '2018-05-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (212792921, 'Andy', 'Pickavant', 'Basindale', 83606804, '1989-03-19', '2017-04-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (284887875, 'Kinna', 'Voules', 'Siflet', 84261620, '1988-01-15', '2018-11-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (151818927, 'Gavan', 'Mumbeson', 'Cramond', 81867923, '1995-09-18', '2016-09-29');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (394210523, 'Colman', 'Pyecroft', 'Burehill', 83518163, '1994-06-21', '2018-02-13');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (208120001, 'Ingamar', 'Finder', 'Scutchings', 81109170, '1999-02-23', '2015-06-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (180040105, 'Zorina', 'Brient', 'Ollett', 80860587, '1991-11-26', '2018-09-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (396988156, 'Brantley', 'Trenholm', 'Clemencet', 84524265, '1984-08-31', '2018-02-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (384859081, 'Svend', 'Ellif', 'Hallan', 84516011, '1990-04-02', '2016-11-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (218281956, 'Minne', 'Wagon', 'Snadden', 81880774, '1995-01-13', '2015-08-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (122350993, 'Amabel', 'Milbourn', 'Coppens', 84941720, '1981-04-11', '2017-11-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (176332885, 'Jenine', 'Betjeman', 'Canada', 84630286, '1993-12-21', '2015-10-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (296061925, 'Buck', 'Lovel', 'Pedrol', 81629124, '1981-08-16', '2019-09-08');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (293182444, 'Eadie', 'Brass', 'Shuter', 80821525, '1997-09-11', '2017-11-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (392703167, 'Sebastien', 'Narrie', 'Greenman', 82489041, '1987-01-07', '2015-01-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (367899371, 'Adlai', 'Heaseman', 'Smalman', 85291510, '1985-05-26', '2019-08-25');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (387659554, 'Stacia', 'Hadgkiss', 'Benneyworth', 81417346, '1981-10-07', '2018-02-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (299926667, 'Cassie', 'Lynam', 'Mattacks', 82126939, '1992-06-20', '2019-03-04');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (279508066, 'Ansley', 'Mosson', 'Magson', 81642446, '1993-02-07', '2016-04-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (370939130, 'Dov', 'Djokovic', 'Marzele', 80838470, '1989-11-06', '2019-06-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (231096273, 'Jaquenette', 'Toombes', 'Phinnessy', 85013893, '1995-08-26', '2017-07-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (161168092, 'Shelden', 'Smythin', 'Edess', 81863748, '1996-08-08', '2017-02-23');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (369477661, 'Natalie', 'Blunden', 'Cremen', 81670360, '1995-03-01', '2018-08-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (385746050, 'Torrance', 'Curado', 'Middiff', 83208164, '1998-11-30', '2019-01-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (305571198, 'Jinny', 'Surtees', 'Winsley', 82662761, '1991-05-17', '2015-01-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (302011377, 'Taryn', 'Symonds', 'Voss', 82921658, '1988-04-25', '2019-07-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (293483793, 'Anni', 'Lorent', 'Alderton', 81710976, '1994-10-19', '2019-03-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (336234850, 'Bogart', 'Ribey', 'Frantzen', 85464931, '1982-05-02', '2016-11-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (324924734, 'Sibel', 'Mellows', 'Gage', 81087323, '1983-01-27', '2016-09-05');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (277969808, 'Rafferty', 'Vasyuchov', 'Shoorbrooke', 81194678, '1983-08-05', '2015-02-06');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (101553408, 'Hilary', 'Benedtti', 'Bines', 81968491, '1998-07-09', '2015-08-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (260977690, 'Othello', 'Warlock', 'Noirel', 83978233, '1988-02-09', '2018-05-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (392032255, 'Gavan', 'Grisewood', 'Mowlam', 85544018, '1984-12-10', '2017-10-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (147353360, 'Bunnie', 'O''Cleary', 'Bengtsson', 82066092, '2000-03-24', '2016-07-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (311836594, 'Ninnette', 'Thame', 'Dorrity', 85236478, '1995-03-23', '2017-03-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (205280940, 'Maurise', 'Massot', 'Massimo', 81259895, '1986-11-20', '2017-07-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (179037889, 'Anna-diane', 'Cronshaw', 'Gruszecki', 84562303, '1981-03-22', '2018-05-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (227516425, 'Rozamond', 'Tarry', 'Foro', 84170169, '1993-10-30', '2019-11-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (360798263, 'Gabie', 'Rowly', 'Kingdom', 81486968, '1983-08-20', '2017-05-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (254619766, 'Lorilee', 'Selesnick', 'Lawles', 82418687, '1984-11-22', '2019-05-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (220062462, 'Aveline', 'Riddel', 'Yeoman', 82826696, '1996-10-21', '2017-05-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (346898430, 'Chanda', 'McIllrick', 'Shorthill', 82403452, '1986-10-12', '2018-11-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (317365690, 'Agathe', 'Brounfield', 'Berkery', 80611071, '1987-04-27', '2015-07-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (222772655, 'Aggy', 'Gallahue', 'Dowsing', 82927237, '1988-09-10', '2016-04-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (385468232, 'Quinlan', 'Spennock', 'Chittie', 84515666, '1991-08-11', '2017-02-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (309312110, 'Byrle', 'Smellie', 'Sifleet', 85453284, '1997-09-02', '2018-10-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (337889824, 'Ralf', 'Gaddes', 'Le Grys', 81070914, '1988-02-03', '2019-07-11');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (236323731, 'Kerri', 'McSporrin', 'Le Hucquet', 81378577, '1981-04-29', '2015-11-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (345047276, 'Iggy', 'Cometti', 'Loades', 85248796, '1989-05-31', '2017-03-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (380115287, 'Daile', 'Arlidge', 'Lazenbury', 81785651, '1991-01-17', '2018-06-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (277503790, 'Margarete', 'Regan', 'Bushel', 82507185, '1998-06-11', '2018-04-20');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (121833704, 'Vonnie', 'Mathey', 'Allison', 84963523, '1985-09-17', '2015-01-30');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (229504525, 'Huey', 'Heineke', 'McAndie', 83287923, '1993-08-24', '2019-08-12');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (303204450, 'Darrick', 'McElrea', 'Syne', 81059344, '1990-07-08', '2017-10-31');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (230348779, 'Dimitri', 'Bruins', 'Clissold', 82929745, '1998-03-01', '2019-02-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (109320405, 'Daryl', 'Raithbie', 'Pirnie', 83407280, '1987-06-30', '2016-08-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (346146007, 'Hailee', 'Nutton', 'Drewett', 85177634, '1998-07-24', '2017-11-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (169699759, 'Caralie', 'Roiz', 'Whymark', 85196545, '1992-01-29', '2017-09-16');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (100833314, 'Smith', 'MacGeffen', 'Bignell', 82620945, '1986-04-27', '2018-07-07');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (396950633, 'Nicola', 'Burroughes', 'Astling', 83435264, '1984-11-26', '2018-12-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (172039608, 'Hannie', 'Endersby', 'Rameau', 84693534, '1992-04-29', '2018-07-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (387909952, 'Erda', 'Boyne', 'Stodit', 85151571, '1987-06-01', '2017-11-27');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (130085965, 'Opal', 'Woodier', 'Blanchet', 80491556, '1980-08-16', '2018-07-01');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (281417675, 'Barnaby', 'Hoyte', 'McKinna', 83234535, '2000-10-07', '2017-01-02');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (268557892, 'Andreas', 'Daile', 'Fleay', 85458434, '1991-06-12', '2015-09-17');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (103332845, 'Hervey', 'Wisedale', 'Widger', 83527888, '1981-06-14', '2018-12-28');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (182113865, 'Stanly', 'Whistance', 'Spratt', 83656621, '1983-04-11', '2018-04-15');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (387966877, 'Ker', 'Brammer', 'Hewlings', 82902549, '1998-05-28', '2016-10-21');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (136746313, 'Ami', 'Filippov', 'Clemenson', 80995662, '1989-08-21', '2015-04-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (154661975, 'Chelsey', 'De Blasiis', 'Dugall', 83012567, '2000-10-12', '2015-01-14');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (209394335, 'Ronnie', 'Falkous', 'McIlheran', 81753522, '1984-11-25', '2018-11-03');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (356967645, 'Rosie', 'Tinwell', 'Ollarenshaw', 84587281, '1991-01-03', '2019-02-10');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (133838029, 'Tallou', 'Hendricks', 'Huitson', 81903059, '1998-02-16', '2017-11-18');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (243370115, 'Rayner', 'Haresnaip', 'Frarey', 81099059, '1983-03-22', '2015-02-26');
insert into Academia.Profesor (ID_Profesor, Nombre, Apellido1, Apellido2, Numero_telefono, fecha_nacimiento, Fecha_ingreso) values (295618933, 'Sebastiano', 'Grigori', 'Hessle', 82123827, '1988-10-14', '2019-05-13');

-- insercion en Academia.Administrativo
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (767374906, 'Constance', 'Bragginton', 'Matiashvili', '715 American Ash Way', 95372982, '1988/02/19', '2017/05/25');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (702410828, 'Alvinia', 'Airds', 'McCarter', '13936 Calypso Way', 95355362, '1991/05/27', '2019/05/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (616475848, 'Gregor', 'Levitt', 'Spatari', '5020 Roxbury Circle', 91743632, '1993/03/30', '2015/06/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (601496940, 'Dory', 'Ccomini', 'Rennox', '2205 Meadow Valley Crossing', 92596163, '1987/01/24', '2017/01/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (796385697, 'Lara', 'Battell', 'Connochie', '281 Forest Run Street', 91303960, '1995/03/18', '2015/08/16');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (624255757, 'Eirena', 'Nevin', 'Dormer', '9 Fair Oaks Terrace', 95496298, '1987/02/13', '2019/03/16');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (666384045, 'Pierre', 'Gush', 'Ponnsett', '1986 Westerfield Park', 95017051, '1986/07/27', '2015/11/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (708466770, 'Efrem', 'Louys', 'Robion', '394 Ludington Crossing', 94055461, '1990/05/08', '2019/04/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (680621501, 'Imojean', 'Wheeliker', 'Sharma', '76 Elgar Point', 93029585, '1986/10/02', '2017/08/16');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (649193243, 'Keriann', 'Scathard', 'Plom', '1 Vera Center', 91629582, '1999/07/18', '2018/01/31');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (678856177, 'Shel', 'Graalman', 'Reinmar', '25 Merrick Plaza', 90883760, '1990/01/27', '2016/04/18');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (718676800, 'Melosa', 'Corness', 'Islep', '0092 Twin Pines Park', 91247793, '1993/05/12', '2015/08/22');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (778438291, 'Fayette', 'Pfaffel', 'Crosgrove', '6949 Toban Terrace', 95057010, '1996/11/22', '2018/02/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (782068660, 'Audy', 'Aldam', 'De Biasi', '4249 Briar Crest Point', 93930285, '1988/08/17', '2018/07/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (622658592, 'Gertie', 'Frantzen', 'Sammars', '4 Corben Place', 93640874, '1991/07/14', '2019/05/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (628529970, 'Sasha', 'Prescote', 'Rahlof', '582 Toban Circle', 93271317, '1997/06/19', '2018/01/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (675573090, 'Brittaney', 'McManamon', 'Eberdt', '4058 Cherokee Point', 93994276, '2000/10/30', '2017/04/30');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (762636101, 'Clayborn', 'Cicchetto', 'Olufsen', '4304 Nancy Way', 95016890, '1997/05/04', '2019/11/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (625967213, 'Julee', 'Woodings', 'Sime', '9 Hayes Drive', 91876256, '1988/09/24', '2019/01/17');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (692979418, 'Tish', 'MacLardie', 'Lannen', '23998 Reindahl Alley', 95003725, '1985/09/01', '2019/03/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (640796110, 'Chiquita', 'Eliez', 'Farthin', '42277 Blaine Pass', 92893570, '1993/07/04', '2016/05/20');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (691162417, 'Duff', 'Bligh', 'Pallaske', '44 Myrtle Trail', 92222355, '1988/09/02', '2017/07/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (629808779, 'Sabina', 'MacNeilly', 'Frany', '6734 Novick Plaza', 91267631, '1989/05/27', '2016/08/19');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (759689316, 'Parnell', 'Duly', 'Corsor', '90582 Cordelia Lane', 93740995, '1987/09/17', '2015/07/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (756814540, 'Martelle', 'Gossan', 'Abbys', '943 Summerview Junction', 93554417, '1999/04/19', '2017/10/24');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (778157115, 'Charles', 'Franchyonok', 'Rivelin', '671 Village Point', 91920710, '1987/12/25', '2018/05/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (715411290, 'Keelby', 'Fosse', 'Bruni', '4 Corscot Plaza', 90926151, '2000/02/22', '2019/02/25');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (795280523, 'Leif', 'Wyley', 'Farlow', '703 Sunfield Crossing', 92493134, '1985/04/17', '2019/10/21');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (606551075, 'Keenan', 'Flieg', 'Sills', '9614 Texas Avenue', 93602586, '1990/04/29', '2017/04/17');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (627873121, 'Kristo', 'Priddle', 'Keedy', '09 Becker Lane', 93968814, '1997/02/27', '2017/01/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (768854052, 'Matty', 'Rack', 'Bohlin', '885 Oak Terrace', 91401172, '1999/09/11', '2019/08/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (686624308, 'Rutter', 'Ponter', 'Pannett', '4713 Pawling Road', 94973135, '1986/10/31', '2017/08/22');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (631763018, 'Cheston', 'Summerskill', 'Linden', '2001 Manufacturers Trail', 90163822, '1991/09/12', '2016/08/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (737934194, 'Wyndham', 'O'' Faherty', 'Bigadike', '735 Victoria Center', 90985524, '1991/03/31', '2019/02/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (625414489, 'Skip', 'Wigley', 'Isworth', '02544 Lawn Drive', 94034251, '1986/05/02', '2018/08/20');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (658213361, 'Breanne', 'Rudeyeard', 'Kilmurry', '9 Miller Drive', 92200027, '1999/05/11', '2018/09/18');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (766922591, 'Gilberto', 'Lissandri', 'Brydson', '18808 American Ash Circle', 93590460, '2000/07/24', '2018/12/19');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (606723220, 'Nicolette', 'Barden', 'Somerled', '7 Sugar Circle', 93346997, '1995/06/04', '2019/02/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (729425376, 'Janeczka', 'Crowdson', 'Keighly', '688 South Street', 95206949, '1992/07/17', '2016/03/25');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (754703235, 'Ruby', 'Signe', 'Yaakov', '626 Vidon Hill', 95270911, '1990/01/29', '2019/10/31');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (624235705, 'Vale', 'Roath', 'Kun', '94237 Express Road', 90206765, '1991/02/07', '2015/01/28');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (617005557, 'Vaclav', 'Gauld', 'Uebel', '2 Arrowood Crossing', 93553492, '1995/07/11', '2016/05/26');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (794200692, 'Elsbeth', 'Philipsson', 'Isaac', '49 Charing Cross Parkway', 94666665, '1994/08/17', '2018/08/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (687820837, 'Karoly', 'Shutte', 'Trewhela', '71599 Maple Trail', 90027198, '2000/08/12', '2017/01/22');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (747963147, 'Clair', 'Loiterton', 'Joinson', '2 Holmberg Terrace', 92963315, '1985/02/20', '2019/05/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (749612996, 'Lannie', 'Heditch', 'Domenico', '39856 Schurz Plaza', 91808124, '1989/01/16', '2016/11/05');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (668897765, 'Marrissa', 'Bingell', 'Annwyl', '243 Transport Park', 93927611, '2000/09/20', '2017/11/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (755494807, 'Madella', 'Kringe', 'Blagden', '23 Hallows Plaza', 91019775, '1988/07/17', '2017/07/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (616896574, 'Godfry', 'Pitkeathly', 'Cosley', '0 Russell Avenue', 94013115, '1996/12/05', '2019/08/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (794515621, 'Berget', 'Stienham', 'Targetter', '8516 Northland Alley', 91141865, '1994/01/02', '2017/08/30');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (670415209, 'Sharon', 'Frow', 'Farquar', '30754 Jenifer Drive', 90988971, '1999/02/14', '2016/06/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (759875135, 'Montague', 'Foucher', 'Gannan', '979 Brown Circle', 91917472, '1985/01/25', '2018/10/29');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (716747817, 'Tammie', 'Hourihane', 'Bains', '95 Reindahl Parkway', 94619140, '1999/02/01', '2017/02/12');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (624804737, 'Wilton', 'Merrett', 'Matevushev', '42 Independence Pass', 92237202, '1990/10/08', '2018/03/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (785579792, 'Gene', 'Greenway', 'Gledhill', '4 Southridge Place', 92928168, '1993/08/29', '2019/07/24');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (610622739, 'Willetta', 'Gaggen', 'Dunkerly', '64 Hooker Park', 93625898, '1986/01/17', '2016/10/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (765901278, 'Avie', 'Carsberg', 'Uppett', '1522 Claremont Way', 92119593, '1996/11/26', '2016/08/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (656413708, 'Lukas', 'Jeaneau', 'Codron', '626 8th Crossing', 93286065, '1985/01/28', '2017/08/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (711874041, 'Horatius', 'Marsden', 'McGinnis', '14 Westridge Drive', 90114636, '1995/10/21', '2016/09/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (629554545, 'Elspeth', 'Blampied', 'Gaul', '6103 Onsgard Trail', 92535409, '2000/05/23', '2019/10/31');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (666797007, 'Filippo', 'Asty', 'Cosser', '703 1st Circle', 93694448, '1985/12/20', '2018/11/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (799143221, 'Demetri', 'McCook', 'Brand-Hardy', '94610 Bowman Park', 92065938, '1993/08/24', '2016/06/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (796439059, 'Rory', 'Raund', 'Babe', '8060 Anniversary Place', 90874050, '1998/09/27', '2018/05/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (778646358, 'Wade', 'Kellitt', 'Ivanyukov', '125 Paget Drive', 91874689, '1992/05/20', '2019/08/21');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (608979392, 'Rebeca', 'Wharrier', 'MacNamara', '6557 Linden Lane', 93724287, '1993/02/06', '2019/01/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (691651070, 'Sherman', 'Thornthwaite', 'Embra', '447 Golf Course Way', 90477088, '2000/09/05', '2017/10/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (627935031, 'Breanne', 'Duncan', 'Breinl', '64 Algoma Park', 95149055, '1997/07/31', '2016/12/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (692569528, 'Edita', 'Tyrer', 'Pagan', '6249 Crowley Road', 93142222, '1985/08/06', '2018/05/05');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (773015159, 'Abbie', 'Biasioli', 'Beatty', '8 Welch Circle', 90770747, '1997/10/28', '2019/04/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (781228824, 'Skylar', 'Arni', 'Flindall', '95418 Rockefeller Lane', 94940099, '1990/01/24', '2016/05/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (649339625, 'Kaylee', 'Collete', 'Levison', '50324 Comanche Court', 92165787, '1998/12/16', '2016/03/14');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (630779534, 'Tracie', 'Foffano', 'Hoyland', '87722 Hauk Way', 92653000, '1995/08/12', '2016/07/20');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (671334667, 'Karylin', 'Crumly', 'Mouat', '1651 Sutherland Terrace', 90298404, '1999/01/09', '2015/01/09');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (609005050, 'Nananne', 'Walton', 'Mellor', '23 Nevada Plaza', 93453679, '1991/04/19', '2015/01/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (769961305, 'Judith', 'Gainsbury', 'Jevons', '97 Eastlawn Hill', 91769655, '1986/11/27', '2017/01/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (730978106, 'Baldwin', 'Jorat', 'Annear', '1580 Oxford Drive', 95107053, '1991/07/12', '2017/03/05');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (799646563, 'Ella', 'McGuirk', 'Mohamed', '66 Heffernan Street', 90616240, '1988/01/15', '2019/06/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (604309920, 'Woody', 'Colliber', 'Barczewski', '31309 Kennedy Alley', 90089379, '1985/06/07', '2015/01/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (728025212, 'Chrysa', 'Deetch', 'McFade', '98 Barnett Park', 90360898, '1998/10/04', '2019/09/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (741501189, 'Chris', 'Adamovicz', 'Matthewman', '06 Everett Park', 92788596, '1992/12/08', '2019/01/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (706864581, 'Lisette', 'Profit', 'Crowcher', '3574 Gerald Center', 93383501, '1987/07/17', '2018/07/21');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (699266938, 'Stirling', 'Swan', 'Braniff', '7936 Chive Place', 91975631, '1999/04/15', '2017/09/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (646365646, 'Billy', 'Clemits', 'Nester', '214 Morrow Lane', 93173268, '1988/05/19', '2016/03/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (663976889, 'Agretha', 'Orleton', 'Cerith', '4 North Road', 92050046, '1998/01/04', '2019/05/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (758974423, 'Gayel', 'Braferton', 'Hurcombe', '8 Hoffman Pass', 92489436, '2000/01/30', '2019/01/09');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (701504272, 'Lyndel', 'Bloss', 'Bulstrode', '76 Eagle Crest Park', 91399231, '1996/07/08', '2018/02/18');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (639214619, 'Leia', 'Jodkowski', 'Sommerland', '84 Burning Wood Park', 91814487, '1992/05/27', '2018/11/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (750722016, 'Nilson', 'Churchouse', 'Bollum', '47678 Bashford Way', 90257829, '1986/11/27', '2019/03/18');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (646545371, 'Jacquelyn', 'Bly', 'Farnworth', '2726 Lerdahl Lane', 93360770, '1998/01/04', '2015/12/19');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (745537137, 'Eilis', 'Verne', 'Jeakins', '50405 Arapahoe Point', 95446597, '1994/12/08', '2017/11/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (772825859, 'Dionisio', 'Jonson', 'Baradel', '0 Bay Plaza', 90254229, '1994/02/13', '2017/10/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (600208676, 'Earvin', 'Stallon', 'Benyon', '03831 Waywood Terrace', 94302862, '1999/09/21', '2015/03/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (665314501, 'Cherilyn', 'Senter', 'Gerger', '8150 Farwell Junction', 92105375, '1994/05/11', '2018/10/16');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (687235499, 'Giusto', 'Allmann', 'Sherar', '3 Farwell Hill', 92086509, '1985/07/24', '2015/04/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (784690555, 'Hedwig', 'Quinet', 'Tottie', '69058 Red Cloud Park', 92149514, '1989/08/15', '2018/11/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (735781598, 'Leilah', 'Brewin', 'Thickpenny', '693 Mayfield Point', 92084673, '1995/09/28', '2019/09/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (665779717, 'Wolf', 'Mark', 'Deneve', '686 Jenna Avenue', 93869419, '1987/08/08', '2019/09/19');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (772190313, 'Forester', 'Curteis', 'MacShirie', '751 Debra Trail', 90435435, '1987/05/02', '2018/03/30');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (753853660, 'Thoma', 'Timson', 'Sayes', '2320 Mcbride Junction', 91656782, '1998/10/06', '2018/09/17');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (706340375, 'Saidee', 'Saket', 'Saunier', '1 Laurel Road', 90400310, '1993/08/16', '2018/05/31');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (797466603, 'Matthaeus', 'Strangwood', 'Pirouet', '4 Bashford Lane', 94464299, '1990/12/03', '2017/08/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (796134978, 'Danell', 'Roseveare', 'Ferraresi', '1 Dixon Road', 92942637, '1998/12/18', '2019/02/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (642179428, 'Elliot', 'Klauber', 'Kabisch', '8613 Clove Trail', 93863836, '1986/10/31', '2016/10/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (785488031, 'Mignon', 'Buzzing', 'Turban', '6275 Shelley Road', 93160775, '1986/12/14', '2019/03/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (751339723, 'Shelly', 'Sutehall', 'Tucker', '55085 Claremont Trail', 91232464, '1991/08/25', '2018/06/22');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (762393900, 'Audi', 'Hancorn', 'Carmen', '37 Parkside Crossing', 91333612, '1999/09/15', '2018/02/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (615324657, 'Currey', 'Cohan', 'McGinley', '9 Lukken Point', 95379778, '1994/12/22', '2016/03/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (784933272, 'Nickey', 'Gunthorpe', 'Antcliffe', '84 Brown Drive', 91179543, '1996/09/29', '2017/04/18');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (622182505, 'Grantham', 'Overill', 'Lashford', '6594 Merrick Center', 91793964, '1999/12/16', '2016/11/12');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (771237214, 'Lowe', 'Garvagh', 'Shellsheere', '5 Susan Junction', 95377648, '1986/01/17', '2015/02/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (777579777, 'Dermot', 'Quilty', 'Gilbertson', '3 Maywood Circle', 92684057, '1996/12/18', '2019/01/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (798979892, 'Hunt', 'Tillot', 'Sugg', '36545 Texas Way', 91893734, '1997/10/14', '2019/09/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (792959448, 'Toddy', 'Berendsen', 'Miell', '0 Lyons Road', 93227970, '1999/02/10', '2017/06/12');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (657536279, 'Koo', 'Descroix', 'Oldroyde', '2355 Longview Terrace', 93704431, '1997/06/01', '2015/10/19');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (773077113, 'Nertie', 'Wallicker', 'MacGillavery', '55496 Kropf Trail', 90308059, '2000/05/09', '2019/03/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (648271895, 'Gwenni', 'Spadoni', 'Martusov', '2325 Ridge Oak Place', 94534115, '1991/06/25', '2017/09/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (662558803, 'Berri', 'Rudman', 'Lowmass', '681 West Way', 94793744, '1999/06/01', '2018/07/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (730095047, 'Angelico', 'Hoofe', 'Kuhnert', '76158 Texas Crossing', 90772677, '1995/02/15', '2019/10/29');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (739627062, 'Katlin', 'Dunsmore', 'Fowles', '83564 Clove Road', 91094871, '1994/05/13', '2018/09/14');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (700039940, 'Donny', 'Hounson', 'Picopp', '334 South Lane', 92202271, '1989/01/04', '2018/08/29');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (679914092, 'Alys', 'Newham', 'Jikylls', '6 Grayhawk Avenue', 93997575, '1996/09/17', '2015/06/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (778094967, 'Clemence', 'Vink', 'Baggalley', '578 Kinsman Street', 93708287, '1989/10/07', '2015/05/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (622091578, 'Gwynne', 'Baber', 'Morales', '411 Brentwood Hill', 94073562, '1995/03/05', '2017/11/18');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (641417148, 'Moll', 'Aleveque', 'Cobbledick', '671 Esch Park', 95400796, '1990/09/06', '2016/11/16');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (772783422, 'Leann', 'Kildahl', 'Baytrop', '3 Schurz Plaza', 92622800, '1992/02/14', '2017/11/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (672841517, 'Filmer', 'Boorne', 'McLugaish', '630 Kensington Point', 90336742, '2000/02/16', '2017/08/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (698632389, 'Siobhan', 'Tidbold', 'Blackeby', '36964 Express Way', 94964097, '1993/07/24', '2015/10/18');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (690946960, 'Ottilie', 'Allenson', 'Younge', '3351 Cascade Lane', 91771920, '1986/12/05', '2019/01/24');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (738939573, 'Luisa', 'Shillam', 'Stouther', '52 Havey Parkway', 94394825, '1999/09/10', '2019/10/30');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (732868291, 'Melita', 'Roach', 'Patzelt', '7 Eliot Road', 94933086, '1998/09/02', '2016/01/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (632437484, 'Jessika', 'Matskiv', 'Dugall', '97 Ridgeview Trail', 91261658, '1993/07/31', '2018/05/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (605809109, 'Hedda', 'Screase', 'Keays', '28220 Pankratz Pass', 90526122, '1992/12/24', '2016/09/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (618460498, 'Harwell', 'Avent', 'Lamas', '9 Everett Parkway', 91072559, '1992/03/26', '2017/12/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (738176831, 'Rufe', 'Amber', 'Adamsky', '75 Ridgeway Plaza', 92409485, '1997/07/28', '2015/06/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (755289776, 'Lamont', 'Tavinor', 'Eakins', '254 Raven Park', 92499830, '1990/10/28', '2017/08/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (742337348, 'Verna', 'Mortimer', 'Ellingworth', '19 Emmet Crossing', 93492826, '1993/07/04', '2016/02/29');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (774033264, 'Marlena', 'Worsnup', 'Jirusek', '25706 Novick Way', 94756717, '1986/01/06', '2019/03/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (646342264, 'Cherida', 'Alison', 'Brotherick', '6136 Basil Point', 94707314, '1991/07/04', '2018/01/17');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (676384690, 'Donica', 'Simeon', 'Tooker', '535 Nevada Lane', 90421442, '1991/08/02', '2016/05/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (657553656, 'Rora', 'de''-Ancy Willis', 'Braidford', '1 Nova Point', 93734632, '1989/02/26', '2015/11/05');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (695404227, 'Lyle', 'Cliff', 'Follen', '73 Onsgard Avenue', 92556983, '1994/06/28', '2016/01/22');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (781316857, 'Cyndie', 'Janaud', 'Doll', '641 Knutson Parkway', 91923403, '1993/09/28', '2015/01/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (682774791, 'Taite', 'Hanscomb', 'Sorensen', '3518 Stuart Circle', 93149033, '1991/04/17', '2015/10/12');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (702505909, 'Alfi', 'Meriguet', 'Pomphrey', '0095 Towne Junction', 94754294, '1989/02/06', '2016/07/12');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (760322767, 'Bank', 'Roobottom', 'Finkle', '8 Garrison Hill', 91727062, '1989/01/15', '2019/06/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (669719048, 'Parke', 'Ollin', 'Duckham', '08818 Marcy Pass', 91694323, '1988/02/05', '2017/01/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (799855433, 'Reggie', 'Koschke', 'Thalmann', '03586 New Castle Terrace', 95335066, '1992/10/29', '2015/01/21');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (687904900, 'Melisande', 'Self', 'Tink', '77828 Warner Hill', 91661864, '1998/03/06', '2015/04/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (748180677, 'Kellyann', 'Ferreras', 'Smallpeice', '14 Paget Place', 92003317, '1986/05/21', '2017/12/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (655968265, 'Vere', 'Matteo', 'McManamen', '28 Crest Line Point', 92426371, '1985/11/30', '2018/08/05');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (608490247, 'Nikki', 'Tuminini', 'Ettridge', '26 East Pass', 93285441, '1999/06/27', '2019/10/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (655702621, 'Tally', 'Shallcross', 'Rawson', '723 Bobwhite Avenue', 90050518, '1997/02/21', '2019/10/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (700115342, 'Retha', 'Tolchard', 'Farrent', '9183 Burning Wood Hill', 92001404, '1991/05/26', '2017/06/21');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (601197773, 'Gaynor', 'McCarry', 'FitzGeorge', '6095 Kings Circle', 93092243, '1988/04/25', '2015/07/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (772350998, 'Rabi', 'Ingilson', 'Yates', '60 Lotheville Way', 92677883, '1999/01/06', '2015/10/22');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (783971355, 'Sarge', 'Roxby', 'Cressar', '0800 Scoville Junction', 92404353, '1989/10/11', '2016/02/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (628079602, 'Robena', 'Knights', 'Domenget', '88 Brickson Park Street', 92679477, '1998/06/13', '2017/05/17');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (642149970, 'Teodoor', 'Linny', 'Vinas', '7 David Way', 92601584, '1997/05/07', '2016/02/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (734377125, 'Harwilll', 'Smallpiece', 'Pietz', '36410 Hagan Avenue', 94930467, '1985/10/16', '2018/02/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (775871262, 'Falkner', 'Margiotta', 'Bartosch', '37 Carioca Alley', 92782555, '1986/08/02', '2019/01/14');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (788162157, 'Fayina', 'Hindmoor', 'Shreve', '57 Waywood Drive', 91630396, '1995/07/08', '2017/06/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (613912566, 'Jacky', 'Swires', 'Sedworth', '4 Grasskamp Crossing', 93382344, '1991/06/22', '2019/08/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (799629867, 'Hilliary', 'Kopmann', 'Darley', '66265 Saint Paul Street', 95164750, '1999/06/12', '2015/01/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (614704994, 'Ariadne', 'Pyett', 'Loomis', '76 Welch Circle', 92666699, '1998/02/17', '2016/04/24');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (618391062, 'Dodie', 'Marney', 'Zanetto', '47678 Del Mar Place', 90895983, '1987/01/03', '2018/02/22');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (767978037, 'Cob', 'Balchen', 'Gaine', '781 Buhler Way', 93909670, '1986/05/05', '2016/01/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (647131254, 'Marrilee', 'Gyenes', 'Paulson', '329 Armistice Hill', 91997533, '1995/10/21', '2017/02/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (608358116, 'Ailee', 'Tother', 'Bleasdale', '80 Lotheville Plaza', 92720479, '1999/10/28', '2015/11/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (684462647, 'Stacie', 'Speare', 'Di Batista', '74 Scofield Court', 90166198, '1993/08/27', '2017/01/24');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (743600426, 'Andra', 'Shilstone', 'Merwede', '186 Lyons Junction', 91825295, '1999/05/06', '2016/02/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (774957563, 'Michaela', 'Dartnall', 'O''Shiels', '69630 Lerdahl Parkway', 92651961, '1990/05/05', '2015/07/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (620994211, 'Jay', 'Cunrado', 'Mickleborough', '09034 Goodland Way', 93896763, '1990/01/01', '2016/05/20');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (689814839, 'Kendre', 'Covely', 'Comettoi', '33 Union Park', 92684614, '1989/10/14', '2017/09/20');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (610842604, 'Kylen', 'Rosbottom', 'Tolomio', '5 Valley Edge Center', 93210088, '2000/10/30', '2019/08/26');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (754957629, 'Kayley', 'Stede', 'Shade', '48453 Mcbride Hill', 90018202, '1991/11/24', '2016/09/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (680897659, 'Libbey', 'Glendenning', 'Sawers', '061 Colorado Parkway', 95509287, '1991/03/06', '2018/01/26');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (690384679, 'Hewett', 'Kedie', 'Rubinovitsch', '50 Brentwood Park', 93504523, '1988/04/13', '2017/03/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (753520307, 'Jasun', 'Helversen', 'Rodinger', '15045 Scoville Street', 94681902, '1985/07/12', '2019/04/09');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (747717742, 'John', 'MacKnocker', 'Murdoch', '7 Monument Circle', 95456855, '1999/04/29', '2018/07/09');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (650908699, 'Karon', 'Stairmond', 'Renzullo', '515 Eastwood Trail', 91139109, '1998/03/19', '2019/11/09');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (729890933, 'Riva', 'Sinclaire', 'Beechcraft', '418 Fair Oaks Alley', 94453753, '1988/02/28', '2015/02/18');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (609927417, 'Conn', 'Moodie', 'Kingshott', '2466 Buhler Point', 90342455, '1990/01/11', '2015/02/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (783226854, 'Michale', 'Poinsett', 'Kleinstub', '02 Mayer Crossing', 90234924, '1989/11/27', '2015/08/30');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (705595078, 'Adelle', 'Grinaway', 'Shaddock', '76698 Corben Trail', 93025589, '1988/02/13', '2017/09/28');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (639987163, 'Dorian', 'Iacovazzi', 'Theyer', '95602 Montana Road', 91542008, '1988/09/05', '2018/03/20');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (780092769, 'Fan', 'Folan', 'Mathissen', '24387 Sundown Plaza', 90252224, '1991/06/01', '2016/08/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (769007715, 'Herrick', 'Brownrigg', 'Strachan', '18 Maryland Street', 91486761, '1997/12/13', '2017/01/24');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (709380980, 'Shay', 'Rudderham', 'Fozard', '2 Nancy Pass', 92221095, '2000/05/02', '2017/11/05');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (616125460, 'Bea', 'Grayson', 'Gersam', '94906 Aberg Way', 93714398, '1997/05/18', '2018/11/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (613487749, 'Florencia', 'Delacoste', 'Pedler', '91084 Eastwood Drive', 91034800, '1994/06/25', '2016/11/10');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (790161658, 'Frannie', 'McLardie', 'Davidescu', '72229 Tennyson Court', 93634773, '1995/09/16', '2018/07/26');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (626987452, 'Octavius', 'Beddin', 'Sarchwell', '114 Hudson Court', 92751224, '1986/06/08', '2018/01/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (609229476, 'Megan', 'Sherred', 'Burgh', '8 Magdeline Way', 93892915, '2000/09/19', '2016/01/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (660869577, 'Ciro', 'Edgar', 'Phippin', '1 Onsgard Place', 93265162, '1986/10/05', '2018/09/18');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (711427022, 'Nealy', 'Goymer', 'Primarolo', '8 Saint Paul Parkway', 92161581, '1996/04/23', '2015/03/17');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (702513266, 'Peirce', 'Wombwell', 'O''Donovan', '93392 Mcbride Road', 93184612, '1993/09/10', '2019/04/29');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (759818404, 'Eolande', 'Newvill', 'Standall', '7826 Dwight Terrace', 94078988, '1987/07/29', '2019/04/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (616832869, 'Pippa', 'Hufton', 'Frank', '9831 Little Fleur Terrace', 93408649, '1997/06/25', '2019/08/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (617580954, 'Ian', 'Algeo', 'Robet', '02546 Northview Way', 91740163, '1997/08/06', '2017/07/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (771588856, 'Conn', 'Radnedge', 'Rivilis', '9 Farmco Park', 92449610, '1992/11/27', '2017/03/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (654699710, 'Lotta', 'Dufer', 'De Angelis', '1584 Dahle Street', 92558550, '1995/12/25', '2015/09/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (661315579, 'Wilow', 'Chasmoor', 'Capsey', '40 Mccormick Parkway', 93679630, '1995/07/08', '2019/04/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (706875134, 'Mano', 'Crenshaw', 'Cuskery', '2 Leroy Parkway', 94606992, '1989/08/19', '2015/01/07');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (752050294, 'Syman', 'Mion', 'Leagas', '540 Russell Parkway', 94628768, '1988/03/15', '2017/06/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (696819060, 'Alvin', 'Kohrsen', 'McDonand', '4 Wayridge Crossing', 90229995, '1991/08/12', '2015/03/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (678071965, 'Florian', 'Quigley', 'Ickowics', '68 Sachtjen Park', 93378671, '1991/09/25', '2019/02/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (677620589, 'Lydia', 'Gornar', 'Davidovitz', '18 Arizona Way', 91215688, '2000/02/28', '2015/08/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (724454621, 'Brok', 'Haverson', 'Galtone', '91 Sutteridge Court', 94414153, '1985/12/28', '2019/04/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (711272725, 'Fidela', 'Roubottom', 'Hynd', '0 Chinook Drive', 91388124, '1998/06/19', '2017/02/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (751539365, 'Sidney', 'Pigford', 'Cranch', '54 Luster Plaza', 94302282, '1993/08/08', '2016/04/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (774786968, 'Marlin', 'Spanton', 'Riddeough', '5 Monterey Plaza', 94986717, '1998/07/25', '2015/04/14');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (707583873, 'Dav', 'Attoc', 'Barbier', '20467 Norway Maple Drive', 95140624, '1994/07/12', '2017/12/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (766000088, 'Bea', 'Carnier', 'Plose', '12 Hauk Point', 93544395, '1999/11/20', '2016/05/24');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (738248821, 'Alexandre', 'Muris', 'Wickersham', '66 Messerschmidt Pass', 91418627, '1992/10/19', '2019/01/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (737023797, 'Guy', 'Gruby', 'Mapledoore', '816 Golf View Place', 95464028, '1991/07/03', '2015/09/21');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (630942635, 'Herb', 'Milsap', 'Hargrove', '1855 Hagan Park', 91343208, '1994/04/17', '2019/01/31');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (616687416, 'Say', 'Oakes', 'Dodell', '6 Blue Bill Park Place', 90401023, '1998/08/05', '2017/08/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (666424328, 'Di', 'Thornborrow', 'Oliveras', '94 Susan Place', 91801759, '1994/04/02', '2016/12/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (654506043, 'Gusty', 'Sloan', 'Riddall', '86 Bobwhite Place', 90148454, '1997/02/08', '2019/11/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (703529616, 'Georgi', 'Gabbidon', 'De Simoni', '6856 Express Parkway', 92607900, '1988/01/08', '2019/02/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (776957607, 'Gil', 'Manchester', 'Julyan', '0 Manley Court', 94209397, '1990/03/17', '2016/03/30');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (722040776, 'Ned', 'Beddoe', 'Clayhill', '3330 Sloan Hill', 90565393, '1999/03/13', '2016/04/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (605714574, 'Marena', 'Heino', 'Inkpin', '58275 Lyons Lane', 90731826, '1993/03/10', '2016/02/17');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (686170845, 'Dionisio', 'Dionsetto', 'Delahunty', '4814 Buena Vista Park', 92699422, '1993/10/28', '2018/04/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (768399366, 'Jephthah', 'Addicote', 'Neville', '47 Ridge Oak Trail', 91396882, '1997/01/15', '2017/07/25');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (745937579, 'Connie', 'Mohring', 'Camier', '28 Loeprich Pass', 94480518, '1990/02/08', '2016/06/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (626142567, 'Massimiliano', 'Thying', 'Fossick', '02 Aberg Alley', 90797606, '1986/02/20', '2017/08/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (623532877, 'Chicky', 'Androck', 'Borrett', '7714 Lukken Court', 93453733, '1989/01/15', '2019/10/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (602829672, 'Hertha', 'Tommei', 'Martill', '6164 Nova Parkway', 92710485, '1998/04/03', '2016/08/22');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (696329690, 'Patsy', 'Kobisch', 'Heindl', '2 Westerfield Point', 91542304, '1999/08/12', '2018/02/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (614290217, 'Prentiss', 'Dunstall', 'Poland', '83752 Mccormick Court', 91068906, '1995/07/22', '2019/06/26');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (617508298, 'Karyl', 'Sealeaf', 'Zanotti', '36 Kings Drive', 92752917, '1993/05/12', '2018/04/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (788599423, 'Colette', 'Surby', 'Renzini', '3093 Jana Plaza', 93290734, '1995/10/29', '2016/06/17');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (632202471, 'Angus', 'Christmas', 'Foulcher', '8331 Southridge Alley', 95412877, '1985/08/13', '2015/06/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (620038124, 'Chickie', 'Blannin', 'Cust', '21 Eastlawn Crossing', 90907193, '1985/05/31', '2016/05/20');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (697600611, 'Emalee', 'Blodgetts', 'Acors', '8365 Banding Crossing', 93775941, '1985/08/11', '2016/08/19');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (664825714, 'Philomena', 'Champneys', 'Hugonnet', '7 Gale Trail', 94149409, '1987/07/16', '2015/06/29');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (770130461, 'Odilia', 'Tockell', 'Wilkerson', '83608 Nobel Court', 92388224, '1986/05/13', '2016/03/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (636867291, 'Catharina', 'Baily', 'Gravenell', '54 Maple Wood Court', 92636744, '1987/09/11', '2017/03/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (676545843, 'Annamaria', 'Billing', 'Gerritsma', '24352 Anthes Alley', 91813309, '1995/03/09', '2018/04/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (665344392, 'Henry', 'Loggie', 'Morley', '3 Karstens Center', 94183165, '1996/04/13', '2016/05/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (785036488, 'Zenia', 'Bompas', 'Tire', '873 Cordelia Lane', 95360397, '1991/11/24', '2018/04/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (651581404, 'Portia', 'Zink', 'Brockie', '47 Pawling Alley', 91288107, '1995/10/16', '2017/01/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (795241084, 'Celka', 'Freschini', 'Sprull', '760 2nd Place', 91222608, '1989/10/21', '2018/03/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (630641797, 'Catie', 'Nutley', 'MacFadden', '42 Lukken Circle', 94285320, '1987/04/02', '2018/07/19');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (784488816, 'Cristionna', 'Lempke', 'Webben', '13 Bartelt Center', 93703704, '1996/09/04', '2019/07/30');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (746036932, 'Rolph', 'Carlet', 'Meechan', '7 Drewry Park', 94538022, '1995/07/01', '2016/06/22');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (705705630, 'Gaylor', 'McIleen', 'Southcoat', '8360 Clove Point', 91572612, '1987/12/13', '2015/08/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (678670387, 'Madeline', 'Rickaby', 'Sinden', '71997 Acker Junction', 93402913, '1997/07/04', '2019/04/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (700941017, 'Aldridge', 'Ferencowicz', 'Scrimgeour', '12827 Thackeray Circle', 91479405, '1999/11/02', '2017/11/20');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (740825675, 'Nerte', 'Sheldrick', 'Sedwick', '162 Eliot Circle', 95088335, '1992/12/15', '2019/10/09');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (770181338, 'Pascal', 'Pleavin', 'Readwood', '39 Sundown Lane', 94544756, '1985/08/10', '2015/02/09');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (702224160, 'Ranice', 'Foskett', 'Heaslip', '24984 Crescent Oaks Crossing', 95543214, '1994/05/22', '2018/09/16');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (603013119, 'Cleo', 'Southam', 'Yancey', '44593 Esch Pass', 94101527, '1989/11/11', '2015/07/16');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (673865924, 'Celinda', 'Breitler', 'Petrasek', '1686 Kipling Hill', 90715842, '1995/06/12', '2018/11/29');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (777037081, 'Josias', 'McCullen', 'Pistol', '6 New Castle Road', 90720305, '1997/07/28', '2019/05/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (668244026, 'Finn', 'Henrion', 'Hauxley', '0848 Jackson Center', 93169520, '1996/01/02', '2015/12/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (761859781, 'Ludovico', 'Leafe', 'Mayberry', '3461 Manufacturers Place', 91277276, '1990/07/13', '2016/07/30');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (670517095, 'Murielle', 'Riseley', 'Denniston', '9 Village Green Trail', 90056602, '1996/06/22', '2015/12/19');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (642547163, 'Nanete', 'Dunklee', 'Leppard', '09887 Reinke Junction', 93408497, '1997/03/29', '2019/07/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (775700509, 'Aldrich', 'Menichelli', 'Whitesel', '12 Prentice Hill', 93632769, '1994/10/10', '2019/01/28');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (763052276, 'Seth', 'Seagar', 'Twigger', '265 5th Road', 92395963, '1994/12/30', '2019/06/25');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (772628885, 'Noella', 'Gaul', 'Kellitt', '03 Sachs Place', 92416062, '1993/08/11', '2017/01/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (645418159, 'Shayla', 'Fulmen', 'Simmon', '01 Riverside Avenue', 91381254, '1987/10/23', '2015/10/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (758655749, 'Myrlene', 'Tume', 'Mitham', '90 Northfield Hill', 94204214, '1988/03/26', '2019/05/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (752641505, 'Aubry', 'Pert', 'Brosius', '6 Eastwood Center', 90869663, '1993/02/17', '2016/05/15');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (733028213, 'Joycelin', 'Standbridge', 'Lejeune', '005 Commercial Alley', 94090869, '1997/09/07', '2016/04/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (670386797, 'Mufi', 'Alsina', 'Kingham', '4 Summerview Center', 94092814, '1986/12/22', '2016/03/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (788904769, 'Buiron', 'Schirok', 'Pfiffer', '97221 Merchant Trail', 94759574, '1990/03/09', '2016/07/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (735847045, 'Wainwright', 'Cockburn', 'Biffen', '589 Menomonie Point', 94390780, '1986/10/13', '2017/03/23');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (700209399, 'Hamlin', 'McIan', 'Bastone', '420 Stephen Junction', 91057252, '1995/01/17', '2017/02/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (642017367, 'Geneva', 'Willard', 'Frenchum', '18 Northwestern Parkway', 93321244, '1985/11/02', '2018/06/28');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (738094573, 'Conant', 'Colvin', 'Hannabus', '2746 Mayfield Trail', 92831841, '1990/08/22', '2016/07/17');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (758758001, 'Dory', 'Rowlson', 'Batha', '1 Fisk Trail', 93050861, '1986/05/10', '2018/08/13');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (770060842, 'Bayard', 'Gioani', 'Chinnery', '7832 Charing Cross Lane', 94485322, '1997/10/02', '2015/04/06');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (634014585, 'Babb', 'Northleigh', 'Casswell', '43 Bonner Street', 90968529, '1994/09/26', '2018/07/21');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (678088771, 'Kellby', 'Ahmad', 'Hitchens', '8190 Havey Parkway', 95090860, '1999/06/23', '2018/05/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (707336176, 'Cara', 'Edwin', 'Feavers', '819 Di Loreto Pass', 90164002, '1987/11/17', '2016/07/30');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (792759742, 'Aleta', 'Pendlington', 'Burdett', '6466 Brickson Park Pass', 94514234, '1997/11/12', '2015/08/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (602443726, 'Tammy', 'Lambswood', 'Biggen', '1 Waubesa Alley', 91743365, '1993/05/16', '2019/07/31');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (792940431, 'Orson', 'Aulds', 'Streets', '6 Welch Street', 94474147, '1991/02/15', '2016/01/09');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (773912465, 'Jolyn', 'Markovic', 'Rudiger', '732 Melby Center', 94229487, '1993/01/12', '2016/04/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (777835322, 'Field', 'Sheehan', 'Shelmerdine', '2400 Morrow Junction', 93778604, '1991/01/31', '2016/10/09');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (633419849, 'Merridie', 'Kloisner', 'Versey', '28977 Melody Parkway', 90485249, '1991/11/24', '2016/03/27');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (673404866, 'Randy', 'Vasishchev', 'Glaves', '0 Holy Cross Pass', 93666858, '1986/08/02', '2016/12/26');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (698789435, 'Marius', 'Zavattieri', 'Rainforth', '1 Hansons Pass', 92479257, '1999/10/09', '2019/05/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (688356507, 'Stella', 'Corke', 'Dawkes', '289 Summit Trail', 94738927, '1992/11/15', '2018/11/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (636488296, 'Sharleen', 'Deboick', 'Lowthian', '39856 Badeau Park', 92185433, '1988/04/20', '2015/07/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (716453826, 'Sigismund', 'Shadfourth', 'Jedrych', '12309 Lakeland Parkway', 94423258, '1994/03/14', '2018/04/20');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (745034564, 'Lisbeth', 'Mallam', 'Conklin', '3650 Westport Circle', 90180245, '1991/07/16', '2017/12/31');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (722616912, 'Milty', 'Mattimoe', 'Delcastel', '31 Bobwhite Park', 90190854, '1987/07/25', '2019/07/21');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (679878636, 'Padget', 'O''Kieran', 'Dawltrey', '65 Clove Road', 90451712, '1991/01/29', '2016/08/02');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (729646893, 'Hobie', 'Howton', 'Dooley', '795 Bay Alley', 93416596, '1991/10/05', '2019/03/04');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (732254136, 'Barnie', 'Vears', 'Ornelas', '5 Charing Cross Point', 91271262, '1994/05/06', '2015/02/26');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (749501814, 'Brockie', 'Crumpe', 'Exeter', '59661 Heath Junction', 94180987, '1988/05/02', '2019/05/03');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (686950191, 'Rolf', 'Haddon', 'Rosenberger', '772 Mifflin Parkway', 91637181, '1985/11/18', '2017/03/11');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (700192908, 'Fayette', 'Harbard', 'Handscomb', '086 Johnson Hill', 92107740, '1985/08/23', '2018/04/01');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (727586437, 'Sayre', 'Brooker', 'Debnam', '6 Thackeray Court', 92048841, '2000/10/15', '2017/03/26');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (690289036, 'Calvin', 'Golbourn', 'Ziemens', '7 Graedel Circle', 94961498, '1987/02/06', '2015/09/08');
insert into Academia.Administrativo (ID_Administrativo, Nombre, Apellido1, Apellido2, Direccion, Numero_telefono, Fecha_nacimiento, Fecha_ingreso) values (734046652, 'Thayne', 'Weir', 'Kembley', '79323 Laurel Point', 95160914, '1993/12/30', '2019/03/23');

-- insercion en Academia.Aula 
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (1, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (2, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (3, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (4, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (5, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (6, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (7, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (8, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (9, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (10, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (11, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (12, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (13, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (14, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (15, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (16, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (17, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (18, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (19, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (20, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (21, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (22, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (23, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (24, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (25, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (26, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (27, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (28, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (29, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (30, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (31, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (32, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (33, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (34, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (35, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (36, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (37, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (38, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (39, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (40, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (41, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (42, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (43, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (44, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (45, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (46, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (47, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (48, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (49, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (50, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (51, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (52, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (53, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (54, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (55, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (56, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (57, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (58, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (59, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (60, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (61, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (62, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (63, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (64, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (65, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (66, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (67, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (68, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (69, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (70, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (71, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (72, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (73, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (74, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (75, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (76, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (77, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (78, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (79, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (80, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (81, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (82, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (83, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (84, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (85, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (86, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (87, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (88, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (89, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (90, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (91, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (92, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (93, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (94, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (95, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (96, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (97, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (98, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (99, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (100, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (101, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (102, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (103, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (104, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (105, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (106, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (107, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (108, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (109, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (110, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (111, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (112, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (113, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (114, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (115, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (116, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (117, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (118, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (119, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (120, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (121, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (122, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (123, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (124, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (125, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (126, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (127, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (128, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (129, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (130, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (131, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (132, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (133, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (134, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (135, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (136, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (137, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (138, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (139, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (140, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (141, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (142, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (143, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (144, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (145, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (146, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (147, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (148, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (149, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (150, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (151, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (152, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (153, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (154, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (155, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (156, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (157, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (158, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (159, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (160, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (161, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (162, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (163, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (164, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (165, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (166, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (167, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (168, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (169, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (170, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (171, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (172, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (173, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (174, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (175, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (176, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (177, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (178, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (179, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (180, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (181, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (182, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (183, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (184, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (185, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (186, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (187, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (188, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (189, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (190, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (191, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (192, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (193, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (194, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (195, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (196, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (197, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (198, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (199, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (200, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (201, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (202, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (203, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (204, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (205, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (206, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (207, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (208, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (209, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (210, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (211, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (212, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (213, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (214, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (215, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (216, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (217, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (218, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (219, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (220, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (221, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (222, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (223, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (224, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (225, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (226, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (227, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (228, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (229, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (230, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (231, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (232, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (233, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (234, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (235, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (236, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (237, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (238, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (239, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (240, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (241, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (242, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (243, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (244, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (245, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (246, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (247, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (248, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (249, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (250, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (251, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (252, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (253, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (254, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (255, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (256, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (257, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (258, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (259, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (260, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (261, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (262, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (263, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (264, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (265, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (266, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (267, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (268, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (269, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (270, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (271, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (272, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (273, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (274, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (275, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (276, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (277, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (278, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (279, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (280, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (281, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (282, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (283, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (284, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (285, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (286, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (287, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (288, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (289, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (290, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (291, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (292, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (293, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (294, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (295, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (296, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (297, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (298, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (299, 25);
insert into Academia.Aula (ID_Aula, Capacidad_maxima) values (300, 25);

-- insercion en Academia.Artes
insert into Academia.Arte (ID_Arte, Nombre) values (1, 'Pintura');
insert into Academia.Arte (ID_Arte, Nombre) values (2, 'Danza');
insert into Academia.Arte (ID_Arte, Nombre) values (3, 'Arquitectura');
insert into Academia.Arte (ID_Arte, Nombre) values (4, 'Musica');
insert into Academia.Arte (ID_Arte, Nombre) values (5, 'Literatura');
insert into Academia.Arte (ID_Arte, Nombre) values (6, 'Cine');
insert into Academia.Arte (ID_Arte, Nombre) values (7, 'Escultura');
insert into Academia.Arte (ID_Arte, Nombre) values (8, 'Fotografia');
insert into Academia.Arte (ID_Arte, Nombre) values (9, 'Opera');
insert into Academia.Arte (ID_Arte, Nombre) values (10, 'Teatro');
insert into Academia.Arte (ID_Arte, Nombre) values (11, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (12, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (13, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (14, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (15, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (16, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (17, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (18, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (19, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (20, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (21, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (22, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (23, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (24, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (25, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (26, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (27, 'Khaki');
insert into Academia.Arte (ID_Arte, Nombre) values (28, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (29, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (30, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (31, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (32, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (33, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (34, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (35, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (36, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (37, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (38, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (39, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (40, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (41, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (42, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (43, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (44, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (45, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (46, 'Khaki');
insert into Academia.Arte (ID_Arte, Nombre) values (47, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (48, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (49, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (50, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (51, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (52, 'Yellow');
insert into Academia.Arte (ID_Arte, Nombre) values (53, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (54, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (55, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (56, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (57, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (58, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (59, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (60, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (61, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (62, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (63, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (64, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (65, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (66, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (67, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (68, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (69, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (70, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (71, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (72, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (73, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (74, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (75, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (76, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (77, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (78, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (79, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (80, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (81, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (82, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (83, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (84, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (85, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (86, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (87, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (88, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (89, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (90, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (91, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (92, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (93, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (94, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (95, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (96, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (97, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (98, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (99, 'Yellow');
insert into Academia.Arte (ID_Arte, Nombre) values (100, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (101, 'Khaki');
insert into Academia.Arte (ID_Arte, Nombre) values (102, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (103, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (104, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (105, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (106, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (107, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (108, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (109, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (110, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (111, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (112, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (113, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (114, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (115, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (116, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (117, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (118, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (119, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (120, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (121, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (122, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (123, 'Yellow');
insert into Academia.Arte (ID_Arte, Nombre) values (124, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (125, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (126, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (127, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (128, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (129, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (130, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (131, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (132, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (133, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (134, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (135, 'Khaki');
insert into Academia.Arte (ID_Arte, Nombre) values (136, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (137, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (138, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (139, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (140, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (141, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (142, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (143, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (144, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (145, 'Yellow');
insert into Academia.Arte (ID_Arte, Nombre) values (146, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (147, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (148, 'Khaki');
insert into Academia.Arte (ID_Arte, Nombre) values (149, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (150, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (151, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (152, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (153, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (154, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (155, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (156, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (157, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (158, 'Yellow');
insert into Academia.Arte (ID_Arte, Nombre) values (159, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (160, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (161, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (162, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (163, 'Yellow');
insert into Academia.Arte (ID_Arte, Nombre) values (164, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (165, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (166, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (167, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (168, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (169, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (170, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (171, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (172, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (173, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (174, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (175, 'Khaki');
insert into Academia.Arte (ID_Arte, Nombre) values (176, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (177, 'Khaki');
insert into Academia.Arte (ID_Arte, Nombre) values (178, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (179, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (180, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (181, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (182, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (183, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (184, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (185, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (186, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (187, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (188, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (189, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (190, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (191, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (192, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (193, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (194, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (195, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (196, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (197, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (198, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (199, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (200, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (201, 'Khaki');
insert into Academia.Arte (ID_Arte, Nombre) values (202, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (203, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (204, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (205, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (206, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (207, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (208, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (209, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (210, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (211, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (212, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (213, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (214, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (215, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (216, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (217, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (218, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (219, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (220, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (221, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (222, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (223, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (224, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (225, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (226, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (227, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (228, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (229, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (230, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (231, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (232, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (233, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (234, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (235, 'Yellow');
insert into Academia.Arte (ID_Arte, Nombre) values (236, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (237, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (238, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (239, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (240, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (241, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (242, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (243, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (244, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (245, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (246, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (247, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (248, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (249, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (250, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (251, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (252, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (253, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (254, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (255, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (256, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (257, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (258, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (259, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (260, 'Purple');
insert into Academia.Arte (ID_Arte, Nombre) values (261, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (262, 'Aquamarine');
insert into Academia.Arte (ID_Arte, Nombre) values (263, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (264, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (265, 'Khaki');
insert into Academia.Arte (ID_Arte, Nombre) values (266, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (267, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (268, 'Yellow');
insert into Academia.Arte (ID_Arte, Nombre) values (269, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (270, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (271, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (272, 'Fuscia');
insert into Academia.Arte (ID_Arte, Nombre) values (273, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (274, 'Yellow');
insert into Academia.Arte (ID_Arte, Nombre) values (275, 'Indigo');
insert into Academia.Arte (ID_Arte, Nombre) values (276, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (277, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (278, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (279, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (280, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (281, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (282, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (283, 'Teal');
insert into Academia.Arte (ID_Arte, Nombre) values (284, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (285, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (286, 'Violet');
insert into Academia.Arte (ID_Arte, Nombre) values (287, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (288, 'Maroon');
insert into Academia.Arte (ID_Arte, Nombre) values (289, 'Crimson');
insert into Academia.Arte (ID_Arte, Nombre) values (290, 'Goldenrod');
insert into Academia.Arte (ID_Arte, Nombre) values (291, 'Green');
insert into Academia.Arte (ID_Arte, Nombre) values (292, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (293, 'Red');
insert into Academia.Arte (ID_Arte, Nombre) values (294, 'Turquoise');
insert into Academia.Arte (ID_Arte, Nombre) values (295, 'Orange');
insert into Academia.Arte (ID_Arte, Nombre) values (296, 'Pink');
insert into Academia.Arte (ID_Arte, Nombre) values (297, 'Mauv');
insert into Academia.Arte (ID_Arte, Nombre) values (298, 'Blue');
insert into Academia.Arte (ID_Arte, Nombre) values (299, 'Puce');
insert into Academia.Arte (ID_Arte, Nombre) values (300, 'Turquoise');

-- insercion en Academia.Curso 
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (1, 'Pintura de Agua', 4, 156176699, 40000, 'Lunes', '8:00 AM', 1);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (2, 'Danza Contemporanea', 1, 130439755, 40000, 'Martes', '10:00 AM', 2);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (3, 'AutoCat', 5, 243370119, 40000, 'Miercoles', '1:00 PM', 3);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (4, 'Guitarra', 5, 357448920, 70000, 'Jueves', '4:00 PM', 4);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (5, 'Poesia', 7, 130439755, 60000, 'viernes', '6:00 PM', 5);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (6, 'Drama', 5, 386972047, 80000, 'Sabado', '7:00 PM', 6);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (7, 'Escultura en Piedra', 2, 352417810, 40000, 'Lunes', '8:00 AM', 7);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (8, 'Fotografia Digital', 5, 264139487, 60000, 'Martes', '10:00 AM', 8);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (9, 'Canto Profundo', 5, 386972047, 30000, 'Miercoles', '1:00 PM', 9);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (10, 'Actuacion Real', 4, 352417810, 30000, 'Jueves', '4:00 PM', 10);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (11, 'Columba palumbus', 5, 130439755, 80000, 'viernes', '6:00 PM', 11);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (12, 'Litrocranius walleri', 10, 315946337, 60000, 'Sabado', '7:00 PM', 12);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (13, 'Gazella thompsonii', 1, 365760523, 70000, 'Lunes', '8:00 AM', 13);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (14, 'Erinaceus frontalis', 9, 130439755, 50000, 'Martes', '10:00 AM', 14);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (15, 'Terrapene carolina', 2, 264087727, 40000, 'Miercoles', '1:00 PM', 15);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (16, 'Prionace glauca', 2, 130439755, 40000, 'Jueves', '4:00 PM', 16);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (17, 'Papio ursinus', 6, 386972047, 40000, 'viernes', '6:00 PM', 17);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (18, 'Papio cynocephalus', 3, 264087727, 30000, 'Sabado', '7:00 PM', 18);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (19, 'Haliaeetus leucocephalus', 9, 285816849, 40000, 'Lunes', '8:00 AM', 19);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (20, 'Callorhinus ursinus', 9, 285816849, 60000, 'Martes', '10:00 AM', 20);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (21, 'Grus rubicundus', 7, 100619454, 80000, 'Miercoles', '1:00 PM', 21);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (22, 'Uraeginthus angolensis', 5, 357448920, 80000, 'Jueves', '4:00 PM', 22);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (23, 'Cathartes aura', 9, 247026125, 70000, 'viernes', '6:00 PM', 23);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (24, 'Perameles nasuta', 4, 285816849, 80000, 'Sabado', '7:00 PM', 24);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (25, 'Genetta genetta', 4, 315946337, 50000, 'Lunes', '8:00 AM', 25);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (26, 'Eumetopias jubatus', 10, 386972047, 40000, 'Martes', '10:00 AM', 26);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (27, 'Callorhinus ursinus', 1, 285816849, 40000, 'Miercoles', '1:00 PM', 27);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (28, 'Pteronura brasiliensis', 2, 234192453, 70000, 'Jueves', '4:00 PM', 28);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (29, 'Dasypus septemcincus', 3, 234192453, 20000, 'viernes', '6:00 PM', 29);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (30, 'Larus fuliginosus', 9, 264139487, 40000, 'Sabado', '7:00 PM', 30);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (31, 'Rhea americana', 8, 120224652, 60000, 'Lunes', '8:00 AM', 31);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (32, 'Columba palumbus', 3, 301522332, 30000, 'Martes', '10:00 AM', 32);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (33, 'Cervus canadensis', 8, 315946337, 70000, 'Miercoles', '1:00 PM', 33);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (34, 'Sagittarius serpentarius', 10, 357448920, 40000, 'Jueves', '4:00 PM', 34);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (35, 'Rhea americana', 5, 247026125, 40000, 'viernes', '6:00 PM', 35);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (36, 'Odocoilenaus virginianus', 2, 243370119, 80000, 'Sabado', '7:00 PM', 36);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (37, 'Diomedea irrorata', 5, 352417810, 40000, 'Lunes', '8:00 AM', 37);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (38, 'Semnopithecus entellus', 9, 365760523, 40000, 'Martes', '10:00 AM', 38);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (39, 'Felis concolor', 9, 100619454, 20000, 'Miercoles', '1:00 PM', 39);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (40, 'Sciurus niger', 3, 357448920, 20000, 'Jueves', '4:00 PM', 40);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (41, 'Balearica pavonina', 3, 295618933, 30000, 'viernes', '6:00 PM', 41);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (42, 'Mazama gouazoubira', 7, 243370119, 40000, 'Sabado', '7:00 PM', 42);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (43, 'Columba palumbus', 9, 365760523, 30000, 'Lunes', '8:00 AM', 43);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (44, 'Bucorvus leadbeateri', 6, 315946337, 60000, 'Martes', '10:00 AM', 44);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (45, 'Zosterops pallidus', 7, 295618933, 50000, 'Miercoles', '1:00 PM', 45);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (46, 'Mirounga angustirostris', 5, 386972047, 20000, 'Jueves', '4:00 PM', 46);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (47, 'Eunectes sp.', 7, 295618933, 70000, 'viernes', '6:00 PM', 47);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (48, 'Cervus unicolor', 8, 106907301, 30000, 'Sabado', '7:00 PM', 48);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (49, 'Anas bahamensis', 8, 365760523, 60000, 'Lunes', '8:00 AM', 49);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (50, 'Stercorarius longicausus', 4, 315946337, 30000, 'Martes', '10:00 AM', 50);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (51, 'Ratufa indica', 3, 234192453, 70000, 'Miercoles', '1:00 PM', 51);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (52, 'Toxostoma curvirostre', 9, 365760523, 30000, 'Jueves', '4:00 PM', 52);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (53, 'unavailable', 1, 120224652, 60000, 'viernes', '6:00 PM', 53);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (54, 'Corvus brachyrhynchos', 7, 234192453, 40000, 'Sabado', '7:00 PM', 54);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (55, 'Cebus apella', 7, 357448920, 30000, 'Lunes', '8:00 AM', 55);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (56, 'Lophoaetus occipitalis', 7, 234192453, 70000, 'Martes', '10:00 AM', 56);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (57, 'Gyps bengalensis', 2, 264087727, 50000, 'Miercoles', '1:00 PM', 57);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (58, 'Acrobates pygmaeus', 3, 301522332, 70000, 'Jueves', '4:00 PM', 58);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (59, 'Chlidonias leucopterus', 8, 357448920, 30000, 'viernes', '6:00 PM', 59);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (60, 'Sciurus niger', 8, 285816849, 20000, 'Sabado', '7:00 PM', 60);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (61, 'Graspus graspus', 1, 315946337, 70000, 'Lunes', '8:00 AM', 61);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (62, 'Propithecus verreauxi', 7, 357448920, 80000, 'Martes', '10:00 AM', 62);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (63, 'Canis mesomelas', 2, 113813522, 70000, 'Miercoles', '1:00 PM', 63);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (64, 'Platalea leucordia', 6, 387966897, 80000, 'Jueves', '4:00 PM', 64);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (65, 'Corallus hortulanus cooki', 6, 357448920, 70000, 'viernes', '6:00 PM', 65);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (66, 'Bubalus arnee', 7, 301522332, 50000, 'Sabado', '7:00 PM', 66);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (67, 'Nycticorax nycticorax', 5, 295618933, 50000, 'Lunes', '8:00 AM', 67);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (68, 'Oryx gazella', 6, 386972047, 60000, 'Martes', '10:00 AM', 68);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (69, 'Cynictis penicillata', 5, 100619454, 20000, 'Miercoles', '1:00 PM', 69);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (70, 'Odocoileus hemionus', 1, 357448920, 50000, 'Jueves', '4:00 PM', 70);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (71, 'Felis libyca', 7, 365760523, 30000, 'viernes', '6:00 PM', 71);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (72, 'Castor fiber', 6, 295618933, 20000, 'Sabado', '7:00 PM', 72);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (73, 'Phaethon aethereus', 3, 365760523, 60000, 'Lunes', '8:00 AM', 73);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (74, 'Chordeiles minor', 1, 315946337, 30000, 'Martes', '10:00 AM', 74);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (75, 'unavailable', 1, 130439755, 50000, 'Miercoles', '1:00 PM', 75);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (76, 'Gekko gecko', 6, 387966897, 20000, 'Jueves', '4:00 PM', 76);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (77, 'Ratufa indica', 10, 315946337, 20000, 'viernes', '6:00 PM', 77);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (78, 'Canis lupus', 3, 100619454, 20000, 'Sabado', '7:00 PM', 78);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (79, 'Helogale undulata', 10, 243370119, 80000, 'Lunes', '8:00 AM', 79);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (80, 'Rhabdomys pumilio', 8, 352417810, 70000, 'Martes', '10:00 AM', 80);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (81, 'Phalacrocorax niger', 9, 234192453, 60000, 'Miercoles', '1:00 PM', 81);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (82, 'Coluber constrictor', 7, 120224652, 40000, 'Jueves', '4:00 PM', 82);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (83, 'Antidorcas marsupialis', 4, 295618933, 60000, 'viernes', '6:00 PM', 83);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (84, 'Sylvicapra grimma', 2, 357448920, 60000, 'Sabado', '7:00 PM', 84);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (85, 'Tockus flavirostris', 9, 365760523, 60000, 'Lunes', '8:00 AM', 85);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (86, 'Tachyglossus aculeatus', 3, 386972047, 60000, 'Martes', '10:00 AM', 86);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (87, 'Hystrix indica', 10, 357448920, 70000, 'Miercoles', '1:00 PM', 87);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (88, 'Meles meles', 6, 264139487, 60000, 'Jueves', '4:00 PM', 88);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (89, 'Chordeiles minor', 6, 100619454, 50000, 'viernes', '6:00 PM', 89);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (90, 'Corvus brachyrhynchos', 4, 106907301, 50000, 'Sabado', '7:00 PM', 90);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (91, 'Eremophila alpestris', 2, 301522332, 50000, 'Lunes', '8:00 AM', 91);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (92, 'Crocuta crocuta', 9, 352417810, 20000, 'Martes', '10:00 AM', 92);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (93, 'Casmerodius albus', 5, 113813522, 80000, 'Miercoles', '1:00 PM', 93);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (94, 'Echimys chrysurus', 9, 315946337, 60000, 'Jueves', '4:00 PM', 94);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (95, 'Psophia viridis', 10, 100619454, 50000, 'viernes', '6:00 PM', 95);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (96, 'Bassariscus astutus', 10, 130439755, 80000, 'Sabado', '7:00 PM', 96);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (97, 'Phalacrocorax carbo', 3, 113813522, 80000, 'Lunes', '8:00 AM', 97);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (98, 'Phacochoerus aethiopus', 7, 120224652, 40000, 'Martes', '10:00 AM', 98);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (99, 'Theropithecus gelada', 3, 264087727, 60000, 'Miercoles', '1:00 PM', 99);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (100, 'Alcelaphus buselaphus cokii', 8, 301522332, 30000, 'Jueves', '4:00 PM', 100);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (101, 'Dendrocygna viduata', 1, 295618933, 30000, 'viernes', '6:00 PM', 101);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (102, 'Heloderma horridum', 1, 113813522, 30000, 'Sabado', '7:00 PM', 102);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (103, 'Phalaropus lobatus', 4, 301522332, 30000, 'Lunes', '8:00 AM', 103);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (104, 'Smithopsis crassicaudata', 9, 264087727, 40000, 'Martes', '10:00 AM', 104);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (105, 'Castor fiber', 2, 234192453, 70000, 'Miercoles', '1:00 PM', 105);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (106, 'Nyctereutes procyonoides', 6, 106907301, 50000, 'Jueves', '4:00 PM', 106);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (107, 'Melanerpes erythrocephalus', 6, 247026125, 80000, 'viernes', '6:00 PM', 107);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (108, 'Phaethon aethereus', 5, 315946337, 70000, 'Sabado', '7:00 PM', 108);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (109, 'Parus atricapillus', 7, 100619454, 50000, 'Lunes', '8:00 AM', 109);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (110, 'Pycnonotus nigricans', 7, 120224652, 70000, 'Martes', '10:00 AM', 110);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (111, 'Tenrec ecaudatus', 5, 386972047, 40000, 'Miercoles', '1:00 PM', 111);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (112, 'Anas bahamensis', 9, 120224652, 20000, 'Jueves', '4:00 PM', 112);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (113, 'Giraffe camelopardalis', 6, 100619454, 40000, 'viernes', '6:00 PM', 113);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (114, 'Megaderma spasma', 10, 301522332, 50000, 'Sabado', '7:00 PM', 114);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (115, 'Dasypus novemcinctus', 9, 234192453, 30000, 'Lunes', '8:00 AM', 115);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (116, 'Graspus graspus', 10, 100619454, 40000, 'Martes', '10:00 AM', 116);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (117, 'Laniarius ferrugineus', 2, 130439755, 80000, 'Miercoles', '1:00 PM', 117);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (118, 'Corvus albicollis', 7, 386972047, 40000, 'Jueves', '4:00 PM', 118);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (119, 'Phalaropus lobatus', 1, 120224652, 70000, 'viernes', '6:00 PM', 119);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (120, 'Nyctanassa violacea', 9, 130439755, 70000, 'Sabado', '7:00 PM', 120);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (121, 'Colaptes campestroides', 3, 295618933, 80000, 'Lunes', '8:00 AM', 121);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (122, 'Crotalus triseriatus', 3, 243370119, 30000, 'Martes', '10:00 AM', 122);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (123, 'Dusicyon thous', 5, 387966897, 20000, 'Miercoles', '1:00 PM', 123);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (124, 'Paroaria gularis', 3, 264139487, 20000, 'Jueves', '4:00 PM', 124);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (125, 'Axis axis', 5, 264087727, 80000, 'viernes', '6:00 PM', 125);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (126, 'Grus antigone', 5, 264087727, 80000, 'Sabado', '7:00 PM', 126);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (127, 'Cordylus giganteus', 2, 295618933, 20000, 'Lunes', '8:00 AM', 127);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (128, 'Acanthaster planci', 8, 234192453, 30000, 'Martes', '10:00 AM', 128);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (129, 'Genetta genetta', 3, 120224652, 50000, 'Miercoles', '1:00 PM', 129);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (130, 'Genetta genetta', 5, 234192453, 60000, 'Jueves', '4:00 PM', 130);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (131, 'Zalophus californicus', 8, 130439755, 40000, 'viernes', '6:00 PM', 131);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (132, 'Sylvilagus floridanus', 5, 387966897, 50000, 'Sabado', '7:00 PM', 132);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (133, 'Canis lupus lycaon', 9, 285816849, 50000, 'Lunes', '8:00 AM', 133);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (134, 'Cacatua galerita', 3, 130439755, 80000, 'Martes', '10:00 AM', 134);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (135, 'Tauraco porphyrelophus', 6, 234192453, 40000, 'Miercoles', '1:00 PM', 135);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (136, 'Cacatua galerita', 10, 295618933, 30000, 'Jueves', '4:00 PM', 136);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (137, 'Zonotrichia capensis', 9, 357448920, 30000, 'viernes', '6:00 PM', 137);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (138, 'Lophoaetus occipitalis', 3, 156176699, 20000, 'Sabado', '7:00 PM', 138);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (139, 'Drymarchon corias couperi', 9, 386972047, 60000, 'Lunes', '8:00 AM', 139);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (140, 'Larus novaehollandiae', 8, 386972047, 20000, 'Martes', '10:00 AM', 140);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (141, 'Neophoca cinerea', 9, 295618933, 70000, 'Miercoles', '1:00 PM', 141);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (142, 'Galictis vittata', 6, 365760523, 30000, 'Jueves', '4:00 PM', 142);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (143, 'Butorides striatus', 2, 243370119, 40000, 'viernes', '6:00 PM', 143);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (144, 'Anser anser', 5, 264139487, 40000, 'Sabado', '7:00 PM', 144);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (145, 'Rhea americana', 3, 295618933, 30000, 'Lunes', '8:00 AM', 145);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (146, 'Castor fiber', 4, 301522332, 60000, 'Martes', '10:00 AM', 146);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (147, 'Geococcyx californianus', 4, 295618933, 60000, 'Miercoles', '1:00 PM', 147);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (148, 'Threskionis aethiopicus', 4, 113813522, 70000, 'Jueves', '4:00 PM', 148);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (149, 'Spermophilus richardsonii', 6, 120224652, 50000, 'viernes', '6:00 PM', 149);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (150, 'Canis aureus', 1, 247026125, 30000, 'Sabado', '7:00 PM', 150);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (151, 'Ovis musimon', 7, 365760523, 60000, 'Lunes', '8:00 AM', 151);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (152, 'Tadorna tadorna', 2, 295618933, 70000, 'Martes', '10:00 AM', 152);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (153, 'Cebus nigrivittatus', 6, 243370119, 50000, 'Miercoles', '1:00 PM', 153);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (154, 'Ardea cinerea', 7, 264139487, 80000, 'Jueves', '4:00 PM', 154);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (155, 'Perameles nasuta', 4, 295618933, 50000, 'viernes', '6:00 PM', 155);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (156, 'Hyaena brunnea', 8, 301522332, 60000, 'Sabado', '7:00 PM', 156);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (157, 'Zonotrichia capensis', 10, 156176699, 80000, 'Lunes', '8:00 AM', 157);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (158, 'Herpestes javanicus', 2, 295618934, 60000, 'Martes', '10:00 AM', 158);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (159, 'Axis axis', 3, 285816849, 80000, 'Miercoles', '1:00 PM', 159);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (160, 'Lamprotornis chalybaeus', 8, 264139487, 30000, 'Jueves', '4:00 PM', 160);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (161, 'Dusicyon thous', 3, 285816849, 80000, 'viernes', '6:00 PM', 161);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (162, 'Manouria emys', 5, 130439755, 30000, 'Sabado', '7:00 PM', 162);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (163, 'Bubo virginianus', 9, 315946337, 40000, 'Lunes', '8:00 AM', 163);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (164, 'Tiliqua scincoides', 5, 264139487, 60000, 'Martes', '10:00 AM', 164);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (165, 'Carduelis uropygialis', 7, 264087727, 70000, 'Miercoles', '1:00 PM', 165);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (166, 'Tiliqua scincoides', 4, 264139487, 20000, 'Jueves', '4:00 PM', 166);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (167, 'Lamprotornis nitens', 7, 100619454, 30000, 'viernes', '6:00 PM', 167);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (168, 'Meleagris gallopavo', 9, 243370119, 70000, 'Sabado', '7:00 PM', 168);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (169, 'Neotis denhami', 10, 247026125, 20000, 'Lunes', '8:00 AM', 169);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (170, 'Gyps bengalensis', 6, 352417810, 70000, 'Martes', '10:00 AM', 170);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (171, 'Balearica pavonina', 10, 387966897, 30000, 'Miercoles', '1:00 PM', 171);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (172, 'Mazama gouazoubira', 6, 285816849, 50000, 'Jueves', '4:00 PM', 172);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (173, 'Hymenolaimus malacorhynchus', 2, 264139487, 50000, 'viernes', '6:00 PM', 173);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (174, 'Myrmecophaga tridactyla', 9, 301522332, 60000, 'Sabado', '7:00 PM', 174);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (175, 'Chauna torquata', 4, 120224652, 30000, 'Lunes', '8:00 AM', 175);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (176, 'Varanus albigularis', 10, 113813522, 40000, 'Martes', '10:00 AM', 176);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (177, 'Eutamias minimus', 8, 243370115, 80000, 'Miercoles', '1:00 PM', 177);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (178, 'Ammospermophilus nelsoni', 9, 315946337, 80000, 'Jueves', '4:00 PM', 178);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (179, 'Phalaropus lobatus', 6, 285816849, 60000, 'viernes', '6:00 PM', 179);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (180, 'Merops nubicus', 8, 301522332, 80000, 'Sabado', '7:00 PM', 180);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (181, 'Tragelaphus strepsiceros', 1, 264139487, 70000, 'Lunes', '8:00 AM', 181);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (182, 'Phalaropus fulicarius', 7, 387966877, 30000, 'Martes', '10:00 AM', 182);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (183, 'Ateles paniscus', 8, 264087727, 50000, 'Miercoles', '1:00 PM', 183);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (184, 'Junonia genoveua', 8, 315946337, 40000, 'Jueves', '4:00 PM', 184);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (185, 'Butorides striatus', 7, 315946337, 40000, 'viernes', '6:00 PM', 185);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (186, 'Larus novaehollandiae', 2, 365760523, 60000, 'Sabado', '7:00 PM', 186);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (187, 'Cebus apella', 7, 100619454, 70000, 'Lunes', '8:00 AM', 187);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (188, 'Ramphastos tucanus', 7, 234192453, 50000, 'Martes', '10:00 AM', 188);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (189, 'Vanessa indica', 3, 315946337, 60000, 'Miercoles', '1:00 PM', 189);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (190, 'Carduelis pinus', 10, 285816849, 70000, 'Jueves', '4:00 PM', 190);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (191, 'Bubalus arnee', 10, 247026125, 80000, 'viernes', '6:00 PM', 191);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (192, 'Vulpes vulpes', 3, 365760523, 60000, 'Sabado', '7:00 PM', 192);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (193, 'Semnopithecus entellus', 3, 247026125, 70000, 'Lunes', '8:00 AM', 193);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (194, 'Papilio canadensis', 4, 386972047, 50000, 'Martes', '10:00 AM', 194);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (195, 'Carphophis sp.', 5, 264087727, 60000, 'Miercoles', '1:00 PM', 195);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (196, 'Cebus nigrivittatus', 2, 113813522, 70000, 'Jueves', '4:00 PM', 196);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (197, 'Trichosurus vulpecula', 7, 365760523, 50000, 'viernes', '6:00 PM', 197);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (198, 'Tockus flavirostris', 9, 113813522, 40000, 'Sabado', '7:00 PM', 198);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (199, 'Isoodon obesulus', 4, 357448920, 50000, 'Lunes', '8:00 AM', 199);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (200, 'Eremophila alpestris', 10, 365760523, 60000, 'Martes', '10:00 AM', 200);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (201, 'Pedetes capensis', 2, 295618933, 70000, 'Miercoles', '1:00 PM', 201);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (202, 'Spermophilus richardsonii', 5, 130439755, 70000, 'Jueves', '4:00 PM', 202);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (203, 'unavailable', 9, 106907301, 40000, 'viernes', '6:00 PM', 203);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (204, 'Acrobates pygmaeus', 6, 301522332, 50000, 'Sabado', '7:00 PM', 204);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (205, 'Paraxerus cepapi', 3, 106907301, 80000, 'Lunes', '8:00 AM', 205);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (206, 'Theropithecus gelada', 7, 295618933, 20000, 'Martes', '10:00 AM', 206);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (207, 'Cabassous sp.', 1, 113813522, 30000, 'Miercoles', '1:00 PM', 207);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (208, 'Lamprotornis chalybaeus', 8, 247026125, 40000, 'Jueves', '4:00 PM', 208);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (209, 'Uraeginthus granatina', 5, 285816849, 70000, 'viernes', '6:00 PM', 209);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (210, 'Panthera pardus', 1, 285816849, 70000, 'Sabado', '7:00 PM', 210);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (211, 'Chlamydosaurus kingii', 10, 156176699, 60000, 'Lunes', '8:00 AM', 211);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (212, 'Cygnus atratus', 8, 106907301, 70000, 'Martes', '10:00 AM', 212);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (213, 'Macropus robustus', 1, 387966897, 60000, 'Miercoles', '1:00 PM', 213);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (214, 'Potamochoerus porcus', 5, 386972047, 70000, 'Jueves', '4:00 PM', 214);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (215, 'Capra ibex', 7, 285816849, 40000, 'viernes', '6:00 PM', 215);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (216, 'Canis dingo', 2, 130439755, 80000, 'Sabado', '7:00 PM', 216);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (217, 'Manouria emys', 4, 387966897, 20000, 'Lunes', '8:00 AM', 217);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (218, 'Tragelaphus strepsiceros', 6, 120224652, 80000, 'Martes', '10:00 AM', 218);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (219, 'Macaca mulatta', 9, 285816849, 30000, 'Miercoles', '1:00 PM', 219);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (220, 'Turtur chalcospilos', 3, 285816849, 20000, 'Jueves', '4:00 PM', 220);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (221, 'unavailable', 5, 301522332, 50000, 'viernes', '6:00 PM', 221);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (222, 'Tamiasciurus hudsonicus', 6, 130439755, 80000, 'Sabado', '7:00 PM', 222);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (223, 'Paradoxurus hermaphroditus', 2, 100619454, 60000, 'Lunes', '8:00 AM', 223);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (224, 'unavailable', 6, 285816849, 40000, 'Martes', '10:00 AM', 224);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (225, 'Dasyurus maculatus', 9, 357448920, 80000, 'Miercoles', '1:00 PM', 225);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (226, 'Pseudoleistes virescens', 10, 156176699, 60000, 'Jueves', '4:00 PM', 226);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (227, 'Himantopus himantopus', 10, 113813522, 80000, 'viernes', '6:00 PM', 227);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (228, 'Lamprotornis nitens', 9, 113813522, 20000, 'Sabado', '7:00 PM', 228);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (229, 'Felis concolor', 8, 315946337, 30000, 'Lunes', '8:00 AM', 229);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (230, 'Spermophilus parryii', 4, 247026125, 20000, 'Martes', '10:00 AM', 230);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (231, 'Tayassu tajacu', 5, 130439755, 20000, 'Miercoles', '1:00 PM', 231);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (232, 'Ara chloroptera', 9, 156176699, 80000, 'Jueves', '4:00 PM', 232);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (233, 'Theropithecus gelada', 7, 264139487, 20000, 'viernes', '6:00 PM', 233);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (234, 'Pterocles gutturalis', 3, 352417810, 40000, 'Sabado', '7:00 PM', 234);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (235, 'Psittacula krameri', 6, 387966897, 50000, 'Lunes', '8:00 AM', 235);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (236, 'Dendrocitta vagabunda', 4, 386972047, 30000, 'Martes', '10:00 AM', 236);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (237, 'Sylvilagus floridanus', 6, 243370119, 50000, 'Miercoles', '1:00 PM', 237);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (238, 'Hystrix cristata', 2, 234192453, 70000, 'Jueves', '4:00 PM', 238);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (239, 'Macaca mulatta', 7, 113813522, 20000, 'viernes', '6:00 PM', 239);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (240, 'Salvadora hexalepis', 3, 264139487, 50000, 'Sabado', '7:00 PM', 240);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (241, 'Ursus americanus', 6, 243370119, 70000, 'Lunes', '8:00 AM', 241);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (242, 'Vanellus armatus', 7, 295618933, 40000, 'Martes', '10:00 AM', 242);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (243, 'Bubo virginianus', 2, 357448920, 50000, 'Miercoles', '1:00 PM', 243);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (244, 'Felis concolor', 10, 130439755, 30000, 'Jueves', '4:00 PM', 244);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (245, 'Eubalaena australis', 7, 130439755, 60000, 'viernes', '6:00 PM', 245);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (246, 'Macropus agilis', 7, 156176699, 60000, 'Sabado', '7:00 PM', 246);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (247, 'Ictalurus furcatus', 10, 365760523, 80000, 'Lunes', '8:00 AM', 247);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (248, 'Zosterops pallidus', 4, 301522332, 50000, 'Martes', '10:00 AM', 248);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (249, 'Felis serval', 3, 301522332, 20000, 'Miercoles', '1:00 PM', 249);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (250, 'Spizaetus coronatus', 5, 285816849, 70000, 'Jueves', '4:00 PM', 250);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (251, 'Alopochen aegyptiacus', 9, 264139487, 60000, 'viernes', '6:00 PM', 251);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (252, 'Acrobates pygmaeus', 9, 301522332, 40000, 'Sabado', '7:00 PM', 252);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (253, 'Alopex lagopus', 7, 243370119, 30000, 'Lunes', '8:00 AM', 253);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (254, 'Drymarchon corias couperi', 10, 387966897, 40000, 'Martes', '10:00 AM', 254);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (255, 'Giraffe camelopardalis', 8, 285816849, 50000, 'Miercoles', '1:00 PM', 255);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (256, 'Milvus migrans', 10, 113813522, 20000, 'Jueves', '4:00 PM', 256);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (257, 'Libellula quadrimaculata', 6, 156176699, 30000, 'viernes', '6:00 PM', 257);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (258, 'Crotalus adamanteus', 5, 295618933, 60000, 'Sabado', '7:00 PM', 258);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (259, 'Propithecus verreauxi', 4, 285816849, 60000, 'Lunes', '8:00 AM', 259);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (260, 'Boa constrictor mexicana', 9, 156176699, 70000, 'Martes', '10:00 AM', 260);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (261, 'Eolophus roseicapillus', 4, 301522332, 40000, 'Miercoles', '1:00 PM', 261);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (262, 'Zenaida asiatica', 5, 386972047, 80000, 'Jueves', '4:00 PM', 262);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (263, 'Larus dominicanus', 8, 264139487, 60000, 'viernes', '6:00 PM', 263);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (264, 'Otaria flavescens', 3, 264087727, 20000, 'Sabado', '7:00 PM', 264);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (265, 'Odocoileus hemionus', 9, 386972047, 60000, 'Lunes', '8:00 AM', 265);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (266, 'Alopex lagopus', 4, 352417810, 50000, 'Martes', '10:00 AM', 266);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (267, 'Trichosurus vulpecula', 5, 386972047, 80000, 'Miercoles', '1:00 PM', 267);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (268, 'Butorides striatus', 1, 100619454, 80000, 'Jueves', '4:00 PM', 268);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (269, 'unavailable', 8, 285816849, 70000, 'viernes', '6:00 PM', 269);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (270, 'Spheniscus mendiculus', 2, 352417810, 40000, 'Sabado', '7:00 PM', 270);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (271, 'Galictis vittata', 3, 301522332, 50000, 'Lunes', '8:00 AM', 271);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (272, 'Nyctereutes procyonoides', 7, 234192453, 30000, 'Martes', '10:00 AM', 272);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (273, 'Odocoilenaus virginianus', 1, 264139487, 30000, 'Miercoles', '1:00 PM', 273);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (274, 'Carduelis uropygialis', 10, 106907301, 60000, 'Jueves', '4:00 PM', 274);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (275, 'Leptoptilus dubius', 3, 386972047, 40000, 'viernes', '6:00 PM', 275);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (276, 'Felis libyca', 8, 156176699, 80000, 'Sabado', '7:00 PM', 276);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (277, 'Turtur chalcospilos', 3, 247026125, 50000, 'Lunes', '8:00 AM', 277);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (278, 'Oreotragus oreotragus', 1, 130439755, 60000, 'Martes', '10:00 AM', 278);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (279, 'Lycosa godeffroyi', 6, 156176699, 30000, 'Miercoles', '1:00 PM', 279);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (280, 'Anser anser', 1, 130439755, 80000, 'Jueves', '4:00 PM', 280);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (281, 'Lycosa godeffroyi', 10, 264087727, 20000, 'viernes', '6:00 PM', 281);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (282, 'Varanus sp.', 9, 113813522, 50000, 'Sabado', '7:00 PM', 282);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (283, 'Perameles nasuta', 4, 247026125, 30000, 'Lunes', '8:00 AM', 283);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (284, 'Cacatua tenuirostris', 4, 357448920, 80000, 'Martes', '10:00 AM', 284);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (285, 'unavailable', 4, 357448920, 20000, 'Miercoles', '1:00 PM', 285);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (286, 'Sus scrofa', 4, 352417810, 50000, 'Jueves', '4:00 PM', 286);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (287, 'Alopochen aegyptiacus', 6, 264087727, 40000, 'viernes', '6:00 PM', 287);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (288, 'Pterocles gutturalis', 8, 352417810, 60000, 'Sabado', '7:00 PM', 288);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (289, 'Grus antigone', 1, 100619454, 50000, 'Lunes', '8:00 AM', 289);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (290, 'Iguana iguana', 1, 285816849, 60000, 'Martes', '10:00 AM', 290);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (291, 'Bugeranus caruncalatus', 10, 100619454, 70000, 'Miercoles', '1:00 PM', 291);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (292, 'Mirounga angustirostris', 8, 285816849, 20000, 'Jueves', '4:00 PM', 292);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (293, 'Papio ursinus', 2, 301522332, 40000, 'viernes', '6:00 PM', 293);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (294, 'Cebus apella', 8, 264139487, 20000, 'Sabado', '7:00 PM', 294);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (295, 'Eubalaena australis', 10, 113813522, 30000, 'Lunes', '8:00 AM', 295);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (296, 'Cervus unicolor', 9, 285816849, 40000, 'Martes', '10:00 AM', 296);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (297, 'Actophilornis africanus', 2, 387966897, 40000, 'Miercoles', '1:00 PM', 297);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (298, 'Eolophus roseicapillus', 2, 156176699, 60000, 'Jueves', '4:00 PM', 298);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (299, 'Sylvicapra grimma', 6, 247026125, 60000, 'viernes', '6:00 PM', 299);
insert into Academia.Curso (ID_Curso, Nombre, ID_Arte, ID_Profesor, Costo, Dia, Hora, ID_Aula) values (300, 'Panthera leo', 5, 357448920, 20000, 'Sabado', '7:00 PM', 300);

--insercion en Academia.Proveedor 
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (1, 'Dabjam', 28856181);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (2, 'Myworks', 23680684);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (3, 'Zoomdog', 27269582);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (4, 'Kare', 27264114);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (5, 'Blognation', 25720989);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (6, 'Abatz', 27663847);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (7, 'Skyble', 22772932);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (8, 'Zooxo', 26600008);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (9, 'Zoombox', 26009568);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (10, 'Quinu', 24855323);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (11, 'Skinder', 28121468);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (12, 'Fliptune', 28064621);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (13, 'Cogidoo', 22166547);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (14, 'Snaptags', 27065105);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (15, 'Topiczoom', 27681054);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (16, 'Fiveclub', 27823422);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (17, 'Gigabox', 22812214);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (18, 'Latz', 25311426);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (19, 'Quinu', 26214127);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (20, 'Babbleopia', 28331079);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (21, 'Quaxo', 28796820);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (22, 'Blognation', 22700964);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (23, 'Katz', 26227168);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (24, 'Demimbu', 22733401);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (25, 'Avavee', 22805629);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (26, 'Ooba', 27403709);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (27, 'Gigashots', 23314082);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (28, 'Abata', 27760518);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (29, 'Pixope', 27516997);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (30, 'Divanoodle', 24674197);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (31, 'Flipbug', 26433485);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (32, 'Aimbo', 26766266);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (33, 'Vinder', 23626172);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (34, 'Meevee', 25880276);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (35, 'Flashpoint', 28106919);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (36, 'Flashpoint', 23159633);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (37, 'Lazzy', 25211755);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (38, 'Wordify', 27885502);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (39, 'Geba', 22694114);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (40, 'Linklinks', 24933100);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (41, 'Yoveo', 27602120);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (42, 'Rhycero', 27713673);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (43, 'Skilith', 25771572);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (44, 'Topicblab', 23862108);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (45, 'Zazio', 24994593);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (46, 'Eare', 23803434);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (47, 'Jazzy', 24027861);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (48, 'Tekfly', 25538289);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (49, 'Kazu', 22736745);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (50, 'Wordify', 26815224);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (51, 'Voomm', 26951759);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (52, 'Kayveo', 23468394);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (53, 'Yoveo', 28637939);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (54, 'Npath', 22108355);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (55, 'Rhyloo', 24102456);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (56, 'Youspan', 28138532);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (57, 'BlogXS', 27239035);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (58, 'Devpoint', 26892775);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (59, 'Skimia', 27138990);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (60, 'Buzzbean', 23361073);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (61, 'Trunyx', 26542306);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (62, 'Jetpulse', 22854342);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (63, 'Gigazoom', 28368275);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (64, 'Izio', 27797299);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (65, 'Feedmix', 23943630);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (66, 'Twimm', 22142794);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (67, 'Jamia', 23838205);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (68, 'Nlounge', 22955781);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (69, 'Yoveo', 27284552);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (70, 'Mydeo', 28790344);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (71, 'Reallinks', 23762894);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (72, 'InnoZ', 24727820);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (73, 'Voolia', 25961224);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (74, 'Trunyx', 23048898);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (75, 'Demizz', 28048104);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (76, 'Photobug', 28506304);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (77, 'Voonyx', 26413152);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (78, 'Tagcat', 28179057);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (79, 'Kwinu', 23838498);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (80, 'Photobug', 22299408);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (81, 'Thoughtblab', 24039813);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (82, 'Zoombeat', 26186882);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (83, 'Fivebridge', 24067256);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (84, 'Roomm', 22543216);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (85, 'Babbleopia', 25600743);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (86, 'Podcat', 28062173);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (87, 'Twitterlist', 26326119);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (88, 'Divavu', 24522211);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (89, 'Feedfish', 27770325);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (90, 'Bubblemix', 24517328);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (91, 'Buzzdog', 27376789);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (92, 'Oba', 28086068);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (93, 'Kanoodle', 27260589);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (94, 'Edgeblab', 28460052);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (95, 'Zoomcast', 27406042);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (96, 'Linklinks', 22139778);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (97, 'Oyope', 22431867);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (98, 'Rhyloo', 27259000);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (99, 'Devpoint', 22373214);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (100, 'Brainlounge', 25522519);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (101, 'Rhyloo', 22695900);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (102, 'Eire', 27788082);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (103, 'Bubbletube', 23316714);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (104, 'Zoomcast', 28177091);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (105, 'Brainverse', 23559352);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (106, 'Photospace', 27004264);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (107, 'Browsedrive', 24242449);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (108, 'Jayo', 22834382);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (109, 'Feedfire', 26030817);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (110, 'Gabvine', 27806118);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (111, 'Flashspan', 28624878);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (112, 'Zoomlounge', 22171702);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (113, 'Topdrive', 22359120);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (114, 'Avamba', 22897466);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (115, 'Yoveo', 28851405);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (116, 'Vidoo', 22935796);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (117, 'Realmix', 26753486);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (118, 'Realbuzz', 27927882);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (119, 'Yombu', 27526157);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (120, 'Geba', 24307914);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (121, 'Eimbee', 22197751);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (122, 'Mybuzz', 27203265);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (123, 'Mybuzz', 24527994);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (124, 'Avamm', 27056345);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (125, 'Skaboo', 25068316);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (126, 'Brainverse', 25548180);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (127, 'Livetube', 23178422);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (128, 'Twimbo', 22049708);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (129, 'Yodo', 22158512);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (130, 'Twitterlist', 27858363);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (131, 'Gabvine', 23925604);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (132, 'Plambee', 26592098);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (133, 'Realmix', 28087277);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (134, 'Roomm', 22548479);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (135, 'Livetube', 23194513);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (136, 'Browseblab', 22943758);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (137, 'Yakidoo', 25702182);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (138, 'Mycat', 28306036);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (139, 'Dabfeed', 22328448);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (140, 'Fiveclub', 28676693);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (141, 'Thoughtsphere', 27895634);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (142, 'Thoughtmix', 27757527);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (143, 'Photobug', 25623201);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (144, 'Brightbean', 23435183);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (145, 'Abata', 22672819);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (146, 'Trilith', 23841944);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (147, 'Zooveo', 26581822);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (148, 'Dabjam', 25197326);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (149, 'Kazu', 26434630);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (150, 'Rhyzio', 22546397);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (151, 'Roombo', 23528843);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (152, 'Talane', 27631011);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (153, 'Devbug', 22510564);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (154, 'Gabtype', 27642058);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (155, 'Yodel', 22825175);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (156, 'Skyble', 27969498);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (157, 'Voonix', 28554699);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (158, 'Camido', 25616044);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (159, 'Jetwire', 23471383);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (160, 'Fadeo', 25332080);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (161, 'Wordtune', 23865030);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (162, 'Edgeclub', 23701369);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (163, 'Zoovu', 22088847);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (164, 'Viva', 25583649);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (165, 'Kazio', 28476985);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (166, 'Realcube', 23175450);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (167, 'Ntag', 27101901);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (168, 'Youbridge', 28156084);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (169, 'Tagopia', 26489598);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (170, 'Jabbertype', 23376029);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (171, 'Tazzy', 25225758);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (172, 'Eare', 28870792);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (173, 'Vitz', 24398034);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (174, 'Fivechat', 26303412);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (175, 'Riffpedia', 25916418);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (176, 'Yombu', 22781057);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (177, 'Vinte', 28647416);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (178, 'Voomm', 24489410);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (179, 'Livetube', 27529237);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (180, 'Feedfish', 26859949);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (181, 'Jetpulse', 23892373);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (182, 'Leenti', 25794873);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (183, 'Skiptube', 24070651);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (184, 'Layo', 27901356);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (185, 'Jatri', 28681778);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (186, 'Skimia', 24751209);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (187, 'Skyba', 25660220);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (188, 'Thoughtstorm', 22697044);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (189, 'Devshare', 23307670);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (190, 'Zoomcast', 26013402);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (191, 'Thoughtmix', 23505419);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (192, 'Oba', 24551059);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (193, 'Tagtune', 23971634);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (194, 'Twinte', 25411481);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (195, 'Digitube', 24224048);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (196, 'Kayveo', 27562382);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (197, 'DabZ', 25344633);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (198, 'Voomm', 22813000);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (199, 'Wordpedia', 22729401);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (200, 'Dabvine', 26809638);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (201, 'Centimia', 24276947);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (202, 'Miboo', 26884834);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (203, 'Eadel', 26205090);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (204, 'Youspan', 25345504);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (205, 'Leenti', 24659442);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (206, 'Quatz', 22081100);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (207, 'Innojam', 23643314);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (208, 'Zoozzy', 25818039);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (209, 'Skyble', 23900981);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (210, 'Fanoodle', 28447368);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (211, 'Brainsphere', 22120585);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (212, 'Aimbu', 25017763);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (213, 'Quimm', 22782141);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (214, 'Avavee', 26948987);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (215, 'Brainverse', 23762037);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (216, 'Yamia', 22674483);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (217, 'Babblestorm', 28254695);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (218, 'Twitterbridge', 24511443);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (219, 'Meedoo', 27854070);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (220, 'Dynava', 23476376);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (221, 'Trudeo', 25513031);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (222, 'Yozio', 23165169);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (223, 'Blogtag', 28340929);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (224, 'Wikizz', 22479847);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (225, 'Fatz', 28507151);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (226, 'Jabberbean', 25842063);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (227, 'Quaxo', 27162199);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (228, 'Demimbu', 23083890);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (229, 'Skaboo', 24712327);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (230, 'Dynazzy', 25158855);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (231, 'Edgetag', 28998789);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (232, 'Trilia', 24457291);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (233, 'Fivebridge', 26649535);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (234, 'Riffpedia', 26032765);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (235, 'Devbug', 22390387);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (236, 'Bubblemix', 23859804);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (237, 'Shufflester', 28971851);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (238, 'Mynte', 27686698);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (239, 'Skippad', 28812068);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (240, 'Kwilith', 22038935);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (241, 'Zoomdog', 27233148);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (242, 'Gabtype', 24866286);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (243, 'Thoughtsphere', 25297034);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (244, 'Topiczoom', 22041935);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (245, 'Demivee', 28356921);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (246, 'Oodoo', 28555450);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (247, 'Kwilith', 24733034);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (248, 'Rhyloo', 25450899);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (249, 'Yodel', 26164196);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (250, 'Jaxworks', 22256063);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (251, 'Dazzlesphere', 24740192);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (252, 'Yodel', 26412180);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (253, 'Feednation', 28234915);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (254, 'Realfire', 24154227);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (255, 'Brightbean', 23960453);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (256, 'Skipstorm', 26053842);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (257, 'Yombu', 28398384);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (258, 'Vipe', 26632683);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (259, 'Bubbletube', 24192781);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (260, 'Feedspan', 27539674);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (261, 'Youspan', 26260286);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (262, 'Ailane', 27973776);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (263, 'Ozu', 26819829);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (264, 'Snaptags', 25862913);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (265, 'Realcube', 23498208);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (266, 'Jetpulse', 28246997);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (267, 'Gigashots', 23614008);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (268, 'Rhynyx', 24982099);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (269, 'Gigaclub', 22100072);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (270, 'Ozu', 25516556);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (271, 'Yadel', 22840594);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (272, 'Meembee', 27308167);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (273, 'Realcube', 25443186);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (274, 'Topicblab', 26617177);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (275, 'Kwideo', 27769544);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (276, 'Yamia', 27096795);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (277, 'Mycat', 24494070);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (278, 'Jayo', 28446362);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (279, 'Gabspot', 22279351);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (280, 'Omba', 23036947);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (281, 'Yozio', 23229226);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (282, 'Jaloo', 22685887);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (283, 'Rhyzio', 27468832);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (284, 'Feedmix', 24834923);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (285, 'Topicware', 26717205);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (286, 'Digitube', 27070518);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (287, 'Wordware', 22247535);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (288, 'Voolia', 23048506);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (289, 'Fiveclub', 22669974);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (290, 'Yombu', 22377634);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (291, 'Dynabox', 28777382);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (292, 'Trilia', 24612585);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (293, 'Edgetag', 23367028);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (294, 'Skyndu', 22105314);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (295, 'JumpXS', 26392893);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (296, 'Zoovu', 28869997);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (297, 'Tagfeed', 23623014);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (298, 'Browseblab', 27184986);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (299, 'Yata', 25491657);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (300, 'Nlounge', 28011726);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (301, 'Skibox', 23250907);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (302, 'BlogXS', 24376496);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (303, 'Trilia', 26499832);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (304, 'Kimia', 27692973);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (305, 'Abata', 25075851);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (306, 'Skimia', 24164502);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (307, 'Trilith', 24046761);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (308, 'Browsebug', 25105751);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (309, 'Wordtune', 24482362);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (310, 'Tazz', 23065743);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (311, 'Babbleset', 25171491);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (312, 'Jabbersphere', 26512811);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (313, 'Plambee', 27815915);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (314, 'Meeveo', 27631330);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (315, 'Izio', 25075292);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (316, 'Gigashots', 27632705);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (317, 'Babbleset', 28989385);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (318, 'Rhybox', 28021848);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (319, 'Zooveo', 24048577);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (320, 'Zoomlounge', 26254358);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (321, 'Reallinks', 26827549);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (322, 'Devbug', 23826918);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (323, 'Meevee', 25366132);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (324, 'Oba', 24074148);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (325, 'Eidel', 23488326);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (326, 'Jaloo', 25567011);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (327, 'Katz', 28328423);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (328, 'Skyndu', 27979425);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (329, 'Linklinks', 25493314);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (330, 'Zava', 28092245);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (331, 'Shufflebeat', 22388080);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (332, 'Flashset', 25396358);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (333, 'Photojam', 27091284);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (334, 'Meejo', 28907003);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (335, 'DabZ', 25984995);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (336, 'Oloo', 27545698);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (337, 'Photobug', 22145051);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (338, 'Yakijo', 22071183);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (339, 'Topicblab', 24281133);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (340, 'Dynazzy', 23745130);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (341, 'Trupe', 22094234);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (342, 'Flashpoint', 22279696);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (343, 'Blogtags', 27743690);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (344, 'Midel', 26308718);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (345, 'Vinder', 28077762);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (346, 'Blogtags', 22857321);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (347, 'Oodoo', 24341125);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (348, 'Fivebridge', 25138754);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (349, 'Jabberstorm', 26976351);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (350, 'Eabox', 25746874);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (351, 'Flipopia', 25238292);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (352, 'Cogilith', 23789623);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (353, 'Dynabox', 22172437);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (354, 'Jaxworks', 27426737);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (355, 'Wikivu', 26463178);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (356, 'Skyndu', 27070282);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (357, 'Quatz', 22058373);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (358, 'Eazzy', 22977430);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (359, 'Oyoba', 25021304);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (360, 'Fatz', 23344298);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (361, 'Ooba', 26210249);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (362, 'Kwimbee', 27513976);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (363, 'Ooba', 23969733);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (364, 'Youspan', 24087599);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (365, 'Kwideo', 26717075);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (366, 'Einti', 26326752);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (367, 'Oozz', 26262513);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (368, 'Edgeblab', 26852066);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (369, 'Rhyzio', 23705919);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (370, 'Gigabox', 22919651);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (371, 'Photobug', 28881777);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (372, 'Skimia', 23070012);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (373, 'Vinte', 24706576);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (374, 'Bubblebox', 25207540);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (375, 'Tagpad', 26754712);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (376, 'Wikibox', 22909515);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (377, 'Skinder', 25638566);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (378, 'Riffpath', 22850067);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (379, 'Devpulse', 22150736);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (380, 'Skippad', 22767231);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (381, 'Bubblemix', 23757467);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (382, 'Kaymbo', 23534491);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (383, 'Zoomdog', 28787062);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (384, 'Tagtune', 28987423);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (385, 'Zoomcast', 28818781);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (386, 'Mydeo', 25906699);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (387, 'Twitterbridge', 27936831);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (388, 'Photobean', 25092992);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (389, 'Skinte', 28733914);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (390, 'Dabvine', 25382039);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (391, 'Talane', 27456019);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (392, 'Rhynoodle', 28499750);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (393, 'Realcube', 23613452);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (394, 'Youspan', 27704858);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (395, 'Quire', 25545304);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (396, 'Edgetag', 28279835);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (397, 'Meembee', 24655853);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (398, 'Mycat', 24871291);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (399, 'Skiptube', 22052504);
insert into Academia.Proveedor (ID_Proveedor, Nombre_Empresa, Telefono) values (400, 'Skidoo', 23807745);

--inserción en Academia.Presentacion
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (1, 'Synergistic upward-trending process improvement', 264139487, 17, '2018/06/02', '1:30', 'Tsuruoka');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (2, 'Fully-configurable intangible flexibility', 113813522, 1, '2015/06/20', '2:30', 'Krajan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (3, 'Devolved clear-thinking capacity', 247026125, 1, '2015/11/18', '1:00', 'Kromy');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (4, 'Business-focused content-based Graphic Interface', 264139487, 11, '2019/04/22', '3:00', 'Kalininskiy');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (5, 'Universal static approach', 387966897, 18, '2017/09/22', '2:00', 'Castleknock');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (6, 'User-centric neutral leverage', 234192453, 10, '2016/08/02', '2:30', 'Casuguran');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (7, 'Exclusive 4th generation local area network', 264139487, 16, '2017/01/03', '2:30', 'Daoxu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (8, 'Customizable client-server moderator', 264087727, 10, '2019/08/18', '2:30', 'Mouriscas');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (9, 'Assimilated system-worthy support', 156176699, 13, '2015/04/17', '1:00', 'Leiwang');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (10, 'Visionary foreground help-desk', 247026125, 14, '2019/04/14', '1:30', 'Ozerki');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (11, 'Assimilated hybrid installation', 387966897, 12, '2016/02/12', '1:30', 'København');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (12, 'Versatile modular neural-net', 106907301, 18, '2016/03/06', '1:30', 'Dampol');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (13, 'Face to face scalable forecast', 264087727, 4, '2019/05/06', '3:30', 'Smolyan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (14, 'Persistent uniform customer loyalty', 352417810, 18, '2017/01/17', '3:30', 'Kusatsu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (15, 'Secured attitude-oriented projection', 352417810, 5, '2015/11/02', '3:00', 'Shuhong');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (16, 'Streamlined next generation throughput', 315946337, 20, '2016/07/29', '2:30', 'Shichuan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (17, 'De-engineered mission-critical capacity', 295618933, 20, '2017/07/11', '2:00', 'Cachoeiras de Macacu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (18, 'Switchable asymmetric infrastructure', 120224652, 13, '2015/07/31', '3:00', 'Rovensko pod Troskami');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (19, 'Multi-channelled regional synergy', 130439755, 18, '2017/03/17', '1:00', 'Banjar Timbrah');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (20, 'Multi-tiered systemic core', 365760523, 16, '2017/06/13', '1:30', 'Jengglungharjo');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (21, 'Configurable 24 hour protocol', 120224652, 8, '2016/09/06', '2:30', 'Bail');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (22, 'Advanced modular knowledge base', 106907301, 1, '2017/04/07', '1:30', 'Villa Cañás');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (23, 'De-engineered reciprocal customer loyalty', 264139487, 1, '2019/06/10', '2:30', 'Viesīte');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (24, 'Cloned asymmetric contingency', 386972047, 14, '2015/12/10', '1:00', 'Tqibuli');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (25, 'Advanced cohesive Graphical User Interface', 243370119, 5, '2017/07/29', '1:30', 'Salaberry-de-Valleyfield');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (26, 'Ameliorated encompassing parallelism', 295618933, 20, '2015/03/06', '3:00', 'Fulu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (27, 'Ameliorated interactive adapter', 264139487, 4, '2019/07/10', '1:00', 'Ya’erya');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (28, 'Synergized optimizing architecture', 264087727, 1, '2017/02/06', '3:30', 'Stamáta');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (29, 'Compatible heuristic array', 247026125, 20, '2019/01/25', '1:00', 'Malangwa');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (30, 'Team-oriented homogeneous flexibility', 386972047, 6, '2017/11/19', '2:00', 'Maiorca');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (31, 'Pre-emptive context-sensitive complexity', 156176699, 18, '2018/11/16', '3:00', 'Uzdin');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (32, 'Multi-lateral intangible initiative', 357448920, 16, '2018/11/10', '3:00', 'Sieniawa Żarska');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (33, 'Persevering incremental algorithm', 100619454, 6, '2017/10/21', '1:30', 'Wangkung');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (34, 'Programmable even-keeled interface', 315946337, 6, '2018/11/29', '1:00', 'Beirut');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (35, 'Optional real-time customer loyalty', 156176699, 17, '2015/11/09', '3:30', 'Nerópolis');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (36, 'Devolved motivating hub', 100619454, 9, '2018/05/20', '1:00', 'Mampong');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (37, 'Digitized incremental knowledge base', 386972047, 8, '2015/07/10', '2:00', 'Niafunké');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (38, 'Advanced explicit knowledge user', 247026125, 1, '2019/06/06', '3:30', 'Vilhena');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (39, 'Configurable disintermediate monitoring', 264087727, 10, '2019/08/24', '3:30', 'Bosaso');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (40, 'Optional bottom-line projection', 113813522, 14, '2018/06/29', '1:00', 'Finspång');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (41, 'Persistent holistic task-force', 264087727, 14, '2015/07/14', '3:00', 'Jacaraú');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (42, 'Grass-roots needs-based software', 386972047, 2, '2018/04/15', '2:30', 'Emiliano Zapata');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (43, 'Inverse 24 hour firmware', 285816849, 13, '2018/02/19', '3:00', 'Maredakamau');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (44, 'Re-engineered zero', 285816849, 15, '2018/11/01', '3:00', 'Qiancheng');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (45, 'Multi-layered needs-based flexibility', 243370119, 10, '2018/11/16', '2:30', 'Gandu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (46, 'Down-sized zero defect paradigm', 285816849, 20, '2017/07/22', '3:30', 'Belajen');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (47, 'Organized modular solution', 295618933, 4, '2016/01/25', '3:00', 'Bilyayivka');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (48, 'Upgradable homogeneous methodology', 264139487, 8, '2018/05/16', '2:00', 'Nariño');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (49, 'Mandatory asymmetric strategy', 100619454, 16, '2018/02/21', '2:00', 'Mojo');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (50, 'Robust fresh-thinking knowledge base', 386972047, 2, '2018/09/16', '3:30', 'Jimo');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (51, 'Realigned upward-trending structure', 352417810, 7, '2015/10/10', '2:30', 'Lolodorf');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (52, 'Devolved discrete approach', 387966897, 3, '2017/01/26', '3:30', 'Lidian');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (53, 'Synergistic local service-desk', 113813522, 2, '2018/11/04', '1:30', 'Pukou');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (54, 'Function-based demand-driven synergy', 234192453, 8, '2017/02/25', '1:00', 'Mendes');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (55, 'Object-based tangible artificial intelligence', 234192453, 7, '2015/06/30', '3:30', 'Erátyra');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (56, 'User-centric bifurcated intranet', 285816849, 20, '2016/02/22', '3:00', 'Dehang');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (57, 'Universal 6th generation initiative', 130439755, 19, '2019/06/25', '3:00', 'Sobue');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (58, 'Pre-emptive bi-directional approach', 315946337, 19, '2015/07/13', '1:30', 'København');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (59, 'Synchronised multimedia project', 247026125, 5, '2019/06/01', '1:00', 'Thị Trấn Na Sầm');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (60, 'Persistent 24/7 solution', 264139487, 19, '2019/03/22', '2:30', 'Cha-am');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (61, 'Polarised regional system engine', 113813522, 13, '2018/08/06', '3:00', 'Tilburg');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (62, 'Cross-group reciprocal extranet', 113813522, 19, '2018/03/19', '3:00', 'Sitajara');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (63, 'Function-based directional hierarchy', 301522332, 7, '2017/08/05', '2:30', 'Tumxuk');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (64, 'Progressive 3rd generation conglomeration', 120224652, 4, '2016/09/13', '3:30', 'Salmi');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (65, 'Face to face mobile contingency', 295618933, 2, '2017/02/12', '3:00', 'Shirokaya Rechka');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (66, 'Multi-layered scalable pricing structure', 386972047, 6, '2018/05/25', '3:00', 'Akhaltsikhe');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (67, 'Down-sized zero defect project', 243370119, 9, '2019/08/28', '3:00', 'Shuyuan Zhen');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (68, 'Profound real-time extranet', 113813522, 14, '2019/02/08', '3:00', 'Vryburg');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (69, 'Customer-focused real-time groupware', 264087727, 2, '2019/01/31', '1:30', 'Zelenogradsk');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (70, 'Fundamental zero defect knowledge user', 156176699, 20, '2017/09/14', '3:30', 'Paoay');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (71, 'Upgradable reciprocal data-warehouse', 247026125, 5, '2017/05/08', '3:00', 'Alangalang');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (72, 'Intuitive attitude-oriented hierarchy', 264087727, 5, '2018/12/19', '2:00', 'Potosí');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (73, 'Switchable mission-critical policy', 365760523, 9, '2015/05/27', '1:30', 'Dehui');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (74, 'Adaptive demand-driven alliance', 386972047, 3, '2016/10/16', '3:00', 'Argasari');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (75, 'Grass-roots zero administration workforce', 352417810, 11, '2019/01/29', '2:30', 'Palumbungan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (76, 'Face to face high-level core', 234192453, 9, '2016/12/10', '3:00', 'Salcedo');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (77, 'Self-enabling clear-thinking alliance', 243370119, 2, '2019/05/11', '1:00', 'Bureya');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (78, 'Customizable maximized solution', 357448920, 10, '2017/09/09', '3:30', 'Harding');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (79, 'Enterprise-wide heuristic focus group', 315946337, 5, '2016/04/10', '1:30', 'Port Loko');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (80, 'Operative actuating internet solution', 243370119, 2, '2015/06/13', '2:30', 'Enrile');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (81, 'Optional fault-tolerant protocol', 113813522, 9, '2015/03/21', '2:00', 'Bánica');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (82, 'Networked static data-warehouse', 386972047, 13, '2018/09/23', '1:00', 'Badian');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (83, 'Horizontal asynchronous task-force', 365760523, 6, '2016/05/17', '1:00', 'Bulualto');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (84, 'Configurable user-facing definition', 365760523, 7, '2015/05/12', '2:30', 'Palauig');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (85, 'Business-focused human-resource knowledge user', 295618933, 15, '2017/11/23', '3:00', 'Las Americas');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (86, 'Integrated 24/7 ability', 106907301, 10, '2018/03/10', '1:30', 'Télimélé');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (87, 'Ergonomic fault-tolerant conglomeration', 301522332, 11, '2017/02/06', '3:00', 'Gbarnga');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (88, 'Expanded uniform help-desk', 264139487, 10, '2017/12/14', '3:30', 'Cigemlong');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (89, 'Managed motivating archive', 264139487, 2, '2018/11/12', '1:00', 'Progreso');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (90, 'User-centric executive superstructure', 156176699, 16, '2015/03/23', '1:30', 'Phú Mỹ');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (91, 'Triple-buffered interactive emulation', 106907301, 4, '2019/03/14', '3:00', 'Zvečan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (92, 'Customizable scalable matrix', 357448920, 18, '2015/12/15', '1:30', 'Vitoria-Gasteiz');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (93, 'Team-oriented upward-trending middleware', 100619454, 18, '2015/11/19', '3:30', 'Pittsburgh');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (94, 'Reduced multi-tasking infrastructure', 387966897, 13, '2015/10/31', '1:30', 'Shangyang');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (95, 'Inverse real-time projection', 357448920, 13, '2017/03/03', '2:00', 'Gulao');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (96, 'Enterprise-wide well-modulated adapter', 285816849, 3, '2018/02/25', '3:30', 'Itu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (97, 'Decentralized scalable frame', 156176699, 5, '2015/03/15', '1:30', 'Zhouzai');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (98, 'Vision-oriented intangible concept', 130439755, 12, '2016/04/22', '3:00', 'Chucatamani');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (99, 'Exclusive global throughput', 285816849, 5, '2018/03/28', '1:00', 'Bangker');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (100, 'Reduced modular leverage', 100619454, 12, '2019/09/26', '1:00', 'Banjarsari');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (101, 'Multi-layered bandwidth-monitored toolset', 301522332, 4, '2016/02/23', '2:30', 'Thành Phố Nam Định');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (102, 'Innovative logistical functionalities', 301522332, 9, '2017/02/14', '2:30', 'Qiucun');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (103, 'Cloned systematic website', 243370119, 10, '2018/12/21', '2:30', 'Jiaoqiao');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (104, 'Programmable bandwidth-monitored access', 352417810, 3, '2017/12/29', '3:00', 'Darwin');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (105, 'Synergistic high-level challenge', 387966897, 6, '2018/03/13', '3:30', 'Leijiadian');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (106, 'Balanced tangible Graphic Interface', 247026125, 4, '2019/05/12', '2:30', 'Coishco');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (107, 'Re-engineered 4th generation implementation', 234192453, 1, '2019/07/22', '1:00', 'Ganjiangtou');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (108, 'Customizable neutral help-desk', 120224652, 2, '2016/03/05', '3:00', 'Kotabunan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (109, 'Multi-channelled full-range service-desk', 120224652, 4, '2016/10/08', '1:00', 'Pakisaji');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (110, 'Customizable methodical middleware', 243370119, 11, '2017/10/04', '2:00', 'Mochishche');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (111, 'Stand-alone fault-tolerant algorithm', 365760523, 10, '2019/08/13', '3:30', 'Tierralta');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (112, 'Advanced 24/7 middleware', 100619454, 4, '2017/10/12', '3:30', 'Kontagora');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (113, 'Synchronised content-based protocol', 365760523, 8, '2019/07/09', '3:30', 'Purral');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (114, 'Ameliorated national paradigm', 234192453, 1, '2016/10/16', '3:30', 'Jiuxian');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (115, 'Configurable background database', 352417810, 16, '2017/07/29', '3:00', 'Ustynivka');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (116, 'Team-oriented value-added protocol', 247026125, 8, '2019/06/07', '2:00', 'Ragay');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (117, 'Business-focused radical productivity', 285816849, 2, '2017/06/04', '3:30', 'Yangxiang');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (118, 'Digitized asynchronous knowledge base', 295618933, 18, '2015/07/22', '3:30', 'Prado');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (119, 'Total human-resource methodology', 352417810, 15, '2019/08/26', '1:30', 'Bełsznica');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (120, 'Extended even-keeled knowledge user', 315946337, 19, '2016/11/13', '1:30', 'Świętajno');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (121, 'Extended real-time open system', 264087727, 6, '2017/06/11', '1:00', 'Baddomalhi');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (122, 'Networked background function', 106907301, 3, '2015/11/07', '3:30', 'Tanagara');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (123, 'Progressive non-volatile data-warehouse', 130439755, 6, '2016/08/23', '3:00', 'Kobayashi');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (124, 'Visionary zero administration structure', 113813522, 4, '2019/11/06', '2:30', 'Valença do Douro');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (125, 'Innovative explicit firmware', 106907301, 11, '2019/01/28', '3:30', 'Zyukayka');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (126, 'Managed intangible support', 365760523, 14, '2019/06/07', '2:30', 'Kauman');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (127, 'Polarised system-worthy time-frame', 285816849, 15, '2018/10/04', '2:30', 'Sumuran');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (128, 'Cloned non-volatile hardware', 120224652, 19, '2018/09/10', '2:00', 'Jambubol');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (129, 'Enterprise-wide 24 hour time-frame', 120224652, 11, '2017/12/16', '3:30', 'Shigony');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (130, 'Synchronised heuristic throughput', 243370119, 18, '2017/08/30', '1:00', 'Huolianpo');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (131, 'Realigned homogeneous middleware', 264139487, 12, '2019/10/20', '1:30', 'Baoxu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (132, 'Future-proofed non-volatile internet solution', 285816849, 18, '2016/04/20', '3:30', 'Tutayev');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (133, 'Distributed intangible local area network', 285816849, 14, '2017/03/25', '1:30', 'La Loma');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (134, 'Organized content-based service-desk', 386972047, 20, '2015/10/19', '2:00', 'Lobuni');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (135, 'Devolved attitude-oriented open system', 264139487, 11, '2017/01/13', '3:00', 'Åmål');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (136, 'Stand-alone high-level capacity', 234192453, 14, '2018/07/04', '1:30', 'Zaqatala');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (137, 'Object-based optimal solution', 113813522, 2, '2018/04/15', '1:30', 'Thị Trấn Mộc Châu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (138, 'Customizable tangible challenge', 130439755, 4, '2015/09/29', '1:30', 'Angren');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (139, 'Triple-buffered multi-tasking process improvement', 120224652, 11, '2016/06/25', '2:00', 'Fale old settlement');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (140, 'Re-contextualized static success', 365760523, 4, '2017/03/15', '2:00', 'Le Tampon');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (141, 'Configurable radical methodology', 243370119, 3, '2019/10/06', '3:30', 'Osnabrück');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (142, 'Down-sized 5th generation orchestration', 264087727, 6, '2016/03/31', '1:00', 'Zephyrhills');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (143, 'Profit-focused mobile initiative', 130439755, 16, '2018/04/26', '3:30', 'Viligili');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (144, 'Face to face contextually-based orchestration', 301522332, 15, '2018/03/02', '1:00', 'Huanglong');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (145, 'Down-sized coherent intranet', 352417810, 11, '2016/01/08', '1:00', 'Juazeiro do Norte');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (146, 'Assimilated web-enabled database', 130439755, 3, '2016/04/05', '3:30', 'Rybnoye');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (147, 'Intuitive neutral knowledge base', 285816849, 3, '2015/06/09', '2:00', 'Yajiwa');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (148, 'Persistent zero administration focus group', 130439755, 12, '2016/02/26', '2:00', 'Sagbayan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (149, 'Switchable composite synergy', 156176699, 8, '2019/02/09', '1:30', 'Brak');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (150, 'Devolved needs-based support', 247026125, 1, '2015/05/08', '1:30', 'Babakansari');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (151, 'Integrated homogeneous toolset', 295618933, 2, '2019/10/11', '2:30', 'Kudowa-Zdrój');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (152, 'Versatile multi-tasking support', 301522332, 16, '2018/05/11', '2:30', 'München');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (153, 'User-friendly explicit software', 315946337, 18, '2015/09/04', '1:30', 'Issy-les-Moulineaux');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (154, 'De-engineered intermediate algorithm', 264087727, 13, '2018/10/22', '2:00', 'Irving');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (155, 'Persistent foreground local area network', 285816849, 2, '2015/12/18', '1:30', 'Libertador General San Martín');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (156, 'Switchable next generation Graphic Interface', 264139487, 8, '2015/03/18', '3:00', 'Ar Rābiyah');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (157, 'Profit-focused holistic middleware', 315946337, 8, '2018/10/11', '2:30', 'Houston');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (158, 'Multi-layered needs-based monitoring', 352417810, 20, '2016/01/21', '3:30', 'Jinka');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (159, 'Polarised even-keeled groupware', 113813522, 15, '2016/09/06', '3:00', 'Strzyżowice');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (160, 'Synergized 6th generation interface', 386972047, 8, '2016/12/31', '3:00', 'Bocos');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (161, 'Public-key disintermediate access', 301522332, 4, '2015/04/01', '2:00', 'Arcos');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (162, 'Progressive asymmetric database', 264087727, 6, '2017/06/09', '2:30', 'Wangtai');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (163, 'Profound asynchronous throughput', 264139487, 13, '2015/06/28', '2:30', 'Bourail');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (164, 'Innovative client-driven frame', 357448920, 17, '2019/03/04', '1:00', 'Rungis');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (165, 'Implemented multi-tasking structure', 352417810, 18, '2018/11/11', '1:00', 'Vol’nyy Aul');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (166, 'Face to face discrete open system', 365760523, 6, '2017/12/27', '2:00', 'Ervedosa do Douro');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (167, 'Multi-tiered actuating project', 386972047, 10, '2016/03/11', '2:00', 'Buchou');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (168, 'De-engineered fresh-thinking project', 130439755, 10, '2018/04/23', '1:00', 'Agnibilékrou');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (169, 'Ameliorated asynchronous open architecture', 295618933, 4, '2019/08/08', '1:00', 'Hanušovice');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (170, 'Diverse zero defect customer loyalty', 243370119, 17, '2017/12/01', '3:30', 'Sanguanzhai');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (171, 'Universal intermediate ability', 130439755, 8, '2016/10/25', '2:00', 'Chigang');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (172, 'Mandatory motivating emulation', 106907301, 3, '2018/01/12', '3:00', 'Wakuya');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (173, 'Phased dedicated protocol', 387966897, 5, '2015/04/24', '3:00', 'Sanjiao');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (174, 'Streamlined object-oriented moderator', 156176699, 7, '2018/08/08', '3:00', 'Oslo');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (175, 'Operative systemic project', 120224652, 15, '2016/12/14', '2:30', 'Quận Tân Phú');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (176, 'Realigned analyzing customer loyalty', 352417810, 6, '2017/05/20', '3:30', 'Old Harbour Bay');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (177, 'Programmable tangible info-mediaries', 352417810, 2, '2018/01/29', '3:30', 'Randuagung');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (178, 'Multi-lateral maximized monitoring', 100619454, 1, '2015/09/04', '3:00', 'Zwolle');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (179, 'Customer-focused modular application', 386972047, 7, '2015/03/30', '1:30', 'Jam');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (180, 'Innovative bandwidth-monitored task-force', 120224652, 12, '2017/05/27', '3:00', 'Dagar');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (181, 'Universal human-resource middleware', 156176699, 3, '2018/05/17', '2:00', 'Sangumata');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (182, 'Multi-channelled web-enabled time-frame', 264139487, 16, '2016/12/04', '2:00', 'Honolulu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (183, 'Reverse-engineered 4th generation interface', 387966897, 16, '2019/10/01', '2:30', 'Pyin Oo Lwin');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (184, 'Inverse local structure', 285816849, 11, '2016/05/05', '1:30', 'Wau');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (185, 'Horizontal uniform initiative', 264139487, 20, '2019/01/03', '3:30', 'Norsborg');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (186, 'Re-contextualized bi-directional analyzer', 387966897, 7, '2017/02/03', '3:30', 'Ferrol');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (187, 'Upgradable even-keeled protocol', 264139487, 17, '2015/12/05', '3:00', 'Piaski');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (188, 'Devolved discrete neural-net', 120224652, 20, '2016/07/07', '2:30', 'Sartrouville');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (189, 'Business-focused attitude-oriented analyzer', 100619454, 14, '2018/02/08', '3:30', 'Tunggaoen Timur');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (190, 'Programmable transitional open architecture', 357448920, 13, '2016/07/13', '3:30', 'Taloko');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (191, 'Reduced 4th generation architecture', 301522332, 19, '2017/10/01', '2:00', 'Pantalowice');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (192, 'Diverse coherent extranet', 357448920, 9, '2019/01/26', '2:00', 'Smach Mean Chey');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (193, 'Synergized radical definition', 357448920, 20, '2017/01/20', '2:00', 'Tekes');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (194, 'Vision-oriented incremental application', 264139487, 14, '2017/07/12', '3:00', 'Doāba');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (195, 'Self-enabling explicit model', 243370119, 1, '2018/05/12', '3:00', 'Stavanger');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (196, 'Centralized human-resource interface', 106907301, 12, '2019/02/26', '2:00', 'Hwangju-ŭp');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (197, 'Future-proofed human-resource project', 156176699, 16, '2019/07/23', '2:00', 'Rominimbang');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (198, 'Fully-configurable bifurcated paradigm', 247026125, 16, '2018/08/19', '3:00', 'Carmen');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (199, 'Adaptive fresh-thinking structure', 113813522, 1, '2017/03/15', '2:30', 'Tallinn');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (200, 'Cloned heuristic secured line', 113813522, 13, '2018/03/28', '1:30', 'Harbin');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (201, 'User-centric uniform open system', 295618933, 4, '2016/12/04', '1:30', 'Barranca');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (202, 'Object-based uniform knowledge user', 243370119, 20, '2017/08/31', '2:30', 'Tuluá');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (203, 'Face to face coherent policy', 315946337, 2, '2017/09/19', '2:00', 'Bokhan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (204, 'Business-focused cohesive strategy', 352417810, 7, '2018/10/19', '3:00', 'Malanville');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (205, 'Exclusive high-level monitoring', 386972047, 12, '2019/03/26', '1:00', 'Narutochō-mitsuishi');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (206, 'Pre-emptive optimizing task-force', 264087727, 18, '2018/02/15', '3:30', 'Bryan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (207, 'Universal optimal time-frame', 113813522, 13, '2016/01/02', '3:00', 'Draguignan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (208, 'Profound dynamic access', 100619454, 15, '2019/07/24', '2:30', 'Zhangjiawo');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (209, 'Configurable stable open architecture', 156176699, 3, '2019/03/16', '2:30', 'Jiumen');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (210, 'Digitized 3rd generation instruction set', 264087727, 20, '2017/10/05', '3:00', 'Nan’an');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (211, 'Balanced 24 hour moderator', 301522332, 11, '2017/11/20', '3:00', 'Xingzi');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (212, 'Stand-alone next generation initiative', 264087727, 9, '2017/08/25', '1:00', 'Santa Rita');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (213, 'Visionary asymmetric groupware', 285816849, 8, '2018/07/18', '3:30', 'Doruchów');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (214, 'Ameliorated holistic frame', 264139487, 3, '2015/05/05', '2:00', 'Xinle');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (215, 'Profit-focused maximized website', 113813522, 7, '2015/03/31', '1:30', 'Cavadas');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (216, 'Mandatory heuristic customer loyalty', 243370119, 9, '2017/05/27', '1:30', 'Dongxing');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (217, 'Up-sized regional monitoring', 365760523, 14, '2018/10/26', '1:00', 'Zouma');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (218, 'Diverse exuding collaboration', 100619454, 19, '2018/07/29', '1:30', 'Vân Đình');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (219, 'Distributed dedicated extranet', 247026125, 7, '2016/07/05', '2:00', 'Hicksville');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (220, 'Vision-oriented object-oriented protocol', 247026125, 5, '2018/09/19', '2:00', 'La Libertad');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (221, 'Versatile zero defect open system', 234192453, 9, '2019/02/25', '1:30', 'Quthing');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (222, 'Operative asynchronous migration', 234192453, 14, '2016/05/25', '3:30', 'Babana');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (223, 'Streamlined mobile conglomeration', 106907301, 6, '2018/06/14', '2:00', 'Tirah');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (224, 'Optimized eco-centric info-mediaries', 264087727, 18, '2015/08/28', '3:00', 'Purwasari');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (225, 'Configurable analyzing interface', 301522332, 9, '2019/01/09', '1:00', 'Long Hồ');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (226, 'Optional multimedia emulation', 243370119, 3, '2015/11/04', '1:00', 'Padangbai');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (227, 'Sharable actuating firmware', 247026125, 3, '2016/06/19', '2:00', 'Baltimore');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (228, 'Face to face next generation initiative', 357448920, 18, '2018/12/13', '2:30', 'Bayan Bulag');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (229, 'Sharable eco-centric system engine', 387966897, 13, '2016/12/07', '3:30', 'Balakhninskiy');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (230, 'Integrated empowering migration', 156176699, 8, '2016/07/06', '1:30', 'Kansas City');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (231, 'Decentralized impactful help-desk', 156176699, 18, '2017/09/12', '1:00', 'Xujia');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (232, 'Customer-focused systemic paradigm', 301522332, 2, '2019/05/22', '1:30', 'Panaoti');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (233, 'Quality-focused zero defect parallelism', 100619454, 15, '2019/04/15', '1:30', 'Caxias do Sul');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (234, 'Open-architected systemic complexity', 243370119, 7, '2015/10/01', '1:30', 'Laocheng');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (235, 'Proactive 4th generation encryption', 120224652, 4, '2015/08/06', '2:00', 'Boliney');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (236, 'Configurable encompassing approach', 120224652, 4, '2016/03/26', '2:00', 'Mahaddayweyne');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (237, 'Quality-focused multimedia frame', 234192453, 7, '2017/02/26', '1:30', 'Zhaoqing');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (238, 'Ameliorated 24 hour extranet', 130439755, 6, '2016/04/23', '1:00', 'Tianhe');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (239, 'Open-architected bandwidth-monitored paradigm', 357448920, 13, '2015/03/16', '1:00', 'Maco');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (240, 'Devolved asynchronous analyzer', 285816849, 16, '2016/08/14', '1:30', 'Tianfu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (241, 'Compatible context-sensitive system engine', 234192453, 16, '2015/06/11', '1:00', 'Parabon');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (242, 'User-friendly uniform capacity', 130439755, 12, '2017/10/17', '3:00', 'Huashu');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (243, 'Configurable full-range forecast', 100619454, 3, '2017/01/31', '1:00', 'Getulio');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (244, 'Persistent explicit encoding', 156176699, 20, '2016/12/21', '3:30', 'Chicago');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (245, 'Versatile bottom-line orchestration', 295618933, 7, '2015/03/02', '3:00', 'Watari');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (246, 'Switchable web-enabled flexibility', 285816849, 20, '2019/06/11', '2:00', 'Xiadingjia');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (247, 'Customizable upward-trending data-warehouse', 315946337, 4, '2018/10/12', '2:00', 'Fort Beaufort');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (248, 'Business-focused fresh-thinking policy', 264087727, 4, '2015/08/08', '2:30', 'Jagodina');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (249, 'Object-based empowering Graphic Interface', 243370119, 8, '2017/10/09', '3:30', 'Wonokerto');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (250, 'Reverse-engineered directional policy', 243370119, 2, '2016/05/25', '2:00', 'Grosuplje');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (251, 'Phased actuating initiative', 387966897, 6, '2015/04/17', '3:00', 'Jinzao');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (252, 'Cross-group 24 hour circuit', 100619454, 12, '2016/11/10', '3:00', 'Kināna');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (253, 'Optional global matrix', 352417810, 18, '2018/05/03', '1:00', 'Nandayure');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (254, 'Future-proofed methodical architecture', 234192453, 6, '2016/07/31', '1:00', 'Skała');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (255, 'Visionary didactic firmware', 264139487, 6, '2017/06/28', '1:00', 'Jiuting');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (256, 'Fundamental full-range complexity', 247026125, 14, '2017/12/31', '1:30', 'Creil');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (257, 'Object-based explicit capacity', 301522332, 20, '2019/01/21', '2:00', 'Gävle');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (258, 'Vision-oriented next generation throughput', 357448920, 2, '2017/05/21', '3:30', 'Baltimore');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (259, 'Secured client-server ability', 247026125, 9, '2015/06/14', '2:30', 'Khurriānwāla');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (260, 'Automated global collaboration', 156176699, 12, '2016/11/12', '3:30', 'Gangu Chengguanzhen');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (261, 'Operative object-oriented benchmark', 285816849, 6, '2016/12/23', '1:30', 'Cilongkrang');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (262, 'Function-based bifurcated hardware', 156176699, 10, '2016/12/05', '3:30', 'Norabats’');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (263, 'Fundamental foreground instruction set', 264139487, 14, '2016/05/09', '3:00', 'Āsmār');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (264, 'Implemented 6th generation software', 264087727, 18, '2016/05/30', '3:00', 'Shihua');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (265, 'Enhanced solution-oriented challenge', 387966897, 3, '2018/08/02', '1:30', 'Mpika');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (266, 'Self-enabling reciprocal product', 130439755, 13, '2019/11/11', '3:00', 'Phanom Sarakham');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (267, 'Assimilated motivating info-mediaries', 120224652, 1, '2015/07/01', '2:30', 'Brody');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (268, 'Open-source 4th generation access', 295618933, 13, '2017/03/12', '1:30', 'Kirovskaya');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (269, 'Secured systemic initiative', 106907301, 9, '2017/06/18', '3:00', 'Victoria');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (270, 'Implemented cohesive hierarchy', 106907301, 13, '2015/09/01', '1:30', 'Sotomayor');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (271, 'Centralized bi-directional implementation', 247026125, 18, '2018/05/11', '1:30', 'Drogomyśl');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (272, 'Polarised tertiary groupware', 130439755, 5, '2019/07/01', '1:00', 'Nakuru');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (273, 'Exclusive clear-thinking hierarchy', 315946337, 8, '2017/03/12', '1:00', 'Diriá');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (274, 'Automated homogeneous infrastructure', 301522332, 19, '2018/08/18', '3:00', 'Severnyy');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (275, 'Persevering upward-trending conglomeration', 243370119, 18, '2015/12/26', '2:00', 'Buenavista');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (276, 'Switchable holistic software', 357448920, 12, '2015/07/17', '2:30', 'Moriyama');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (277, 'Grass-roots transitional model', 106907301, 15, '2019/01/30', '1:30', 'Santa Catalina');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (278, 'Ameliorated object-oriented installation', 387966897, 14, '2015/05/04', '3:30', 'Tirlyanskiy');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (279, 'Synchronised responsive software', 387966897, 13, '2019/08/02', '3:30', 'Murmashi');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (280, 'Object-based client-server archive', 113813522, 19, '2019/05/26', '3:30', 'Alfenas');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (281, 'Enterprise-wide solution-oriented attitude', 243370119, 13, '2019/08/07', '2:00', 'Крива Паланка');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (282, 'Fully-configurable global encryption', 365760523, 5, '2018/03/20', '2:00', 'Ila Orangun');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (283, 'Polarised well-modulated extranet', 315946337, 7, '2018/11/06', '3:30', 'Mehar');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (284, 'Streamlined bandwidth-monitored database', 386972047, 7, '2015/10/24', '1:00', 'Alīpur');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (285, 'Up-sized cohesive hierarchy', 301522332, 17, '2016/09/26', '2:30', 'Sukaharja');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (286, 'Customer-focused regional projection', 387966897, 3, '2017/01/13', '2:00', 'Lenakapa');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (287, 'User-centric logistical standardization', 100619454, 1, '2018/03/03', '1:30', 'Fort Worth');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (288, 'Streamlined homogeneous portal', 113813522, 15, '2017/12/17', '2:30', 'Xifangcheng');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (289, 'Multi-lateral reciprocal collaboration', 234192453, 15, '2017/03/13', '3:00', 'General Villegas');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (290, 'Polarised clear-thinking benchmark', 113813522, 16, '2017/12/23', '1:30', 'Tanzhesi');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (291, 'Organized intermediate policy', 365760523, 10, '2018/06/14', '2:30', 'Huangpi');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (292, 'Synchronised bifurcated matrix', 100619454, 19, '2017/11/11', '3:30', 'Kolbano');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (293, 'Profound modular ability', 247026125, 19, '2015/05/23', '3:30', 'Dananshan');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (294, 'Configurable dedicated core', 264087727, 9, '2015/06/01', '2:30', 'Memphis');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (295, 'Re-contextualized bi-directional interface', 130439755, 5, '2015/11/10', '1:00', 'Vale de Figueira');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (296, 'Fundamental web-enabled adapter', 120224652, 7, '2017/02/05', '3:00', 'Yuyue');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (297, 'Balanced 4th generation software', 264087727, 12, '2018/02/01', '2:00', 'Liqiao');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (298, 'Open-source grid-enabled forecast', 234192453, 7, '2015/04/11', '1:30', 'Trzcinica');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (299, 'Multi-tiered client-driven architecture', 315946337, 10, '2017/02/06', '2:30', 'Solnechnoye');
insert into Academia.Presentacion (ID_Presentacion, Titulo, ID_Profesor, ID_Arte, Fecha_presentacion, Duracion, Lugar) values (300, 'Profit-focused object-oriented definition', 100619454, 15, '2019/01/17', '1:00', 'Cabannungan Second');

-- insercion en Academia.Inventario 
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (1, 'Alleen', 1, 30, 1);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (2, 'Ingra', 2, 42, 2);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (3, 'Gratia', 3, 36, 3);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (4, 'Joshuah', 4, 33, 4);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (5, 'Tilda', 5, 45, 5);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (6, 'Salem', 6, 31, 6);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (7, 'Roderick', 7, 42, 7);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (8, 'Giffard', 8, 30, 8);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (9, 'Malinde', 9, 37, 9);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (10, 'Idette', 10, 27, 10);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (11, 'Falito', 11, 38, 11);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (12, 'Stanton', 12, 40, 12);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (13, 'Rudolfo', 13, 40, 13);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (14, 'Kylie', 14, 44, 14);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (15, 'Kippie', 15, 42, 15);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (16, 'Cami', 16, 26, 16);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (17, 'Trudey', 17, 29, 17);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (18, 'Halley', 18, 32, 18);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (19, 'Louella', 19, 36, 19);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (20, 'Agnola', 20, 37, 20);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (21, 'Cosetta', 21, 43, 21);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (22, 'Arielle', 22, 45, 22);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (23, 'Leslie', 23, 45, 23);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (24, 'Craggy', 24, 44, 24);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (25, 'Daffy', 25, 37, 25);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (26, 'Olive', 26, 37, 26);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (27, 'Clay', 27, 48, 27);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (28, 'Jarad', 28, 34, 28);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (29, 'Rafaelita', 29, 37, 29);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (30, 'Aldon', 30, 34, 30);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (31, 'Preston', 31, 26, 31);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (32, 'Rickie', 32, 37, 32);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (33, 'Darwin', 33, 36, 33);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (34, 'Joann', 34, 41, 34);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (35, 'Ilaire', 35, 47, 35);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (36, 'Cristobal', 36, 26, 36);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (37, 'Carin', 37, 32, 37);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (38, 'Wheeler', 38, 34, 38);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (39, 'Ferdinanda', 39, 46, 39);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (40, 'Ollie', 40, 27, 40);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (41, 'Nico', 41, 25, 41);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (42, 'Hanni', 42, 45, 42);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (43, 'Jasmin', 43, 45, 43);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (44, 'Adam', 44, 39, 44);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (45, 'Martainn', 45, 37, 45);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (46, 'Jerome', 46, 42, 46);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (47, 'Raven', 47, 34, 47);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (48, 'Gerta', 48, 48, 48);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (49, 'Starr', 49, 26, 49);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (50, 'Elsy', 50, 38, 50);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (51, 'Hermann', 51, 45, 51);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (52, 'Morgana', 52, 29, 52);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (53, 'Filip', 53, 49, 53);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (54, 'Baldwin', 54, 34, 54);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (55, 'Ruddy', 55, 26, 55);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (56, 'Redford', 56, 27, 56);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (57, 'Chad', 57, 45, 57);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (58, 'Donia', 58, 42, 58);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (59, 'Jeni', 59, 26, 59);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (60, 'Ruprecht', 60, 43, 60);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (61, 'Douglas', 61, 30, 61);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (62, 'Sherwin', 62, 34, 62);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (63, 'Isabeau', 63, 36, 63);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (64, 'Cicily', 64, 48, 64);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (65, 'Terri-jo', 65, 26, 65);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (66, 'Daryle', 66, 28, 66);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (67, 'Justus', 67, 42, 67);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (68, 'Lise', 68, 42, 68);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (69, 'Paton', 69, 44, 69);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (70, 'Susette', 70, 26, 70);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (71, 'Valera', 71, 48, 71);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (72, 'Suzie', 72, 38, 72);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (73, 'Hallie', 73, 50, 73);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (74, 'Sybyl', 74, 40, 74);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (75, 'Morie', 75, 27, 75);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (76, 'Modesty', 76, 37, 76);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (77, 'Sherry', 77, 30, 77);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (78, 'Mellie', 78, 40, 78);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (79, 'Gerri', 79, 31, 79);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (80, 'Dedra', 80, 44, 80);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (81, 'Garwin', 81, 38, 81);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (82, 'Millie', 82, 27, 82);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (83, 'Jillane', 83, 32, 83);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (84, 'Carolus', 84, 37, 84);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (85, 'Luce', 85, 42, 85);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (86, 'Tiffy', 86, 26, 86);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (87, 'Alika', 87, 42, 87);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (88, 'Lamont', 88, 27, 88);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (89, 'Chaddie', 89, 31, 89);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (90, 'Fleming', 90, 36, 90);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (91, 'Marlie', 91, 29, 91);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (92, 'Binny', 92, 40, 92);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (93, 'Kyle', 93, 42, 93);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (94, 'Laverne', 94, 35, 94);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (95, 'Thorny', 95, 26, 95);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (96, 'Ingunna', 96, 41, 96);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (97, 'Monica', 97, 36, 97);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (98, 'Putnem', 98, 33, 98);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (99, 'Sam', 99, 25, 99);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (100, 'Josephine', 100, 46, 100);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (101, 'Brendis', 101, 25, 101);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (102, 'Ilsa', 102, 40, 102);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (103, 'Casar', 103, 38, 103);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (104, 'Jo ann', 104, 49, 104);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (105, 'Livvyy', 105, 33, 105);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (106, 'Corenda', 106, 44, 106);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (107, 'Daniella', 107, 33, 107);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (108, 'Costanza', 108, 43, 108);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (109, 'Josh', 109, 29, 109);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (110, 'Wain', 110, 25, 110);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (111, 'Gilemette', 111, 43, 111);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (112, 'Mitchel', 112, 46, 112);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (113, 'Kelly', 113, 46, 113);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (114, 'Faustina', 114, 45, 114);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (115, 'Rowena', 115, 41, 115);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (116, 'Oneida', 116, 31, 116);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (117, 'Olav', 117, 32, 117);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (118, 'Harper', 118, 43, 118);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (119, 'Lotti', 119, 34, 119);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (120, 'Alyce', 120, 30, 120);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (121, 'Trisha', 121, 45, 121);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (122, 'Cassandra', 122, 44, 122);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (123, 'Elvis', 123, 41, 123);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (124, 'Duffie', 124, 38, 124);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (125, 'Chandler', 125, 26, 125);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (126, 'Aeriell', 126, 30, 126);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (127, 'Stephanus', 127, 40, 127);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (128, 'Ardath', 128, 25, 128);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (129, 'Tami', 129, 36, 129);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (130, 'Roth', 130, 31, 130);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (131, 'Claiborn', 131, 29, 131);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (132, 'Lenard', 132, 36, 132);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (133, 'Niall', 133, 37, 133);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (134, 'Elaine', 134, 32, 134);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (135, 'North', 135, 47, 135);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (136, 'Lynna', 136, 34, 136);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (137, 'Debor', 137, 40, 137);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (138, 'Joleen', 138, 39, 138);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (139, 'Luke', 139, 50, 139);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (140, 'Jillie', 140, 49, 140);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (141, 'Calhoun', 141, 48, 141);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (142, 'Anett', 142, 34, 142);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (143, 'Ebba', 143, 40, 143);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (144, 'Jamal', 144, 45, 144);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (145, 'Leonhard', 145, 25, 145);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (146, 'Aluin', 146, 36, 146);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (147, 'Lotty', 147, 25, 147);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (148, 'Harmony', 148, 36, 148);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (149, 'Ricoriki', 149, 50, 149);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (150, 'Krishna', 150, 33, 150);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (151, 'Beverie', 151, 40, 151);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (152, 'Taddeusz', 152, 34, 152);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (153, 'Mandie', 153, 30, 153);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (154, 'Dodie', 154, 26, 154);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (155, 'Masha', 155, 48, 155);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (156, 'Aldric', 156, 37, 156);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (157, 'Antoine', 157, 28, 157);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (158, 'Dene', 158, 47, 158);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (159, 'Baillie', 159, 41, 159);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (160, 'Shaylynn', 160, 49, 160);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (161, 'Edouard', 161, 34, 161);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (162, 'Aylmer', 162, 35, 162);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (163, 'Harald', 163, 34, 163);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (164, 'Adelaida', 164, 34, 164);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (165, 'Margaretha', 165, 31, 165);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (166, 'Deane', 166, 41, 166);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (167, 'Kamillah', 167, 28, 167);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (168, 'Jodi', 168, 45, 168);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (169, 'Odey', 169, 29, 169);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (170, 'Natalina', 170, 31, 170);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (171, 'Gwenora', 171, 37, 171);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (172, 'Sylvan', 172, 29, 172);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (173, 'Clarabelle', 173, 42, 173);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (174, 'Rodrigo', 174, 43, 174);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (175, 'Lucila', 175, 50, 175);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (176, 'Ogdan', 176, 33, 176);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (177, 'Ania', 177, 46, 177);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (178, 'Daffy', 178, 45, 178);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (179, 'Meredithe', 179, 30, 179);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (180, 'Kevyn', 180, 38, 180);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (181, 'Carlie', 181, 49, 181);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (182, 'Kinnie', 182, 39, 182);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (183, 'Ravid', 183, 49, 183);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (184, 'Ashlan', 184, 41, 184);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (185, 'Hally', 185, 49, 185);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (186, 'Janel', 186, 46, 186);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (187, 'Sky', 187, 50, 187);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (188, 'Bo', 188, 28, 188);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (189, 'Rozanne', 189, 28, 189);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (190, 'Josselyn', 190, 28, 190);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (191, 'Jordan', 191, 36, 191);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (192, 'Berk', 192, 47, 192);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (193, 'Erik', 193, 35, 193);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (194, 'Pieter', 194, 36, 194);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (195, 'Netty', 195, 45, 195);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (196, 'Ajay', 196, 38, 196);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (197, 'Cammy', 197, 34, 197);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (198, 'Pernell', 198, 25, 198);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (199, 'Phoebe', 199, 27, 199);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (200, 'Scarface', 200, 40, 200);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (201, 'Verina', 201, 27, 201);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (202, 'Thaddus', 202, 44, 202);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (203, 'Allistir', 203, 34, 203);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (204, 'Hestia', 204, 29, 204);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (205, 'Gwennie', 205, 31, 205);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (206, 'Dell', 206, 43, 206);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (207, 'Merrick', 207, 32, 207);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (208, 'Alexandre', 208, 40, 208);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (209, 'Chadwick', 209, 48, 209);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (210, 'Emelda', 210, 35, 210);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (211, 'Caroljean', 211, 27, 211);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (212, 'Hestia', 212, 44, 212);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (213, 'Adria', 213, 48, 213);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (214, 'Jackie', 214, 47, 214);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (215, 'Constantine', 215, 39, 215);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (216, 'Salmon', 216, 34, 216);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (217, 'Brynn', 217, 40, 217);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (218, 'Arin', 218, 29, 218);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (219, 'Redford', 219, 36, 219);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (220, 'Sacha', 220, 36, 220);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (221, 'Alistair', 221, 44, 221);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (222, 'Brion', 222, 29, 222);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (223, 'Lenette', 223, 50, 223);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (224, 'Caryn', 224, 31, 224);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (225, 'Koren', 225, 39, 225);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (226, 'Darwin', 226, 25, 226);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (227, 'Nerty', 227, 38, 227);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (228, 'Corette', 228, 47, 228);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (229, 'Bertrand', 229, 45, 229);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (230, 'Caritta', 230, 45, 230);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (231, 'Bronson', 231, 41, 231);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (232, 'Bailie', 232, 35, 232);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (233, 'Erinn', 233, 35, 233);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (234, 'Emelina', 234, 49, 234);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (235, 'Lorry', 235, 25, 235);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (236, 'Roselia', 236, 29, 236);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (237, 'Lyndel', 237, 48, 237);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (238, 'Felicle', 238, 48, 238);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (239, 'Cicily', 239, 32, 239);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (240, 'Andris', 240, 30, 240);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (241, 'Falkner', 241, 38, 241);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (242, 'Caresa', 242, 36, 242);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (243, 'Angel', 243, 44, 243);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (244, 'Fred', 244, 49, 244);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (245, 'Luce', 245, 39, 245);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (246, 'Cecily', 246, 47, 246);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (247, 'Fallon', 247, 34, 247);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (248, 'Christean', 248, 50, 248);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (249, 'Hale', 249, 41, 249);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (250, 'Doy', 250, 31, 250);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (251, 'Jeremias', 251, 28, 251);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (252, 'Nessie', 252, 50, 252);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (253, 'Conroy', 253, 34, 253);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (254, 'Camala', 254, 44, 254);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (255, 'Julianne', 255, 26, 255);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (256, 'Phylis', 256, 31, 256);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (257, 'Pammie', 257, 50, 257);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (258, 'Sorcha', 258, 28, 258);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (259, 'Emilia', 259, 29, 259);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (260, 'Fremont', 260, 48, 260);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (261, 'Glennis', 261, 34, 261);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (262, 'Catha', 262, 26, 262);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (263, 'Terencio', 263, 50, 263);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (264, 'Wain', 264, 47, 264);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (265, 'Colin', 265, 45, 265);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (266, 'Elva', 266, 35, 266);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (267, 'Martha', 267, 41, 267);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (268, 'Jolie', 268, 43, 268);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (269, 'Simeon', 269, 48, 269);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (270, 'Heddie', 270, 48, 270);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (271, 'Sven', 271, 47, 271);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (272, 'Ruthann', 272, 38, 272);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (273, 'Lanette', 273, 49, 273);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (274, 'Maisie', 274, 36, 274);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (275, 'Vincents', 275, 35, 275);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (276, 'Wilona', 276, 47, 276);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (277, 'Renault', 277, 25, 277);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (278, 'Vassili', 278, 27, 278);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (279, 'Brigham', 279, 30, 279);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (280, 'Geoffrey', 280, 41, 280);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (281, 'Merilee', 281, 27, 281);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (282, 'Justen', 282, 48, 282);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (283, 'Rae', 283, 37, 283);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (284, 'Rupert', 284, 50, 284);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (285, 'Maximilianus', 285, 41, 285);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (286, 'Janela', 286, 26, 286);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (287, 'Natalie', 287, 39, 287);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (288, 'Alexandr', 288, 31, 288);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (289, 'Ignace', 289, 45, 289);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (290, 'Archibaldo', 290, 28, 290);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (291, 'Nikolaus', 291, 28, 291);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (292, 'Georgena', 292, 50, 292);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (293, 'Erin', 293, 40, 293);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (294, 'Deena', 294, 28, 294);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (295, 'Lani', 295, 27, 295);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (296, 'Marybelle', 296, 28, 296);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (297, 'Ganny', 297, 36, 297);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (298, 'Ara', 298, 48, 298);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (299, 'Hall', 299, 46, 299);
insert into Academia.Inventario (ID_Material, Nombre_Material, ID_Proveedor, Cantidad, ID_Arte) values (300, 'Shawn', 300, 49, 300);

-- insercion en Academia.Matriculacion 
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (1, 6, 574023080, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (2, 2, 508514244, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (3, 5, 508514244, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (4, 9, 496982654, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (5, 2, 508918810, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (6, 4, 435229275, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (7, 4, 419386689, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (8, 7, 584506376, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (9, 8, 522161642, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (10, 1, 508918810, 796385697);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (11, 1, 435229275, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (12, 8, 574023080, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (13, 1, 407842323, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (14, 3, 508514244, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (15, 1, 567290097, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (16, 8, 449869350, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (17, 4, 496982654, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (18, 6, 529840745, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (19, 3, 505445806, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (20, 4, 419386689, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (21, 7, 579167277, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (22, 3, 505445806, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (23, 7, 587825067, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (24, 9, 508918810, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (25, 2, 567290097, 601496940);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (26, 6, 529840745, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (27, 10, 587825067, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (28, 7, 508918810, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (29, 9, 529770583, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (30, 8, 526834867, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (31, 1, 579167277, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (32, 9, 496982654, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (33, 6, 529770583, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (34, 3, 522161642, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (35, 10, 449869350, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (36, 8, 496982654, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (37, 7, 529770583, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (38, 6, 435229275, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (39, 6, 574023080, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (40, 6, 508514244, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (41, 10, 579167277, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (42, 10, 529840745, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (43, 2, 496982654, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (44, 10, 578548772, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (45, 6, 402398434, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (46, 6, 587825067, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (47, 6, 407842323, 601496940);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (48, 6, 587825067, 616475848);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (49, 3, 584506376, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (50, 3, 587825067, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (51, 4, 402398434, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (52, 8, 522161642, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (53, 5, 419386689, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (54, 7, 526834867, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (55, 2, 574023080, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (56, 1, 587825067, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (57, 7, 449869350, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (58, 2, 419386689, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (59, 9, 510422495, 796385697);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (60, 6, 419386689, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (61, 6, 526834867, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (62, 10, 529840745, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (63, 6, 578548772, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (64, 7, 402398434, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (65, 6, 529840745, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (66, 1, 510422495, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (67, 4, 579167277, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (68, 1, 584506376, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (69, 9, 496982654, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (70, 10, 419386689, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (71, 2, 529840745, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (72, 8, 578548772, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (73, 2, 584506376, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (74, 8, 529770583, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (75, 4, 584506376, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (76, 5, 435229275, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (77, 6, 522161642, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (78, 8, 567290097, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (79, 8, 578548772, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (80, 9, 567290097, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (81, 6, 529840745, 601496940);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (82, 8, 574023080, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (83, 9, 522161642, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (84, 2, 505445806, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (85, 2, 579167277, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (86, 7, 574023080, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (87, 1, 574023080, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (88, 4, 407842323, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (89, 9, 574023080, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (90, 3, 526834867, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (91, 4, 419386689, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (92, 5, 508918810, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (93, 7, 567290097, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (94, 6, 567290097, 616475848);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (95, 7, 510422495, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (96, 8, 419386689, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (97, 5, 496982654, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (98, 4, 508918810, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (99, 1, 508514244, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (100, 4, 435229275, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (101, 1, 449869350, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (102, 10, 510422495, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (103, 6, 402398434, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (104, 8, 587825067, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (105, 1, 578548772, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (106, 3, 496982654, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (107, 3, 567290097, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (108, 1, 508514244, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (109, 10, 567290097, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (110, 1, 449869350, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (111, 1, 449869350, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (112, 9, 496982654, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (113, 7, 407842323, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (114, 5, 567290097, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (115, 3, 505445806, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (116, 9, 419386689, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (117, 6, 449869350, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (118, 6, 526834867, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (119, 2, 508918810, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (120, 1, 579167277, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (121, 7, 508514244, 796385697);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (122, 10, 522161642, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (123, 7, 567290097, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (124, 5, 449869350, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (125, 1, 496982654, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (126, 10, 567290097, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (127, 6, 449869350, 601496940);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (128, 7, 529840745, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (129, 6, 407842323, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (130, 1, 449869350, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (131, 5, 510422495, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (132, 4, 579167277, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (133, 8, 574023080, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (134, 1, 529840745, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (135, 4, 522161642, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (136, 1, 419386689, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (137, 4, 584506376, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (138, 6, 567290097, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (139, 6, 526834867, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (140, 10, 526834867, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (141, 3, 579167277, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (142, 7, 449869350, 601496940);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (143, 6, 505445806, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (144, 9, 496982654, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (145, 4, 419386689, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (146, 10, 496982654, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (147, 1, 526834867, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (148, 4, 449869350, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (149, 8, 449869350, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (150, 4, 435229275, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (151, 4, 567290097, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (152, 1, 510422495, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (153, 6, 435229275, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (154, 2, 529770583, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (155, 7, 526834867, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (156, 5, 508514244, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (157, 6, 578548772, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (158, 2, 496982654, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (159, 3, 587825067, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (160, 6, 529770583, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (161, 8, 567290097, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (162, 7, 510422495, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (163, 4, 587825067, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (164, 2, 419386689, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (165, 6, 508514244, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (166, 2, 529770583, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (167, 1, 407842323, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (168, 9, 587825067, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (169, 8, 526834867, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (170, 3, 505445806, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (171, 2, 508918810, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (172, 10, 526834867, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (173, 6, 508514244, 796385697);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (174, 3, 402398434, 796385697);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (175, 6, 567290097, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (176, 1, 578548772, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (177, 1, 435229275, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (178, 3, 529840745, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (179, 1, 508918810, 616475848);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (180, 2, 584506376, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (181, 8, 526834867, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (182, 2, 584506376, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (183, 2, 508514244, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (184, 10, 510422495, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (185, 4, 579167277, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (186, 6, 526834867, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (187, 8, 578548772, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (188, 3, 567290097, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (189, 5, 584506376, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (190, 10, 584506376, 601496940);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (191, 7, 419386689, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (192, 4, 407842323, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (193, 2, 419386689, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (194, 8, 522161642, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (195, 5, 526834867, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (196, 7, 510422495, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (197, 4, 529770583, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (198, 3, 449869350, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (199, 2, 578548772, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (200, 2, 526834867, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (201, 6, 419386689, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (202, 2, 587825067, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (203, 3, 496982654, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (204, 5, 419386689, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (205, 8, 529770583, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (206, 3, 578548772, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (207, 6, 529840745, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (208, 9, 496982654, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (209, 5, 529770583, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (210, 4, 579167277, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (211, 1, 510422495, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (212, 4, 510422495, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (213, 6, 508918810, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (214, 3, 435229275, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (215, 2, 496982654, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (216, 9, 587825067, 628529970);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (217, 1, 449869350, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (218, 1, 435229275, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (219, 8, 587825067, 796385697);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (220, 8, 435229275, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (221, 9, 529770583, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (222, 1, 419386689, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (223, 3, 529770583, 796385697);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (224, 8, 402398434, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (225, 10, 529770583, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (226, 6, 567290097, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (227, 3, 584506376, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (228, 5, 508514244, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (229, 1, 587825067, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (230, 1, 579167277, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (231, 7, 578548772, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (232, 10, 526834867, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (233, 10, 435229275, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (234, 2, 567290097, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (235, 5, 419386689, 616475848);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (236, 7, 529840745, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (237, 10, 529840745, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (238, 1, 510422495, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (239, 4, 578548772, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (240, 3, 578548772, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (241, 1, 578548772, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (242, 7, 402398434, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (243, 2, 579167277, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (244, 7, 574023080, 616475848);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (245, 10, 449869350, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (246, 3, 587825067, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (247, 5, 529770583, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (248, 6, 510422495, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (249, 5, 419386689, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (250, 3, 402398434, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (251, 9, 402398434, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (252, 7, 407842323, 796385697);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (253, 4, 508918810, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (254, 3, 574023080, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (255, 6, 584506376, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (256, 4, 402398434, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (257, 6, 510422495, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (258, 10, 407842323, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (259, 1, 526834867, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (260, 3, 526834867, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (261, 3, 407842323, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (262, 7, 579167277, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (263, 8, 584506376, 680621501);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (264, 10, 402398434, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (265, 10, 526834867, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (266, 2, 402398434, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (267, 2, 579167277, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (268, 7, 579167277, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (269, 6, 584506376, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (270, 10, 578548772, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (271, 1, 505445806, 616475848);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (272, 6, 526834867, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (273, 2, 505445806, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (274, 9, 584506376, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (275, 9, 567290097, 625967213);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (276, 10, 587825067, 796385697);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (277, 2, 508514244, 708466770);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (278, 8, 508514244, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (279, 9, 579167277, 767374906);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (280, 5, 419386689, 678856177);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (281, 7, 505445806, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (282, 9, 584506376, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (283, 4, 578548772, 649193243);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (284, 10, 508514244, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (285, 9, 587825067, 622658592);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (286, 2, 505445806, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (287, 3, 584506376, 624255757);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (288, 5, 529770583, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (289, 4, 526834867, 782068660);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (290, 4, 578548772, 718676800);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (291, 6, 407842323, 702410828);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (292, 8, 435229275, 666384045);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (293, 7, 587825067, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (294, 8, 567290097, 692979418);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (295, 9, 510422495, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (296, 10, 508514244, 762636101);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (297, 9, 567290097, 778438291);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (298, 8, 508514244, 675573090);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (299, 6, 435229275, 616475848);
insert into Academia.Matriculacion (ID_Matriculacion, ID_Curso, ID_Estudiante, ID_Administrativo) values (300, 5, 574023080, 601496940);

-- insercion en Academia.Factura 
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (1, 574023080, 762636101, '2017/08/24');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (2, 402398434, 718676800, '2017/08/30');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (3, 522161642, 625967213, '2019/04/08');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (4, 496982654, 628529970, '2019/02/21');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (5, 526834867, 702410828, '2015/12/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (6, 508918810, 649193243, '2015/09/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (7, 435229275, 778438291, '2017/01/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (8, 505445806, 767374906, '2017/07/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (9, 435229275, 666384045, '2018/02/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (10, 407842323, 675573090, '2017/11/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (11, 435229275, 616475848, '2018/06/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (12, 449869350, 622658592, '2018/08/09');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (13, 522161642, 767374906, '2019/08/10');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (14, 587825067, 778438291, '2015/06/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (15, 407842323, 624255757, '2015/09/18');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (16, 505445806, 762636101, '2018/07/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (17, 529840745, 702410828, '2016/12/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (18, 510422495, 796385697, '2015/04/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (19, 574023080, 622658592, '2017/10/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (20, 587825067, 702410828, '2015/04/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (21, 496982654, 628529970, '2015/07/26');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (22, 529770583, 666384045, '2019/01/10');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (23, 407842323, 767374906, '2016/09/24');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (24, 435229275, 708466770, '2016/09/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (25, 587825067, 718676800, '2015/11/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (26, 587825067, 702410828, '2015/05/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (27, 505445806, 666384045, '2015/05/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (28, 508918810, 625967213, '2015/09/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (29, 419386689, 666384045, '2017/08/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (30, 510422495, 628529970, '2018/03/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (31, 449869350, 675573090, '2018/06/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (32, 529840745, 796385697, '2018/07/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (33, 529840745, 666384045, '2018/02/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (34, 505445806, 675573090, '2018/12/29');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (35, 435229275, 601496940, '2019/10/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (36, 496982654, 666384045, '2017/10/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (37, 510422495, 680621501, '2018/10/27');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (38, 574023080, 708466770, '2015/12/29');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (39, 402398434, 762636101, '2019/03/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (40, 578548772, 782068660, '2018/02/04');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (41, 508514244, 649193243, '2017/07/30');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (42, 407842323, 675573090, '2017/02/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (43, 522161642, 675573090, '2015/06/09');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (44, 579167277, 767374906, '2017/12/18');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (45, 522161642, 624255757, '2019/09/30');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (46, 402398434, 767374906, '2016/01/08');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (47, 587825067, 692979418, '2018/08/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (48, 510422495, 616475848, '2018/06/13');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (49, 584506376, 622658592, '2019/10/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (50, 587825067, 624255757, '2018/06/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (51, 508918810, 767374906, '2015/01/30');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (52, 505445806, 616475848, '2019/10/10');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (53, 407842323, 718676800, '2017/12/03');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (54, 402398434, 675573090, '2016/06/22');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (55, 579167277, 666384045, '2017/10/24');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (56, 508918810, 767374906, '2015/03/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (57, 584506376, 675573090, '2018/07/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (58, 587825067, 782068660, '2017/08/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (59, 567290097, 678856177, '2016/06/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (60, 508514244, 624255757, '2018/03/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (61, 584506376, 601496940, '2015/07/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (62, 508918810, 680621501, '2016/11/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (63, 407842323, 796385697, '2016/09/18');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (64, 419386689, 702410828, '2016/12/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (65, 508918810, 702410828, '2015/09/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (66, 508918810, 616475848, '2019/09/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (67, 496982654, 675573090, '2019/10/27');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (68, 449869350, 628529970, '2017/07/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (69, 584506376, 622658592, '2016/05/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (70, 567290097, 628529970, '2018/06/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (71, 508514244, 778438291, '2018/05/14');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (72, 579167277, 649193243, '2016/04/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (73, 419386689, 762636101, '2017/02/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (74, 526834867, 702410828, '2017/12/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (75, 529770583, 702410828, '2017/01/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (76, 435229275, 622658592, '2015/07/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (77, 584506376, 622658592, '2018/11/26');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (78, 508918810, 616475848, '2016/10/24');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (79, 579167277, 622658592, '2017/07/27');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (80, 587825067, 767374906, '2017/09/21');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (81, 587825067, 622658592, '2016/01/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (82, 508514244, 675573090, '2015/03/29');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (83, 579167277, 616475848, '2015/07/04');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (84, 449869350, 625967213, '2017/05/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (85, 587825067, 624255757, '2017/12/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (86, 578548772, 702410828, '2017/07/24');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (87, 529840745, 767374906, '2019/01/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (88, 584506376, 796385697, '2018/05/08');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (89, 435229275, 678856177, '2017/07/08');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (90, 578548772, 601496940, '2017/08/14');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (91, 574023080, 702410828, '2018/12/04');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (92, 579167277, 622658592, '2015/02/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (93, 496982654, 616475848, '2015/08/14');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (94, 505445806, 782068660, '2015/08/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (95, 567290097, 666384045, '2019/08/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (96, 435229275, 778438291, '2019/03/03');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (97, 587825067, 778438291, '2016/04/10');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (98, 419386689, 778438291, '2019/01/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (99, 587825067, 708466770, '2019/09/24');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (100, 505445806, 616475848, '2016/10/21');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (101, 449869350, 692979418, '2017/11/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (102, 526834867, 678856177, '2019/04/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (103, 526834867, 666384045, '2019/09/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (104, 529770583, 622658592, '2016/03/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (105, 508918810, 778438291, '2018/12/13');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (106, 508918810, 616475848, '2017/04/26');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (107, 496982654, 680621501, '2018/05/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (108, 402398434, 624255757, '2017/12/24');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (109, 449869350, 601496940, '2019/08/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (110, 508514244, 675573090, '2017/11/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (111, 567290097, 678856177, '2019/09/22');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (112, 407842323, 678856177, '2016/09/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (113, 579167277, 601496940, '2017/07/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (114, 587825067, 624255757, '2015/05/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (115, 505445806, 622658592, '2019/04/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (116, 505445806, 649193243, '2016/04/09');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (117, 529770583, 622658592, '2018/12/14');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (118, 526834867, 782068660, '2018/12/27');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (119, 496982654, 767374906, '2017/09/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (120, 510422495, 678856177, '2015/03/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (121, 508514244, 628529970, '2019/09/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (122, 529770583, 649193243, '2015/11/30');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (123, 578548772, 762636101, '2017/04/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (124, 522161642, 692979418, '2019/08/13');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (125, 435229275, 796385697, '2016/02/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (126, 574023080, 675573090, '2018/01/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (127, 419386689, 601496940, '2015/06/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (128, 508514244, 718676800, '2015/08/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (129, 505445806, 625967213, '2017/12/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (130, 579167277, 624255757, '2015/03/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (131, 522161642, 778438291, '2017/06/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (132, 574023080, 680621501, '2017/01/24');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (133, 567290097, 708466770, '2015/12/24');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (134, 508918810, 718676800, '2017/09/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (135, 522161642, 796385697, '2017/12/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (136, 435229275, 782068660, '2018/10/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (137, 435229275, 601496940, '2015/01/29');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (138, 584506376, 708466770, '2017/12/10');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (139, 579167277, 767374906, '2018/02/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (140, 574023080, 666384045, '2019/10/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (141, 529770583, 796385697, '2015/07/04');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (142, 529770583, 718676800, '2016/08/22');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (143, 505445806, 624255757, '2016/11/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (144, 587825067, 767374906, '2018/09/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (145, 574023080, 622658592, '2018/04/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (146, 567290097, 624255757, '2019/02/21');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (147, 508918810, 622658592, '2015/09/09');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (148, 419386689, 625967213, '2015/02/22');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (149, 496982654, 692979418, '2016/12/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (150, 584506376, 762636101, '2018/04/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (151, 579167277, 675573090, '2016/04/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (152, 407842323, 666384045, '2019/09/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (153, 578548772, 767374906, '2019/02/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (154, 574023080, 718676800, '2018/10/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (155, 508514244, 601496940, '2016/11/26');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (156, 529840745, 625967213, '2017/11/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (157, 578548772, 624255757, '2017/08/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (158, 567290097, 778438291, '2015/12/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (159, 529840745, 767374906, '2017/06/08');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (160, 407842323, 622658592, '2017/11/14');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (161, 419386689, 778438291, '2017/04/10');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (162, 526834867, 796385697, '2017/12/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (163, 526834867, 762636101, '2018/07/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (164, 587825067, 622658592, '2016/08/27');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (165, 435229275, 649193243, '2018/03/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (166, 508514244, 680621501, '2016/01/27');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (167, 567290097, 796385697, '2018/01/29');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (168, 584506376, 718676800, '2019/04/18');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (169, 508918810, 718676800, '2017/11/08');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (170, 449869350, 624255757, '2017/07/18');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (171, 435229275, 782068660, '2018/02/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (172, 574023080, 625967213, '2018/06/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (173, 508918810, 601496940, '2016/04/22');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (174, 529840745, 649193243, '2017/08/31');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (175, 505445806, 796385697, '2015/03/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (176, 435229275, 675573090, '2016/06/22');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (177, 526834867, 762636101, '2017/11/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (178, 529770583, 782068660, '2016/08/30');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (179, 449869350, 628529970, '2015/09/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (180, 578548772, 601496940, '2017/11/22');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (181, 449869350, 796385697, '2019/09/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (182, 579167277, 601496940, '2015/05/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (183, 529770583, 708466770, '2018/05/04');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (184, 510422495, 718676800, '2015/12/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (185, 508514244, 624255757, '2018/05/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (186, 510422495, 624255757, '2016/08/14');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (187, 419386689, 628529970, '2017/01/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (188, 587825067, 782068660, '2018/04/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (189, 508514244, 622658592, '2017/01/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (190, 508918810, 628529970, '2019/01/22');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (191, 508918810, 616475848, '2016/12/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (192, 522161642, 762636101, '2018/12/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (193, 567290097, 601496940, '2017/09/08');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (194, 579167277, 718676800, '2019/10/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (195, 407842323, 666384045, '2018/06/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (196, 578548772, 649193243, '2016/10/10');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (197, 407842323, 718676800, '2017/09/21');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (198, 496982654, 782068660, '2015/06/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (199, 526834867, 622658592, '2018/07/10');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (200, 579167277, 796385697, '2016/02/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (201, 578548772, 622658592, '2016/05/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (202, 567290097, 702410828, '2015/06/27');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (203, 578548772, 624255757, '2015/10/30');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (204, 578548772, 796385697, '2015/08/18');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (205, 567290097, 702410828, '2018/08/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (206, 522161642, 708466770, '2015/09/13');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (207, 587825067, 666384045, '2018/12/29');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (208, 584506376, 692979418, '2018/09/04');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (209, 508918810, 718676800, '2017/05/22');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (210, 522161642, 678856177, '2018/12/31');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (211, 579167277, 702410828, '2018/06/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (212, 435229275, 622658592, '2015/01/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (213, 526834867, 625967213, '2018/08/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (214, 522161642, 649193243, '2015/01/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (215, 526834867, 718676800, '2015/06/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (216, 529770583, 762636101, '2018/12/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (217, 508918810, 782068660, '2016/01/08');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (218, 522161642, 708466770, '2015/02/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (219, 584506376, 718676800, '2018/03/27');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (220, 402398434, 622658592, '2017/03/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (221, 529770583, 601496940, '2015/08/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (222, 508514244, 616475848, '2016/11/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (223, 574023080, 678856177, '2016/11/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (224, 449869350, 767374906, '2015/05/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (225, 510422495, 624255757, '2015/08/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (226, 496982654, 718676800, '2016/06/27');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (227, 529770583, 782068660, '2017/11/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (228, 522161642, 675573090, '2015/04/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (229, 449869350, 628529970, '2015/02/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (230, 574023080, 666384045, '2017/12/10');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (231, 526834867, 622658592, '2016/09/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (232, 529840745, 616475848, '2015/08/29');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (233, 526834867, 675573090, '2015/09/09');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (234, 567290097, 625967213, '2016/08/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (235, 584506376, 616475848, '2018/12/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (236, 402398434, 767374906, '2018/06/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (237, 402398434, 628529970, '2016/03/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (238, 505445806, 762636101, '2017/01/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (239, 505445806, 649193243, '2015/05/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (240, 574023080, 778438291, '2015/06/30');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (241, 508918810, 718676800, '2017/03/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (242, 510422495, 625967213, '2016/12/21');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (243, 510422495, 767374906, '2016/04/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (244, 587825067, 762636101, '2018/05/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (245, 510422495, 692979418, '2019/08/04');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (246, 584506376, 678856177, '2018/07/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (247, 578548772, 708466770, '2016/01/18');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (248, 522161642, 628529970, '2019/09/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (249, 435229275, 649193243, '2017/05/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (250, 529840745, 782068660, '2017/04/13');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (251, 567290097, 778438291, '2018/03/29');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (252, 508514244, 601496940, '2019/04/19');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (253, 529770583, 762636101, '2019/05/04');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (254, 522161642, 675573090, '2018/11/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (255, 496982654, 778438291, '2017/11/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (256, 407842323, 796385697, '2018/09/23');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (257, 526834867, 601496940, '2016/08/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (258, 529770583, 601496940, '2019/08/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (259, 578548772, 675573090, '2018/04/05');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (260, 508918810, 702410828, '2019/08/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (261, 435229275, 708466770, '2015/05/26');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (262, 578548772, 718676800, '2015/02/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (263, 578548772, 678856177, '2015/03/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (264, 508514244, 675573090, '2017/06/21');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (265, 574023080, 782068660, '2019/06/01');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (266, 579167277, 622658592, '2017/02/20');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (267, 522161642, 782068660, '2016/10/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (268, 526834867, 624255757, '2019/04/11');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (269, 449869350, 678856177, '2015/09/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (270, 529840745, 796385697, '2016/11/09');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (271, 529770583, 680621501, '2015/04/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (272, 578548772, 762636101, '2015/10/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (273, 529840745, 625967213, '2016/12/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (274, 508514244, 778438291, '2015/07/13');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (275, 407842323, 628529970, '2016/10/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (276, 508918810, 796385697, '2019/04/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (277, 508514244, 702410828, '2018/01/12');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (278, 435229275, 622658592, '2015/05/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (279, 407842323, 767374906, '2018/06/02');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (280, 402398434, 625967213, '2016/05/03');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (281, 529840745, 708466770, '2018/09/09');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (282, 407842323, 692979418, '2018/08/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (283, 435229275, 796385697, '2016/03/17');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (284, 510422495, 680621501, '2016/06/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (285, 529770583, 625967213, '2019/03/25');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (286, 526834867, 628529970, '2019/07/13');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (287, 529770583, 680621501, '2015/08/16');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (288, 510422495, 625967213, '2016/06/28');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (289, 584506376, 702410828, '2018/11/14');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (290, 529840745, 692979418, '2015/03/31');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (291, 529770583, 767374906, '2018/01/18');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (292, 435229275, 625967213, '2019/04/06');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (293, 449869350, 675573090, '2016/11/08');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (294, 574023080, 666384045, '2016/07/03');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (295, 574023080, 622658592, '2019/03/18');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (296, 579167277, 762636101, '2015/04/21');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (297, 402398434, 692979418, '2018/03/07');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (298, 508918810, 782068660, '2017/04/03');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (299, 419386689, 678856177, '2017/09/15');
insert into Academia.Factura (ID_Factura , ID_Estudiante, ID_Administrativo, Fecha_pago) values (300, 510422495, 628529970, '2016/02/02');


drop table if exists cedulas_temp 
create table Cedulas_temp (
	ID_fila int IDENTITY (1,1) primary key  not null, 
	Cedula_TSE int,
	Cedula_E   int,
)

insert into Cedulas_temp (Cedula_TSE) select TOP (select count(*) from Academia.Estudiante) Cedula from TSE.Personas 

declare @Cedula_E int, @ID_fila int = 0  
declare cursor_PRUEBA cursor for 
select ID_Estudiante from Academia.Estudiante 
open cursor_prueba 
fetch next from cursor_prueba into @Cedula_E 
while @@FETCH_STATUS = 0 
begin 
	set @ID_fila += 1 
	update Cedulas_temp 
	set Cedula_E = @Cedula_E where ID_Fila = @ID_fila 

fetch next from cursor_prueba into @Cedula_E 
end 
close cursor_prueba
deallocate cursor_prueba    

drop table if exists NewFactura 
drop table if exists NewMatriculacion 

select * into NewFactura from Academia.Factura
select * into NewMatriculacion from Academia.Matriculacion

delete from Academia.Factura
delete from Academia.Matriculacion


declare @id int, @cedula_tse_temp int, @cedula_estudiante_temp int,
		@Nombre_temp varchar(50), @ap1_temp varchar(50), @ap2_temp varchar(50) 

declare cursor_tabla_temp cursor for 
select ID_Fila from Cedulas_temp 
open cursor_tabla_temp 
fetch next from cursor_tabla_temp into @id 
while @@FETCH_STATUS = 0
begin 
	set @cedula_tse_temp = (Select Cedula_tse from Cedulas_temp where ID_Fila = @id) 
	 
	set @cedula_estudiante_temp = (select Cedula_E from Cedulas_temp where ID_fila = @id)

	set @Nombre_temp = (Select Nombre from TSE.Personas where Cedula = @cedula_tse_temp)

	set @ap1_temp = (Select Apellido1 from TSE.Personas where Cedula = @cedula_tse_temp)

	set @ap2_temp = (Select Apellido2 from TSE.Personas where Cedula = @cedula_tse_temp)


	UPDATE Academia.Estudiante 
	set ID_Estudiante = @cedula_tse_temp
	where ID_Estudiante = @cedula_estudiante_temp
			 
	UPDATE Academia.Estudiante 
	set Nombre = @Nombre_temp 
	where ID_Estudiante in (@cedula_estudiante_temp, @cedula_tse_temp)
	  
			 
	UPDATE Academia.Estudiante 
	set Apellido1 = @ap1_temp		 
	where ID_Estudiante in (@cedula_estudiante_temp, @cedula_tse_temp)

	UPDATE Academia.Estudiante 	
	set Apellido2 = @ap2_temp 
	where ID_Estudiante in (@cedula_estudiante_temp, @cedula_tse_temp)
	
	UPDATE NewMatriculacion 
	set ID_Estudiante = @cedula_tse_temp
	where ID_Estudiante = @cedula_estudiante_temp			
	
	UPDATE NewFactura 
	set ID_Estudiante = @cedula_tse_temp
	where ID_Estudiante = @cedula_estudiante_temp			
	
	fetch next from cursor_tabla_temp into @id 

end 
close cursor_tabla_temp 
deallocate cursor_tabla_temp  


insert into Academia.Factura 
select * from NewFactura 

insert into Academia.Matriculacion
select * from NewMatriculacion

drop table NewFactura
drop table NewMatriculacion
drop table Cedulas_temp 
