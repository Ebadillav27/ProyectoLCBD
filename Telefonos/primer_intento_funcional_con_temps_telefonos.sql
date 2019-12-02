DECLARE @ID_temp			int, 
		@telefono_temp		varchar(50), 
		@Cedula_temp		varchar(50),
		@Cedula_nuevas		varchar(50), 
		@contador_interno	int,
		@cant_filas			int 

set @cant_filas = (SELECT Count(Cedula) FROM Telefonos_General_VProv)

DECLARE cursor_telefonos_temps CURSOR FOR 
	SELECT ID_fila, Telefono, Cedula FROM Telefonos_TEMP 

OPEN cursor_telefonos_temps 
FETCH NEXT FROM cursor_telefonos_temps INTO @ID_temp, @telefono_temp, @Cedula_temp

WHILE @@FETCH_STATUS = 0
BEGIN -- INICIO CICLO EXTERNO 

	SET @contador_interno = 1
	
	WHILE @contador_interno < @cant_filas
	BEGIN -- INICIO CICLO INTERNO 
		set @Cedula_nuevas = (select Cedula FROM Telefonos_General_VProv WHERE ID_fila = @contador_interno)
		
		IF @Cedula_temp = @Cedula_nuevas
		BEGIN 
			UPDATE Telefonos_General_VProv 
				set Cantidad_Telefonos += 1 WHERE ID_fila = @contador_interno 
			
			UPDATE Telefonos_General_VProv 
				set Telefonos += ', ' + @telefono_temp WHERE ID_fila = @contador_interno 
		END;
		set @contador_interno += 1
	
	END; -- FIN CICLO INTERNO 
	FETCH NEXT FROM cursor_telefonos_temps INTO 
		@ID_temp, @telefono_temp, @Cedula_temp	
END; -- FIN CICLO EXTERNO
CLOSE cursor_telefonos_temps
DEALLOCATE cursor_telefonos_temps
