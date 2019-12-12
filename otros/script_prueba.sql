exec AcademiaCompleto

select * from NewFactura
select Academia.Estudiante.*, Telefonos.Telefonos_General_V2.Cantidad_Telefonos  from Academia.Estudiante inner join Telefonos.Telefonos_General_V2 on Academia.Estudiante.ID_Estudiante = Telefonos.Telefonos_General_V2.Cedula