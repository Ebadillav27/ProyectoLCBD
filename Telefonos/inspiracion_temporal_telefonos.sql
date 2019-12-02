CREATE TABLE Telefonos_Generales(
		Cedula int NOT NULL PRIMARY KEY,
		Telefono nvarchar(255) NOT NULL
		--Nombre_Cliente nvarchar(255) NOT NULL
	);

DECLARE @cedula int,
		-- @telefono nvarchar(255),
		@prev int

DECLARE Cursor1 CURSOR SCROLL
	FOR	
	SELECT distinct Cedula FROM Telefonos_General
	

OPEN Cursor1
FETCH NEXT FROM Cursor1 into @cedula --, @telefono
WHILE (@@FETCH_STATUS=0)
	BEGIN
	IF @prev IS NULL or @prev != @cedula
		INSERT INTO Telefonos_Generales(Cedula, Telefono) --, Telefono)
			values (@cedula, (SELECT top (1) Telefono from Telefonos_General where @cedula = Cedula))   --, @telefono)
	ELSE 
		UPDATE Telefonos_Generales
		SET Telefono = Telefono + ', ' 	
		WHERE Cedula = @cedula;
	SET @prev = @cedula
	FETCH NEXT FROM Cursor1 INTO @cedula
END
CLOSE Cursor1
DEALLOCATE Cursor1

select * from Telefonos_Generales 