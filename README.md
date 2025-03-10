# Sistema de Gestión de Parques Naturales

## Descripción del Proyecto

El objetivo del proyecto es diseñar y desarrollar una base de datos que permita gestionar de manera eficiente todas las operaciones relacionadas con los parques naturales bajo la supervisión del Ministerio del Medio Ambiente. El sistema abarca la administración de departamentos, parques, áreas, especies, personal, proyectos de investigación, visitantes y alojamientos, asegurando una solución robusta, optimizada y capaz de facilitar consultas críticas para la toma de decisiones.

## Requisitos del Sistema

Para ejecutar correctamente este sistema, se requiere:

- MySQL versión 8 o superior
- Cliente MySQL Workbench o DBeaver
- Mínimo 4GB de RAM para un rendimiento óptimo
- Al menos 500MB de espacio en disco para la base de datos inicial

## Instalación y Configuración

### 1. Configuración de la Base de Datos

1. Inicie su servidor MySQL
2. Abra su cliente MySQL (MySQL Workbench o DBeaver)
3. Conéctese a su servidor MySQL local con credenciales de administrador

### 2. Creación de la Estructura de Base de Datos

1. Ejecute el archivo `ddl.sql` para crear la base de datos y todas sus tablas:
   ```
   mysql -u root -p < ddl.sql
   ```
   O bien, abra el archivo en su cliente MySQL y ejecute todas las instrucciones.

   Este script realiza las siguientes acciones:
   - Crea la base de datos `parques_naturales`
   - Configura todas las tablas del sistema con sus relaciones
   - Crea tablas de registro (logs) para auditoría
   - Establece los usuarios del sistema con sus respectivos permisos

### 3. Carga de Datos Iniciales

1. Ejecute el archivo `dml.sql` para poblar la base de datos con información inicial:
   ```
   mysql -u root -p parques_naturales < dml.sql
   ```
   O bien, abra el archivo en su cliente MySQL y ejecute todas las instrucciones.

### 4. Ejecución de Consultas y Procedimientos

- Para ejecutar consultas predefinidas, abra los archivos correspondientes en la carpeta `/consultas`
- Para utilizar los procedimientos almacenados y funciones, consulte los ejemplos en la carpeta `/ejemplos`

### 5. Verificación de la Instalación

Para verificar que la instalación se realizó correctamente, ejecute:

```sql
USE parques_naturales;
SHOW TABLES;
SELECT COUNT(*) FROM parque_natural;
```

Debería ver la lista completa de tablas y un conteo de los parques naturales registrados.

## Estructura de la Base de Datos

El sistema está compuesto por las siguientes tablas principales:

### Entidades Geográficas
- **entidad**: Almacena información de las entidades administrativas superiores
- **departamento**: Registra los departamentos con su información geográfica y demográfica
- **parque_natural**: Contiene la información básica de cada parque natural
- **jurisdiccion**: Establece la relación entre departamentos y parques naturales

### Gestión Interna
- **area**: Subdivide los parques naturales en áreas específicas
- **especie**: Registra las especies de fauna y flora en cada área
- **personal**: Almacena información del personal que trabaja en las áreas
- **guardaparque**: Información específica para el personal de tipo guardaparque
- **vehiculo** y **vehiculo_vigilancia**: Gestiona los vehículos utilizados en tareas de vigilancia

### Visitantes
- **alojamiento**: Opciones de hospedaje disponibles en los parques
- **visitante**: Registro de personas que visitan los parques
- **visita**: Registra cada visita realizada a un área específica
- **gestion_visita**: Relaciona al personal con la gestión de visitas

### Investigación
- **proyecto_investigacion**: Proyectos científicos realizados en los parques
- **especie_investigacion**: Especies estudiadas en cada proyecto
- **investigador_investigacion**: Personal investigador asociado a cada proyecto

### Tablas de Auditoría
- Diversas tablas con prefijo **log_** para registrar cambios y eventos importantes en el sistema

El diseño sigue un modelo relacional con claves foráneas que garantizan la integridad referencial entre todas las entidades.

## Roles de Usuario y Permisos

El sistema implementa cinco roles de usuario con permisos específicos:

### 1. Administrador
- **Usuario**: `administrador@localhost`
- **Contraseña**: `AdminPass123`
- **Permisos**: Acceso total a todas las tablas y funciones del sistema
- **Descripción**: Destinado al personal técnico y administradores de la base de datos

### 2. Gestor de Parques
- **Usuario**: `gestor_parques@localhost`
- **Contraseña**: `GestorPass456`
- **Permisos**: 
  - Gestión completa (SELECT, INSERT, UPDATE, DELETE) de parques naturales, áreas y especies
  - Consulta (SELECT) de jurisdicciones y departamentos
- **Descripción**: Para el personal encargado de la administración de parques y su información biológica

### 3. Investigador
- **Usuario**: `investigador@localhost`
- **Contraseña**: `InvestPass789`
- **Permisos**: 
  - Consulta (SELECT) de proyectos, especies, áreas y parques
  - Consulta y actualización (SELECT, UPDATE) de su participación en investigaciones
- **Descripción**: Destinado al personal científico que realiza estudios en los parques

### 4. Auditor
- **Usuario**: `auditor@localhost`
- **Contraseña**: `AuditPass101`
- **Permisos**: 
  - Consulta (SELECT) de información financiera y de personal
  - Acceso a datos de proyectos, parques y áreas
- **Descripción**: Para personal de control interno y auditoría

### 5. Encargado de Visitantes
- **Usuario**: `encargado_visitantes@localhost`
- **Contraseña**: `VisitPass202`
- **Permisos**: 
  - Gestión completa (SELECT, INSERT, UPDATE, DELETE) de alojamientos, visitantes y visitas
  - Gestión parcial (SELECT, INSERT, UPDATE) de la asignación de visitas
  - Consulta (SELECT) de parques y áreas
- **Descripción**: Para el personal responsable de atención al público y gestión de visitantes

### Creación de Usuarios Adicionales

Para crear un nuevo usuario con uno de estos roles, ejecute los siguientes comandos (ajustando según sea necesario):

```sql
-- Ejemplo para crear un nuevo gestor de parques
CREATE USER 'nuevo_gestor'@'localhost' IDENTIFIED BY 'ContraseñaSegura';
GRANT SELECT, INSERT, UPDATE, DELETE ON parques_naturales.parque_natural TO 'nuevo_gestor'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON parques_naturales.area TO 'nuevo_gestor'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON parques_naturales.especie TO 'nuevo_gestor'@'localhost';
GRANT SELECT ON parques_naturales.jurisdiccion TO 'nuevo_gestor'@'localhost';
GRANT SELECT ON parques_naturales.departamento TO 'nuevo_gestor'@'localhost';
FLUSH PRIVILEGES;
```
