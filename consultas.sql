-- Reporte de Riesgo Acumulado:
SELECT
	estado,
	SUM(monto_credito) AS Total_Capital_Prestado,
	AVG(tasa_interes_mensual) AS Promedio_Tasa_Interes
FROM Operaciones.Creditos
GROUP BY estado;

-- Reporte de Concetración Vehicular:
SELECT
	marca,
	COUNT(*) AS Total_Prestamos
FROM Operaciones.Creditos
GROUP BY marca
HAVING COUNT(*) > 50;

-- Análisis de Extremos
SELECT 
	MAX(monto_credito) AS Mayor_Monto_Historico,
	MIN(monto_credito) AS Menor_Monto_Historico 
FROM Operaciones.Creditos;