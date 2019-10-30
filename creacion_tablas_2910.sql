-- use Academia; 


create table Tipos_Personas
(
	ID_Tipo				int				not null,
  	Descripcion			varchar(50)		not null,
	Primary key(ID_Tipo)
)


create table Personas
(
	ID_Persona			int				not null,
	Nombre				varchar(50)		not null, 
	Apellido1			varchar(50)		not null, 
	Apellido2			varchar(50)		not null, 
	Direccion			varchar(100)	not null, 
	Numero_telefono		varchar(50)		not null, -- debería ser int, pero hay que corregir las inserciones. 
	fecha_nacimiento	date			not null, 
	Fecha_ingreso		date			not null, 
  	tipo_persona 		int				not null,
	es_becado			bit				not null,

	primary key(ID_Persona),
	constraint fk_tipo_persona			foreign key(tipo_persona)	references Tipos_Personas(ID_Tipo)
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

create table Aulas
(
	ID_Aula				int				not null, 
	Capacidad_maxima	int				not null,

	Primary key(ID_Aula)
)

create table Artes
(
	ID_Arte				varchar(10)		not null,
	Nombre				varchar(50)		not null,

	Primary key(ID_Arte)
)
create table Cursos 
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

create table Matriculaciones
(
	ID_Matriculacion	int				not null,
	ID_Curso			int				not null, 
	ID_Persona			int				not null,

	primary key(ID_Matriculacion),
	constraint fk_id_curso_matric		foreign key(ID_Curso)		references Cursos(ID_Curso),
	constraint fk_id_persona_matric		foreign key(ID_Persona)			references Personas(ID_Persona),
)

create table Facturas 
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

create table Presentaciones
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

create table Inventarios
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
