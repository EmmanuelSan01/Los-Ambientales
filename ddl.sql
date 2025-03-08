DROP DATABASE IF EXISTS parques_naturales;
CREATE DATABASE parques_naturales;
USE parques_naturales;

CREATE TABLE entidad (
	id INT PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR(64) NOT NULL
);

CREATE TABLE departamento (
	id INT PRIMARY KEY AUTO_INCREMENT,
	entidad INT NOT NULL,
	nombre VARCHAR(64) NOT NULL,
	capital VARCHAR(64) NOT NULL,
	superficie_km2 INT CHECK (superficie_km2 > 0) NOT NULL,
	poblacion INT CHECK (poblacion > 0) NOT NULL,
	prefijo_telefonico INT NOT NULL,
	region ENUM("Amazonía", "Andina", "Caribe", "Insular", "Orinoquía", "Pacífico") DEFAULT "Amazonía",
	FOREIGN KEY (entidad) REFERENCES entidad(id)
);

CREATE TABLE parque_natural (
	id INT PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR(64) NOT NULL,
	fecha_declaracion DATE NOT NULL,
	terrreno_km2 INT CHECK (terrreno_km2 > 0) NOT NULL
);

CREATE TABLE jurisdiccion (
	departamento INT NOT NULL,
	parque_natural INT NOT NULL,
	terreno_km2 INT CHECK (terreno_km2 > 0) NOT NULL,
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
	cedula VARCHAR(20) CHECK (cedula LIKE '%[0-9]%' AND LENGTH(cedula) > 6) NOT NULL,
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
	den_cientifica VARCHAR(64) NOT NULL,
	den_vulgar VARCHAR(64) NOT NULL,
	cantidad INT CHECK (cantidad > 0) NOT NULL,
	FOREIGN KEY (area) REFERENCES area(id)
);

CREATE TABLE personal (
	id INT PRIMARY KEY AUTO_INCREMENT,
	area INT NOT NULL,
	cedula VARCHAR(20) CHECK (cedula LIKE '%[0-9]%' AND LENGTH(cedula) > 6) NOT NULL,
	nombre1 VARCHAR(20) NOT NULL,
	nombre2 VARCHAR(20),
	apellido1 VARCHAR(20) NOT NULL,
	apellido2 VARCHAR(20) NOT NULL,
	diceccion VARCHAR(100) NOT NULL,
	tel_fijo VARCHAR(20) CHECK (tel_fijo LIKE '%[0-9]%' AND LENGTH(tel_fijo) > 6),
	tel_movil VARCHAR(20) CHECK (tel_movil LIKE '%[0-9]%' AND LENGTH(tel_movil) > 9) NOT NULL,
	codigo ENUM("001", "002", "003", "004") DEFAULT "001",
	tipo ENUM("Gestión", "Vigilancia", "Conservación", "Investigador") DEFAULT "Gestión",
	CHECK (
		(codigo = "001" AND tipo = "Gestión") OR
		(codigo = "002" AND tipo = "Vigilancia") OR
		(codigo = "003" AND tipo = "Conservación") OR
		(codigo = "004" AND tipo = "Investigador")
	), 
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
	especialidad VARCHAR(20),
	FOREIGN KEY (personal) REFERENCES personal(id)
);

CREATE TABLE proyecto_investigacion (
	id INT PRIMARY KEY AUTO_INCREMENT,
	titulo VARCHAR(64) NOT NULL,
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
	funcion VARCHAR(20),
	FOREIGN KEY (investigador) REFERENCES personal(id),
	FOREIGN KEY (investigacion) REFERENCES proyecto_investigacion(id),
	PRIMARY KEY (investigador, investigacion)
);