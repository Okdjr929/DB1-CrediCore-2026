/*=========================================================
   			PARTE A: Capa de Abstracción
=========================================================*/
CREATE SCHEMA vistas; -- Es un esquema utilizado para guardar las vistas

CREATE VIEW vistas.vw_AtencionAlCliente --Nombre del esqema
AS
SELECT nombres, apellidos, 
	   credito_id, 
	   marca, 
	   estado, monto_credito
FROM Operaciones.Clientes C
INNER JOIN Operaciones.Creditos CR
	    ON C.cliente_id = CR.credito_id
INNER JOIN Garantias.Vehiculos V
		ON CR.credito_id = V.vehiculo_id;

SELECT * FROM vistas.vw_AtencionAlCliente;-- SELECT a la vista creada


/*=========================================================
   			PARTE B: Lógica de Negocio Segura
=========================================================*/
-- 1. Tabla Historial Pagos
CREATE TABLE Operaciones.HistorialPagos(
	pago_id INT IDENTITY(1,1) PRIMARY KEY,
	credito_id INT NOT NULL,
	monto_abono DECIMAL(12,2) NOT NULL,
	fecha_pago DATETIME DEFAULT GETDATE()
);
GO
-- 2. Procedimiento almacenado
CREATE PROCEDURE Operaciones.SP_ProcesarPago
	@credito_id INT, -- Parametro que indica el código del crédito
	@MontoAbono DECIMAL(12, 2) -- Dinero que el cliente está pagando
AS
BEGIN
	-- Variable temporal para averiguar el saldo actual
	DECLARE @SaldoActual DECIMAL(12,2);

	-- Buscamos el saldo en la BD y lo guardamos en nuestra variable
	SELECT @SaldoActual = monto_credito
	FROM Operaciones.Creditos
	WHERE credito_id = @credito_id;
	
	BEGIN TRY
		BEGIN TRAN
			IF @MontoAbono > @SaldoActual
				BEGIN
					THROW 51000, 'El Monto Abonado es mayor al Monto del Crédito', 1;
				END
			ELSE	
				BEGIN 
					-- Guardamos el recibo en el historial
					INSERT INTO Operaciones.HistorialPagos (credito_id, monto_abono)
					VALUES(@credito_id, @MontoAbono);

					-- Restamos de la deuda principal el abono
					UPDATE Operaciones.Creditos 
					SET monto_credito = monto_credito - @MontoAbono
					WHERE credito_id = @credito_id;
				
					-- Confirmamos el cambio
					COMMIT;
				END				
	END TRY
	BEGIN CATCH
		-- Sí el THROW se activó, deshacemos todo
		ROLLBACK;
	END CATCH
END;

/*=========================================================
   			PARTE C: El Auditor Silencioso (Triggers)
=========================================================*/
CREATE SCHEMA Auditoria;

CREATE TABLE Auditoria.Logs_Creditos(
	IdLog INT IDENTITY(1,1) PRIMARY KEY,
	Accion VARCHAR(100),
	ValorAnterior DECIMAL(6, 4),
	ValorNuevo DECIMAL(6, 4),
	FechaHora DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_audit
ON Operaciones.Creditos 
AFTER UPDATE -- Vigilante que se despierta después de ralizar un UPDATE
AS
BEGIN
	-- Insertamos el registro en nuestra bitácora
	INSERT INTO Auditoria.Logs_Creditos(Accion, ValorAnterior, ValorNuevo, FechaHora)
	
	-- Extraemos los datos de las tablas mágicas que están temporalmente en memoria
	SELECT
		'Actualización de Tasa',
		d.tasa_interes_mensual, -- Tabla deleted: tiene la foto de cómo estaba el dato ANTES
		i.tasa_interes_mensual, -- Tabla inserted: tiene la foto de cómo quedó el datos DESPUÉS
		GETDATE()
	FROM deleted d
	INNER JOIN inserted i ON d.credito_id = i.credito_id
	WHERE d.tasa_interes_mensual != i.tasa_interes_mensual; -- Sólo guarda sí las tasas son diferentes
END;


-- PRUEBA DE LA PARTE 2
SELECT credito_id, monto_credito, c.tasa_interes_mensual 
FROM Operaciones.Creditos c
WHERE c.credito_id = 2;

EXEC Operaciones.SP_ProcesarPago
	@credito_id = 2,
	@MontoAbono = 100.00;
	
SELECT * FROM Operaciones.HistorialPagos hp WHERE hp.credito_id = 2;
	




SELECT * FROM Operaciones.Creditos 
WHERE credito_id = 2;

-- PRUEBA DE LA PARTE 3
UPDATE Operaciones.Creditos
SET tasa_interes_mensual = 0.0400
WHERE credito_id = 2;


SELECT * FROM Auditoria.Logs_Creditos;
