use ProyectoFinal; 
go 
create trigger TSE.ejemplo
on    [TSE].[PADRON_COMPLETO]
after insert as 
begin
declare @check  int 
 
set @check = (select COUNT([cedula]) from  [TSE].[PADRON_COMPLETO])
    if @check  = @check 
    begin
        rollback transaction
        raiserror ('NO PUEDE INSERTAR DATOS',1,1)
    end
end

-- delete from [TSE].[PADRON_COMPLETO] where [cedula] = 100339724 --PRUEBA PARA EL TRIGGER 



--------------------------------------------------------------------
--------------------------------------------------------------------
drop table if exists historial 
create table historial
(
Usuario varchar(5000),
descripcion varchar(111),
hora datetime
)
go
---------------------------------
create trigger Academia.log
on   Academia.Inventario for delete 
as 
set nocount on 
declare @usuario varchar(1000)
set @usuario = ( SELECT distinct top(1) login_name FROM sys.dm_exec_sessions )
insert into historial values (@usuario, 'Modificado', CURRENT_TIMESTAMP)
go
-------------------------------------
drop trigger Academia.log 

-- delete from  Academia.Inventario where id_material = 2 -- prueba para el trigger 

-- select * from historial -- para ver los datos de la tabla historial 