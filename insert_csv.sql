-- 1. Creamos la vista que mapea solo las 4 columnas del archivo
CREATE OR ALTER VIEW Operaciones.vw_CargaCreditos AS
SELECT cliente_id, vehiculo_id, monto_credito, tasa_interes_mensual
FROM Operaciones.Creditos;
GO


-- accedemos al .csv alojado en nuestro ubuntu server
BULK INSERT Operaciones.vw_CargaCreditos
FROM '/var/opt/mssql/creditos_v2.csv'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0A', 
    TABLOCK
);

SELECT * FROM Operaciones.Creditos;

