DECLARE 
@cedula int, 
--@codigo_distrito int,
-- @sexo	int, 
--@fechacaduc date,
--@junta_votos int, 
@nombre varchar(50),
@apellido1 varchar(50),
@apellido2 varchar(50); 

DECLARE cursor_personas CURSOR 
FOR SELECT 
	Academia.dbo.Estudiante.ID_Estudiante,
	Academia.dbo.Estudiante.Nombre,
	Academia.dbo.Estudiante.Apellido1,
	Academia.dbo.Estudiante.Apellido2

FROM Academia.dbo.Estudiante;

open cursor_personas; 

FETCH NEXT FROM cursor_personas INTO @cedula, @nombre, @apellido1, @apellido2; 

WHILE @@FETCH_STATUS = 0
BEGIN
	

	INSERT INTO TSE.dbo.Personas (TSE.dbo.Personas.cedula, TSE.dbo.Personas.nombre, TSE.dbo.Personas.apellido1, TSE.dbo.Personas.apellido2)
	values (@cedula, @nombre, @apellido1, @apellido2) 

FETCH NEXT FROM cursor_personas into @cedula, @nombre, @apellido1, @apellido2;
END;

CLOSE cursor_personas; 
DEALLOCATE cursor_personas;

