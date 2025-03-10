USE parques_naturales;

-- 1. Calcular la superficie total de parques por departamento
DROP FUNCTION IF EXISTS superficie_parques_por_departamento;
DELIMITER $$
CREATE FUNCTION superficie_parques_por_departamento(id_departamento INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
  DECLARE superficie_total DECIMAL(12,2);
   SELECT SUM(pn.superficie_ha) INTO superficie_total
  FROM parque_natural pn
  JOIN jurisdiccion j ON pn.id = j.parque_natural
  WHERE j.departamento = id_departamento;
   RETURN IFNULL(superficie_total, 0);
END$$
DELIMITER ;

-- 2. Contar el número de especies por área y reino
DROP FUNCTION IF EXISTS contar_especies_por_area_reino;
DELIMITER $$
CREATE FUNCTION contar_especies_por_area_reino(id_area INT, reino_esp VARCHAR(10))
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
   SELECT COUNT(*) INTO total
  FROM especie
  WHERE area = id_area AND reino = reino_esp;
   RETURN IFNULL(total, 0);
END$$
DELIMITER ;

-- 3. Calcular la capacidad total de alojamiento en un parque
DROP FUNCTION IF EXISTS capacidad_alojamiento_parque;
DELIMITER $$
CREATE FUNCTION capacidad_alojamiento_parque(id_parque INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE capacidad_total INT;
   SELECT SUM(capacidad) INTO capacidad_total
  FROM alojamiento
  WHERE parque_natural = id_parque;
   RETURN IFNULL(capacidad_total, 0);
END$$
DELIMITER ;

-- 4. Calcular el costo total de personal por área
DROP FUNCTION IF EXISTS costo_personal_por_area;
DELIMITER $$
CREATE FUNCTION costo_personal_por_area(id_area INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
  DECLARE costo_total DECIMAL(12,2);
   SELECT SUM(sueldo) INTO costo_total
  FROM personal
  WHERE area = id_area;
   RETURN IFNULL(costo_total, 0);
END$$
DELIMITER ;

-- 5. Calcular el presupuesto total de investigaciones en una especie
DROP FUNCTION IF EXISTS presupuesto_investigaciones_especie;
DELIMITER $$
CREATE FUNCTION presupuesto_investigaciones_especie(id_especie INT)
RETURNS DECIMAL(14,2)
DETERMINISTIC
BEGIN
  DECLARE presupuesto_total DECIMAL(14,2);
   SELECT SUM(pi.presupuesto) INTO presupuesto_total
  FROM proyecto_investigacion pi
  JOIN especie_investigacion ei ON pi.id = ei.investigacion
  WHERE ei.especie = id_especie;
   RETURN IFNULL(presupuesto_total, 0);
END$$
DELIMITER ;

-- 6. Calcular el número total de visitantes por parque en un periodo
DROP FUNCTION IF EXISTS total_visitantes_parque_periodo;
DELIMITER $$
CREATE FUNCTION total_visitantes_parque_periodo(id_parque INT, fecha_inicio DATE, fecha_fin DATE)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total_visitantes INT;
   SELECT COUNT(DISTINCT v.visitante) INTO total_visitantes
  FROM visita v
  JOIN area a ON v.area = a.id
  WHERE a.parque_natural = id_parque
  AND DATE(v.ingreso) BETWEEN fecha_inicio AND fecha_fin;
   RETURN IFNULL(total_visitantes, 0);
END$$
DELIMITER ;

-- 7. Calcular el promedio de duración de visitas por área
DROP FUNCTION IF EXISTS promedio_duracion_visitas_area;
DELIMITER $$
CREATE FUNCTION promedio_duracion_visitas_area(id_area INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE duracion_promedio DECIMAL(10,2);
   SELECT AVG(TIMESTAMPDIFF(HOUR, ingreso, salida)) INTO duracion_promedio
  FROM visita
  WHERE area = id_area;
   RETURN IFNULL(duracion_promedio, 0);
END$$
DELIMITER ;

-- 8. Calcular la densidad de especies por km^2 en un área
DROP FUNCTION IF EXISTS densidad_especies_area;
DELIMITER $$
CREATE FUNCTION densidad_especies_area(id_area INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE total_especies INT;
  DECLARE extension DECIMAL(10,2);
  DECLARE densidad DECIMAL(10,2);
   SELECT COUNT(*) INTO total_especies
  FROM especie
  WHERE area = id_area;
   SELECT extension_km2 INTO extension
  FROM area
  WHERE id = id_area;
   IF extension > 0 THEN
      SET densidad = total_especies / extension;
  ELSE
      SET densidad = 0;
  END IF;
   RETURN densidad;
END$$
DELIMITER ;

-- 9. Calcular el porcentaje de ocupación de alojamientos
DROP FUNCTION IF EXISTS porcentaje_ocupacion_alojamiento;
DELIMITER $$
CREATE FUNCTION porcentaje_ocupacion_alojamiento(id_alojamiento INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
  DECLARE capacidad_max INT;
  DECLARE ocupantes INT;
  DECLARE porcentaje DECIMAL(5,2);
   SELECT capacidad INTO capacidad_max
  FROM alojamiento
  WHERE id = id_alojamiento;
   SELECT COUNT(*) INTO ocupantes
  FROM visitante
  WHERE alojamiento = id_alojamiento;
   IF capacidad_max > 0 THEN
      SET porcentaje = (ocupantes / capacidad_max) * 100;
  ELSE
      SET porcentaje = 0;
  END IF;
   RETURN porcentaje;
END$$
DELIMITER ;

-- 10. Calcular la duración total en días de un proyecto de investigación
DROP FUNCTION IF EXISTS duracion_proyecto;
DELIMITER $$
CREATE FUNCTION duracion_proyecto(id_proyecto INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE dias INT;
   SELECT DATEDIFF(final, comienzo) INTO dias
  FROM proyecto_investigacion
  WHERE id = id_proyecto;
   RETURN IFNULL(dias, 0);
END$$
DELIMITER ;

-- 11. Calcular el costo diario promedio de un proyecto de investigación
DROP FUNCTION IF EXISTS costo_diario_proyecto;
DELIMITER $$
CREATE FUNCTION costo_diario_proyecto(id_proyecto INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
  DECLARE presup DECIMAL(12,2);
  DECLARE dias INT;
  DECLARE costo_dia DECIMAL(12,2);
   SELECT presupuesto INTO presup
  FROM proyecto_investigacion
  WHERE id = id_proyecto;
   SELECT duracion_proyecto(id_proyecto) INTO dias;
   IF dias > 0 THEN
      SET costo_dia = presup / dias;
  ELSE
      SET costo_dia = 0;
  END IF;
   RETURN costo_dia;
END$$
DELIMITER ;

-- 12. Calcular el número total de áreas por parque
DROP FUNCTION IF EXISTS total_areas_parque;
DELIMITER $$
CREATE FUNCTION total_areas_parque(id_parque INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
   SELECT COUNT(*) INTO total
  FROM area
  WHERE parque_natural = id_parque;
   RETURN IFNULL(total, 0);
END$$
DELIMITER ;

-- 13. Calcular el sueldo promedio por tipo de personal
DROP FUNCTION IF EXISTS sueldo_promedio_tipo_personal;
DELIMITER $$
CREATE FUNCTION sueldo_promedio_tipo_personal(tipo_personal VARCHAR(20))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE promedio DECIMAL(10,2);
   SELECT AVG(sueldo) INTO promedio
  FROM personal
  WHERE tipo = tipo_personal;
   RETURN IFNULL(promedio, 0);
END$$
DELIMITER ;

-- 14. Calcular la antigüedad en años de un parque natural
DROP FUNCTION IF EXISTS antiguedad_parque;
DELIMITER $$
CREATE FUNCTION antiguedad_parque(id_parque INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE años INT;
   SELECT TIMESTAMPDIFF(YEAR, fecha_declaracion, CURRENT_DATE()) INTO años
  FROM parque_natural
  WHERE id = id_parque;
   RETURN IFNULL(años, 0);
END$$
DELIMITER ;

-- 15. Calcular el porcentaje que representa un parque sobre la superficie total del departamento
DROP FUNCTION IF EXISTS porcentaje_parque_en_departamento;
DELIMITER $$
CREATE FUNCTION porcentaje_parque_en_departamento(id_parque INT, id_departamento INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
  DECLARE superficie_parque DECIMAL(12,2);
  DECLARE superficie_depto DECIMAL(12,2);
  DECLARE porcentaje DECIMAL(5,2);
   SELECT superficie_ha INTO superficie_parque
  FROM parque_natural
  WHERE id = id_parque;
   SELECT superficie_km2 * 100 INTO superficie_depto
  FROM departamento
  WHERE id = id_departamento;
   IF superficie_depto > 0 THEN
      SET porcentaje = (superficie_parque / superficie_depto) * 100;
  ELSE
      SET porcentaje = 0;
  END IF;
   RETURN porcentaje;
END$$
DELIMITER ;

-- 16. Calcular el número total de especies en peligro (cantidad < 100) por parque
DROP FUNCTION IF EXISTS especies_en_peligro_parque;
DELIMITER $$
CREATE FUNCTION especies_en_peligro_parque(id_parque INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total_especies INT;
   SELECT COUNT(*) INTO total_especies
  FROM especie e
  JOIN area a ON e.area = a.id
  WHERE a.parque_natural = id_parque
  AND e.cantidad < 100;
   RETURN IFNULL(total_especies, 0);
END$$
DELIMITER ;

-- 17. Calcular el índice de biodiversidad (especies totales / extensión) de un parque
DROP FUNCTION IF EXISTS indice_biodiversidad_parque;
DELIMITER $$
CREATE FUNCTION indice_biodiversidad_parque(id_parque INT)
RETURNS DECIMAL(10,4)
DETERMINISTIC
BEGIN
  DECLARE total_especies INT;
  DECLARE extension_total DECIMAL(12,2);
  DECLARE indice DECIMAL(10,4);
   SELECT COUNT(*) INTO total_especies
  FROM especie e
  JOIN area a ON e.area = a.id
  WHERE a.parque_natural = id_parque;
   SELECT SUM(extension_km2) INTO extension_total
  FROM area
  WHERE parque_natural = id_parque;
   IF extension_total > 0 THEN
      SET indice = total_especies / extension_total;
  ELSE
      SET indice = 0;
  END IF;
   RETURN indice;
END$$
DELIMITER ;

-- 18. Calcular la carga de visitantes por km^2 en un área específica en un periodo
DROP FUNCTION IF EXISTS carga_visitantes_area_periodo;
DELIMITER $$
CREATE FUNCTION carga_visitantes_area_periodo(id_area INT, fecha_inicio DATE, fecha_fin DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE total_visitantes INT;
  DECLARE extension DECIMAL(10,2);
  DECLARE carga DECIMAL(10,2);
   SELECT COUNT(*) INTO total_visitantes
  FROM visita
  WHERE area = id_area
  AND DATE(ingreso) BETWEEN fecha_inicio AND fecha_fin;
   SELECT extension_km2 INTO extension
  FROM area
  WHERE id = id_area;
   IF extension > 0 THEN
      SET carga = total_visitantes / extension;
  ELSE
      SET carga = 0;
  END IF;
   RETURN carga;
END$$
DELIMITER ;

-- 19. Calcular la eficiencia de presupuesto por espécimen investigado
DROP FUNCTION IF EXISTS eficiencia_presupuesto_investigacion;
DELIMITER $$
CREATE FUNCTION eficiencia_presupuesto_investigacion(id_investigacion INT)
RETURNS DECIMAL(14,2)
DETERMINISTIC
BEGIN
  DECLARE presupuesto_total DECIMAL(14,2);
  DECLARE total_especimenes INT;
  DECLARE eficiencia DECIMAL(14,2);
   SELECT presupuesto INTO presupuesto_total
  FROM proyecto_investigacion
  WHERE id = id_investigacion;
   SELECT SUM(especimenes) INTO total_especimenes
  FROM especie_investigacion
  WHERE investigacion = id_investigacion;
   IF total_especimenes > 0 THEN
      SET eficiencia = presupuesto_total / total_especimenes;
  ELSE
      SET eficiencia = 0;
  END IF;
   RETURN eficiencia;
END$$
DELIMITER ;

-- 20. Calcular el índice de cobertura de vigilancia (personal de vigilancia / extensión) en un área
DROP FUNCTION IF EXISTS indice_cobertura_vigilancia_area;
DELIMITER $$
CREATE FUNCTION indice_cobertura_vigilancia_area(id_area INT)
RETURNS DECIMAL(10,4)
DETERMINISTIC
BEGIN
  DECLARE personal_vigilancia INT;
  DECLARE extension DECIMAL(10,2);
  DECLARE indice DECIMAL(10,4);
   SELECT COUNT(*) INTO personal_vigilancia
  FROM personal
  WHERE area = id_area AND tipo = "Vigilancia";
   SELECT extension_km2 INTO extension
  FROM area
  WHERE id = id_area;
   IF extension > 0 THEN
      SET indice = personal_vigilancia / extension;
  ELSE
      SET indice = 0;
  END IF;
   RETURN indice;
END$$
DELIMITER ;