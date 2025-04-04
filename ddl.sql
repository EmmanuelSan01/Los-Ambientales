-- I. CREACIÓN DE LA BASE DE DATOS

DROP DATABASE IF EXISTS parques_naturales;
CREATE DATABASE parques_naturales;
USE parques_naturales;

CREATE TABLE entidad (
	id INT PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR(40) NOT NULL
);

CREATE TABLE departamento (
	id INT PRIMARY KEY AUTO_INCREMENT,
	entidad INT NOT NULL,
	nombre VARCHAR(25) NOT NULL,
	capital VARCHAR(25) NOT NULL,
	superficie_km2 INT CHECK (superficie_km2 > 0) NOT NULL,
	poblacion INT CHECK (poblacion > 0) NOT NULL,
	prefijo_telefonico INT NOT NULL,
	region ENUM("Amazonía", "Andina", "Caribe", "Insular", "Orinoquía", "Pacífico") DEFAULT "Amazonía",
	FOREIGN KEY (entidad) REFERENCES entidad(id)
);

CREATE TABLE parque_natural (
	id INT PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR(100) NOT NULL,
	fecha_declaracion DATE NOT NULL,
	superficie_ha INT CHECK (superficie_ha > 0) NOT NULL
);

CREATE TABLE jurisdiccion (
	departamento INT NOT NULL,
	parque_natural INT NOT NULL,
	relacion ENUM("Principal", "Secundario") DEFAULT "Principal",
	FOREIGN KEY (departamento) REFERENCES departamento(id),
	FOREIGN KEY (parque_natural) REFERENCES parque_natural(id),
	PRIMARY KEY (departamento, parque_natural)
);

CREATE TABLE alojamiento (
	id INT PRIMARY KEY AUTO_INCREMENT,
	parque_natural INT NOT NULL,
	categoria ENUM("Bungalow", "Cabaña", "Camping", "Glamping") DEFAULT "Bungalow",
	capacidad INT CHECK (capacidad > 0) NOT NULL,
	FOREIGN KEY (parque_natural) REFERENCES parque_natural(id)
);

CREATE TABLE area (
	id INT PRIMARY KEY AUTO_INCREMENT,
	parque_natural INT NOT NULL,
	nombre VARCHAR(64) NOT NULL,
	extension_km2 INT CHECK (extension_km2 > 0) NOT NULL,
	FOREIGN KEY (parque_natural) REFERENCES parque_natural(id)
);

CREATE TABLE visitante (
	id INT PRIMARY KEY AUTO_INCREMENT,
	alojamiento INT NOT NULL,
	cedula VARCHAR(20) CHECK (LENGTH(cedula) > 6) UNIQUE NOT NULL,
	nombre1 VARCHAR(20) NOT NULL,
	nombre2 VARCHAR(20),
	apellido1 VARCHAR(20) NOT NULL,
	apellido2 VARCHAR(20) NOT NULL,
	direccion VARCHAR(100) NOT NULL,
	profesion VARCHAR(64),
	FOREIGN KEY (alojamiento) REFERENCES alojamiento(id)
);

CREATE TABLE especie (
	id INT PRIMARY KEY AUTO_INCREMENT,
	area INT NOT NULL,
	reino ENUM("Animal", "Mineral", "Vegetal") DEFAULT "Animal",
	den_cientifica VARCHAR(30) NOT NULL,
	den_vulgar VARCHAR(30) NOT NULL,
	cantidad INT CHECK (cantidad > 0) NOT NULL,
	FOREIGN KEY (area) REFERENCES area(id)
);

CREATE TABLE personal (
	id INT PRIMARY KEY AUTO_INCREMENT,
	area INT NOT NULL,
	cedula VARCHAR(20) CHECK (LENGTH(cedula) > 6) UNIQUE NOT NULL,
	nombre1 VARCHAR(20) NOT NULL,
	nombre2 VARCHAR(20),
	apellido1 VARCHAR(20) NOT NULL,
	apellido2 VARCHAR(20) NOT NULL,
	diceccion VARCHAR(100) NOT NULL,
	tel_fijo VARCHAR(20) CHECK (LENGTH(tel_fijo) > 6),
	tel_movil VARCHAR(20) CHECK (LENGTH(tel_movil) > 9) NOT NULL,
	codigo ENUM("001", "002", "003", "004") DEFAULT "001",
	tipo ENUM("Gestión", "Vigilancia", "Conservación", "Investigador") DEFAULT "Gestión",
	sueldo DECIMAL(10,2) CHECK (sueldo > 0) NOT NULL,
	FOREIGN KEY (area) REFERENCES area(id)
);

CREATE TABLE visita (
	id INT PRIMARY KEY AUTO_INCREMENT,
	area INT NOT NULL,
	visitante INT NOT NULL,
	ingreso DATETIME NOT NULL,
	salida DATETIME NOT NULL,
	FOREIGN KEY (area) REFERENCES area(id),
	FOREIGN KEY (visitante) REFERENCES visitante(id)
);

CREATE TABLE gestion_visita (
	gestor INT NOT NULL,
	visita INT NOT NULL,
	operacion ENUM("Ingreso", "Salida") DEFAULT "Ingreso",
	FOREIGN KEY (gestor) REFERENCES personal(id),
	FOREIGN KEY (visita) REFERENCES visita(id),
	PRIMARY KEY (gestor, visita)
);

CREATE TABLE vehiculo (
	id INT PRIMARY KEY AUTO_INCREMENT,
	tipo VARCHAR(20) NOT NULL,
	marca VARCHAR(20) NOT NULL
);

CREATE TABLE vehiculo_vigilancia (
	vigilante INT NOT NULL,
	vehiculo INT NOT NULL,
	rol ENUM("Conductor", "Pasajero") DEFAULT "Pasajero",
	FOREIGN KEY (vigilante) REFERENCES personal(id),
	FOREIGN KEY (vehiculo) REFERENCES vehiculo(id),
	PRIMARY KEY (vigilante, vehiculo)
);

CREATE TABLE guardaparque (
	personal INT PRIMARY KEY,
	especialidad VARCHAR(30),
	FOREIGN KEY (personal) REFERENCES personal(id)
);

CREATE TABLE proyecto_investigacion (
	id INT PRIMARY KEY AUTO_INCREMENT,
	titulo VARCHAR(100) NOT NULL,
	presupuesto DECIMAL(12,2) CHECK (presupuesto > 0) NOT NULL,
	comienzo DATE NOT NULL,
	final DATE NOT NULL
);

CREATE TABLE especie_investigacion (
	especie INT NOT NULL,
	investigacion INT NOT NULL,
	especimenes INT CHECK (especimenes > 0) NOT NULL,
	FOREIGN KEY (especie) REFERENCES especie(id),
	FOREIGN KEY (investigacion) REFERENCES proyecto_investigacion(id),
	PRIMARY KEY (especie, investigacion)
);

CREATE TABLE investigador_investigacion (
	investigador INT NOT NULL,
	investigacion INT NOT NULL,
	funcion VARCHAR(30),
	FOREIGN KEY (investigador) REFERENCES personal(id),
	FOREIGN KEY (investigacion) REFERENCES proyecto_investigacion(id),
	PRIMARY KEY (investigador, investigacion)
);

-- II. CREACIÓN DE LAS TABLAS DE LOG

CREATE TABLE log_cambios_sueldo (
   id INT PRIMARY KEY AUTO_INCREMENT,
   personal_id INT,
   sueldo_anterior DECIMAL(10,2),
   sueldo_nuevo DECIMAL(10,2),
   fecha_cambio DATETIME
);

CREATE TABLE log_eventos (
   id INT PRIMARY KEY AUTO_INCREMENT,
   mensaje VARCHAR(255),
   fecha DATETIME
);

CREATE TABLE log_inventario_especies (
   id INT PRIMARY KEY AUTO_INCREMENT,
   especie_id INT,
   cantidad_anterior INT,
   cantidad_nueva INT,
   fecha_cambio DATETIME
);

CREATE TABLE log_movimientos_personal (
   id INT PRIMARY KEY AUTO_INCREMENT,
   cedula VARCHAR(20),
   nombre VARCHAR(50),
   accion VARCHAR(20),
   fecha DATETIME
);

CREATE TABLE log_cambios_alojamiento (
   id INT PRIMARY KEY AUTO_INCREMENT,
   alojamiento_id INT,
   capacidad_anterior INT,
   capacidad_nueva INT,
   fecha DATETIME
);

CREATE TABLE log_visitas_area (
   id INT PRIMARY KEY AUTO_INCREMENT,
   area_id INT,
   visitante_id INT,
   ingreso DATETIME,
   fecha_registro DATETIME
);

CREATE TABLE log_cambios_jurisdiccion (
   id INT PRIMARY KEY AUTO_INCREMENT,
   departamento INT,
   parque_natural INT,
   relacion_anterior ENUM("Principal", "Secundario"),
   relacion_nueva ENUM("Principal", "Secundario"),
   fecha DATETIME
);

-- III. CREACIÓN DE USUARIOS

-- 1. Administrador: Acceso total
DROP USER "administrador"@"localhost";
FLUSH PRIVILEGES;
CREATE USER "administrador"@"localhost" IDENTIFIED BY "AdminPass123";
GRANT ALL PRIVILEGES ON parques_naturales.* TO "administrador"@"localhost";
FLUSH PRIVILEGES;

-- 2. Gestor de parques: Gestión de parques, áreas y especies
DROP USER "gestor_parques"@"localhost";
FLUSH PRIVILEGES;
CREATE USER "gestor_parques"@"localhost" IDENTIFIED BY "GestorPass456";
GRANT SELECT, INSERT, UPDATE, DELETE ON parques_naturales.parque_natural TO "gestor_parques"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON parques_naturales.area TO "gestor_parques"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON parques_naturales.especie TO "gestor_parques"@"localhost";
GRANT SELECT ON parques_naturales.jurisdiccion TO "gestor_parques"@"localhost";
GRANT SELECT ON parques_naturales.departamento TO "gestor_parques"@"localhost";
FLUSH PRIVILEGES;

-- 3. Investigador: Acceso a datos de proyectos y especies
DROP USER "investigador"@"localhost";
FLUSH PRIVILEGES;
CREATE USER "investigador"@"localhost" IDENTIFIED BY "InvestPass789";
GRANT SELECT ON parques_naturales.proyecto_investigacion TO "investigador"@"localhost";
GRANT SELECT ON parques_naturales.especie_investigacion TO "investigador"@"localhost";
GRANT SELECT ON parques_naturales.especie TO "investigador"@"localhost";
GRANT SELECT ON parques_naturales.area TO "investigador"@"localhost";
GRANT SELECT ON parques_naturales.parque_natural TO "investigador"@"localhost";
GRANT SELECT, UPDATE ON parques_naturales.investigador_investigacion TO "investigador"@"localhost";
FLUSH PRIVILEGES;

-- 4. Auditor: Acceso a reportes financieros
DROP USER "auditor"@"localhost";
FLUSH PRIVILEGES;
CREATE USER "auditor"@"localhost" IDENTIFIED BY "AuditPass101";
GRANT SELECT ON parques_naturales.proyecto_investigacion TO "auditor"@"localhost";
GRANT SELECT ON parques_naturales.personal TO "auditor"@"localhost";
GRANT SELECT ON parques_naturales.parque_natural TO "auditor"@"localhost";
GRANT SELECT ON parques_naturales.area TO "auditor"@"localhost";
FLUSH PRIVILEGES;

-- 5. Encargado de visitantes: Gestión de visitantes y alojamientos
DROP USER "encargado_visitantes"@"localhost";
FLUSH PRIVILEGES;
CREATE USER "encargado_visitantes"@"localhost" IDENTIFIED BY "VisitPass202";
GRANT SELECT, INSERT, UPDATE, DELETE ON parques_naturales.alojamiento TO "encargado_visitantes"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON parques_naturales.visitante TO "encargado_visitantes"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON parques_naturales.visita TO "encargado_visitantes"@"localhost";
GRANT SELECT, INSERT, UPDATE ON parques_naturales.gestion_visita TO "encargado_visitantes"@"localhost";
GRANT SELECT ON parques_naturales.parque_natural TO "encargado_visitantes"@"localhost";
GRANT SELECT ON parques_naturales.area TO "encargado_visitantes"@"localhost";
FLUSH PRIVILEGES;