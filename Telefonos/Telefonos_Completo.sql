use Telefonos; 
GO
drop proc if exists Creador_Telefonos
GO

create proc Creador_Telefonos 
as 

drop table IF EXISTS Telefonos_General_V2;

create table Telefonos_General_V2
(
	Cedula				varchar(50)	not null,
	Nombre				varchar(50), 
	Cantidad_Telefonos	int,				
	Telefonos			varchar(max),	
	
	primary key (Cedula)
)

INSERT INTO Telefonos_General_V2 (Cedula)
SELECT distinct top (1000) Cedula from Telefonos_General --quitar el top 
ORDER BY Cedula

update Telefonos_General_V2 
set Cantidad_Telefonos = 0

update Telefonos_General_V2 
set Telefonos = ''

--- CURSOR, SOLO ES UNO 
DECLARE @telefono_Tabla_Vieja	varchar(50), 
		@Cedula_Tabla_Vieja		varchar(50),
		@Nombre					varchar(50) -- cambio temporal 

DECLARE cursor_telefonos CURSOR FOR 
	SELECT Telefono, Cedula, Nombre_Cliente FROM Telefonos_General 

OPEN cursor_telefonos 
FETCH NEXT FROM cursor_telefonos INTO @telefono_Tabla_Vieja, @Cedula_Tabla_Vieja, @Nombre

WHILE @@FETCH_STATUS = 0
BEGIN -- INICIO CICLO

	
		UPDATE Telefonos_General_V2
			set Cantidad_Telefonos += 1 WHERE Cedula = @Cedula_Tabla_Vieja
			
		
		UPDATE Telefonos_General_V2 
			set Telefonos += ', ' + @telefono_Tabla_Vieja WHERE Cedula = @Cedula_Tabla_Vieja AND Telefonos not like ''  

		UPDATE Telefonos_General_V2
			SET Telefonos = @telefono_Tabla_Vieja WHERE Cedula = @Cedula_Tabla_Vieja AND Telefonos LIKE ''		

		UPDATE Telefonos_General_V2 
			Set Nombre = @Nombre WHERE Cedula = @Cedula_Tabla_Vieja
		 
	
	
	FETCH NEXT FROM cursor_telefonos 
		INTO @telefono_Tabla_Vieja, @Cedula_Tabla_Vieja, @Nombre	

END; -- FIN CICLO
CLOSE cursor_telefonos
DEALLOCATE cursor_telefonos

--exec Creador_Telefonos

