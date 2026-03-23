-- ============================================================
-- SCRIPT 06: ETL - Poblar Dim_Tiempo
-- Proyecto: TalentCorp S.A.
-- ============================================================

USE RRHH_DW;

DROP PROCEDURE IF EXISTS sp_Generar_Dim_Tiempo;

DELIMITER $$

CREATE PROCEDURE sp_Generar_Dim_Tiempo(
    IN p_FechaInicio DATE,
    IN p_FechaFin    DATE
)
BEGIN
    DECLARE v_LogID INT;
    DECLARE v_FechaInicio DATE;
    DECLARE v_FechaFin DATE;

    SET v_FechaInicio = p_FechaInicio;
    SET v_FechaFin = p_FechaFin;

    -- ============================================
    -- LOG INICIO
    -- ============================================
    INSERT INTO ETL_Log (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Generar_Dim_Tiempo', NOW(), 'Ejecutando');

    SET v_LogID = LAST_INSERT_ID();

    -- LIMPIAR RANGO
    DELETE FROM Dim_Tiempo
    WHERE Fecha BETWEEN v_FechaInicio AND v_FechaFin;

    INSERT INTO Dim_Tiempo (
        TiempoKey,
        Fecha,
        Anio,
        Trimestre,
        NombreTrimestre,
        Mes,
        NombreMes,
        AbreviaturaMes,
        Semana,
        DiaMes,
        DiaSemana,
        NombreDiaSemana,
        EsFinDeSemana,
        EsFestivoColombia,
        AnioMes,
        AnioTrimestre
    )
    WITH RECURSIVE fechas AS (
        SELECT v_FechaInicio AS Fecha
        UNION ALL
        SELECT DATE_ADD(Fecha, INTERVAL 1 DAY)
        FROM fechas
        WHERE Fecha < v_FechaFin
    )
    SELECT
        YEAR(Fecha) * 10000 + MONTH(Fecha) * 100 + DAY(Fecha),
        Fecha,
        YEAR(Fecha),
        QUARTER(Fecha),
        CONCAT('Q', QUARTER(Fecha)),
        MONTH(Fecha),

        CASE MONTH(Fecha)
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END,

        CASE MONTH(Fecha)
            WHEN 1 THEN 'Ene'
            WHEN 2 THEN 'Feb'
            WHEN 3 THEN 'Mar'
            WHEN 4 THEN 'Abr'
            WHEN 5 THEN 'May'
            WHEN 6 THEN 'Jun'
            WHEN 7 THEN 'Jul'
            WHEN 8 THEN 'Ago'
            WHEN 9 THEN 'Sep'
            WHEN 10 THEN 'Oct'
            WHEN 11 THEN 'Nov'
            WHEN 12 THEN 'Dic'
        END,

        WEEK(Fecha, 1),
        DAY(Fecha),

        IF(DAYOFWEEK(Fecha) = 1, 7, DAYOFWEEK(Fecha) - 1),

        CASE IF(DAYOFWEEK(Fecha) = 1, 7, DAYOFWEEK(Fecha) - 1)
            WHEN 1 THEN 'Lunes'
            WHEN 2 THEN 'Martes'
            WHEN 3 THEN 'Miércoles'
            WHEN 4 THEN 'Jueves'
            WHEN 5 THEN 'Viernes'
            WHEN 6 THEN 'Sábado'
            WHEN 7 THEN 'Domingo'
        END,

        IF(IF(DAYOFWEEK(Fecha)=1,7,DAYOFWEEK(Fecha)-1) IN (6,7), TRUE, FALSE),

        CASE
            WHEN MONTH(Fecha)=1 AND DAY(Fecha)=1 THEN TRUE     
            WHEN MONTH(Fecha)=5 AND DAY(Fecha)=1 THEN TRUE     
            WHEN MONTH(Fecha)=7 AND DAY(Fecha)=20 THEN TRUE   
            WHEN MONTH(Fecha)=12 AND DAY(Fecha)=25 THEN TRUE  
            ELSE FALSE
        END,

        YEAR(Fecha) * 100 + MONTH(Fecha),
        CONCAT(YEAR(Fecha), '-Q', QUARTER(Fecha))

    FROM fechas;

    -- LOG FIN
    UPDATE ETL_Log
    SET 
        FechaFin = NOW(),
        Estado = 'Exitoso',
        RegistrosInsertados = ROW_COUNT()
    WHERE LogID = v_LogID;

    -- RESULTADO
    SELECT CONCAT(
        'Dim_Tiempo generada desde ',
        v_FechaInicio,
        ' hasta ',
        v_FechaFin
    ) AS Resultado;

END$$

DELIMITER ;

-- ============================================
-- CONFIGURACIÓN
-- ============================================
SET SESSION cte_max_recursion_depth = 2000;

-- ============================================
-- EJECUCIÓN
-- ============================================
CALL sp_Generar_Dim_Tiempo('2023-01-01', '2026-12-31');

-- ============================================
-- VALIDACIÓN
-- ============================================
SELECT COUNT(*) AS TotalDias FROM Dim_Tiempo;

SELECT * 
FROM Dim_Tiempo 
WHERE Fecha IN ('2023-01-01','2023-07-20','2024-12-25')
ORDER BY Fecha;