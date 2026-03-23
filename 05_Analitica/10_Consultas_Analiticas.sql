-- ============================================================
-- SCRIPT 10: Consultas Analíticas y KPIs Estratégicos
-- Proyecto: TalentCorp S.A.
-- 15 consultas sobre el Data Warehouse RRHH_DW
-- ============================================================

USE RRHH_DW;

-- CONSULTA 1: Headcount (Plantilla activa) por Departamento
-- KPI: ¿Cuántos empleados tiene cada departamento actualmente?

SELECT '-- CONSULTA 1: Headcount por Departamento --' AS '';

SELECT
    dd.NombreDpto                               AS Departamento,
    dd.OficinaCiudad                            AS Ciudad,
    COUNT(de.EmpleadoKey)                       AS TotalEmpleados,
    ROUND(AVG(de.Salario), 0)                   AS SalarioPromedio,
    MIN(de.Salario)                             AS SalarioMinimo,
    MAX(de.Salario)                             AS SalarioMaximo,
    ROUND(SUM(de.Salario), 0)                   AS MasaSalarial,
    ROUND(COUNT(de.EmpleadoKey) * 100.0 /
        SUM(COUNT(de.EmpleadoKey)) OVER (), 1)  AS PorcentajePlantilla
FROM Dim_Empleado de
INNER JOIN Dim_Departamento dd ON de.DepartamentoNombre = dd.NombreDpto
WHERE de.EsActual = TRUE AND dd.EsActual = TRUE
GROUP BY dd.NombreDpto, dd.OficinaCiudad
ORDER BY TotalEmpleados DESC;

-- CONSULTA 2: Tasa de Ausentismo por Departamento y Año
-- KPI: Días ausentes / Días laborales disponibles * 100

SELECT '-- CONSULTA 2: Tasa de Ausentismo por Departamento y Año --' AS '';

SELECT
    dd.NombreDpto                       AS Departamento,
    dt.Anio                             AS Año,
    COUNT(fa.AusenciaKey)               AS TotalAusencias,
    SUM(fa.DiasTotales)                 AS TotalDiasAusentes,
    COUNT(DISTINCT fa.EmpleadoKey)      AS EmpleadosConAusencias,
    -- Días laborales disponibles = empleados * 250 días hábiles aprox
    ROUND(SUM(fa.DiasTotales) * 100.0 /
        (COUNT(DISTINCT fa.EmpleadoKey) * 250), 2) AS TasaAusentismo_Pct,
    -- Clasificación del nivel de ausentismo
    CASE
        WHEN ROUND(SUM(fa.DiasTotales) * 100.0 /
             (COUNT(DISTINCT fa.EmpleadoKey) * 250), 2) < 2   THEN 'Bajo'
        WHEN ROUND(SUM(fa.DiasTotales) * 100.0 /
             (COUNT(DISTINCT fa.EmpleadoKey) * 250), 2) < 5   THEN 'Moderado'
        ELSE 'Alto'
    END AS NivelAusentismo
FROM Fact_Ausencias fa
INNER JOIN Dim_Empleado    de ON fa.EmpleadoKey     = de.EmpleadoKey
INNER JOIN Dim_Departamento dd ON fa.DepartamentoKey = dd.DepartamentoKey
INNER JOIN Dim_Tiempo      dt ON fa.TiempoInicioKey  = dt.TiempoKey
GROUP BY dd.NombreDpto, dt.Anio
ORDER BY dt.Anio, TasaAusentismo_Pct DESC;

-- CONSULTA 3: Distribución de Ausencias por Tipo
-- KPI: ¿Qué tipo de ausencia genera más días perdidos?

SELECT '-- CONSULTA 3: Distribución de Ausencias por Tipo --' AS '';

SELECT
    fa.TipoAusencia,
    COUNT(*)                                AS TotalRegistros,
    SUM(fa.DiasTotales)                     AS TotalDias,
    ROUND(AVG(fa.DiasTotales), 1)           AS PromedioDias,
    ROUND(SUM(fa.CostoAproximado), 0)       AS CostoTotal,
    fa.Justificada,
    ROUND(SUM(fa.DiasTotales) * 100.0 /
        SUM(SUM(fa.DiasTotales)) OVER (), 1) AS PorcentajeDias
FROM Fact_Ausencias fa
GROUP BY fa.TipoAusencia, fa.Justificada
ORDER BY TotalDias DESC;

-- CONSULTA 4: Promedio de Calificación de Desempeño por Dpto y Período
-- KPI: ¿Qué departamentos tienen mejor desempeño?

SELECT '-- CONSULTA 4: Desempeño por Departamento y Período Semestral --' AS '';

SELECT
    dd.NombreDpto                       AS Departamento,
    fe.PeriodoEvaluacion                AS Periodo,
    COUNT(*)                            AS NumEvaluaciones,
    ROUND(AVG(fe.Calificacion), 2)      AS PromedioCalificacion,
    ROUND(MIN(fe.Calificacion), 1)      AS CalificacionMinima,
    ROUND(MAX(fe.Calificacion), 1)      AS CalificacionMaxima,
    SUM(CASE WHEN fe.EsAprobado = TRUE THEN 1 ELSE 0 END)  AS Aprobados,
    SUM(CASE WHEN fe.EsAprobado = FALSE THEN 1 ELSE 0 END) AS Reprobados,
    ROUND(SUM(CASE WHEN fe.EsAprobado = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1)
                                        AS PorcentajeAprobacion
FROM Fact_Evaluaciones fe
INNER JOIN Dim_Departamento dd ON fe.DepartamentoKey = dd.DepartamentoKey
GROUP BY dd.NombreDpto, fe.PeriodoEvaluacion
ORDER BY fe.PeriodoEvaluacion, PromedioCalificacion DESC;

-- CONSULTA 5: Top 10 empleados con mejor desempeño 2024
-- KPI: Identificar talento de alto rendimiento

SELECT '-- CONSULTA 5: Top 10 Empleados con Mejor Desempeño 2024 --' AS '';

SELECT
    de.NombreCompleto                   AS Empleado,
    de.DepartamentoNombre               AS Departamento,
    de.PuestoNombre                     AS Puesto,
    de.NivelSalarial,
    COUNT(fe.EvaluacionKey)             AS NumEvaluaciones,
    ROUND(AVG(fe.Calificacion), 2)      AS PromedioCalificacion,
    ROUND(AVG(fe.CalificacionNorm), 1)  AS CalificacionNorm_100,
    MAX(fe.Calificacion)                AS MejorCalificacion
FROM Fact_Evaluaciones fe
INNER JOIN Dim_Empleado de ON fe.EmpleadoKey = de.EmpleadoKey
INNER JOIN Dim_Tiempo   dt ON fe.TiempoKey   = dt.TiempoKey
WHERE dt.Anio = 2024 AND de.EsActual = TRUE
GROUP BY de.NombreCompleto, de.DepartamentoNombre, de.PuestoNombre, de.NivelSalarial
ORDER BY PromedioCalificacion DESC
LIMIT 10;

-- CONSULTA 6: Análisis de Masa Salarial Mensual por Departamento
-- KPI: Evolución del costo de nómina mensual

SELECT '-- CONSULTA 6: Masa Salarial Mensual 2023-2024 --' AS '';

SELECT
    dt.Anio                             AS Año,
    dt.NombreMes                        AS Mes,
    dt.AnioMes,
    dd.NombreDpto                       AS Departamento,
    COUNT(fn.NominaKey)                 AS Empleados,
    ROUND(SUM(fn.Salario), 0)           AS MasaSalarial,
    ROUND(AVG(fn.Salario), 0)           AS SalarioPromedio,
    ROUND(AVG(fn.PorcentajeEnRango), 1) AS PosicionPromedioEnRango
FROM Fact_Nomina fn
INNER JOIN Dim_Tiempo       dt ON fn.TiempoKey       = dt.TiempoKey
INNER JOIN Dim_Departamento dd ON fn.DepartamentoKey = dd.DepartamentoKey
GROUP BY dt.Anio, dt.NombreMes, dt.AnioMes, dd.NombreDpto
ORDER BY dt.AnioMes, dd.NombreDpto;

-- CONSULTA 7: Inversión en Capacitación por Departamento
-- KPI: ¿Cuánto se invierte en desarrollo de talento?

SELECT '-- CONSULTA 7: Inversión en Capacitación por Departamento --' AS '';

SELECT
    dd.NombreDpto                       AS Departamento,
    COUNT(fc.CapacitacionKey)           AS TotalAsignaciones,
    COUNT(DISTINCT fc.EmpleadoKey)      AS EmpleadosCapacitados,
    COUNT(DISTINCT fc.CapacitacionID)   AS CapacitacionesDistintas,
    ROUND(SUM(fc.CostoCapacitacion), 0) AS InversionTotal,
    ROUND(AVG(fc.CostoCapacitacion), 0) AS CostoPromedioPorCapacitacion,
    ROUND(SUM(fc.CostoCapacitacion) /
        NULLIF(COUNT(DISTINCT fc.EmpleadoKey), 0), 0) AS CostoPorEmpleado,
    SUM(CASE WHEN fc.Estado = 'Completado' THEN 1 ELSE 0 END) AS Completadas,
    ROUND(SUM(CASE WHEN fc.Estado = 'Completado' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 1)         AS TasaCompletacion_Pct
FROM Fact_Capacitaciones fc
INNER JOIN Dim_Departamento dd ON fc.DepartamentoKey = dd.DepartamentoKey
GROUP BY dd.NombreDpto
ORDER BY InversionTotal DESC;

-- CONSULTA 8: Calificaciones de Capacitaciones por Programa
-- KPI: Efectividad de cada programa de capacitación

SELECT '-- CONSULTA 8: Efectividad de Programas de Capacitación --' AS '';

SELECT
    fc.NombreCapacitacion,
    fc.Proveedor,
    fc.DuracionDias,
    ROUND(AVG(fc.CostoCapacitacion), 0)         AS Costo,
    COUNT(*)                                    AS TotalInscritos,
    SUM(CASE WHEN fc.Estado='Completado' THEN 1 ELSE 0 END) AS Completados,
    ROUND(AVG(CASE WHEN fc.CalificacionObtenida IS NOT NULL
                   THEN fc.CalificacionObtenida END), 1)    AS CalificacionPromedio,
    SUM(CASE WHEN fc.EsAprobado = TRUE THEN 1 ELSE 0 END)  AS Aprobados,
    ROUND(SUM(CASE WHEN fc.EsAprobado=TRUE THEN 1 ELSE 0 END)
        * 100.0 / NULLIF(SUM(CASE WHEN fc.Estado='Completado' THEN 1 ELSE 0 END),0), 1)
                                                AS TasaAprobacion_Pct
FROM Fact_Capacitaciones fc
GROUP BY fc.NombreCapacitacion, fc.Proveedor, fc.DuracionDias
ORDER BY CalificacionPromedio DESC;

-- CONSULTA 9: Antigüedad Promedio por Departamento
-- KPI: Estabilidad y retención del talento

SELECT '-- CONSULTA 9: Antigüedad Promedio por Departamento --' AS '';

SELECT
    de.DepartamentoNombre                           AS Departamento,
    COUNT(*)                                        AS Empleados,
    ROUND(AVG(DATEDIFF(CURDATE(), de.FechaContratacion) / 365.0), 1)
                                                    AS AntiguedadPromedioAnios,
    MIN(de.FechaContratacion)                       AS ContrataciónMásAntigua,
    MAX(de.FechaContratacion)                       AS ContrataciónMásReciente,
    SUM(CASE WHEN DATEDIFF(CURDATE(), de.FechaContratacion)/365.0 >= 5 THEN 1 ELSE 0 END)
                                                    AS VeteranosMas5Anios,
    SUM(CASE WHEN DATEDIFF(CURDATE(), de.FechaContratacion)/365.0 < 1  THEN 1 ELSE 0 END)
                                                    AS NuevosMenosDeUnAnio
FROM Dim_Empleado de
WHERE de.EsActual = TRUE
GROUP BY de.DepartamentoNombre
ORDER BY AntiguedadPromedioAnios DESC;

-- CONSULTA 10: Distribución Salarial por Nivel y Departamento
-- KPI: Equidad salarial y posicionamiento en el mercado

SELECT '-- CONSULTA 10: Distribución Salarial por Nivel y Departamento --' AS '';

SELECT
    de.DepartamentoNombre                           AS Departamento,
    de.NivelSalarial                                AS Nivel,
    COUNT(*)                                        AS Empleados,
    ROUND(MIN(de.Salario), 0)                       AS SalarioMin,
    ROUND(AVG(de.Salario), 0)                       AS SalarioPromedio,
    ROUND(MAX(de.Salario), 0)                       AS SalarioMax,
    ROUND(AVG(fn_stats.PorcentajeEnRango), 1)       AS PosicionPromEnRango_Pct
FROM Dim_Empleado de
LEFT JOIN (
    SELECT EmpleadoKey, AVG(PorcentajeEnRango) AS PorcentajeEnRango
    FROM Fact_Nomina
    GROUP BY EmpleadoKey
) fn_stats ON de.EmpleadoKey = fn_stats.EmpleadoKey
WHERE de.EsActual = TRUE
GROUP BY de.DepartamentoNombre, de.NivelSalarial
ORDER BY de.DepartamentoNombre, de.NivelSalarial;

-- CONSULTA 11: Tendencia de Ausentismo Trimestral 2023 vs 2024
-- KPI: ¿Está mejorando o empeorando el ausentismo?

SELECT '-- CONSULTA 11: Tendencia de Ausentismo Trimestral --' AS '';

SELECT
    dt.Anio                                         AS Año,
    dt.NombreTrimestre                              AS Trimestre,
    COUNT(fa.AusenciaKey)                           AS NumAusencias,
    SUM(fa.DiasTotales)                             AS TotalDias,
    ROUND(SUM(fa.CostoAproximado), 0)               AS CostoTotal,
    ROUND(AVG(fa.DiasTotales), 1)                   AS PromDiasPorAusencia,
    -- Comparación vs trimestre anterior usando LAG
    LAG(SUM(fa.DiasTotales), 1) OVER (ORDER BY dt.Anio, dt.Trimestre)
                                                    AS DiasTrimAnterior,
    ROUND(
        (SUM(fa.DiasTotales) -
         LAG(SUM(fa.DiasTotales),1) OVER (ORDER BY dt.Anio, dt.Trimestre))
        * 100.0 /
        NULLIF(LAG(SUM(fa.DiasTotales),1) OVER (ORDER BY dt.Anio, dt.Trimestre), 0)
    , 1)                                            AS VariacionPct
FROM Fact_Ausencias fa
INNER JOIN Dim_Tiempo dt ON fa.TiempoInicioKey = dt.TiempoKey
GROUP BY dt.Anio, dt.Trimestre, dt.NombreTrimestre
ORDER BY dt.Anio, dt.Trimestre;

-- CONSULTA 12: Empleados con Más Ausencias No Justificadas
-- KPI: Identificar casos de atención en bienestar laboral

SELECT '-- CONSULTA 12: Top 10 Empleados con Más Ausencias No Justificadas --' AS '';

SELECT
    de.NombreCompleto                               AS Empleado,
    de.DepartamentoNombre                           AS Departamento,
    de.PuestoNombre                                 AS Puesto,
    COUNT(fa.AusenciaKey)                           AS TotalAusencias,
    SUM(CASE WHEN fa.Justificada = FALSE THEN 1 ELSE 0 END) AS NoJustificadas,
    SUM(CASE WHEN fa.Justificada = TRUE  THEN 1 ELSE 0 END) AS Justificadas,
    SUM(fa.DiasTotales)                             AS TotalDias,
    ROUND(SUM(CASE WHEN fa.Justificada=FALSE THEN fa.DiasTotales ELSE 0 END)
        * 100.0 / NULLIF(SUM(fa.DiasTotales), 0), 1) AS PctNoJustificado
FROM Fact_Ausencias fa
INNER JOIN Dim_Empleado de ON fa.EmpleadoKey = de.EmpleadoKey
WHERE de.EsActual = TRUE
GROUP BY de.NombreCompleto, de.DepartamentoNombre, de.PuestoNombre
HAVING SUM(CASE WHEN fa.Justificada = FALSE THEN 1 ELSE 0 END) > 0
ORDER BY NoJustificadas DESC, TotalDias DESC
LIMIT 10;

-- CONSULTA 13: ROI de Capacitación (Relación Inversión-Desempeño)
-- KPI: ¿Los empleados capacitados tienen mejor desempeño?

SELECT '-- CONSULTA 13: Impacto de Capacitaciones en el Desempeño --' AS '';

SELECT
    de.NombreCompleto                               AS Empleado,
    de.DepartamentoNombre                           AS Departamento,
    COUNT(DISTINCT fc.CapacitacionKey)              AS NumCapacitaciones,
    ROUND(SUM(fc.CostoCapacitacion), 0)             AS InversionEnCapacitacion,
    ROUND(AVG(fc.CalificacionObtenida), 1)          AS PromedioCalifCapacitacion,
    ROUND(AVG(fe.Calificacion), 2)                  AS PromedioDesempeno,
    -- Categorización del perfil del empleado
    CASE
        WHEN AVG(fe.Calificacion) >= 4.5 THEN 'Alto Potencial'
        WHEN AVG(fe.Calificacion) >= 3.5 THEN 'Buen Desempeño'
        WHEN AVG(fe.Calificacion) >= 2.5 THEN 'Desempeño Estándar'
        ELSE 'Requiere Mejora'
    END AS CategoriaTalento
FROM Dim_Empleado de
LEFT JOIN Fact_Capacitaciones fc ON de.EmpleadoKey = fc.EmpleadoKey
LEFT JOIN Fact_Evaluaciones   fe ON de.EmpleadoKey = fe.EmpleadoKey
WHERE de.EsActual = TRUE
GROUP BY de.NombreCompleto, de.DepartamentoNombre
HAVING COUNT(DISTINCT fc.CapacitacionKey) > 0
ORDER BY PromedioDesempeno DESC, NumCapacitaciones DESC;

-- CONSULTA 14: Dashboard Ejecutivo - KPIs Globales de RRHH
-- Resumen de los principales indicadores de la empresa

SELECT '-- CONSULTA 14: Dashboard Ejecutivo - KPIs Globales --' AS '';

SELECT 'Total Empleados Activos'   AS KPI,
       CAST(COUNT(*) AS CHAR)      AS Valor,
       'Personas'                  AS Unidad
FROM Dim_Empleado WHERE EsActual = TRUE
UNION ALL
SELECT 'Masa Salarial Mensual',
       FORMAT(SUM(de.Salario), 0),
       'COP'
FROM Dim_Empleado de WHERE de.EsActual = TRUE
UNION ALL
SELECT 'Salario Promedio',
       FORMAT(AVG(de.Salario), 0),
       'COP'
FROM Dim_Empleado de WHERE de.EsActual = TRUE
UNION ALL
SELECT 'Total Ausencias 2023-2024',
       CAST(COUNT(*) AS CHAR),
       'Registros'
FROM Fact_Ausencias
UNION ALL
SELECT 'Dias Ausentes Totales',
       CAST(SUM(DiasTotales) AS CHAR),
       'Días'
FROM Fact_Ausencias
UNION ALL
SELECT 'Costo Total Ausencias',
       FORMAT(SUM(CostoAproximado), 0),
       'COP'
FROM Fact_Ausencias
UNION ALL
SELECT 'Promedio Desempeño Empresa',
       CAST(ROUND(AVG(Calificacion), 2) AS CHAR),
       'Escala 1-5'
FROM Fact_Evaluaciones
UNION ALL
SELECT 'Tasa Aprobación Evaluaciones',
       CONCAT(ROUND(AVG(CASE WHEN EsAprobado=TRUE THEN 100.0 ELSE 0 END), 1), '%'),
       'Porcentaje'
FROM Fact_Evaluaciones
UNION ALL
SELECT 'Inversión Total Capacitaciones',
       FORMAT(SUM(CostoCapacitacion), 0),
       'COP'
FROM Fact_Capacitaciones
UNION ALL
SELECT 'Tasa Completación Capacitaciones',
       CONCAT(ROUND(SUM(CASE WHEN Estado='Completado' THEN 1 ELSE 0 END)*100.0/COUNT(*),1),'%'),
       'Porcentaje'
FROM Fact_Capacitaciones;

-- CONSULTA 15: Análisis de Desempeño vs Antigüedad
-- KPI: ¿Los empleados más antiguos tienen mejor desempeño?

SELECT '-- CONSULTA 15: Correlación Desempeño vs Antigüedad --' AS '';

SELECT
    -- Segmentación por antigüedad
    CASE
        WHEN DATEDIFF(CURDATE(), de.FechaContratacion) / 365.0 < 1   THEN 'Menos de 1 año'
        WHEN DATEDIFF(CURDATE(), de.FechaContratacion) / 365.0 < 3   THEN '1 a 3 años'
        WHEN DATEDIFF(CURDATE(), de.FechaContratacion) / 365.0 < 5   THEN '3 a 5 años'
        ELSE 'Más de 5 años'
    END                                                 AS SegmentoAntiguedad,
    COUNT(DISTINCT de.EmpleadoKey)                      AS NumEmpleados,
    ROUND(AVG(DATEDIFF(CURDATE(), de.FechaContratacion)/365.0), 1)
                                                        AS AntiguedadPromedioAnios,
    ROUND(AVG(fe.Calificacion), 2)                      AS PromedioDesempeno,
    ROUND(AVG(de.Salario), 0)                           AS SalarioPromedio,
    SUM(CASE WHEN fe.EsAprobado = TRUE THEN 1 ELSE 0 END)  AS Aprobados,
    ROUND(SUM(CASE WHEN fe.EsAprobado=TRUE THEN 1 ELSE 0 END)
        * 100.0 / NULLIF(COUNT(fe.EvaluacionKey), 0), 1) AS TasaAprobacion_Pct,
    -- Conclusión del segmento
    CASE
        WHEN AVG(fe.Calificacion) >= 4.3 THEN 'Alto rendimiento'
        WHEN AVG(fe.Calificacion) >= 3.7 THEN 'Rendimiento sólido'
        WHEN AVG(fe.Calificacion) >= 3.0 THEN 'Rendimiento aceptable'
        ELSE 'Requiere atención'
    END                                                 AS Conclusion
FROM Dim_Empleado de
INNER JOIN Fact_Evaluaciones fe ON de.EmpleadoKey = fe.EmpleadoKey
WHERE de.EsActual = TRUE
GROUP BY
    CASE
        WHEN DATEDIFF(CURDATE(), de.FechaContratacion) / 365.0 < 1   THEN 'Menos de 1 año'
        WHEN DATEDIFF(CURDATE(), de.FechaContratacion) / 365.0 < 3   THEN '1 a 3 años'
        WHEN DATEDIFF(CURDATE(), de.FechaContratacion) / 365.0 < 5   THEN '3 a 5 años'
        ELSE 'Más de 5 años'
    END
ORDER BY AntiguedadPromedioAnios;