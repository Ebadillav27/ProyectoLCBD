use Academia; 

create table Estudiantes 
(
	ID_Estudiante		int				not null,
	Nombre				varchar(50)		not null, 
	Apellido1			varchar(50)		not null, 
	Apellido2			varchar(50)		not null, 
	Direccion			varchar(100)	not null, 
	Numero_telefono		int				not null, 
	Edad				int				not null, 
	Fecha_ingreso		date			not null, 
	es_becado			bit				not null,

	primary key(ID_Estudiante)
)

create table Profesores
(
	ID_Profesor			int				not null,
	Nombre				varchar(50)		not null, 
	Apellido1			varchar(50)		not null, 
	Apellido2			varchar(50)		not null, 
	Direccion			varchar(100)	not null, 
	Numero_telefono		int				not null, 
	Edad				int				not null, 
	Fecha_inicio		date			not null, 

	primary key(ID_Profesor)
)

create table Aulas
(
	ID_Aula				int				not null, 
	Capacidad_maxima	int				not null,

	Primary key(ID_Aula)
)

create table Artes
(
	ID_Arte				int				not null,
	Nombre				varchar(50)		not null,

	Primary key(ID_Arte)
)
create table Cursos 
(
	ID_Curso			int				not null, 
	Nombre				varchar(50)		not null, 
	ID_Arte				int				not null, 
	ID_Profesor			int				not null, 
	Costo				smallmoney		not null,
	Dia					varchar(10)		not null,
	Hora				time			not null,
	ID_Aula				int				not null, 

	Primary key(ID_Curso), 
	constraint fk_id_profresor_cursos	foreign key(ID_Profesor)	references Profesores(ID_Profesor), 
	constraint fk_id_aula_cursos		foreign key(ID_Aula)		references Aulas(ID_Aula),
	constraint fk_id_arte_cursos		foreign key(ID_Arte)		references Artes(ID_Arte)
)

create table Matriculaciones
(
	ID_Matriculacion	int				not null,
	ID_Curso			int				not null, 
	ID_Estudiante		int				not null,

	primary key(ID_Matriculacion),
	constraint fk_id_curso_matric		foreign key(ID_Curso)		references Cursos(ID_Curso),
	constraint fk_id_estudiante_matric	foreign key(ID_Estudiante)	references Estudiantes(ID_Estudiante),
)

create table Pagos_Cursos 
(
	ID_Pago				int				not null, 
	ID_Estudiante		int				not null, 
	Total_Pagado		smallmoney		not null, 
	Fecha_pago			date			not null, 

	Primary key(ID_Pago), 
	constraint fk_ID_Estudiante_pagos	foreign key(ID_Estudiante)	references Estudiantes(ID_Estudiante)
)

create table Proveedores
(
	ID_Proveedor		int				not null,
	Nombre_Empresa		varchar(50)		not null,
	Telefono			int				not null,
	ID_Arte				int				not null,

	Primary key(ID_Proveedor),
	constraint fk_ID_arte_proveedores	foreign key(ID_Arte)		references Artes(ID_Arte)
)

create table Presentaciones
(
	ID_Presentacion		int				not null,
	ID_Profesor			int				not null,
	ID_Arte				int				not null,
	Fecha_presentacion	date			not null,
	Duracion			time			not null,
	Lugar				varchar(50)		not null,

	Primary key(ID_Presentacion),
	constraint fk_id_profesor_pres		foreign key(ID_Profesor)	references Profesores(ID_Profesor),
	constraint fk_ID_arte_pres			foreign key(ID_Arte)		references Artes(ID_Arte)
)

create table Inventarios
(
	ID_Material			int				not null,
	ID_Proveedor		int				not null,
	Cantidad			int				not null,
	ID_Arte				int				not null,

	Primary key(ID_Material),
	constraint fk_id_proveedor_inv		foreign key(ID_Proveedor)	references Proveedores(ID_Proveedor),
	constraint fk_ID_arte_inv			foreign key(ID_Arte)		references Artes(ID_Arte)
)