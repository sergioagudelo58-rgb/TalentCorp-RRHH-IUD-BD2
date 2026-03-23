-- ============================================================
-- SCRIPT 03: Creación BD Data Warehouse RRHH_DW
-- Proyecto: TalentCorp S.A.
-- Esquema estrella
-- ============================================================

DROP DATABASE IF EXISTS RRHH_DW;
CREATE DATABASE RRHH_DW
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE RRHH_DW;

-- TABLAS DE CONTROL ETL
-- Registran cada ejecución de carga para trazabilidad

-- Control de ejecuciones de carga ETL
CREATE TABLE ETL_Log (
    LogID           INT             AUTO_INCREMENT PRIMARY KEY,
    NombreProceso   VARCHAR(100)    NOT NULL,       -- Nombre del procedimiento ejecutado
    FechaInicio     DATETIME        NOT NULL,
    FechaFin        DATETIME        NULL,
    Estado          VARCHAR(20)     NOT NULL DEFAULT 'Ejecutando', -- Ejecutando / Exitoso / Error
    RegistrosProcesados INT         NULL DEFAULT 0,
    RegistrosInsertados INT         NULL DEFAULT 0,
    RegistrosActualizados INT       NULL DEFAULT 0,
    MensajeError    VARCHAR(500)    NULL,
    FechaCreacion   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para auditoría de cambios SCD Tipo 2
CREATE TABLE ETL_AuditoriaSCD (
    AuditoriaID         INT             AUTO_INCREMENT PRIMARY KEY,
    NombreDimension     VARCHAR(100)    NOT NULL,
    ClaveNegocio        INT             NOT NULL,
    TipoCambio          VARCHAR(50)     NOT NULL,   -- INSERT NUEVO / UPDATE SCD2 / CIERRE REGISTRO
    FechaDeteccion      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DescripcionCambio   VARCHAR(300)    NULL
);

-- Tabla de metadatos del DWH (configuración general)
CREATE TABLE ETL_Configuracion (
    ConfigID        INT             AUTO_INCREMENT PRIMARY KEY,
    Clave           VARCHAR(100)    NOT NULL UNIQUE,
    Valor           VARCHAR(255)    NOT NULL,
    Descripcion     VARCHAR(255)    NULL,
    FechaModificacion DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Valores iniciales de configuración
INSERT INTO ETL_Configuracion (Clave, Valor, Descripcion) VALUES
('RRHH_FUENTE',         'RRHH',         'Base de datos OLTP fuente'),
('DWH_DESTINO',         'RRHH_DW',      'Base de datos DWH destino'),
('FECHA_INICIO_TIEMPO', '2023-01-01',   'Fecha mínima para Dim_Tiempo'),
('FECHA_FIN_TIEMPO',    '2026-12-31',   'Fecha máxima para Dim_Tiempo'),
('VERSION_ETL',         '1.0',          'Versión del proceso ETL'),
('FECHA_ULTIMA_CARGA',  '1900-01-01',   'Última carga exitosa al DWH');

-- Vista general del estado del DWH
CREATE OR REPLACE VIEW v_Estado_DWH AS
SELECT
    'ETL_Log'           AS Componente,
    COUNT(*)            AS TotalRegistros,
    MAX(FechaCreacion)  AS UltimaActividad
FROM ETL_Log
UNION ALL
SELECT 'ETL_AuditoriaSCD', COUNT(*), MAX(FechaDeteccion) FROM ETL_AuditoriaSCD
UNION ALL
SELECT 'ETL_Configuracion', COUNT(*), MAX(FechaModificacion) FROM ETL_Configuracion;

SELECT 'Data Warehouse RRHH_DW creado correctamente.' AS Resultado;
SHOW TABLES;