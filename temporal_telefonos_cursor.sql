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


DECLARE @Cedula		varchar(50),
		@Telefono	varchar(50),
		@temp		int		

DECLARE cursor_telefono_final CURSOR
FOR SELECT distinct Cedula, Telefono from Telefonos_General 
OPEN cursor_telefono_final

FETCH NEXT FROM cursor_telefono_final INTO @Cedula, @Telefono

WHILE @@FETCH_STATUS = 0
BEGIN 
	/* 
	IF @temp IS NULL OR @temp <> @Cedula 
				
		INSERT INTO Telefonos_General_V2 (Cedula, Cantidad_Telefonos, Telefonos)
		values (@Cedula, @cnt_tels, @Telefono)
		
	*/
	ELSE 
		UPDATE Telefonos_General_V2 
		SET Telefonos = Telefonos + ', ' + @Telefono WHERE @Cedula = Cedula 
		UPDATE Telefonos_General_V2
		SET Cantidad_Telefonos = Cantidad_Telefonos + 1 
	
END
CLOSE cursor_telefono_final 
DEALLOCATE cursor_telefono_final 
select * from Telefonos_General_V2;
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