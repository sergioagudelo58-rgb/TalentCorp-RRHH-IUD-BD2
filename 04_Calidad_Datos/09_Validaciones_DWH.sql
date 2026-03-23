-- ============================================================
-- SCRIPT 09: Validaciones de Calidad del DWH
-- Proyecto: TalentCorp S.A.
-- 12 validaciones cubren: integridad, completitud, consistencia
-- ============================================================

USE RRHH_DW;

-- VALIDACIÓN 1: Conteo de registros OLTP vs DWH
-- Verifica que no se perdieron registros en el proceso ETL

SELECT 'VALIDACIÓN 1 - Conteo OLTP vs DWH' AS Validacion;

SELECT
    'Empleados OLTP'    AS Fuente, COUNT(*) AS Total FROM RRHH.Empleados
UNION ALL SELECT 'Empleados DWH (activos)', COUNT(*) FROM Dim_Empleado WHERE EsActual = TRUE
UNION ALL SELECT 'Ausencias OLTP', COUNT(*) FROM RRHH.Ausencias
UNION ALL SELECT 'Ausencias DWH', COUNT(*) FROM Fact_Ausencias
UNION ALL SELECT 'Evaluaciones OLTP', COUNT(*) FROM RRHH.Evaluaciones
UNION ALL SELECT 'Evaluaciones DWH', COUNT(*) FROM Fact_Evaluaciones
UNION ALL SELECT 'Capacitaciones OLTP', COUNT(*) FROM RRHH.EmpleadoCapacitacion
UNION ALL SELECT 'Capacitaciones DWH', COUNT(*) FROM Fact_Capacitaciones;

-- VALIDACIÓN 2: Empleados sin clave subrogada en Hechos
-- Detecta referencias huérfanas (EmpleadoKey = NULL)

SELECT 'VALIDACIÓN 2 - Registros huérfanos en Hechos (EmpleadoKey NULL)' AS Validacion;

SELECT 'Fact_Ausencias'      AS Hecho,
       SUM(CASE WHEN EmpleadoKey IS NULL THEN 1 ELSE 0 END) AS RegistrosSinEmpleado
FROM Fact_Ausencias
UNION ALL
SELECT 'Fact_Evaluaciones',
       SUM(CASE WHEN EmpleadoKey IS NULL THEN 1 ELSE 0 END)
FROM Fact_Evaluaciones
UNION ALL
SELECT 'Fact_Capacitaciones',
       SUM(CASE WHEN EmpleadoKey IS NULL THEN 1 ELSE 0 END)
FROM Fact_Capacitaciones
UNION ALL
SELECT 'Fact_Nomina',
       SUM(CASE WHEN EmpleadoKey IS NULL THEN 1 ELSE 0 END)
FROM Fact_Nomina;

-- VALIDACIÓN 3: Fechas de Hechos existentes en Dim_Tiempo

SELECT 'VALIDACIÓN 3 - TiempoKey sin correspondencia en Dim_Tiempo' AS Validacion;

SELECT 'Fact_Ausencias - FechaInicio' AS Hecho,
       COUNT(*) AS SinCorrespondencia
FROM Fact_Ausencias fa
WHERE NOT EXISTS (
    SELECT 1 FROM Dim_Tiempo dt WHERE dt.TiempoKey = fa.TiempoInicioKey
)
UNION ALL
SELECT 'Fact_Evaluaciones - FechaEval',
       COUNT(*)
FROM Fact_Evaluaciones fe
WHERE NOT EXISTS (
    SELECT 1 FROM Dim_Tiempo dt WHERE dt.TiempoKey = fe.TiempoKey
);

-- VALIDACIÓN 4: Consistencia SCD Tipo 2 en Dim_Empleado
-- Regla: ningún empleado puede tener dos registros activos simultáneos

SELECT 'VALIDACIÓN 4 - Empleados con más de un registro activo (SCD2)' AS Validacion;

SELECT
    EmpleadoID,
    COUNT(*) AS RegistrosActivos,
    CASE WHEN COUNT(*) > 1 THEN 'ERROR - Duplicado activo' ELSE 'OK' END AS Estado
FROM Dim_Empleado
WHERE EsActual = TRUE
GROUP BY EmpleadoID
HAVING COUNT(*) > 1
ORDER BY EmpleadoID;

SELECT IF(
    (SELECT COUNT(*) FROM (
        SELECT EmpleadoID FROM Dim_Empleado
        WHERE EsActual = TRUE
        GROUP BY EmpleadoID HAVING COUNT(*) > 1
    ) t) = 0,
    'OK - Sin duplicados activos en Dim_Empleado',
    'ALERTA - Existen duplicados activos'
) AS Resultado;

-- VALIDACIÓN 5: Solapamiento de vigencias en SCD Tipo 2
-- No deben existir dos versiones del mismo empleado con fechas solapadas

SELECT 'VALIDACIÓN 5 - Solapamiento de vigencias en Dim_Empleado' AS Validacion;

SELECT
    a.EmpleadoID,
    a.FechaInicioVigencia AS InicioPrimero,
    a.FechaFinVigencia    AS FinPrimero,
    b.FechaInicioVigencia AS InicioSegundo,
    b.FechaFinVigencia    AS FinSegundo,
    'SOLAPAMIENTO DETECTADO'  AS Problema
FROM Dim_Empleado a
INNER JOIN Dim_Empleado b
    ON a.EmpleadoID = b.EmpleadoID
   AND a.EmpleadoKey < b.EmpleadoKey
WHERE a.FechaInicioVigencia <= COALESCE(b.FechaFinVigencia, '9999-12-31')
  AND COALESCE(a.FechaFinVigencia, '9999-12-31') >= b.FechaInicioVigencia
LIMIT 20;

-- VALIDACIÓN 6: Salario fuera del rango del puesto
-- El salario del empleado no puede estar fuera del rango definido

SELECT 'VALIDACIÓN 6 - Empleados con salario fuera del rango del puesto' AS Validacion;

SELECT
    e.Id                AS EmpleadoID,
    CONCAT(e.Nombres,' ',e.Apellidos) AS Empleado,
    p.Nombre            AS Puesto,
    p.SalarioMinimo,
    e.Salario           AS SalarioActual,
    p.SalarioMaximo,
    CASE
        WHEN e.Salario < p.SalarioMinimo THEN 'Por debajo del mínimo'
        WHEN e.Salario > p.SalarioMaximo THEN 'Por encima del máximo'
    END AS Observacion
FROM RRHH.Empleados e
INNER JOIN RRHH.Puestos p ON e.PuestoID = p.Id
WHERE e.Salario < p.SalarioMinimo OR e.Salario > p.SalarioMaximo;

-- VALIDACIÓN 7: Ausencias con duración negativa o cero

SELECT 'VALIDACIÓN 7 - Ausencias con duración <= 0 días' AS Validacion;

SELECT COUNT(*) AS AusenciasInvalidas
FROM Fact_Ausencias
WHERE DiasTotales <= 0;

SELECT
    fa.AusenciaID,
    fa.DiasTotales,
    fa.TipoAusencia,
    'Duración inválida' AS Problema
FROM Fact_Ausencias fa
WHERE fa.DiasTotales <= 0;

-- VALIDACIÓN 8: Evaluadores evaluando a sí mismos
-- Un empleado no debería autoevaluarse

SELECT 'VALIDACIÓN 8 - Empleados que se autoevalúan' AS Validacion;

SELECT
    ev.EvaluacionID,
    e.Id        AS EmpleadoID,
    CONCAT(e.Nombres,' ',e.Apellidos) AS Empleado,
    'Se autoevalúa' AS Problema
FROM RRHH.Evaluaciones ev
INNER JOIN RRHH.Empleados e ON ev.EmpleadoID = e.Id
WHERE ev.EmpleadoID = ev.EvaluadorID;

SELECT IF(
    (SELECT COUNT(*) FROM RRHH.Evaluaciones WHERE EmpleadoID = EvaluadorID) = 0,
    'OK - Ningún empleado se autoevalúa',
    'ALERTA - Hay autoevaluaciones'
) AS Resultado;

-- VALIDACIÓN 9: Dim_Tiempo - Continuidad sin días faltantes
-- Verifica que no hay saltos en la secuencia de fechas

SELECT 'VALIDACIÓN 9 - Continuidad de fechas en Dim_Tiempo' AS Validacion;

SELECT
    COUNT(*)                        AS TotalDias,
    MIN(Fecha)                      AS PrimeraFecha,
    MAX(Fecha)                      AS UltimaFecha,
    DATEDIFF(MAX(Fecha), MIN(Fecha)) + 1 AS DiasEsperados,
    CASE
        WHEN COUNT(*) = DATEDIFF(MAX(Fecha), MIN(Fecha)) + 1
        THEN 'OK - Sin días faltantes'
        ELSE CONCAT('ALERTA - Faltan ', DATEDIFF(MAX(Fecha), MIN(Fecha)) + 1 - COUNT(*), ' días')
    END AS Estado
FROM Dim_Tiempo;

-- VALIDACIÓN 10: Costo de ausencias coherente con salario
-- El costo no puede ser negativo ni desproporcionado

SELECT 'VALIDACIÓN 10 - Costos de ausencia incoherentes' AS Validacion;

SELECT
    fa.AusenciaID,
    fa.DiasTotales,
    fa.CostoAproximado,
    ROUND(e.Salario / 30.0 * fa.DiasTotales, 2) AS CostoEsperado,
    ABS(fa.CostoAproximado - ROUND(e.Salario / 30.0 * fa.DiasTotales, 2)) AS Diferencia,
    'Costo no coincide con salario' AS Observacion
FROM Fact_Ausencias fa
INNER JOIN RRHH.Ausencias a  ON fa.AusenciaID    = a.Id
INNER JOIN RRHH.Empleados e  ON a.EmpleadoID     = e.Id
WHERE ABS(fa.CostoAproximado - ROUND(e.Salario / 30.0 * fa.DiasTotales, 2)) > 1  -- Tolerancia de 1 COP
LIMIT 20;

-- VALIDACIÓN 11: Evaluaciones sin empleado activo en el período

SELECT 'VALIDACIÓN 11 - Evaluaciones sin EmpleadoKey o EvaluadorKey válido' AS Validacion;

SELECT
    COUNT(*) AS EvaluacionesConNulls,
    SUM(CASE WHEN EmpleadoKey IS NULL THEN 1 ELSE 0 END) AS SinEmpleado,
    SUM(CASE WHEN EvaluadorKey IS NULL THEN 1 ELSE 0 END) AS SinEvaluador
FROM Fact_Evaluaciones;

-- VALIDACIÓN 12: Resumen ejecutivo de calidad del DWH

SELECT 'VALIDACIÓN 12 - Resumen Ejecutivo de Calidad' AS Validacion;

SELECT
    'Dim_Tiempo'        AS Objeto,
    COUNT(*)            AS Registros,
    'Sin PK duplicada'  AS Estado
FROM Dim_Tiempo
UNION ALL
SELECT 'Dim_Empleado (activos)',    COUNT(*), 'Registros activos únicos' FROM Dim_Empleado WHERE EsActual=TRUE
UNION ALL
SELECT 'Dim_Empleado (historial)',  COUNT(*), 'Total versiones SCD2'     FROM Dim_Empleado
UNION ALL
SELECT 'Dim_Departamento',          COUNT(*), '' FROM Dim_Departamento WHERE EsActual=TRUE
UNION ALL
SELECT 'Dim_Puesto',                COUNT(*), '' FROM Dim_Puesto        WHERE EsActual=TRUE
UNION ALL
SELECT 'Dim_Oficina',               COUNT(*), '' FROM Dim_Oficina       WHERE EsActual=TRUE
UNION ALL
SELECT 'Fact_Ausencias',            COUNT(*), '' FROM Fact_Ausencias
UNION ALL
SELECT 'Fact_Evaluaciones',         COUNT(*), '' FROM Fact_Evaluaciones
UNION ALL
SELECT 'Fact_Capacitaciones',       COUNT(*), '' FROM Fact_Capacitaciones
UNION ALL
SELECT 'Fact_Nomina',               COUNT(*), '' FROM Fact_Nomina;
