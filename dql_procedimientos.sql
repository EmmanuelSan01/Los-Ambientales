USE parques_naturales;

-- 1. Registrar un nuevo parque natural
DROP PROCEDURE IF EXISTS registrar_parque_natural;
DELIMITER $$
CREATE PROCEDURE registrar_parque_natural(
  IN p_nombre VARCHAR(100),
  IN p_fecha_declaracion DATE,
  IN p_superficie_ha INT
)
BEGIN
  INSERT INTO parque_natural (nombre, fecha_declaracion, superficie_ha)
  VALUES (p_nombre, p_fecha_declaracion, p_superficie_ha);
   SELECT LAST_INSERT_ID() AS id_parque_creado;
END$$
DELIMITER ;

-- 2. Actualizar información de un parque natural
DROP PROCEDURE IF EXISTS actualizar_parque_natural;
DELIMITER $$
CREATE PROCEDURE actualizar_parque_natural(
  IN p_id INT,
  IN p_nombre VARCHAR(100),
  IN p_fecha_declaracion DATE,
  IN p_superficie_ha INT
)
BEGIN
  UPDATE parque_natural
  SET nombre = p_nombre,
      fecha_declaracion = p_fecha_declaracion,
      superficie_ha = p_superficie_ha
  WHERE id = p_id;
   SELECT ROW_COUNT() AS filas_actualizadas;
END$$
DELIMITER ;

-- 3. Registrar un área dentro de un parque natural
DROP PROCEDURE IF EXISTS registrar_area;
DELIMITER $$
CREATE PROCEDURE registrar_area(
  IN p_parque_natural INT,
  IN p_nombre VARCHAR(64),
  IN p_extension_km2 INT
)
BEGIN
  DECLARE parque_existe INT;
   SELECT COUNT(*) INTO parque_existe FROM parque_natural WHERE id = p_parque_natural;
   IF parque_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El parque natural especificado no existe";
  ELSE
      INSERT INTO area (parque_natural, nombre, extension_km2)
      VALUES (p_parque_natural, p_nombre, p_extension_km2);
    
      SELECT LAST_INSERT_ID() AS id_area_creada;
  END IF;
END$$
DELIMITER ;

-- 4. Registrar una nueva especie en un área
DROP PROCEDURE IF EXISTS registrar_especie;
DELIMITER $$
CREATE PROCEDURE registrar_especie(
  IN p_area INT,
  IN p_reino ENUM("Animal", "Mineral", "Vegetal"),
  IN p_den_cientifica VARCHAR(30),
  IN p_den_vulgar VARCHAR(30),
  IN p_cantidad INT
)
BEGIN
  DECLARE area_existe INT;
   SELECT COUNT(*) INTO area_existe FROM area WHERE id = p_area;
   IF area_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El área especificada no existe";
  ELSE
      INSERT INTO especie (area, reino, den_cientifica, den_vulgar, cantidad)
      VALUES (p_area, p_reino, p_den_cientifica, p_den_vulgar, p_cantidad);
    
      SELECT LAST_INSERT_ID() AS id_especie_creada;
  END IF;
END$$
DELIMITER ;

-- 5. Actualizar la población de una especie
DROP PROCEDURE IF EXISTS actualizar_poblacion_especie;
DELIMITER $$
CREATE PROCEDURE actualizar_poblacion_especie(
  IN p_id INT,
  IN p_nueva_cantidad INT
)
BEGIN
  DECLARE especie_existe INT;
   SELECT COUNT(*) INTO especie_existe FROM especie WHERE id = p_id;
   IF especie_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La especie especificada no existe";
  ELSE
      UPDATE especie SET cantidad = p_nueva_cantidad WHERE id = p_id;
      SELECT "Población actualizada correctamente" AS mensaje;
  END IF;
END$$
DELIMITER ;

-- 6. Registrar un nuevo visitante y asignar alojamiento
DROP PROCEDURE IF EXISTS registrar_visitante;
DELIMITER $$
CREATE PROCEDURE registrar_visitante(
  IN p_alojamiento INT,
  IN p_cedula VARCHAR(20),
  IN p_nombre1 VARCHAR(20),
  IN p_nombre2 VARCHAR(20),
  IN p_apellido1 VARCHAR(20),
  IN p_apellido2 VARCHAR(20),
  IN p_direccion VARCHAR(100),
  IN p_profesion VARCHAR(64)
)
BEGIN
  DECLARE alojamiento_existe INT;
  DECLARE capacidad_actual INT;
  DECLARE ocupacion_actual INT;
   SELECT COUNT(*) INTO alojamiento_existe FROM alojamiento WHERE id = p_alojamiento;
   IF alojamiento_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El alojamiento especificado no existe";
  ELSE
      SELECT capacidad INTO capacidad_actual FROM alojamiento WHERE id = p_alojamiento;
      SELECT COUNT(*) INTO ocupacion_actual FROM visitante WHERE alojamiento = p_alojamiento;
    
      IF ocupacion_actual >= capacidad_actual THEN
          SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El alojamiento seleccionado está a capacidad máxima";
      ELSE
          INSERT INTO visitante (alojamiento, cedula, nombre1, nombre2, apellido1, apellido2, direccion, profesion)
          VALUES (p_alojamiento, p_cedula, p_nombre1, p_nombre2, p_apellido1, p_apellido2, p_direccion, p_profesion);
        
          SELECT LAST_INSERT_ID() AS id_visitante_creado;
      END IF;
  END IF;
END$$
DELIMITER ;

-- 7. Registrar visita de un visitante a un área
DROP PROCEDURE IF EXISTS registrar_visita;
DELIMITER $$
CREATE PROCEDURE registrar_visita(
  IN p_area INT,
  IN p_visitante INT,
  IN p_ingreso DATETIME,
  IN p_salida DATETIME
)
BEGIN
  DECLARE area_existe INT;
  DECLARE visitante_existe INT;
   SELECT COUNT(*) INTO area_existe FROM area WHERE id = p_area;
   SELECT COUNT(*) INTO visitante_existe FROM visitante WHERE id = p_visitante;
   IF area_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El área especificada no existe";
  ELSEIF visitante_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El visitante especificado no existe";
  ELSEIF p_ingreso >= p_salida THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La fecha de ingreso debe ser anterior a la fecha de salida";
  ELSE
      INSERT INTO visita (area, visitante, ingreso, salida)
      VALUES (p_area, p_visitante, p_ingreso, p_salida);
    
      SELECT LAST_INSERT_ID() AS id_visita_creada;
  END IF;
END$$
DELIMITER ;

-- 8. Gestionar entrada/salida de visitantes
DROP PROCEDURE IF EXISTS gestionar_visita;
DELIMITER $$
CREATE PROCEDURE gestionar_visita(
  IN p_gestor INT,
  IN p_visita INT,
  IN p_operacion ENUM("Ingreso", "Salida")
)
BEGIN
  DECLARE gestor_existe INT;
  DECLARE visita_existe INT;
  DECLARE es_gestor INT;
   SELECT COUNT(*) INTO gestor_existe FROM personal WHERE id = p_gestor;
   SELECT COUNT(*) INTO visita_existe FROM visita WHERE id = p_visita;
   SELECT COUNT(*) INTO es_gestor FROM personal WHERE id = p_gestor AND tipo = "Gestión";
   IF gestor_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El gestor especificado no existe";
  ELSEIF visita_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La visita especificada no existe";
  ELSEIF es_gestor = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El personal debe ser de tipo Gestión para registrar visitas";
  ELSE
      INSERT INTO gestion_visita (gestor, visita, operacion)
      VALUES (p_gestor, p_visita, p_operacion);
    
      SELECT "Gestión de visita registrada correctamente" AS mensaje;
  END IF;
END$$
DELIMITER ;

-- 9. Crear nuevo alojamiento en parque natural
DROP PROCEDURE IF EXISTS crear_alojamiento;
DELIMITER $$
CREATE PROCEDURE crear_alojamiento(
  IN p_parque_natural INT,
  IN p_categoria ENUM("Bungalow", "Cabaña", "Camping", "Glamping"),
  IN p_capacidad INT
)
BEGIN
  DECLARE parque_existe INT;
   SELECT COUNT(*) INTO parque_existe FROM parque_natural WHERE id = p_parque_natural;
   IF parque_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El parque natural especificado no existe";
  ELSE
      INSERT INTO alojamiento (parque_natural, categoria, capacidad)
      VALUES (p_parque_natural, p_categoria, p_capacidad);
    
      SELECT LAST_INSERT_ID() AS id_alojamiento_creado;
  END IF;
END$$
DELIMITER ;

-- 10. Asignar personal a un área
DROP PROCEDURE IF EXISTS asignar_personal;
DELIMITER $$
CREATE PROCEDURE asignar_personal(
  IN p_area INT,
  IN p_cedula VARCHAR(20),
  IN p_nombre1 VARCHAR(20),
  IN p_nombre2 VARCHAR(20),
  IN p_apellido1 VARCHAR(20),
  IN p_apellido2 VARCHAR(20),
  IN p_direccion VARCHAR(100),
  IN p_tel_fijo VARCHAR(20),
  IN p_tel_movil VARCHAR(20),
  IN p_codigo ENUM("001", "002", "003", "004"),
  IN p_tipo ENUM("Gestión", "Vigilancia", "Conservación", "Investigador"),
  IN p_sueldo DECIMAL(10,2)
)
BEGIN
  DECLARE area_existe INT;
   SELECT COUNT(*) INTO area_existe FROM area WHERE id = p_area;
   IF area_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El área especificada no existe";
  ELSE
      INSERT INTO personal (area, cedula, nombre1, nombre2, apellido1, apellido2, diceccion, tel_fijo, tel_movil, codigo, tipo, sueldo)
      VALUES (p_area, p_cedula, p_nombre1, p_nombre2, p_apellido1, p_apellido2, p_direccion, p_tel_fijo, p_tel_movil, p_codigo, p_tipo, p_sueldo);
    
      SELECT LAST_INSERT_ID() AS id_personal_creado;
  END IF;
END$$
DELIMITER ;

-- 11. Registrar guardaparque especializado
DROP PROCEDURE IF EXISTS registrar_guardaparque;
DELIMITER $$
CREATE PROCEDURE registrar_guardaparque(
  IN p_personal INT,
  IN p_especialidad VARCHAR(30)
)
BEGIN
  DECLARE personal_existe INT;
  DECLARE es_conservacion INT;
   SELECT COUNT(*) INTO personal_existe FROM personal WHERE id = p_personal;
   SELECT COUNT(*) INTO es_conservacion FROM personal WHERE id = p_personal AND tipo = "Conservación";
   IF personal_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El personal especificado no existe";
  ELSEIF es_conservacion = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El personal debe ser de tipo Conservación para ser guardaparque";
  ELSE
      INSERT INTO guardaparque (personal, especialidad)
      VALUES (p_personal, p_especialidad);
    
      SELECT "Guardaparque registrado correctamente" AS mensaje;
  END IF;
END$$
DELIMITER ;

-- 12. Crear nuevo proyecto de investigación
DROP PROCEDURE IF EXISTS crear_proyecto_investigacion;
DELIMITER $$
CREATE PROCEDURE crear_proyecto_investigacion(
  IN p_titulo VARCHAR(100),
  IN p_presupuesto DECIMAL(12,2),
  IN p_comienzo DATE,
  IN p_final DATE
)
BEGIN
  IF p_comienzo >= p_final THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La fecha de comienzo debe ser anterior a la fecha final";
  ELSE
      INSERT INTO proyecto_investigacion (titulo, presupuesto, comienzo, final)
      VALUES (p_titulo, p_presupuesto, p_comienzo, p_final);
    
      SELECT LAST_INSERT_ID() AS id_proyecto_creado;
  END IF;
END$$
DELIMITER ;

-- 13. Asignar investigador a proyecto
DROP PROCEDURE IF EXISTS asignar_investigador_proyecto;
DELIMITER $$
CREATE PROCEDURE asignar_investigador_proyecto(
  IN p_investigador INT,
  IN p_investigacion INT,
  IN p_funcion VARCHAR(30)
)
BEGIN
  DECLARE investigador_existe INT;
  DECLARE proyecto_existe INT;
  DECLARE es_investigador INT;
   SELECT COUNT(*) INTO investigador_existe FROM personal WHERE id = p_investigador;
   SELECT COUNT(*) INTO proyecto_existe FROM proyecto_investigacion WHERE id = p_investigacion;
   SELECT COUNT(*) INTO es_investigador FROM personal WHERE id = p_investigador AND tipo = "Investigador";
   IF investigador_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El investigador especificado no existe";
  ELSEIF proyecto_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El proyecto de investigación especificado no existe";
  ELSEIF es_investigador = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El personal debe ser de tipo Investigador para asignarlo a un proyecto";
  ELSE
      INSERT INTO investigador_investigacion (investigador, investigacion, funcion)
      VALUES (p_investigador, p_investigacion, p_funcion);
    
      SELECT "Investigador asignado al proyecto correctamente" AS mensaje;
  END IF;
END$$
DELIMITER ;

-- 14. Incluir especie en proyecto de investigación
DROP PROCEDURE IF EXISTS incluir_especie_investigacion;
DELIMITER $$
CREATE PROCEDURE incluir_especie_investigacion(
  IN p_especie INT,
  IN p_investigacion INT,
  IN p_especimenes INT
)
BEGIN
  DECLARE especie_existe INT;
  DECLARE proyecto_existe INT;
  DECLARE poblacion_actual INT;
   SELECT COUNT(*) INTO especie_existe FROM especie WHERE id = p_especie;
   SELECT COUNT(*) INTO proyecto_existe FROM proyecto_investigacion WHERE id = p_investigacion;
   IF especie_existe > 0 THEN
      SELECT cantidad INTO poblacion_actual FROM especie WHERE id = p_especie;
  END IF;
   IF especie_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La especie especificada no existe";
  ELSEIF proyecto_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El proyecto de investigación especificado no existe";
  ELSEIF p_especimenes > poblacion_actual THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La cantidad de especímenes excede la población actual de la especie";
  ELSE
      INSERT INTO especie_investigacion (especie, investigacion, especimenes)
      VALUES (p_especie, p_investigacion, p_especimenes);
    
      SELECT "Especie incluida en el proyecto correctamente" AS mensaje;
  END IF;
END$$
DELIMITER ;

-- 15. Asignar jurisdicción de un parque a un departamento
DROP PROCEDURE IF EXISTS asignar_jurisdiccion;
DELIMITER $$
CREATE PROCEDURE asignar_jurisdiccion(
  IN p_departamento INT,
  IN p_parque_natural INT,
  IN p_relacion ENUM("Principal", "Secundario")
)
BEGIN
  DECLARE departamento_existe INT;
  DECLARE parque_existe INT;
   SELECT COUNT(*) INTO departamento_existe FROM departamento WHERE id = p_departamento;
   SELECT COUNT(*) INTO parque_existe FROM parque_natural WHERE id = p_parque_natural;
   IF departamento_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El departamento especificado no existe";
  ELSEIF parque_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El parque natural especificado no existe";
  ELSE
      INSERT INTO jurisdiccion (departamento, parque_natural, relacion)
      VALUES (p_departamento, p_parque_natural, p_relacion);
    
      SELECT "Jurisdicción asignada correctamente" AS mensaje;
  END IF;
END$$
DELIMITER ;

-- 16. Registrar entidad y obtener listado
DROP PROCEDURE IF EXISTS registrar_entidad;
DELIMITER $$
CREATE PROCEDURE registrar_entidad(
  IN p_nombre VARCHAR(40)
)
BEGIN
  INSERT INTO entidad (nombre) VALUES (p_nombre);
   SELECT "Nueva entidad registrada:" AS mensaje;
  SELECT * FROM entidad WHERE id = LAST_INSERT_ID();
   SELECT "Listado completo de entidades:" AS mensaje;
  SELECT * FROM entidad ORDER BY nombre;
END$$
DELIMITER ;

-- 17. Asignar vehículo a vigilante
DROP PROCEDURE IF EXISTS asignar_vehiculo_vigilante;
DELIMITER $$
CREATE PROCEDURE asignar_vehiculo_vigilante(
  IN p_vigilante INT,
  IN p_vehiculo INT,
  IN p_rol ENUM("Conductor", "Pasajero")
)
BEGIN
  DECLARE vigilante_existe INT;
  DECLARE vehiculo_existe INT;
  DECLARE es_vigilancia INT;
   SELECT COUNT(*) INTO vigilante_existe FROM personal WHERE id = p_vigilante;
   SELECT COUNT(*) INTO vehiculo_existe FROM vehiculo WHERE id = p_vehiculo;
   SELECT COUNT(*) INTO es_vigilancia FROM personal WHERE id = p_vigilante AND tipo = "Vigilancia";
   IF vigilante_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El vigilante especificado no existe";
  ELSEIF vehiculo_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El vehículo especificado no existe";
  ELSEIF es_vigilancia = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El personal debe ser de tipo Vigilancia para asignarle un vehículo";
  ELSE
      INSERT INTO vehiculo_vigilancia (vigilante, vehiculo, rol)
      VALUES (p_vigilante, p_vehiculo, p_rol);
    
      SELECT "Vehículo asignado al vigilante correctamente" AS mensaje;
  END IF;
END$$
DELIMITER ;

-- 18. Obtener estadísticas de un parque natural
DROP PROCEDURE IF EXISTS estadisticas_parque;
DELIMITER $$
CREATE PROCEDURE estadisticas_parque(
  IN p_parque_natural INT
)
BEGIN
  DECLARE parque_existe INT;
   SELECT COUNT(*) INTO parque_existe FROM parque_natural WHERE id = p_parque_natural;
   IF parque_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El parque natural especificado no existe";
  ELSE
      SELECT "INFORMACIÓN GENERAL DEL PARQUE" AS seccion;
      SELECT * FROM parque_natural WHERE id = p_parque_natural;
    
      SELECT "ÁREAS DEL PARQUE" AS seccion;
      SELECT id, nombre, extension_km2 FROM area WHERE parque_natural = p_parque_natural;
    
      SELECT "TOTAL DE ESPECIES POR REINO" AS seccion;
      SELECT e.reino, COUNT(*) as total_especies, SUM(e.cantidad) as total_ejemplares
      FROM especie e
      JOIN area a ON e.area = a.id
      WHERE a.parque_natural = p_parque_natural
      GROUP BY e.reino;
    
      SELECT "PERSONAL ASIGNADO POR TIPO" AS seccion;
      SELECT p.tipo, COUNT(*) as total_personal
      FROM personal p
      JOIN area a ON p.area = a.id
      WHERE a.parque_natural = p_parque_natural
      GROUP BY p.tipo;
    
      SELECT "CAPACIDAD DE ALOJAMIENTO" AS seccion;
      SELECT categoria, COUNT(*) as num_alojamientos, SUM(capacidad) as capacidad_total
      FROM alojamiento
      WHERE parque_natural = p_parque_natural
      GROUP BY categoria;
    
      SELECT "ESTADÍSTICAS DE VISITAS (ÚLTIMO AÑO)" AS seccion;
      SELECT
          DATE_FORMAT(v.ingreso, "%Y-%m") as mes,
          COUNT(DISTINCT v.visitante) as total_visitantes,
          COUNT(*) as total_visitas
      FROM visita v
      JOIN area a ON v.area = a.id
      WHERE a.parque_natural = p_parque_natural
      AND v.ingreso >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
      GROUP BY DATE_FORMAT(v.ingreso, "%Y-%m")
      ORDER BY mes;
  END IF;
END$$
DELIMITER ;

-- 19. Actualizar presupuesto de proyecto de investigación
DROP PROCEDURE IF EXISTS actualizar_presupuesto_proyecto;
DELIMITER $$
CREATE PROCEDURE actualizar_presupuesto_proyecto(
  IN p_proyecto INT,
  IN p_nuevo_presupuesto DECIMAL(12,2)
)
BEGIN
  DECLARE proyecto_existe INT;
  DECLARE presupuesto_actual DECIMAL(12,2);
  DECLARE diferencia DECIMAL(12,2);
   SELECT COUNT(*) INTO proyecto_existe FROM proyecto_investigacion WHERE id = p_proyecto;
   IF proyecto_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El proyecto de investigación especificado no existe";
  ELSE
      SELECT presupuesto INTO presupuesto_actual FROM proyecto_investigacion WHERE id = p_proyecto;
    
      SET diferencia = p_nuevo_presupuesto - presupuesto_actual;
    
      UPDATE proyecto_investigacion
      SET presupuesto = p_nuevo_presupuesto
      WHERE id = p_proyecto;
    
      SELECT
          "Presupuesto actualizado correctamente" AS mensaje,
          presupuesto_actual AS presupuesto_anterior,
          p_nuevo_presupuesto AS nuevo_presupuesto,
          diferencia AS diferencia_presupuesto,
          CASE
              WHEN diferencia > 0 THEN "Incremento"
              WHEN diferencia < 0 THEN "Reducción"
              ELSE "Sin cambios"
          END AS tipo_cambio;
  END IF;
END$$
DELIMITER ;

-- 20. Transferir visitante entre alojamientos
DROP PROCEDURE IF EXISTS transferir_visitante;
DELIMITER $$
CREATE PROCEDURE transferir_visitante(
  IN p_visitante INT,
  IN p_nuevo_alojamiento INT
)
BEGIN
  DECLARE visitante_existe INT;
  DECLARE alojamiento_existe INT;
  DECLARE alojamiento_actual INT;
  DECLARE capacidad_actual INT;
  DECLARE ocupacion_actual INT;
   SELECT COUNT(*) INTO visitante_existe FROM visitante WHERE id = p_visitante;
   SELECT COUNT(*) INTO alojamiento_existe FROM alojamiento WHERE id = p_nuevo_alojamiento;
   IF visitante_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El visitante especificado no existe";
  ELSEIF alojamiento_existe = 0 THEN
      SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El alojamiento especificado no existe";
  ELSE
      SELECT alojamiento INTO alojamiento_actual FROM visitante WHERE id = p_visitante;
    
      SELECT capacidad INTO capacidad_actual FROM alojamiento WHERE id = p_nuevo_alojamiento;
      SELECT COUNT(*) INTO ocupacion_actual FROM visitante WHERE alojamiento = p_nuevo_alojamiento;
    
      IF alojamiento_actual = p_nuevo_alojamiento THEN
          SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El visitante ya se encuentra en este alojamiento";
      ELSEIF ocupacion_actual >= capacidad_actual THEN
          SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El nuevo alojamiento está a capacidad máxima";
      ELSE
          UPDATE visitante
          SET alojamiento = p_nuevo_alojamiento
          WHERE id = p_visitante;
        
          SELECT
              "Visitante transferido correctamente" AS mensaje,
              alojamiento_actual AS alojamiento_anterior,
              p_nuevo_alojamiento AS nuevo_alojamiento;
      END IF;
  END IF;
END$$
DELIMITER ;