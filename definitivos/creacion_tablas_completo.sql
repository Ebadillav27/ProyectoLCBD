create database Academia; 
use Academia;


create table Tipo_Beca
(
	ID_Beca				int				not null,
  	Porcentaje			int				not null,
	Primary key(ID_Beca)
)
 

create table Estudiante 
(
	ID_Estudiante		int				not null,
	Nombre				varchar(50)		not null, 
	Apellido1			varchar(50)		not null, 
	Apellido2			varchar(50)		not null, 
	Direccion			varchar(100)	not null, 
	Numero_telefono		int				not null, 
	fecha_nacimiento	date			not null, 
	Fecha_ingreso		date			not null, 
	ID_Beca			bit				not null,

	primary key(ID_Estudiante), 
	constraint fk_tipo_beca_estudiante	foreign key(ID_Beca) references Tipo_Beca(ID_Beca)
)

create table Profesor 
(
	ID_Profesor			int				not null,
	Nombre				varchar(50)		not null, 
	Apellido1			varchar(50)		not null, 
	Apellido2			varchar(50)		not null, 
	Direccion			varchar(100)	not null, 
	Numero_telefono		int				not null, 
	fecha_nacimiento	date			not null, 
	Fecha_ingreso		date			not null, 

	primary key(ID_Profesor)	
)

/*
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
*/ 

create table Aula
(
	ID_Aula				int				not null, 
	Capacidad_maxima	int				not null,

	Primary key(ID_Aula)
)

create table Arte
(
	ID_Arte				varchar(10)		not null,
	Nombre				varchar(50)		not null,

	Primary key(ID_Arte)
)
create table Curso 
(
	ID_Curso			int				not null, 
	Nombre				varchar(50)		not null, 
	ID_Arte				varchar(10)		not null, 
	ID_Persona			int				not null, 
	Costo				smallmoney		not null,
	Dia					varchar(10)		not null,
	Hora				time			not null,
	ID_Aula				int				not null, 

	Primary key(ID_Curso), 
	constraint fk_id_persona_cursos		foreign key(ID_Persona)		references Personas(ID_Persona), 
	constraint fk_id_aula_cursos		foreign key(ID_Aula)		references Aulas(ID_Aula),
	constraint fk_id_arte_cursos		foreign key(ID_Arte)		references Artes(ID_Arte)
)

create table Matriculacion
(
	ID_Matriculacion	int				not null,
	ID_Curso			int				not null, 
	ID_Persona			int				not null,

	primary key(ID_Matriculacion),
	constraint fk_id_curso_matric		foreign key(ID_Curso)		references Cursos(ID_Curso),
	constraint fk_id_persona_matric		foreign key(ID_Persona)			references Personas(ID_Persona),
)

create table Factura 
(
	ID_Pago				int				not null, 
	ID_Persona			int				not null, 
	Total_Pagado		smallmoney		not null, 
	descuento			smallmoney		not null,
  	Fecha_pago			date			not null, 

	Primary key(ID_Pago), 
	constraint fk_ID_Persona_factura	foreign key(ID_Persona)		references Personas(ID_Persona)
) 

create table Proveedores
(
	ID_Proveedor		int				not null,
	Nombre_Empresa		varchar(50)		not null,
	Telefono			int				not null,

	Primary key(ID_Proveedor)
)

create table Presentacion
(
	ID_Presentacion		int				not null,
	ID_Persona			int				not null,
	ID_Arte				varchar(10)		not null,
	Fecha_presentacion	date			not null,
	Duracion			time			not null,
	Lugar				varchar(50)		not null,

	Primary key(ID_Presentacion),
	constraint fk_ID_persona_pres		foreign key(ID_Persona)		references Personas(ID_Persona),
	constraint fk_ID_arte_pres			foreign key(ID_Arte)		references Artes(ID_Arte)
)

create table Inventario
(
	ID_Material			int				not null,
	Nombre_Material		varchar(50)		not null,
	ID_Proveedor		int				not null,
	Cantidad			int				not null,
	ID_Arte				varchar(10)		not null,

	Primary key(ID_Material),
	constraint fk_id_proveedor_inv		foreign key(ID_Proveedor)	references Proveedores(ID_Proveedor),
	constraint fk_ID_arte_inv			foreign key(ID_Arte)		references Artes(ID_Arte)
	)
