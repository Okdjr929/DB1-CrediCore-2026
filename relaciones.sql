/*========================================================================
	PASO 1: RESTRICCIONES FORÁNEAS
 ========================================================================*/
-- 1. Conectar clientes con créditos
ALTER TABLE Operaciones.Creditos 
ADD CONSTRAINT FK_Creditos_Clientes 
FOREIGN KEY(cliente_id) REFERENCES Operaciones.Clientes(cliente_id);


-- 2. Conectar Créditos con Vehiculos (Garantias)
ALTER TABLE Operaciones.Creditos
ADD CONSTRAINT FK_Creditos_Garantias
FOREIGN KEY(vehiculo_id) REFERENCES Garantias.Vehiculos(vehiculo_id);

DELETE FROM Operaciones.Clientes WHERE cliente_id = 15;



-- INNER JOIN TRIPLE
SELECT TOP 5 C.nombres, C.apellidos, C.telefono,
VH.marca, VH.placa, 
CR.monto_credito, CR.estado
FROM Operaciones.Clientes C --(A)
INNER JOIN Operaciones.Creditos CR --(B)  
	ON CR.cliente_id = C.cliente_id  
INNER JOIN Garantias.Vehiculos VH --(C) 
	ON VH.vehiculo_id = CR.vehiculo_id;

-- LEFT JOIN
SELECT 
    c.cliente_id, c.nombres, c.apellidos, c.CUI
FROM Operaciones.Clientes c
LEFT JOIN Operaciones.Creditos cr 
    ON c.cliente_id = cr.cliente_id
WHERE cr.credito_id IS NULL;

SELECT * FROM Operaciones.Creditos C
WHERE C.cliente_id = 34;


-- PARTE C
-- 1. FILTRO DINÁMICO (SUBCONSULTA CON WHERE)
SELECT C.nombres, CR.monto_credito 
FROM Operaciones.Clientes C
INNER JOIN Operaciones.Creditos CR
	ON CR.cliente_id = C.cliente_id
WHERE CR.monto_credito > 
(SELECT AVG(monto_credito) FROM Operaciones.Creditos)
ORDER BY monto_credito ASC;

-- 2. Patrones anidados (Subconsulta con IN)
SELECT C.nombres, CR.credito_id  
FROM Operaciones.Clientes C
INNER JOIN Operaciones.Creditos CR 
	ON CR.cliente_id = C.cliente_id 
WHERE CR.vehiculo_id IN (
	SELECT vehiculo_id  
	FROM Garantias.Vehiculos 
	WHERE anio <= 2011
)
ORDER BY CR.credito_id ASC;



