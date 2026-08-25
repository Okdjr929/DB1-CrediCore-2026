/*============================================================
					CREAMOS LA BASE DE DATOS
=============================================================*/
CREATE DATABASE CrediCore;

USE CrediCore;

-- Creamos el login a nivel de servidor
CREATE LOGIN CrediCoreUser WITH PASSWORD = 'Contraseña_de_Prueba';

-- Crear el Usuario dentro de la BD CrediCore
CREATE USER CrediCoreUser FOR LOGIN CrediCoreUser;


-- Asignamos rol db_owner
ALTER ROLE db_owner ADD MEMBER CrediCoreUser;


/*============================================================
					CREAMOS NUESTROS ESQUEMAS
=============================================================*/
CREATE SCHEMA Operaciones;
CREATE SCHEMA Garantias;

/*============================================================
						TABLA CLIENTES
=============================================================*/
CREATE TABLE Operaciones.Clientes(
	cliente_id INT IDENTITY(1, 1) PRIMARY KEY,
	nombres VARCHAR(100) NOT NULL,
	apellidos VARCHAR(100) NOT NULL,
	email VARCHAR(50) UNIQUE NOT NULL,
	CUI CHAR(13) UNIQUE NOT NULL,
	telefono CHAR(8) NOT NULL
);

/*============================================================
						TABLA VEHICULOS
=============================================================*/
CREATE TABLE Garantias.Vehiculos(
	vehiculo_id INT IDENTITY(1, 1) PRIMARY KEY,
	marca VARCHAR(50) NOT NULL,
	modelo VARCHAR(50) NOT NULL,
	color VARCHAR(20) NOT NULL,                 
	anio INT CHECK(anio >= 2011) NOT NULL,
	placa VARCHAR(7) UNIQUE NOT NULL 
);

/*============================================================
						TABLA CREDITOS
=============================================================*/
CREATE TABLE Operaciones.Creditos(
	credito_id INT IDENTITY(1,1) PRIMARY KEY,
	
	cliente_id INT NOT NULL,
	vehiculo_id INT UNIQUE NOT NULL,
	
	monto_credito DECIMAL(12,2) CHECK(monto_credito > 1000) NOT NULL,
	tasa_interes_mensual DECIMAL(6,4) CHECK(tasa_interes_mensual >= 0) NOT NULL,
	
	estado VARCHAR(10) DEFAULT('Activo'),
	fecha_desembolso DATETIME DEFAULT GETDATE()
);



-- Caso 1: Violación de CHECK en Garantias.Vehiculos (anio < 2011)
-- Error esperado: Conflict with CHECK constraint on column 'anio'
INSERT INTO Garantias.Vehiculos (marca, modelo, color, anio, placa) 
VALUES ('Toyota', 'Yaris', 'Rojo', 2009, 'P999ERR');


-- Caso 2: Violación de CHECK en Operaciones.Creditos (monto_credito <= 1000)
-- Error esperado: Conflict with CHECK constraint on column 'monto_credito'
INSERT INTO Operaciones.Creditos (cliente_id, vehiculo_id, monto_credito, tasa_interes_mensual) 
VALUES (1, 1, 500.00, 0.0200);

-- Caso 5: Violación de CHECK en Operaciones.Creditos (tasa_interes_mensual < 0)
-- Error esperado: Conflict with CHECK constraint on column 'tasa_interes_mensual'
INSERT INTO Operaciones.Creditos (cliente_id, vehiculo_id, monto_credito, tasa_interes_mensual) 
VALUES (3, 4, 15000.00, -0.0500);


-- 1. Clientes válidos
INSERT INTO Operaciones.Clientes (nombres, apellidos, email, CUI, telefono) VALUES
('Juan Carlos', 'Pérez Gómez', 'juan.perez@example.com', '1234567890101', '55551234'),
('María Fernanda', 'López Ruiz', 'maria.lopez@example.com', '2345678901012', '44445678'),
('Carlos Alberto', 'Mendoza Soto', 'carlos.mendoza@example.com', '3456789010123', '33339012'),
('Ana Sofía', 'Torres Girón', 'ana.torres@example.com', '4567890101234', '55553456'),
('Luis Eduardo', 'Ramírez Ramos', 'luis.ramirez@example.com', '5678901012345', '44447890');

-- 2. Vehículos válidos (Año >= 2011, Placas únicas)
INSERT INTO Garantias.Vehiculos (marca, modelo, color, anio, placa) VALUES
('Toyota', 'Corolla', 'Gris', 2018, 'P123ABC'),
('Honda', 'Civic', 'Negro', 2020, 'P234DEF'),
('Mazda', 'CX-5', 'Rojo', 2015, 'P345GHI'),
('Nissan', 'Sentra', 'Blanco', 2011, 'P456JKL'),
('Hyundai', 'Tucson', 'Azul', 2022, 'P567MNO');

-- 3. Créditos válidos (Relacionan cliente/vehículo 1:1, monto > 1000, tasa >= 0)
INSERT INTO Operaciones.Creditos (cliente_id, vehiculo_id, monto_credito, tasa_interes_mensual) VALUES
(1, 1, 25000.00, 0.0250),
(2, 2, 45000.50, 0.0180),
(3, 3, 15000.00, 0.0300),
(4, 4, 1200.00, 0.0210),
(5, 5, 80000.00, 0.0150);


-- SELECT PARA VER LA ESTRUCTURA Y DATOS DE NUESTRAS TABLAS
SELECT * FROM Operaciones.Creditos;
SELECT * FROM Operaciones.Clientes;
SELECT* FROM Garantias.Vehiculos;
