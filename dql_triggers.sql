USE parques_naturales;

DELIMITER $$

-- 1. Registrar cambios salariales antes de actualizar sueldo en personal
CREATE TRIGGER registrar_cambio_sueldo_before
BEFORE UPDATE ON personal
FOR EACH ROW
BEGIN
   IF OLD.sueldo != NEW.sueldo THEN
       INSERT INTO log_cambios_sueldo (personal_id, sueldo_anterior, sueldo_nuevo, fecha_cambio)
       VALUES (OLD.id, OLD.sueldo, NEW.sueldo, NOW());
   END IF;
END$$

-- 2. Registrar cambios salariales después de actualizar sueldo en personal
CREATE TRIGGER registrar_cambio_sueldo_after
AFTER UPDATE ON personal
FOR EACH ROW
BEGIN
   IF OLD.sueldo != NEW.sueldo THEN
       SET @mensaje = CONCAT("Sueldo actualizado para ", OLD.nombre1, " ", OLD.apellido1, ": ", OLD.sueldo, " -> ", NEW.sueldo);
       INSERT INTO log_eventos (mensaje, fecha) VALUES (@mensaje, NOW());
   END IF;
END$$

-- 3. Actualizar inventario de especies al modificar cantidad
CREATE TRIGGER actualizar_inventario_especies
AFTER UPDATE ON especie
FOR EACH ROW
BEGIN
   IF OLD.cantidad != NEW.cantidad THEN
       INSERT INTO log_inventario_especies (especie_id, cantidad_anterior, cantidad_nueva, fecha_cambio)
       VALUES (OLD.id, OLD.cantidad, NEW.cantidad, NOW());
   END IF;
END$$

-- 4. Restringir cédula numérica en visitante (antes de insertar)
CREATE TRIGGER restringir_cedula_visitante_insert
BEFORE INSERT ON visitante
FOR EACH ROW
BEGIN
   IF NEW.cedula NOT REGEXP "^[0-9]+$" THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La cédula debe contener solo números";
   END IF;
END$$

-- 5. Restringir cédula numérica en visitante (antes de actualizar)
CREATE TRIGGER restringir_cedula_visitante_update
BEFORE UPDATE ON visitante
FOR EACH ROW
BEGIN
   IF NEW.cedula NOT REGEXP "^[0-9]+$" THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La cédula debe contener solo números";
   END IF;
END$$

-- 6. Restringir cédula numérica en personal (antes de insertar)
CREATE TRIGGER restringir_cedula_personal_insert
BEFORE INSERT ON personal
FOR EACH ROW
BEGIN
   IF NEW.cedula NOT REGEXP "^[0-9]+$" THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La cédula debe contener solo números";
   END IF;
END$$

-- 7. Restringir cédula numérica en personal (antes de actualizar)
CREATE TRIGGER restringir_cedula_personal_update
BEFORE UPDATE ON personal
FOR EACH ROW
BEGIN
   IF NEW.cedula NOT REGEXP "^[0-9]+$" THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "La cédula debe contener solo números";
   END IF;
END$$

-- 8. Restringir teléfono fijo numérico en personal (antes de insertar)
CREATE TRIGGER restringir_tel_fijo_insert
BEFORE INSERT ON personal
FOR EACH ROW
BEGIN
   IF NEW.tel_fijo IS NOT NULL AND NEW.tel_fijo NOT REGEXP "^[0-9]+$" THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El teléfono fijo debe contener solo números";
   END IF;
END$$

-- 9. Restringir teléfono fijo numérico en personal (antes de actualizar)
CREATE TRIGGER restringir_tel_fijo_update
BEFORE UPDATE ON personal
FOR EACH ROW
BEGIN
   IF NEW.tel_fijo IS NOT NULL AND NEW.tel_fijo NOT REGEXP "^[0-9]+$" THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El teléfono fijo debe contener solo números";
   END IF;
END$$

-- 10. Restringir teléfono móvil numérico en personal (antes de insertar)
CREATE TRIGGER restringir_tel_movil_insert
BEFORE INSERT ON personal
FOR EACH ROW
BEGIN
   IF NEW.tel_movil NOT REGEXP "^[0-9]+$" THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El teléfono móvil debe contener solo números";
   END IF;
END$$

-- 11.Restringir teléfono móvil numérico en personal (antes de actualizar)
CREATE TRIGGER restringir_tel_movil_update
BEFORE UPDATE ON personal
FOR EACH ROW
BEGIN
   IF NEW.tel_movil NOT REGEXP "^[0-9]+$" THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El teléfono móvil debe contener solo números";
   END IF;
END$$

-- 12. Restringir relación código-tipo en personal (antes de insertar)
CREATE TRIGGER restringir_codigo_tipo_insert
BEFORE INSERT ON personal
FOR EACH ROW
BEGIN
   IF NOT (
       (NEW.codigo = "001" AND NEW.tipo = "Gestión") OR
       (NEW.codigo = "002" AND NEW.tipo = "Vigilancia") OR
       (NEW.codigo = "003" AND NEW.tipo = "Conservación") OR
       (NEW.codigo = "004" AND NEW.tipo = "Investigador")
   ) THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El código y tipo de personal no coinciden";
   END IF;
END$$

-- 13. Restringir relación código-tipo en personal (antes de actualizar)
CREATE TRIGGER restringir_codigo_tipo_update
BEFORE UPDATE ON personal
FOR EACH ROW
BEGIN
   IF NOT (
       (NEW.codigo = "001" AND NEW.tipo = "Gestión") OR
       (NEW.codigo = "002" AND NEW.tipo = "Vigilancia") OR
       (NEW.codigo = "003" AND NEW.tipo = "Conservación") OR
       (NEW.codigo = "004" AND NEW.tipo = "Investigador")
   ) THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El código y tipo de personal no coinciden";
   END IF;
END$$

-- 14. Registrar movimientos de personal al eliminar
CREATE TRIGGER registrar_eliminacion_personal
AFTER DELETE ON personal
FOR EACH ROW
BEGIN
   INSERT INTO log_movimientos_personal (cedula, nombre, accion, fecha)
   VALUES (OLD.cedula, CONCAT(OLD.nombre1, " ", OLD.apellido1), "Eliminación", NOW());
END$$

-- 15. Registrar movimientos de personal al actualizar
CREATE TRIGGER registrar_actualizacion_personal
AFTER UPDATE ON personal
FOR EACH ROW
BEGIN
   INSERT INTO log_movimientos_personal (cedula, nombre, accion, fecha)
   VALUES (NEW.cedula, CONCAT(NEW.nombre1, " ", NEW.apellido1), "Actualización", NOW());
END$$

-- 16. Actualizar extensión total de parque al modificar área
CREATE TRIGGER actualizar_superficie_parque
AFTER UPDATE ON area
FOR EACH ROW
BEGIN
   UPDATE parque_natural
   SET superficie_ha = (
       SELECT SUM(extension_km2) * 100
       FROM area
       WHERE parque_natural = NEW.parque_natural
   )
   WHERE id = NEW.parque_natural;
END$$

-- 17. Registrar cambios en alojamiento al actualizar capacidad
CREATE TRIGGER registrar_cambio_capacidad
AFTER UPDATE ON alojamiento
FOR EACH ROW
BEGIN
   IF OLD.capacidad != NEW.capacidad THEN
       INSERT INTO log_cambios_alojamiento (alojamiento_id, capacidad_anterior, capacidad_nueva, fecha)
       VALUES (OLD.id, OLD.capacidad, NEW.capacidad, NOW());
   END IF;
END$$

-- 18. Registrar visitas al área
CREATE TRIGGER registrar_visita_area
AFTER INSERT ON visita
FOR EACH ROW
BEGIN
   INSERT INTO log_visitas_area (area_id, visitante_id, ingreso, fecha_registro)
   VALUES (NEW.area, NEW.visitante, NEW.ingreso, NOW());
END$$

-- 19. Verificar presupuesto positivo en proyectos de investigación
CREATE TRIGGER verificar_presupuesto_investigacion
BEFORE UPDATE ON proyecto_investigacion
FOR EACH ROW
BEGIN
   IF NEW.presupuesto <= 0 THEN
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El presupuesto debe ser mayor a 0";
   END IF;
END$$

-- 20. Registrar cambios en jurisdicción
CREATE TRIGGER registrar_cambio_jurisdiccion
AFTER UPDATE ON jurisdiccion
FOR EACH ROW
BEGIN
   IF OLD.relacion != NEW.relacion THEN
       INSERT INTO log_cambios_jurisdiccion (departamento, parque_natural, relacion_anterior, relacion_nueva, fecha)
       VALUES (OLD.departamento, OLD.parque_natural, OLD.relacion, NEW.relacion, NOW());
   END IF;
END$$
DELIMITER ;