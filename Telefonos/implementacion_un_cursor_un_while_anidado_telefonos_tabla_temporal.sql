--CREATE TABLE Telefonos_TEMP ( -- CREANDO TABLA TEMPORAL PARA USAR EL IDENTITY COMO EVALUADOR EN EL CICLO INTERNO 
--	ID_fila	int IDENTITY(1,1), 
--	Telefono	varchar(50) NOT NULL, 
--	Cedula		varchar(50) NOT NULL

--)
--drop table Telefonos_TEMP
--INSERT INTO Telefonos_TEMP (Telefono, Cedula) 
--SELECT Telefono, Cedula FROM Telefonos_General ORDER BY CEDULA

----------------------------------------------------------------------------
DECLARE @Cedula_TN			varchar(50),
		@cedula_temp		varchar(50),		
		@Telefonos_TN		varchar(50),
		@telefono_temp		varchar(50),
		@ntels_TN			int,
		@contador_interno	int,
		@count_filas		int

set @count_filas = 	(SELECT Count(Cedula) FROM Telefonos_General)	

DECLARE cursor_telefonos_nuevos CURSOR -- CURSOR DE LA TABLA FINAL  

FOR SELECT Cedula, Telefonos, Cantidad_Telefonos from Telefonos_General_V2 

OPEN cursor_telefonos_nuevos

FETCH NEXT FROM cursor_telefonos_nuevos INTO @Cedula_TN, @Telefonos_TN, @ntels_TN 

WHILE @@FETCH_STATUS = 0
BEGIN -- INICIA PRIMER CICLO
	SET @contador_interno = 1 -- CONTADOR PARA CICLO INTERNO SIN CURSOR
		
	WHILE @contador_interno < @count_filas
	
	BEGIN -- INICIA CICLO DEL SEGUNDO CURSOR (INTERIOR)
		
		
		set @cedula_temp = 	(SELECT Cedula FROM Telefonos_TEMP where ID_fila = @contador_interno) 
		
		IF @Cedula_TN = @cedula_temp -- meter los datos si encuentra un match  	
		
			BEGIN -- empiezan acciones del IF
				
				set @telefono_temp = (SELECT Telefono FROM Telefonos_TEMP where ID_fila = @contador_interno)
		
				PRINT 'hola aquí hay un match: ' + @Cedula_TN 
				UPDATE Telefonos_General_V2 
				SET Telefonos = @Telefonos_TN + ', ' + @telefono_temp WHERE @Cedula_TN = @cedula_temp
				
				UPDATE Telefonos_General_V2
				SET Cantidad_Telefonos = @ntels_TN +1 WHERE @Cedula_TN = @cedula_temp

				SET @contador_interno = @contador_interno + 1 	
			END; -- TERMINAN ACCIONES DEL IF 
		ELSE 
			BEGIN

			PRINT 'hola aquí NO hay un match: ' + @Cedula_TN + 'porque el ID_Fila era: ' + CONVERT(varchar(50), @contador_interno)
			SET @contador_interno = @contador_interno + 1 
			
			END; 
	
			
	END; -- TERMINA CICLO INTERIOR 
		
	FETCH NEXT FROM cursor_telefonos_nuevos INTO @Cedula_TN, @Telefonos_TN, @ntels_TN 
END; -- TERMINA CICLO DEL CURSOR (EXTERIOR) 
CLOSE cursor_telefonos_nuevos
DEALLOCATE cursor_telefonos_nuevos