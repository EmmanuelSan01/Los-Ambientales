USE parques_naturales;

-- 1. Actualizar sueldo del personal según tipo
DROP PROCEDURE IF EXISTS actualizar_sueldo_personal;
DELIMITER $$
CREATE PROCEDURE actualizar_sueldo_personal()
BEGIN
  UPDATE personal
  SET sueldo = sueldo * 1.05
  WHERE tipo = "Investigador";
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_sueldo_personal;
CREATE EVENT actualizar_sueldo_personal
ON SCHEDULE EVERY 1 MONTH
STARTS "2025-04-01 00:00:00"
DO
  CALL actualizar_sueldo_personal()
;

-- 2. Contar visitantes por parque natural
DROP PROCEDURE IF EXISTS contar_visitantes_parque;
DELIMITER $$
CREATE PROCEDURE contar_visitantes_parque()
BEGIN
  SELECT p.nombre, COUNT(v.id) AS total_visitantes
  FROM parque_natural p
  LEFT JOIN alojamiento a ON p.id = a.parque_natural
  LEFT JOIN visitante v ON a.id = v.alojamiento
  GROUP BY p.nombre;
END$$
DELIMITER ;
DROP EVENT IF EXISTS contar_visitantes_parque;
CREATE EVENT contar_visitantes_parque
ON SCHEDULE EVERY 1 WEEK
STARTS "2025-03-10 08:00:00"
DO
  CALL contar_visitantes_parque()
;

-- 3. Actualizar capacidad de alojamientos tipo "Camping"
DROP PROCEDURE IF EXISTS actualizar_capacidad_camping;
DELIMITER $$
CREATE PROCEDURE actualizar_capacidad_camping()
BEGIN
  UPDATE alojamiento
  SET capacidad = capacidad + 2
  WHERE categoria = "Camping";
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_capacidad_camping;
CREATE EVENT actualizar_capacidad_camping
ON SCHEDULE EVERY 3 MONTH
STARTS "2025-06-01 00:00:00"
DO
  CALL actualizar_capacidad_camping()
;

-- 4. Listar especies por área con más de 100 individuos
DROP PROCEDURE IF EXISTS listar_especies_abundantes;
DELIMITER $$
CREATE PROCEDURE listar_especies_abundantes()
BEGIN
  SELECT a.nombre, e.den_vulgar, e.cantidad
  FROM especie e
  JOIN area a ON e.area = a.id
  WHERE e.cantidad > 100;
END$$
DELIMITER ;
DROP EVENT IF EXISTS listar_especies_abundantes;
CREATE EVENT listar_especies_abundantes
ON SCHEDULE EVERY 2 WEEK
STARTS "2025-03-15 09:00:00"
DO
  CALL listar_especies_abundantes()
;

-- 5. Actualizar región de departamentos sin asignar
DROP PROCEDURE IF EXISTS actualizar_region_default;
DELIMITER $$
CREATE PROCEDURE actualizar_region_default()
BEGIN
  UPDATE departamento
  SET region = "Andina"
  WHERE region IS NULL;
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_region_default;
CREATE EVENT actualizar_region_default
ON SCHEDULE EVERY 1 MONTH
STARTS "2025-04-05 00:00:00"
DO
  CALL actualizar_region_default()
;

-- 6. Contar personal por tipo
DROP PROCEDURE IF EXISTS contar_personal_tipo;
DELIMITER $$
CREATE PROCEDURE contar_personal_tipo()
BEGIN
  SELECT tipo, COUNT(id) AS total
  FROM personal
  GROUP BY tipo;
END$$
DELIMITER ;
DROP EVENT IF EXISTS contar_personal_tipo;
CREATE EVENT contar_personal_tipo
ON SCHEDULE EVERY 1 WEEK
STARTS "2025-03-12 10:00:00"
DO
  CALL contar_personal_tipo()
;

-- 7. Actualizar presupuesto de proyectos de investigación
DROP PROCEDURE IF EXISTS aumentar_presupuesto_investigacion;
DELIMITER $$
CREATE PROCEDURE aumentar_presupuesto_investigacion()
BEGIN
  UPDATE proyecto_investigacion
  SET presupuesto = presupuesto * 1.10
  WHERE final > CURRENT_DATE();
END$$
DELIMITER ;
DROP EVENT IF EXISTS aumentar_presupuesto_investigacion;
CREATE EVENT aumentar_presupuesto_investigacion
ON SCHEDULE EVERY 6 MONTH
STARTS "2025-07-01 00:00:00"
DO
  CALL aumentar_presupuesto_investigacion()
;

-- 8. Listar áreas con mayor extensión
DROP PROCEDURE IF EXISTS listar_areas_grandes;
DELIMITER $$
CREATE PROCEDURE listar_areas_grandes()
BEGIN
  SELECT p.nombre, a.nombre, a.extension_km2
  FROM area a
  JOIN parque_natural p ON a.parque_natural = p.id
  WHERE a.extension_km2 > 50;
END$$
DELIMITER ;
DROP EVENT IF EXISTS listar_areas_grandes;
CREATE EVENT listar_areas_grandes
ON SCHEDULE EVERY 1 MONTH
STARTS "2025-03-20 08:00:00"
DO
  CALL listar_areas_grandes()
;

-- 9. Actualizar teléfono móvil del personal
DROP PROCEDURE IF EXISTS actualizar_telefono_personal;
DELIMITER $$
CREATE PROCEDURE actualizar_telefono_personal()
BEGIN
  UPDATE personal
  SET tel_movil = CONCAT("57", tel_movil)
  WHERE tel_movil NOT LIKE "57%";
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_telefono_personal;
CREATE EVENT actualizar_telefono_personal
ON SCHEDULE EVERY 2 MONTH
STARTS "2025-05-01 00:00:00"
DO
  CALL actualizar_telefono_personal()
;

-- 10. Contar visitas por área
DROP PROCEDURE IF EXISTS contar_visitas_area;
DELIMITER $$
CREATE PROCEDURE contar_visitas_area()
BEGIN
  SELECT a.nombre, COUNT(v.id) AS total_visitas
  FROM area a
  LEFT JOIN visita v ON a.id = v.area
  GROUP BY a.nombre;
END$$
DELIMITER ;
DROP EVENT IF EXISTS contar_visitas_area;
CREATE EVENT contar_visitas_area
ON SCHEDULE EVERY 1 WEEK
STARTS "2025-03-11 09:00:00"
DO
  CALL contar_visitas_area()
;

-- 11. Actualizar relación de jurisdicción a "Secundario"
DROP PROCEDURE IF EXISTS actualizar_jurisdiccion_secundaria;
DELIMITER $$
CREATE PROCEDURE actualizar_jurisdiccion_secundaria()
BEGIN
  UPDATE jurisdiccion
  SET relacion = "Secundario"
  WHERE relacion = "Principal" AND departamento > 5;
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_jurisdiccion_secundaria;
CREATE EVENT actualizar_jurisdiccion_secundaria
ON SCHEDULE EVERY 3 MONTH
STARTS "2025-06-15 00:00:00"
DO
  CALL actualizar_jurisdiccion_secundaria()
;

-- 12. Listar proyectos de investigación activos
DROP PROCEDURE IF EXISTS listar_proyectos_activos;
DELIMITER $$
CREATE PROCEDURE listar_proyectos_activos()
BEGIN
  SELECT titulo, presupuesto, comienzo, final
  FROM proyecto_investigacion
  WHERE final > CURRENT_DATE();
END$$
DELIMITER ;
DROP EVENT IF EXISTS listar_proyectos_activos;
CREATE EVENT listar_proyectos_activos
ON SCHEDULE EVERY 1 MONTH
STARTS "2025-03-25 08:00:00"
DO
  CALL listar_proyectos_activos()
;

-- 13. Actualizar categoría de alojamiento a "Glamping"
DROP PROCEDURE IF EXISTS actualizar_alojamiento_glamping;
DELIMITER $$
CREATE PROCEDURE actualizar_alojamiento_glamping()
BEGIN
  UPDATE alojamiento
  SET categoria = "Glamping"
  WHERE capacidad > 5 AND categoria = "Bungalow";
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_alojamiento_glamping;
CREATE EVENT actualizar_alojamiento_glamping
ON SCHEDULE EVERY 4 MONTH
STARTS "2025-08-01 00:00:00"
DO
  CALL actualizar_alojamiento_glamping()
;

-- 14. Contar especies por reino
DROP PROCEDURE IF EXISTS contar_especies_reino;
DELIMITER $$
CREATE PROCEDURE contar_especies_reino()
BEGIN
  SELECT reino, COUNT(id) AS total
  FROM especie
  GROUP BY reino;
END$$
DELIMITER ;
DROP EVENT IF EXISTS contar_especies_reino;
CREATE EVENT contar_especies_reino
ON SCHEDULE EVERY 2 WEEK
STARTS "2025-03-14 10:00:00"
DO
  CALL contar_especies_reino()
;

-- 15. Actualizar rol de vigilantes en vehículos
DROP PROCEDURE IF EXISTS actualizar_rol_vigilantes;
DELIMITER $$
CREATE PROCEDURE actualizar_rol_vigilantes()
BEGIN
  UPDATE vehiculo_vigilancia
  SET rol = "Conductor"
  WHERE rol = "Pasajero" AND vigilante % 2 = 0;
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_rol_vigilantes;
CREATE EVENT actualizar_rol_vigilantes
ON SCHEDULE EVERY 1 MONTH
STARTS "2025-04-10 00:00:00"
DO
  CALL actualizar_rol_vigilantes()
;

-- 16. Listar guardaparques por especialidad
DROP PROCEDURE IF EXISTS actualizar_codigo_vigilancia;
DELIMITER $$
CREATE PROCEDURE actualizar_codigo_vigilancia()
BEGIN
  UPDATE personal
  SET codigo = "003"
  WHERE tipo = "Vigilancia" AND codigo = "001";
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_codigo_vigilancia;
CREATE EVENT actualizar_codigo_vigilancia
ON SCHEDULE EVERY 2 MONTH
STARTS "2025-05-15 00:00:00"
DO
  CALL actualizar_codigo_vigilancia()
;

-- 17. Actualizar código del personal de vigilancia
DROP PROCEDURE IF EXISTS actualizar_codigo_vigilancia;
DELIMITER $$
CREATE PROCEDURE actualizar_codigo_vigilancia()
BEGIN
  UPDATE personal
  SET codigo = "003"
  WHERE tipo = "Vigilancia" AND codigo = "001";
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_codigo_vigilancia;
CREATE EVENT actualizar_codigo_vigilancia
ON SCHEDULE EVERY 2 MONTH
STARTS "2025-05-15 00:00:00"
DO
  CALL actualizar_codigo_vigilancia()
;

-- 18. Contar vehículos por tipo
DROP PROCEDURE IF EXISTS contar_vehiculos_tipo;
DELIMITER $$
CREATE PROCEDURE contar_vehiculos_tipo()
BEGIN
  SELECT tipo, COUNT(id) AS total
  FROM vehiculo
  GROUP BY tipo;
END$$
DELIMITER ;
DROP EVENT IF EXISTS contar_vehiculos_tipo;
CREATE EVENT contar_vehiculos_tipo
ON SCHEDULE EVERY 1 WEEK
STARTS "2025-03-16 08:00:00"
DO
  CALL contar_vehiculos_tipo()
;

-- 19. Actualizar superficie de parques naturales
DROP PROCEDURE IF EXISTS actualizar_superficie_parques;
DELIMITER $$
CREATE PROCEDURE actualizar_superficie_parques()
BEGIN
  UPDATE parque_natural
  SET superficie_ha = superficie_ha + 10
  WHERE fecha_declaracion < "2000-01-01";
END$$
DELIMITER ;
DROP EVENT IF EXISTS actualizar_superficie_parques;
CREATE EVENT actualizar_superficie_parques
ON SCHEDULE EVERY 6 MONTH
STARTS "2025-09-01 00:00:00"
DO
  CALL actualizar_superficie_parques()
;

-- 20. Listar departamentos por región
DROP PROCEDURE IF EXISTS listar_departamentos_region;
DELIMITER $$
CREATE PROCEDURE listar_departamentos_region()
BEGIN
  SELECT region, COUNT(id) AS total_departamentos
  FROM departamento
  GROUP BY region;
END$$
DELIMITER ;
DROP EVENT IF EXISTS listar_departamentos_region;
CREATE EVENT listar_departamentos_region
ON SCHEDULE EVERY 1 MONTH
STARTS "2025-03-30 08:00:00"
DO
  CALL listar_departamentos_region()
;