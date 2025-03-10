USE parques_naturales;

-- I. ESTADO ACTUAL DE PARQUES: CANTIDAD POR DEPARTAMENTO Y SUPERFICIES DECLARADAS (20 CONSULTAS)

-- 1. Cantidad de parques por departamento
SELECT d.nombre, COUNT(j.parque_natural) AS cantidad_parques
FROM departamento d
LEFT JOIN jurisdiccion j ON d.id = j.departamento
GROUP BY d.nombre;

-- 2. Superficie total de parques por departamento
SELECT d.nombre, SUM(p.superficie_ha) AS superficie_total_ha
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
GROUP BY d.nombre;

-- 3. Departamentos con más de un parque
SELECT d.nombre, COUNT(j.parque_natural) AS cantidad_parques
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
GROUP BY d.nombre
HAVING COUNT(j.parque_natural) > 1;

-- 4. Parques con mayor superficie por departamento
SELECT d.nombre, p.nombre AS parque, p.superficie_ha
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
WHERE p.superficie_ha = (SELECT MAX(p2.superficie_ha) 
                        FROM parque_natural p2 
                        JOIN jurisdiccion j2 ON p2.id = j2.parque_natural 
                        WHERE j2.departamento = d.id);

-- 5. Superficie promedio de parques por región
SELECT d.region, AVG(p.superficie_ha) AS superficie_promedio_ha
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
GROUP BY d.region;

-- 6. Parques declarados antes del año 2000 por departamento
SELECT d.nombre, COUNT(p.id) AS parques_anteriores_2000
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
WHERE p.fecha_declaracion < "2000-01-01"
GROUP BY d.nombre;

-- 7. Departamentos sin parques
SELECT d.nombre
FROM departamento d
LEFT JOIN jurisdiccion j ON d.id = j.departamento
WHERE j.parque_natural IS NULL;

-- 8. Total de parques por región
SELECT d.region, COUNT(DISTINCT p.id) AS total_parques
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
GROUP BY d.region;

-- 9. Parques con jurisdicción secundaria por departamento
SELECT d.nombre, COUNT(j.parque_natural) AS parques_secundarios
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
WHERE j.relacion = "Secundario"
GROUP BY d.nombre;

-- 10. Parque más grande en general
SELECT p.nombre, p.superficie_ha
FROM parque_natural p
ORDER BY p.superficie_ha DESC
LIMIT 1;

-- 11. Parques por entidad
SELECT e.nombre, COUNT(DISTINCT p.id) AS parques
FROM entidad e
JOIN departamento d ON e.id = d.entidad
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
GROUP BY e.nombre;

-- 12. Departamentos con parques más grandes que el promedio
SELECT d.nombre, p.nombre, p.superficie_ha
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
WHERE p.superficie_ha > (SELECT AVG(superficie_ha) FROM parque_natural);

-- 13. Parque más antiguo por departamento
SELECT d.nombre, p.nombre, p.fecha_declaracion
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
WHERE p.fecha_declaracion = (SELECT MIN(p2.fecha_declaracion) 
                            FROM parque_natural p2 
                            JOIN jurisdiccion j2 ON p2.id = j2.parque_natural 
                            WHERE j2.departamento = d.id);

-- 14. Parques según año de declaración
SELECT YEAR(p.fecha_declaracion) AS anio, COUNT(p.id) AS cantidad
FROM parque_natural p
GROUP BY YEAR(p.fecha_declaracion);

-- 15. Departamentos con mayor densidad de parques (parques por km²)
SELECT d.nombre, COUNT(j.parque_natural) / d.superficie_km2 AS densidad_parques
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
GROUP BY d.nombre, d.superficie_km2
ORDER BY densidad_parques DESC;

-- 16. Superficie total de parques por entidad
SELECT e.nombre, SUM(p.superficie_ha) AS superficie_total
FROM entidad e
JOIN departamento d ON e.id = d.entidad
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
GROUP BY e.nombre;

-- 17. Parques en múltiples departamentos
SELECT p.nombre, COUNT(j.departamento) AS departamentos
FROM parque_natural p
JOIN jurisdiccion j ON p.id = j.parque_natural
GROUP BY p.nombre
HAVING COUNT(j.departamento) > 1;

-- 18. Departamentos con parques en la región Amazónica
SELECT d.nombre, COUNT(p.id) AS parques_amazonia
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
WHERE d.region = "Amazonía"
GROUP BY d.nombre;

-- 19. Parque más pequeño por departamento
SELECT d.nombre, p.nombre, p.superficie_ha
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
WHERE p.superficie_ha = (SELECT MIN(p2.superficie_ha) 
                        FROM parque_natural p2 
                        JOIN jurisdiccion j2 ON p2.id = j2.parque_natural 
                        WHERE j2.departamento = d.id);

-- 20. Parques sin áreas definidas
SELECT p.nombre
FROM parque_natural p
LEFT JOIN area a ON p.id = a.parque_natural
WHERE a.id IS NULL;

-- II. INVENTARIOS DE ESPECIES POR ÁREAS Y TIPOS (20 CONSULTAS)

-- 21. Total de especies por área
SELECT a.nombre, COUNT(e.id) AS total_especies
FROM area a
JOIN especie e ON a.id = e.area
GROUP BY a.nombre;

-- 22. Cantidad de especies por reino por parque
SELECT p.nombre, e.reino, COUNT(e.id) AS cantidad
FROM parque_natural p
JOIN area a ON p.id = a.parque_natural
JOIN especie e ON a.id = e.area
GROUP BY p.nombre, e.reino;

-- 23. Áreas con más de 10 especies animales
SELECT a.nombre, COUNT(e.id) AS especies_animales
FROM area a
JOIN especie e ON a.id = e.area
WHERE e.reino = "Animal"
GROUP BY a.nombre
HAVING COUNT(e.id) > 10;

-- 24. Especies más comunes por área
SELECT a.nombre, e.den_vulgar, e.cantidad
FROM area a
JOIN especie e ON a.id = e.area
WHERE e.cantidad = (SELECT MAX(e2.cantidad) 
                    FROM especie e2 
                    WHERE e2.area = a.id);

-- 25. Total de individuos de especies por parque
SELECT p.nombre, SUM(e.cantidad) AS total_individuos
FROM parque_natural p
JOIN area a ON p.id = a.parque_natural
JOIN especie e ON a.id = e.area
GROUP BY p.nombre;

-- 26. Áreas sin especies registradas
SELECT a.nombre
FROM area a
LEFT JOIN especie e ON a.id = e.area
WHERE e.id IS NULL;

-- 27. Especies con nombre científico que empieza con "A"
SELECT a.nombre, e.den_cientifica, e.den_vulgar
FROM area a
JOIN especie e ON a.id = e.area
WHERE e.den_cientifica LIKE "A%";

-- 28. Promedio de especies por área
SELECT AVG(cantidad_especies) AS promedio_especies
FROM (SELECT a.id, COUNT(e.id) AS cantidad_especies 
      FROM area a 
      JOIN especie e ON a.id = e.area 
      GROUP BY a.id) AS subquery;

-- 29. Parques con solo especies vegetales
SELECT p.nombre
FROM parque_natural p
JOIN area a ON p.id = a.parque_natural
JOIN especie e ON a.id = e.area
GROUP BY p.nombre
HAVING MAX(e.reino) = "Vegetal" AND MIN(e.reino) = "Vegetal";

-- 30. Especie con mayor población por parque
SELECT p.nombre, e.den_vulgar, e.cantidad
FROM parque_natural p
JOIN area a ON p.id = a.parque_natural
JOIN especie e ON a.id = e.area
WHERE e.cantidad = (SELECT MAX(e2.cantidad) 
                    FROM especie e2 
                    JOIN area a2 ON e2.area = a2.id 
                    WHERE a2.parque_natural = p.id);

-- 31. Áreas con especies minerales
SELECT a.nombre, COUNT(e.id) AS minerales
FROM area a
JOIN especie e ON a.id = e.area
WHERE e.reino = "Mineral"
GROUP BY a.nombre;

-- 32. Total de especies por región
SELECT d.region, COUNT(DISTINCT e.id) AS total_especies
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural p ON j.parque_natural = p.id
JOIN area a ON p.id = a.parque_natural
JOIN especie e ON a.id = e.area
GROUP BY d.region;

-- 33. Áreas con cantidad de especies por encima del promedio del parque
SELECT a.nombre, COUNT(e.id) AS especies
FROM area a
JOIN especie e ON a.id = e.area
GROUP BY a.nombre
HAVING COUNT(e.id) > (SELECT AVG(cantidad) 
                      FROM (SELECT a2.id, COUNT(e2.id) AS cantidad 
                            FROM area a2 
                            JOIN especie e2 ON a2.id = e2.area 
                            GROUP BY a2.id) AS avg_sub);

-- 34. Especies presentes en múltiples áreas
SELECT e.den_vulgar, COUNT(DISTINCT a.id) AS areas
FROM especie e
JOIN area a ON e.area = a.id
GROUP BY e.den_vulgar
HAVING COUNT(DISTINCT a.id) > 1;

-- 35. Parques sin especies animales
SELECT p.nombre
FROM parque_natural p
WHERE NOT EXISTS (SELECT 1 
                  FROM area a 
                  JOIN especie e ON a.id = e.area 
                  WHERE a.parque_natural = p.id 
                  AND e.reino = "Animal");

-- 36. Áreas con mayor extensión y cantidad de especies
SELECT a.nombre, a.extension_km2, COUNT(e.id) AS especies
FROM area a
JOIN especie e ON a.id = e.area
GROUP BY a.nombre, a.extension_km2
ORDER BY a.extension_km2 DESC
LIMIT 5;

-- 37. Densidad de especies (individuos por extensión) por área
SELECT a.nombre, SUM(e.cantidad) / a.extension_km2 AS densidad
FROM area a
JOIN especie e ON a.id = e.area
GROUP BY a.nombre, a.extension_km2;

-- 38. Parques con representación de los tres reinos
SELECT p.nombre
FROM parque_natural p
JOIN area a ON p.id = a.parque_natural
JOIN especie e ON a.id = e.area
GROUP BY p.nombre
HAVING COUNT(DISTINCT e.reino) = 3;

-- 39. Área más diversa en cantidad de especies
SELECT a.nombre, COUNT(e.id) AS diversidad_especies
FROM area a
JOIN especie e ON a.id = e.area
GROUP BY a.nombre
ORDER BY diversidad_especies DESC
LIMIT 1;

-- 40. Especies con población menor a 10
SELECT a.nombre, e.den_vulgar, e.cantidad
FROM area a
JOIN especie e ON a.id = e.area
WHERE e.cantidad < 10;

-- III. ACTIVIDADES DEL PERSONAL SEGÚN TIPO, ÁREAS ASIGNADAS Y SUELDOS (20 CONSULTAS)

-- 41. Cantidad de personal por tipo
SELECT tipo, COUNT(id) AS cantidad
FROM personal
GROUP BY tipo;

-- 42. Costo total de salarios por área
SELECT a.nombre, SUM(p.sueldo) AS costo_total
FROM area a
JOIN personal p ON a.id = p.area
GROUP BY a.nombre;

-- 43. Personal con el salario más alto por tipo
SELECT tipo, nombre1, apellido1, sueldo
FROM personal p1
WHERE sueldo = (SELECT MAX(sueldo) 
                FROM personal p2 
                WHERE p2.tipo = p1.tipo)
GROUP BY tipo, nombre1, apellido1, sueldo;

-- 44. Áreas sin personal asignado
SELECT a.nombre
FROM area a
LEFT JOIN personal p ON a.id = p.area
WHERE p.id IS NULL;

-- 45. Salario promedio por tipo de personal
SELECT tipo, AVG(sueldo) AS sueldo_promedio
FROM personal
GROUP BY tipo;

-- 46. Personal asignado a múltiples áreas (no es posible)
SELECT p.cedula, p.nombre1, p.apellido1, COUNT(DISTINCT a.id) AS areas
FROM personal p
JOIN area a ON p.area = a.id
GROUP BY p.cedula, p.nombre1, p.apellido1
HAVING COUNT(DISTINCT a.id) > 1;

-- 47. Personal de vigilancia con vehículos
SELECT p.nombre1, p.apellido1, v.tipo, v.marca
FROM personal p
JOIN vehiculo_vigilancia vv ON p.id = vv.vigilante
JOIN vehiculo v ON vv.vehiculo = v.id
WHERE p.tipo = "Vigilancia";

-- 48. Guardaparques por área
SELECT a.nombre, COUNT(g.personal) AS guardaparques
FROM area a
JOIN personal p ON a.id = p.area
JOIN guardaparque g ON p.id = g.personal
GROUP BY a.nombre;

-- 49. Personal con número de celular que empieza con "300"
SELECT nombre1, apellido1, tel_movil
FROM personal
WHERE tel_movil LIKE "300%";

-- 50. Costo total del personal por parque
SELECT pn.nombre, SUM(p.sueldo) AS costo_total
FROM parque_natural pn
JOIN area a ON pn.id = a.parque_natural
JOIN personal p ON a.id = p.area
GROUP BY pn.nombre;

-- 51. Personal con salario por encima del promedio del parque
SELECT p.nombre1, p.apellido1, p.sueldo
FROM personal p
JOIN area a ON p.area = a.id
WHERE p.sueldo > (SELECT AVG(p2.sueldo) 
                  FROM personal p2 
                  JOIN area a2 ON p2.area = a2.id 
                  WHERE a2.parque_natural = a.parque_natural);

-- 52. Áreas con solo personal de conservación
SELECT a.nombre
FROM area a
JOIN personal p ON a.id = p.area
GROUP BY a.nombre
HAVING MAX(p.tipo) = "Conservación" AND MIN(p.tipo) = "Conservación";

-- 53. Cantidad de personal por código
SELECT codigo, COUNT(id) AS cantidad
FROM personal
GROUP BY codigo;

-- 54. Guardaparque mejor pagado por área
SELECT a.nombre, p.nombre1, p.apellido1, p.sueldo
FROM area a
JOIN personal p ON a.id = p.area
JOIN guardaparque g ON p.id = g.personal
WHERE p.sueldo = (SELECT MAX(p2.sueldo) 
                  FROM personal p2 
                  JOIN guardaparque g2 ON p2.id = g2.personal 
                  WHERE p2.area = a.id);

-- 55. Personal sin teléfono fijo
SELECT nombre1, apellido1
FROM personal
WHERE tel_fijo IS NULL OR LENGTH(tel_fijo) <= 6;

-- 56. Total de personal de vigilancia por parque
SELECT pn.nombre, COUNT(p.id) AS vigilancia
FROM parque_natural pn
JOIN area a ON pn.id = a.parque_natural
JOIN personal p ON a.id = p.area
WHERE p.tipo = "Vigilancia"
GROUP BY pn.nombre;

-- 57. Áreas con personal que gana más de 5000
SELECT a.nombre, COUNT(p.id) AS personal_alto_sueldo
FROM area a
JOIN personal p ON a.id = p.area
WHERE p.sueldo > 5000
GROUP BY a.nombre;

-- 58. Personal involucrado en gestión de visitas
SELECT DISTINCT p.nombre1, p.apellido1
FROM personal p
JOIN gestion_visita gv ON p.id = gv.gestor;

-- 59. Parques sin investigadores
SELECT pn.nombre
FROM parque_natural pn
WHERE NOT EXISTS (SELECT 1 
                  FROM area a 
                  JOIN personal p ON a.id = p.area 
                  WHERE a.parque_natural = pn.id 
                  AND p.tipo = "Investigador");

-- 60. Densidad de personal (por km^2) por área
SELECT a.nombre, COUNT(p.id) / a.extension_km2 AS densidad_personal
FROM area a
JOIN personal p ON a.id = p.area
GROUP BY a.nombre, a.extension_km2;

-- IV. ESTADÍSTICAS DE PROYECTOS DE INVESTIGACIÓN: COSTOS, ESPECIES INVOLUCRADAS Y EQUIPOS (20 CONSULTAS)

-- 61. Costo total de todos los proyectos de investigación
SELECT SUM(presupuesto) AS costo_total
FROM proyecto_investigacion;

-- 62. Proyectos con presupuesto por encima del promedio
SELECT titulo, presupuesto
FROM proyecto_investigacion
WHERE presupuesto > (SELECT AVG(presupuesto) FROM proyecto_investigacion);

-- 63. Número de especies por proyecto
SELECT pi.titulo, COUNT(ei.especie) AS especies
FROM proyecto_investigacion pi
JOIN especie_investigacion ei ON pi.id = ei.investigacion
GROUP BY pi.titulo;

-- 64. Total de especímenes estudiados por proyecto
SELECT pi.titulo, SUM(ei.especimenes) AS total_especimenes
FROM proyecto_investigacion pi
JOIN especie_investigacion ei ON pi.id = ei.investigacion
GROUP BY pi.titulo;

-- 65. Proyectos que involucran especies animales
SELECT DISTINCT pi.titulo
FROM proyecto_investigacion pi
JOIN especie_investigacion ei ON pi.id = ei.investigacion
JOIN especie e ON ei.especie = e.id
WHERE e.reino = "Animal";

-- 66. Investigadores por proyecto
SELECT pi.titulo, COUNT(ii.investigador) AS investigadores
FROM proyecto_investigacion pi
JOIN investigador_investigacion ii ON pi.id = ii.investigacion
GROUP BY pi.titulo;

-- 67. Projects with highest budget
SELECT titulo, presupuesto
FROM proyecto_investigacion
ORDER BY presupuesto DESC
LIMIT 1;

-- 68. Duración promedio de los proyectos en días
SELECT AVG(DATEDIFF(final, comienzo)) AS duracion_promedio_dias
FROM proyecto_investigacion;

-- 69. Proyectos con más de 1 especies
SELECT pi.titulo, COUNT(ei.especie) AS especies
FROM proyecto_investigacion pi
JOIN especie_investigacion ei ON pi.id = ei.investigacion
GROUP BY pi.titulo
HAVING COUNT(ei.especie) > 0;

-- 70. Presupuesto total por año de inicio
SELECT YEAR(comienzo) AS anio, SUM(presupuesto) AS presupuesto_total
FROM proyecto_investigacion
GROUP BY YEAR(comienzo);

-- 71. Proyectos sin investigadores asignados
SELECT pi.titulo
FROM proyecto_investigacion pi
LEFT JOIN investigador_investigacion ii ON pi.id = ii.investigacion
WHERE ii.investigador IS NULL;

-- 72. Especie más estudiada en los proyectos
SELECT e.den_vulgar, COUNT(ei.investigacion) AS proyectos
FROM especie e
JOIN especie_investigacion ei ON e.id = ei.especie
GROUP BY e.den_vulgar
ORDER BY proyectos DESC
LIMIT 1;

-- 73. Proyectos que finalizan en 2025
SELECT titulo, final
FROM proyecto_investigacion
WHERE YEAR(final) = 2025;

-- 74. Investigadores con múltiples proyectos
SELECT p.nombre1, p.apellido1, COUNT(ii.investigacion) AS proyectos
FROM personal p
JOIN investigador_investigacion ii ON p.id = ii.investigador
GROUP BY p.nombre1, p.apellido1
HAVING COUNT(ii.investigacion) > 1;

-- 75. Costo total de proyectos por parque
SELECT pn.nombre, SUM(pi.presupuesto) AS costo_total
FROM parque_natural pn
JOIN area a ON pn.id = a.parque_natural
JOIN especie e ON a.id = e.area
JOIN especie_investigacion ei ON e.id = ei.especie
JOIN proyecto_investigacion pi ON ei.investigacion = pi.id
GROUP BY pn.nombre;

-- 76. Proyectos con presupuesto por espécimen por encima del promedio
WITH CostoPorProyecto AS (
    SELECT pi.id, pi.titulo, pi.presupuesto, SUM(ei.especimenes) AS total_especimenes,
           pi.presupuesto / SUM(ei.especimenes) AS costo_por_especimen
    FROM proyecto_investigacion pi
    JOIN especie_investigacion ei ON pi.id = ei.investigacion
    GROUP BY pi.id, pi.titulo, pi.presupuesto
),
PromedioCosto AS (
    SELECT AVG(costo_por_especimen) AS promedio_global
    FROM CostoPorProyecto
)
SELECT cpp.titulo, cpp.costo_por_especimen
FROM CostoPorProyecto cpp, PromedioCosto pc
WHERE cpp.costo_por_especimen > pc.promedio_global;

-- 77. Proyectos con solo especies vegetales
SELECT pi.titulo
FROM proyecto_investigacion pi
JOIN especie_investigacion ei ON pi.id = ei.investigacion
JOIN especie e ON ei.especie = e.id
GROUP BY pi.titulo
HAVING MAX(e.reino) = "Vegetal" AND MIN(e.reino) = "Vegetal";

-- 78. Promedio de investigadores por proyecto
SELECT AVG(investigadores) AS promedio_investigadores
FROM (SELECT pi.id, COUNT(ii.investigador) AS investigadores 
      FROM proyecto_investigacion pi 
      JOIN investigador_investigacion ii ON pi.id = ii.investigacion 
      GROUP BY pi.id) AS subquery;

-- 79. Proyectos con mayor cantidad de especímenes
SELECT pi.titulo, SUM(ei.especimenes) AS especimenes
FROM proyecto_investigacion pi
JOIN especie_investigacion ei ON pi.id = ei.investigacion
GROUP BY pi.titulo
ORDER BY especimenes DESC
LIMIT 1;

-- 80. Parques sin proyectos de investigación
SELECT pn.nombre
FROM parque_natural pn
WHERE NOT EXISTS (SELECT 1 
                  FROM area a 
                  JOIN especie e ON a.id = e.area 
                  JOIN especie_investigacion ei ON e.id = ei.especie 
                  WHERE a.parque_natural = pn.id);

-- V. GESTIÓN DE VISITANTES Y OCUPACIÓN DE ALOJAMIENTOS (20 CONSULTAS)

-- 81. Total de visitantes por parque
SELECT pn.nombre, COUNT(DISTINCT v.id) AS visitantes
FROM parque_natural pn
JOIN alojamiento al ON pn.id = al.parque_natural
JOIN visitante v ON al.id = v.alojamiento
GROUP BY pn.nombre;

-- 82. Tasa de ocupación por tipo de alojamiento
SELECT categoria, SUM(capacidad) AS capacidad_total, COUNT(v.id) AS visitantes_actuales
FROM alojamiento al
LEFT JOIN visitante v ON al.id = v.alojamiento
GROUP BY categoria;

-- 83. Áreas más visitadas
SELECT a.nombre, COUNT(vs.id) AS visitas
FROM area a
JOIN visita vs ON a.id = vs.area
GROUP BY a.nombre
ORDER BY visitas DESC
LIMIT 5;

-- 84. Visitantes actualmente en los parques
SELECT pn.nombre, COUNT(v.id) AS visitantes_actuales
FROM parque_natural pn
JOIN alojamiento al ON pn.id = al.parque_natural
JOIN visitante v ON al.id = v.alojamiento
JOIN visita vs ON v.id = vs.visitante
WHERE vs.salida > NOW()
GROUP BY pn.nombre;

-- 85. Duración promedio de visitas por área
SELECT a.nombre, AVG(TIMESTAMPDIFF(HOUR, vs.ingreso, vs.salida)) AS duracion_promedio_horas
FROM area a
JOIN visita vs ON a.id = vs.area
GROUP BY a.nombre;

-- 86. Alojamientos con capacidad completa
SELECT al.id, al.categoria, al.capacidad
FROM alojamiento al
JOIN visitante v ON al.id = v.alojamiento
GROUP BY al.id, al.categoria, al.capacidad
HAVING COUNT(v.id) = al.capacidad;

-- 87. Visitantes por profesión
SELECT v.profesion, COUNT(v.id) AS cantidad
FROM visitante v
GROUP BY v.profesion;

-- 88. Parques sin visitantes
SELECT pn.nombre
FROM parque_natural pn
LEFT JOIN alojamiento al ON pn.id = al.parque_natural
LEFT JOIN visitante v ON al.id = v.alojamiento
WHERE v.id IS NULL;

-- 89. Tipo de alojamiento más utilizado
SELECT al.categoria, COUNT(v.id) AS visitantes
FROM alojamiento al
JOIN visitante v ON al.id = v.alojamiento
GROUP BY al.categoria
ORDER BY visitantes DESC
LIMIT 1;

-- 90. Visitantes con estadía más larga
SELECT v.nombre1, v.apellido1, MAX(TIMESTAMPDIFF(DAY, vs.ingreso, vs.salida)) AS dias_estancia
FROM visitante v
JOIN visita vs ON v.id = vs.visitante
GROUP BY v.nombre1, v.apellido1
ORDER BY dias_estancia DESC
LIMIT 1;

-- 91. Áreas sin visitas registradas
SELECT a.nombre
FROM area a
LEFT JOIN visita vs ON a.id = vs.area
WHERE vs.id IS NULL;

-- 92. Total de visitas gestionadas por cada gestor
SELECT p.nombre1, p.apellido1, COUNT(gv.visita) AS visitas_gestionadas
FROM personal p
JOIN gestion_visita gv ON p.id = gv.gestor
GROUP BY p.nombre1, p.apellido1;

-- 93. Alojamientos sin visitantes
SELECT al.id, al.categoria
FROM alojamiento al
LEFT JOIN visitante v ON al.id = v.alojamiento
WHERE v.id IS NULL;

-- 94. Visitantes que ingresaron después del 14/03/2025
SELECT v.nombre1, v.apellido1, vs.ingreso
FROM visitante v
JOIN visita vs ON v.id = vs.visitante
WHERE vs.ingreso > "2025-03-14";

-- 95. Parques con mayor densidad de visitantes (visitantes por ha)
SELECT pn.nombre, COUNT(v.id) / pn.superficie_ha AS densidad_visitantes
FROM parque_natural pn
JOIN alojamiento al ON pn.id = al.parque_natural
JOIN visitante v ON al.id = v.alojamiento
GROUP BY pn.nombre, pn.superficie_ha
ORDER BY densidad_visitantes DESC;

-- 96. Visitas gestionadas como "Ingreso" vs "Salida"
SELECT gv.operacion, COUNT(gv.visita) AS cantidad
FROM gestion_visita gv
GROUP BY gv.operacion;

-- 97. Visitantes con múltiples visitas
SELECT v.nombre1, v.apellido1, COUNT(vs.id) AS visitas
FROM visitante v
JOIN visita vs ON v.id = vs.visitante
GROUP BY v.nombre1, v.apellido1
HAVING COUNT(vs.id) > 1
ORDER BY visitas DESC;

-- 98. Alojamientos con capacidad por encima del promedio del parque
SELECT al.id, al.categoria, al.capacidad
FROM alojamiento al
WHERE al.capacidad > (SELECT AVG(capacidad) 
                      FROM alojamiento al2 
                      WHERE al2.parque_natural = al.parque_natural);

-- 99. Total de visitantes por región
SELECT d.region, COUNT(DISTINCT v.id) AS visitantes
FROM departamento d
JOIN jurisdiccion j ON d.id = j.departamento
JOIN parque_natural pn ON j.parque_natural = pn.id
JOIN alojamiento al ON pn.id = al.parque_natural
JOIN visitante v ON al.id = v.alojamiento
GROUP BY d.region;

-- 100. Áreas con visitas más largas que el promedio
SELECT a.nombre, AVG(TIMESTAMPDIFF(HOUR, vs.ingreso, vs.salida)) AS duracion_promedio
FROM area a
JOIN visita vs ON a.id = vs.area
GROUP BY a.nombre
HAVING AVG(TIMESTAMPDIFF(HOUR, vs.ingreso, vs.salida)) > (SELECT AVG(TIMESTAMPDIFF(HOUR, ingreso, salida)) 
                                                          FROM visita);