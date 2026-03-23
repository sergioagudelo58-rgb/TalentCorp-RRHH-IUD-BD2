-- ============================================================
-- SCRIPT 08: ETL - Carga Tablas de Hechos
-- Proyecto: TalentCorp S.A.
-- Hechos: Ausencias, Evaluaciones, Capacitaciones, Nómina
-- ============================================================

USE RRHH_DW;

-- SP 1: Cargar Fact_Ausencias

DROP PROCEDURE IF EXISTS sp_Cargar_Fact_Ausencias;
DELIMITER $$

CREATE PROCEDURE sp_Cargar_Fact_Ausencias()
BEGIN
    DECLARE v_LogID INT;
    DECLARE v_Ins   INT DEFAULT 0;

    INSERT INTO ETL_Log (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Cargar_Fact_Ausencias', NOW(), 'Ejecutando');
    SET v_LogID = LAST_INSERT_ID();

    -- Limpiar hechos previos (recarga completa)
    TRUNCATE TABLE Fact_Ausencias;

    INSERT INTO Fact_Ausencias (
        TiempoInicioKey,
        TiempoFinKey,
        EmpleadoKey,
        DepartamentoKey,
        OficinaKey,
        AusenciaID,
        TipoAusencia,
        Justificada,
        DiasTotales,
        CostoAproximado
    )
    SELECT
        -- TiempoKey = YYYYMMDD
        YEAR(a.FechaInicio)*10000 + MONTH(a.FechaInicio)*100 + DAY(a.FechaInicio) AS TiempoInicioKey,
        YEAR(a.FechaFin)*10000    + MONTH(a.FechaFin)*100    + DAY(a.FechaFin)    AS TiempoFinKey,
        -- Buscar la clave subrogada del empleado activo
        (SELECT de.EmpleadoKey
         FROM Dim_Empleado de
         WHERE de.EmpleadoID = a.EmpleadoID
           AND de.EsActual = TRUE
         LIMIT 1) AS EmpleadoKey,
        -- Departamento del empleado en ese momento
        (SELECT dd.DepartamentoKey
         FROM Dim_Departamento dd
         INNER JOIN RRHH.Empleados e ON e.DepartamentoID = dd.DepartamentoID
         WHERE e.Id = a.EmpleadoID AND dd.EsActual = TRUE
         LIMIT 1) AS DepartamentoKey,
        -- Oficina del empleado
        (SELECT dof.OficinaKey
         FROM Dim_Oficina dof
         INNER JOIN RRHH.Empleados e ON e.OficinaID = dof.OficinaID
         WHERE e.Id = a.EmpleadoID AND dof.EsActual = TRUE
         LIMIT 1) AS OficinaKey,
        a.Id                                                        AS AusenciaID,
        a.TipoAusencia,
        a.Justificada,
        a.DiasTotales,
        -- Costo aproximado: salario diario * días ausente
        ROUND((e.Salario / 30.0) * a.DiasTotales, 2)               AS CostoAproximado
    FROM RRHH.Ausencias a
    INNER JOIN RRHH.Empleados e ON a.EmpleadoID = e.Id
    -- Solo se cargan ausencias cuyas fechas existen en Dim_Tiempo
    WHERE EXISTS (
        SELECT 1 FROM Dim_Tiempo dt WHERE dt.TiempoKey =
            YEAR(a.FechaInicio)*10000 + MONTH(a.FechaInicio)*100 + DAY(a.FechaInicio)
    );

    SET v_Ins = ROW_COUNT();

    UPDATE ETL_Log
    SET FechaFin = NOW(), Estado = 'Exitoso', RegistrosInsertados = v_Ins
    WHERE LogID = v_LogID;

    SELECT CONCAT('Fact_Ausencias cargada: ', v_Ins, ' registros.') AS Resultado;
END$$
DELIMITER ;

-- SP 2: Cargar Fact_Evaluaciones

DROP PROCEDURE IF EXISTS sp_Cargar_Fact_Evaluaciones;
DELIMITER $$

CREATE PROCEDURE sp_Cargar_Fact_Evaluaciones()
BEGIN
    DECLARE v_LogID INT;
    DECLARE v_Ins   INT DEFAULT 0;

    INSERT INTO ETL_Log (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Cargar_Fact_Evaluaciones', NOW(), 'Ejecutando');
    SET v_LogID = LAST_INSERT_ID();

    TRUNCATE TABLE Fact_Evaluaciones;

    INSERT INTO Fact_Evaluaciones (
        TiempoKey,
        EmpleadoKey,
        EvaluadorKey,
        DepartamentoKey,
        PuestoKey,
        EvaluacionID,
        PeriodoEvaluacion,
        Calificacion,
        CalificacionNorm,
        EsAprobado
    )
    SELECT
        YEAR(ev.FechaEvaluacion)*10000 + MONTH(ev.FechaEvaluacion)*100 + DAY(ev.FechaEvaluacion),
        -- Empleado evaluado - registro activo
        (SELECT de.EmpleadoKey FROM Dim_Empleado de
         WHERE de.EmpleadoID = ev.EmpleadoID
           AND de.EsActual = TRUE
         LIMIT 1),
        -- Evaluador
        (SELECT de2.EmpleadoKey FROM Dim_Empleado de2
         WHERE de2.EmpleadoID = ev.EvaluadorID AND de2.EsActual = TRUE
         LIMIT 1),
        -- Departamento del evaluado
        (SELECT dd.DepartamentoKey FROM Dim_Departamento dd
         INNER JOIN RRHH.Empleados e ON e.DepartamentoID = dd.DepartamentoID
         WHERE e.Id = ev.EmpleadoID AND dd.EsActual = TRUE
         LIMIT 1),
        -- Puesto del evaluado
        (SELECT dp.PuestoKey FROM Dim_Puesto dp
         INNER JOIN RRHH.Empleados e ON e.PuestoID = dp.PuestoID
         WHERE e.Id = ev.EmpleadoID AND dp.EsActual = TRUE
         LIMIT 1),
        ev.EvaluacionID,
        -- Período: 'AAAA-S1' si mes <= 6, 'AAAA-S2' si mes > 6
        CONCAT(YEAR(ev.FechaEvaluacion), IF(MONTH(ev.FechaEvaluacion) <= 6, '-S1', '-S2')),
        ev.Calificacion,
        -- Normalizar 1-5 a 0-100
        ROUND((ev.Calificacion - 1.0) / 4.0 * 100, 2),
        IF(ev.Calificacion >= 3.0, TRUE, FALSE)
    FROM RRHH.Evaluaciones ev;

    SET v_Ins = ROW_COUNT();

    UPDATE ETL_Log
    SET FechaFin = NOW(), Estado = 'Exitoso', RegistrosInsertados = v_Ins
    WHERE LogID = v_LogID;

    SELECT CONCAT('Fact_Evaluaciones cargada: ', v_Ins, ' registros.') AS Resultado;
END$$
DELIMITER ;

-- SP 3: Cargar Fact_Capacitaciones

DROP PROCEDURE IF EXISTS sp_Cargar_Fact_Capacitaciones;
DELIMITER $$

CREATE PROCEDURE sp_Cargar_Fact_Capacitaciones()
BEGIN
    DECLARE v_LogID INT;
    DECLARE v_Ins   INT DEFAULT 0;

    INSERT INTO ETL_Log (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Cargar_Fact_Capacitaciones', NOW(), 'Ejecutando');
    SET v_LogID = LAST_INSERT_ID();

    TRUNCATE TABLE Fact_Capacitaciones;

    INSERT INTO Fact_Capacitaciones (
        TiempoInscripKey,
        TiempoFinalKey,
        EmpleadoKey,
        DepartamentoKey,
        CapacitacionID,
        NombreCapacitacion,
        Proveedor,
        Estado,
        CostoCapacitacion,
        CalificacionObtenida,
        DuracionDias,
        EsAprobado
    )
    SELECT
        YEAR(ec.FechaInscripcion)*10000 + MONTH(ec.FechaInscripcion)*100 + DAY(ec.FechaInscripcion),
        -- TiempoFinalKey puede ser NULL si no finalizó
        CASE WHEN ec.FechaFinalizacion IS NOT NULL
             THEN YEAR(ec.FechaFinalizacion)*10000 + MONTH(ec.FechaFinalizacion)*100 + DAY(ec.FechaFinalizacion)
             ELSE NULL
        END,
        -- EmpleadoKey vigente
        (SELECT de.EmpleadoKey FROM Dim_Empleado de
         WHERE de.EmpleadoID = ec.EmpleadoID AND de.EsActual = TRUE
         LIMIT 1),
        -- DepartamentoKey del empleado
        (SELECT dd.DepartamentoKey FROM Dim_Departamento dd
         INNER JOIN RRHH.Empleados e ON e.DepartamentoID = dd.DepartamentoID
         WHERE e.Id = ec.EmpleadoID AND dd.EsActual = TRUE
         LIMIT 1),
        c.CapacitacionID,
        c.NombreCapacitacion,
        c.Proveedor,
        ec.Estado,
        c.Costo,
        ec.Calificacion,
        DATEDIFF(c.FechaFin, c.FechaInicio) + 1,
        -- Aprobado si calificación >= 70
        CASE WHEN ec.Calificacion IS NOT NULL AND ec.Calificacion >= 70 THEN TRUE
             WHEN ec.Calificacion IS NOT NULL THEN FALSE
             ELSE NULL
        END
    FROM RRHH.EmpleadoCapacitacion ec
    INNER JOIN RRHH.Capacitaciones c ON ec.CapacitacionID = c.CapacitacionID;

    SET v_Ins = ROW_COUNT();

    UPDATE ETL_Log
    SET FechaFin = NOW(), Estado = 'Exitoso', RegistrosInsertados = v_Ins
    WHERE LogID = v_LogID;

    SELECT CONCAT('Fact_Capacitaciones cargada: ', v_Ins, ' registros.') AS Resultado;
END$$
DELIMITER ;

-- SP 4: Cargar Fact_Nomina, Genera un registro por empleado para cada mes entre su
-- fecha de contratación y el mes actual

DROP PROCEDURE IF EXISTS sp_Cargar_Fact_Nomina;
DELIMITER $$

CREATE PROCEDURE sp_Cargar_Fact_Nomina()
BEGIN
    DECLARE v_LogID INT;
    DECLARE v_Ins   INT DEFAULT 0;

    INSERT INTO ETL_Log (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Cargar_Fact_Nomina', NOW(), 'Ejecutando');
    SET v_LogID = LAST_INSERT_ID();

    TRUNCATE TABLE Fact_Nomina;

    -- Tabla temporal de meses (2023-01 a 2024-12)
    DROP TEMPORARY TABLE IF EXISTS tmp_Meses;
    CREATE TEMPORARY TABLE tmp_Meses AS
    SELECT dt.Fecha, dt.TiempoKey, dt.AnioMes
    FROM Dim_Tiempo dt
    WHERE dt.DiaMes = 1            
      AND dt.Anio BETWEEN 2023 AND 2024;

    INSERT INTO Fact_Nomina (
        TiempoKey,
        EmpleadoKey,
        DepartamentoKey,
        PuestoKey,
        OficinaKey,
        AnioMes,
        Salario,
        SalarioMinPuesto,
        SalarioMaxPuesto,
        PorcentajeEnRango,
        DesviacionDelPromedio,
        EsActivo
    )
    SELECT
        m.TiempoKey,
        -- EmpleadoKey activo
        (SELECT de.EmpleadoKey FROM Dim_Empleado de
         WHERE de.EmpleadoID = e.Id
           AND de.EsActual = TRUE
         LIMIT 1),
        -- DepartamentoKey
        (SELECT dd.DepartamentoKey FROM Dim_Departamento dd
         WHERE dd.DepartamentoID = e.DepartamentoID AND dd.EsActual = TRUE LIMIT 1),
        -- PuestoKey
        (SELECT dp.PuestoKey FROM Dim_Puesto dp
         WHERE dp.PuestoID = e.PuestoID AND dp.EsActual = TRUE LIMIT 1),
        -- OficinaKey
        (SELECT dof.OficinaKey FROM Dim_Oficina dof
         WHERE dof.OficinaID = e.OficinaID AND dof.EsActual = TRUE LIMIT 1),
        m.AnioMes,
        e.Salario,
        p.SalarioMinimo,
        p.SalarioMaximo,
        -- Posición en rango salarial (0%=mínimo, 100%=máximo)
        ROUND(
            CASE WHEN p.SalarioMaximo > p.SalarioMinimo
                 THEN (e.Salario - p.SalarioMinimo) / (p.SalarioMaximo - p.SalarioMinimo) * 100
                 ELSE 50.0
            END, 2),
        -- Desviación vs promedio del mismo puesto
        e.Salario - (
            SELECT AVG(e2.Salario) FROM RRHH.Empleados e2
            WHERE e2.PuestoID = e.PuestoID
        ),
        TRUE
    FROM RRHH.Empleados e
    INNER JOIN RRHH.Puestos p ON e.PuestoID = p.Id
    CROSS JOIN tmp_Meses m
    -- Solo incluir meses donde el empleado ya trabajaba
    WHERE m.Fecha >= DATE_FORMAT(e.FechaContratacion, '%Y-%m-01');

    SET v_Ins = ROW_COUNT();

    DROP TEMPORARY TABLE IF EXISTS tmp_Meses;

    UPDATE ETL_Log
    SET FechaFin = NOW(), Estado = 'Exitoso', RegistrosInsertados = v_Ins
    WHERE LogID = v_LogID;

    SELECT CONCAT('Fact_Nomina cargada: ', v_Ins, ' registros.') AS Resultado;
END$$
DELIMITER ;

-- PROCEDIMIENTO MAESTRO: Carga todos los hechos en orden

DROP PROCEDURE IF EXISTS sp_Cargar_Todos_Hechos;
DELIMITER $$
CREATE PROCEDURE sp_Cargar_Todos_Hechos()
BEGIN
    CALL sp_Cargar_Fact_Ausencias();
    CALL sp_Cargar_Fact_Evaluaciones();
    CALL sp_Cargar_Fact_Capacitaciones();
    CALL sp_Cargar_Fact_Nomina();
    SELECT 'Todas las tablas de hechos cargadas.' AS Resultado;
END$$
DELIMITER ;

-- EJECUTAR CARGA

CALL sp_Cargar_Todos_Hechos();

-- Verificación
SELECT 'Fact_Ausencias' AS Hecho, COUNT(*) AS Filas FROM Fact_Ausencias
UNION ALL
SELECT 'Fact_Evaluaciones', COUNT(*) FROM Fact_Evaluaciones
UNION ALL
SELECT 'Fact_Capacitaciones', COUNT(*) FROM Fact_Capacitaciones
UNION ALL
SELECT 'Fact_Nomina', COUNT(*) FROM Fact_Nomina;