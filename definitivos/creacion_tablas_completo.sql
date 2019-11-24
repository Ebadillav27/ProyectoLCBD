use master;
DROP DATABASE IF EXISTS Academia;
create database Academia;
GO
use Academia;

create table Tipo_Beca
(--Listo
	ID_Beca				int				not null,
  	Valor				decimal			not null,
	Primary key(ID_Beca)
)
 

create table Estudiante 
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
	constraint fk_tipo_beca_estudiante	foreign key(ID_Beca) references Tipo_Beca(ID_Beca)
)

create table Profesor 
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

create table Administrativo
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
 

create table Aula
(
	ID_Aula				int				not null, 
	Capacidad_maxima	int				not null,

	Primary key(ID_Aula)
)

create table Arte
(
	ID_Arte				int				not null,
	Nombre				varchar(50)		not null,

	Primary key(ID_Arte)
)
create table Curso 
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
	constraint fk_id_profesor_cursos	foreign key(ID_Profesor)	references Profesor(ID_Profesor), 
	constraint fk_id_aula_cursos		foreign key(ID_Aula)		references Aula(ID_Aula),
	constraint fk_id_arte_cursos		foreign key(ID_Arte)		references Arte(ID_Arte)
)

create table Matriculacion
(
	ID_Matriculacion	int				not null,
	ID_Curso			int				not null, 
	ID_Estudiante		int				not null,
	ID_Administrativo	int				not null, 
	--Total				int				not null, -- estos datos se generan multiplicando el costo del curso por la beca del estudainte (Valor en Becas)

	primary key(ID_Matriculacion),
	constraint fk_id_curso_matric		foreign key(ID_Curso)		references curso(ID_Curso),
	constraint fk_id_estudiante_matric	foreign key(ID_Estudiante)	references Estudiante(ID_Estudiante),
	constraint fk_id_admin_matric		foreign key(ID_Administrativo) references Administrativo(ID_Administrativo)
	
)

create table Factura 
(
	ID_Factura			int				not null, 
	ID_Estudiante		int				not null, 
	--Total_Pagado		int				not null, -- Generada a partir de la suma de los datos de matriculacion segun estudiante	
  	Fecha_pago			date			not null, 

	Primary key(ID_Factura), 
	constraint fk_ID_Persona_factura	foreign key(ID_Estudiante)		references Estudiante(ID_Estudiante)
) 

create table Proveedor
(
	ID_Proveedor		int				not null,
	Nombre_Empresa		varchar(50)		not null,
	Telefono			int				not null,

	Primary key(ID_Proveedor)
)

create table Presentacion
(
	ID_Presentacion		int				not null,
	Titulo				varchar(50)		not null, 

	ID_Profesor			int				not null,
	ID_Arte				int				not null,
	Fecha_presentacion	date			not null,
	Duracion			time			not null,
	Lugar				varchar(50)		not null,

	Primary key(ID_Presentacion),

	constraint fk_ID_profe_pres		foreign key(ID_Profesor)		references Profesor(ID_Profesor),
	constraint fk_ID_arte_pres			foreign key(ID_Arte)		references Arte(ID_Arte)
)

create table Inventario
(
	ID_Material			int				not null,
	Nombre_Material		varchar(50)		not null,
	ID_Proveedor		int				not null,
	Cantidad			int				not null,
	ID_Arte				int				not null,

	Primary key(ID_Material),
	constraint fk_id_proveedor_inv		foreign key(ID_Proveedor)	references Proveedor(ID_Proveedor),
	constraint fk_ID_arte_inv			foreign key(ID_Arte)		references Arte(ID_Arte)
	)
	--DELETE FROM Profesor;
	--Drop Table Admistrativo
	--SELECT * FROM Estudiante