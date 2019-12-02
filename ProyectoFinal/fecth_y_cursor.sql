DECLARE 
    @nombre		VARCHAR(50), 
    @numero_telefono   INT;
 
DECLARE cursor_nombres CURSOR
FOR SELECT 
        Nombre, 
        Numero_telefono
    FROM 
        Estudiante;

OPEN cursor_nombres;

FETCH NEXT from cursor_nombres INTO 
@nombre,
@Numero_telefono;

WHILE @@FETCH_STATUS = 0 
	BEGIN 
	PRINT 'Nombre: ' + @Nombre + ' Numero de telefono: ' + CAST(@Numero_telefono AS VARCHAR); 
	FETCH NEXT FROM cursor_nombres INTO 
	@nombre,
	@Numero_telefono;
	END;

CLOSE cursor_nombres; 

DEALLOCATE cursor_nombres; 