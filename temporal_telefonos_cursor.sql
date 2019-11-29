drop table Telefonos_General_V2;

create table Telefonos_General_V2
(
	Cedula				int				not null, 
	-- Nombre				varchar(50)		not null, 
	Cantidad_Telefonos	int,				-- not null,
	Telefonos			varchar(100),	--not null --,
	
	primary key (Cedula)
)

INSERT INTO Telefonos_General_V2 (Cedula)
SELECT distinct Cedula from Telefonos_General 

update Telefonos_General_V2 
set Cantidad_Telefonos = 0

update Telefonos_General_V2 
set Telefonos = ''
------------------------------------------------ 

--PRIMER CURSOR 

DECLARE @Cedula_TN		varchar(50),
		@Telefonos_TN	varchar(50),
		@ntels_TN		int
		
DECLARE cursor_telefonos_nuevos CURSOR

FOR SELECT Cedula, Telefonos, Cantidad_Telefonos from Telefonos_General_V2 

OPEN cursor_telefonos_nuevos

FETCH NEXT FROM cursor_telefonos_nuevos INTO @Cedula_TN, @Telefonos_TN, @ntels_TN 

WHILE @@FETCH_STATUS = 0
BEGIN -- INICIA PRIMER CURSOR, Y SE DECLARA EL SEGUNDO 
	
	DECLARE @cedula_TV varchar(50),
			@telefono_TV varchar(50) 
			
	DECLARE cursor_telefonos_viejos CURSOR 
	FOR SELECT Cedula, Telefono FROM Telefonos_General
	OPEN cursor_telefonos_viejos
	FETCH NEXT FROM cursor_telefonos_viejos INTO @cedula_TV, @telefono_TV
	WHILE @@FETCH_STATUS = 0
	BEGIN -- INICIA SEGUNDO CURSOR
		IF @Cedula_TN = @cedula_TV  -- meter los datos si encuentra un match  
			BEGIN -- empiezan acciones del IF 
			UPDATE Telefonos_General_V2 
			SET Telefonos = @Telefonos_TN + ', ' + @Telefono_TV 
				WHERE @Cedula_TN = @cedula_TV
				
			UPDATE Telefonos_General_V2
			SET Cantidad_Telefonos = @ntels_TN +1 
				WHERE @Cedula_TN = @cedula_TV
			END -- TERMINAN ACCIONES DEL IF 
	
		
		
	END -- TERMINA EL CURSOR INTERIOR 
	CLOSE cursor_telefonos_viejos 
	DEALLOCATE cursor_telefonos_viejos 
		
	
END -- TERMINA CURSOR EXTERIOR 
CLOSE cursor_telefonos_nuevos
DEALLOCATE cursor_telefonos_nuevos

-------------------------------------------------------
/*
delete from Telefonos_General_V2;

INSERT INTO Telefonos_General_V2 (Cedula)
SELECT distinct Cedula from Telefonos_General 

update Telefonos_General_V2 
set Cantidad_Telefonos = 0

update Telefonos_General_V2 
set Telefonos = ''
*/ 
-------------------------------------------------------
-- SELECT distinct Cedula, Nombre_Cliente from Telefonos_General where Cedula = 100586453
-- SELECT distinct Cedula, Nombre_Cliente from Telefonos_General where Cedula = 100774770
-- delete from Telefonos_General where Nombre_Cliente = 'PICADO CHINCHILLA RAFAEL'
-- delete from Telefonos_General where Nombre_Cliente = 'CRUZ BOLA/OS LUIS'
-- delete from Telefonos_General where Cedula = '0' or Cedula = ''
-- SELECT distinct Cedula, Nombre_Cliente from Telefonos_General where Cedula = 100586453
-- SELECT distinct Cedula, Nombre_Cliente from Telefonos_General where Cedula = 100520253
-- delete from Telefonos_General where Nombre_Cliente = 'QUESADA FLORA MONTEALEGRE D'
-- también borramos los 0s y el vacío 

-------------------------------------------------------
/*
DECLARE @telefono	varchar(50), 
		@cedula		varchar(50);
		-- @ntels		int; 

DECLARE cursor_telefonos CURSOR
FOR 
SELECT	Telefonos_General.Telefono,
		Telefonos_General.Cedula --, 
		--Telefonos_General_V2.Cantidad_Telefonos 

FROM	Telefonos_General --, Telefonos_General_V2 

open cursor_telefonos;

FETCH NEXT FROM cursor_telefonos into  @telefono, @cedula --, @ntels

WHILE @@FETCH_STATUS = 0
BEGIN 
	IF @cedula in (select Cedula from Telefonos_General)

		UPDATE Telefonos_General_V2 
			set Cantidad_Telefonos = (SELECT Cantidad_Telefonos FROM Telefonos_General_V2 where @cedula = Telefonos_General_V2.Cedula) + 1 where @cedula = Telefonos_General_V2.Cedula
		
		UPDATE Telefonos_General_V2
			set Telefonos = (SELECT Telefonos FROM Telefonos_General_V2 where @cedula = Telefonos_General_V2.Cedula) + @telefono + ', ' where @cedula = Telefonos_General_V2.Cedula
		
	FETCH NEXT FROM cursor_telefonos into @telefono, @cedula; -- @ntels; 

END;  

CLOSE cursor_telefonos; 
DEALLOCATE cursor_telefonos; 
*/
-------------------------------------------------------
select * from Telefonos_General_V2;