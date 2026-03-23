-- ============================================================
-- SCRIPT 07: ETL - Carga Dimensiones con SCD Tipo 2
-- Proyecto: TalentCorp S.A.
-- Procedimientos: sp_Cargar_Dim_Oficina, Departamento, Puesto, Empleado
-- ============================================================

USE RRHH_DW;

-- PROCEDIMIENTO AUXILIAR: Registra un cambio SCD2 en auditoría

DROP PROCEDURE IF EXISTS sp_RegistrarAuditoriaSCD;
DELIMITER $$
CREATE PROCEDURE sp_RegistrarAuditoriaSCD(
    IN p_Dimension   VARCHAR(100),
    IN p_ClaveNeg    INT,
    IN p_TipoCambio  VARCHAR(50),
    IN p_Descripcion VARCHAR(300)
)
BEGIN
    INSERT INTO ETL_AuditoriaSCD (NombreDimension, ClaveNegocio, TipoCambio, DescripcionCambio)
    VALUES (p_Dimension, p_ClaveNeg, p_TipoCambio, p_Descripcion);
END$$
DELIMITER ;

-- SP 1: Cargar Dim_Oficina (SCD Tipo 2)

DROP PROCEDURE IF EXISTS sp_Cargar_Dim_Oficina;
DELIMITER $$

CREATE PROCEDURE sp_Cargar_Dim_Oficina()
BEGIN
    DECLARE v_LogID     INT;
    DECLARE v_Ins       INT DEFAULT 0;
    DECLARE v_Upd       INT DEFAULT 0;

    INSERT INTO ETL_Log (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Cargar_Dim_Oficina', NOW(), 'Ejecutando');
    SET v_LogID = LAST_INSERT_ID();

    -- Cerrar registros activos que cambiaron
    UPDATE Dim_Oficina d
    INNER JOIN RRHH.Oficinas s ON d.OficinaID = s.codigo
    SET
        d.FechaFinVigencia  = CURRENT_DATE() - INTERVAL 1 DAY,
        d.EsActual          = FALSE
    WHERE d.EsActual = TRUE
      AND (
            d.Ciudad        <> s.Ciudad     OR
            d.Pais          <> s.Pais       OR
            d.Region        <> s.Region     OR
            d.Telefono      <> s.Telefono   OR
            d.Direccion     <> s.Direccion
          );
    SET v_Upd = ROW_COUNT();

    -- Insertar nuevas versiones para los cerrados + registros nuevos
    INSERT INTO Dim_Oficina (
        OficinaID, CodigoOficina, Ciudad, Pais, Region,
        CodigoPostal, Telefono, Direccion,
        FechaInicioVigencia, FechaFinVigencia, EsActual, VersionRegistro
    )
    SELECT
        s.codigo,
        s.CodigoOficina,
        s.Ciudad,
        s.Pais,
        s.Region,
        s.CodigoPostal,
        s.Telefono,
        s.Direccion,
        CURRENT_DATE(),
        NULL,
        TRUE,
        COALESCE((
            SELECT MAX(d2.VersionRegistro) + 1
            FROM Dim_Oficina d2
            WHERE d2.OficinaID = s.codigo
        ), 1)
    FROM RRHH.Oficinas s
    WHERE NOT EXISTS (
        SELECT 1 FROM Dim_Oficina d
        WHERE d.OficinaID = s.codigo AND d.EsActual = TRUE
    );
    SET v_Ins = ROW_COUNT();

    -- Registrar auditoría
    IF v_Ins > 0 OR v_Upd > 0 THEN
        CALL sp_RegistrarAuditoriaSCD('Dim_Oficina', 0, 'CARGA_COMPLETA',
            CONCAT('Insertados: ', v_Ins, ' | Cerrados SCD2: ', v_Upd));
    END IF;

    UPDATE ETL_Log
    SET FechaFin = NOW(), Estado = 'Exitoso',
        RegistrosInsertados = v_Ins, RegistrosActualizados = v_Upd
    WHERE LogID = v_LogID;

    SELECT CONCAT('Dim_Oficina - Insertados: ', v_Ins, ' | SCD2 cerrados: ', v_Upd) AS Resultado;
END$$
DELIMITER ;

-- SP 2: Cargar Dim_Departamento (SCD Tipo 2)

DROP PROCEDURE IF EXISTS sp_Cargar_Dim_Departamento;
DELIMITER $$

CREATE PROCEDURE sp_Cargar_Dim_Departamento()
BEGIN
    DECLARE v_LogID INT;
    DECLARE v_Ins INT DEFAULT 0;
    DECLARE v_Upd INT DEFAULT 0;

    INSERT INTO ETL_Log (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Cargar_Dim_Departamento', NOW(), 'Ejecutando');
    SET v_LogID = LAST_INSERT_ID();

    -- Cerrar registros que cambiaron
    UPDATE Dim_Departamento dd
    INNER JOIN RRHH.Departamentos s  ON dd.DepartamentoID = s.Id
    INNER JOIN RRHH.Oficinas o       ON s.OficinaID       = o.codigo
    SET
        dd.FechaFinVigencia = CURRENT_DATE() - INTERVAL 1 DAY,
        dd.EsActual         = FALSE
    WHERE dd.EsActual = TRUE
      AND (
            dd.NombreDpto    <> s.NombreDpto   OR
            dd.OficinaCiudad <> o.Ciudad
          );
    SET v_Upd = ROW_COUNT();

    -- Insertar nuevas versiones o nuevos registros
    INSERT INTO Dim_Departamento (
        DepartamentoID, NombreDpto, Descripcion,
        OficinaCiudad, OficinaPais,
        FechaInicioVigencia, FechaFinVigencia, EsActual, VersionRegistro
    )
    SELECT
        s.Id,
        s.NombreDpto,
        s.Descripcion,
        o.Ciudad,
        o.Pais,
        CURRENT_DATE(),
        NULL,
        TRUE,
        COALESCE((SELECT MAX(d2.VersionRegistro)+1 FROM Dim_Departamento d2 WHERE d2.DepartamentoID=s.Id), 1)
    FROM RRHH.Departamentos s
    INNER JOIN RRHH.Oficinas o ON s.OficinaID = o.codigo
    WHERE NOT EXISTS (
        SELECT 1 FROM Dim_Departamento d WHERE d.DepartamentoID = s.Id AND d.EsActual = TRUE
    );
    SET v_Ins = ROW_COUNT();

    UPDATE ETL_Log
    SET FechaFin = NOW(), Estado = 'Exitoso',
        RegistrosInsertados = v_Ins, RegistrosActualizados = v_Upd
    WHERE LogID = v_LogID;

    SELECT CONCAT('Dim_Departamento - Insertados: ', v_Ins, ' | SCD2 cerrados: ', v_Upd) AS Resultado;
END$$
DELIMITER ;

-- SP 3: Cargar Dim_Puesto (SCD Tipo 2)

DROP PROCEDURE IF EXISTS sp_Cargar_Dim_Puesto;
DELIMITER $$

CREATE PROCEDURE sp_Cargar_Dim_Puesto()
BEGIN
    DECLARE v_LogID INT;
    DECLARE v_Ins   INT DEFAULT 0;
    DECLARE v_Upd   INT DEFAULT 0;

    INSERT INTO ETL_Log (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Cargar_Dim_Puesto', NOW(), 'Ejecutando');
    SET v_LogID = LAST_INSERT_ID();

    -- Cerrar los que cambiaron
    UPDATE Dim_Puesto dp
    INNER JOIN RRHH.Puestos s ON dp.PuestoID = s.Id
    SET
        dp.FechaFinVigencia = CURRENT_DATE() - INTERVAL 1 DAY,
        dp.EsActual         = FALSE
    WHERE dp.EsActual = TRUE
      AND (
            dp.NombrePuesto   <> s.Nombre         OR
            dp.NivelSalarial  <> s.NivelSalarial   OR
            dp.SalarioMinimo  <> s.SalarioMinimo   OR
            dp.SalarioMaximo  <> s.SalarioMaximo
          );
    SET v_Upd = ROW_COUNT();

    -- Insertar nuevas versiones
    INSERT INTO Dim_Puesto (
        PuestoID, NombrePuesto, NivelSalarial,
        SalarioMinimo, SalarioMaximo, RangaSalarial,
        FechaInicioVigencia, FechaFinVigencia, EsActual, VersionRegistro
    )
    SELECT
        s.Id,
        s.Nombre,
        s.NivelSalarial,
        s.SalarioMinimo,
        s.SalarioMaximo,
        -- Etiqueta legible del rango salarial en millones
        CONCAT(
            FORMAT(s.SalarioMinimo / 1000000, 1), 'M - ',
            FORMAT(s.SalarioMaximo / 1000000, 1), 'M'
        ),
        CURRENT_DATE(),
        NULL,
        TRUE,
        COALESCE((SELECT MAX(d2.VersionRegistro)+1 FROM Dim_Puesto d2 WHERE d2.PuestoID=s.Id), 1)
    FROM RRHH.Puestos s
    WHERE NOT EXISTS (
        SELECT 1 FROM Dim_Puesto d WHERE d.PuestoID = s.Id AND d.EsActual = TRUE
    );
    SET v_Ins = ROW_COUNT();

    UPDATE ETL_Log
    SET FechaFin = NOW(), Estado = 'Exitoso',
        RegistrosInsertados = v_Ins, RegistrosActualizados = v_Upd
    WHERE LogID = v_LogID;

    SELECT CONCAT('Dim_Puesto - Insertados: ', v_Ins, ' | SCD2 cerrados: ', v_Upd) AS Resultado;
END$$
DELIMITER ;

-- SP 4: Cargar Dim_Empleado (SCD Tipo 2)
-- Detecta cambios en: Dpto, Puesto, Salario, Oficina, Jefe

DROP PROCEDURE IF EXISTS sp_Cargar_Dim_Empleado;
DELIMITER $$

CREATE PROCEDURE sp_Cargar_Dim_Empleado()
BEGIN
    DECLARE v_LogID INT;
    DECLARE v_Ins   INT DEFAULT 0;
    DECLARE v_Upd   INT DEFAULT 0;

    INSERT INTO ETL_Log (NombreProceso, FechaInicio, Estado)
    VALUES ('sp_Cargar_Dim_Empleado', NOW(), 'Ejecutando');
    SET v_LogID = LAST_INSERT_ID();

    -- Cerrar registros activos donde algún atributo rastreado cambió
    UPDATE Dim_Empleado de
    INNER JOIN RRHH.Empleados      e   ON de.EmpleadoID      = e.Id
    INNER JOIN RRHH.Departamentos  d   ON e.DepartamentoID   = d.Id
    INNER JOIN RRHH.Puestos        p   ON e.PuestoID         = p.Id
    INNER JOIN RRHH.Oficinas       o   ON e.OficinaID        = o.codigo
    LEFT  JOIN RRHH.Empleados      j   ON e.JefeID           = j.Id
    SET
        de.FechaFinVigencia = CURRENT_DATE() - INTERVAL 1 DAY,
        de.EsActual         = FALSE
    WHERE de.EsActual = TRUE
      AND (
            de.DepartamentoNombre  <> d.NombreDpto    OR
            de.PuestoNombre        <> p.Nombre         OR
            de.NivelSalarial       <> p.NivelSalarial  OR
            de.OficinaCiudad       <> o.Ciudad         OR
            de.Salario             <> e.Salario        OR
            -- Cambio en jefe
            COALESCE(de.NombreJefe, '') <>
                COALESCE(CONCAT(j.Nombres, ' ', j.Apellidos), '')
          );
    SET v_Upd = ROW_COUNT();

    -- Insertar nuevas versiones para registros cerrados + empleados nuevos
    INSERT INTO Dim_Empleado (
        EmpleadoID, Nombres, Apellidos, NombreCompleto,
        FechaNacimiento, Genero, EstadoCivil, Email, Telefono,
        FechaContratacion, DepartamentoNombre, PuestoNombre,
        NivelSalarial, OficinaCiudad, OficinaPais, Salario, NombreJefe,
        FechaInicioVigencia, FechaFinVigencia, EsActual, VersionRegistro
    )
    SELECT
        e.Id,
        e.Nombres,
        e.Apellidos,
        CONCAT(e.Nombres, ' ', e.Apellidos),
        e.FechaNacimiento,
        e.Genero,
        e.EstadoCivil,
        e.Email,
        e.Telefono,
        e.FechaContratacion,
        d.NombreDpto,
        p.Nombre,
        p.NivelSalarial,
        o.Ciudad,
        o.Pais,
        e.Salario,
        CONCAT(j.Nombres, ' ', j.Apellidos),  -- NULL si no tiene jefe
        CURRENT_DATE(),
        NULL,
        TRUE,
        COALESCE((SELECT MAX(de2.VersionRegistro)+1 FROM Dim_Empleado de2 WHERE de2.EmpleadoID=e.Id), 1)
    FROM RRHH.Empleados     e
    INNER JOIN RRHH.Departamentos  d  ON e.DepartamentoID = d.Id
    INNER JOIN RRHH.Puestos        p  ON e.PuestoID       = p.Id
    INNER JOIN RRHH.Oficinas       o  ON e.OficinaID      = o.codigo
    LEFT  JOIN RRHH.Empleados      j  ON e.JefeID         = j.Id
    WHERE NOT EXISTS (
        SELECT 1 FROM Dim_Empleado de
        WHERE de.EmpleadoID = e.Id AND de.EsActual = TRUE
    );
    SET v_Ins = ROW_COUNT();

    IF v_Ins > 0 OR v_Upd > 0 THEN
        CALL sp_RegistrarAuditoriaSCD('Dim_Empleado', 0, 'CARGA_COMPLETA',
            CONCAT('Insertados: ', v_Ins, ' | SCD2 cerrados: ', v_Upd));
    END IF;

    UPDATE ETL_Log
    SET FechaFin = NOW(), Estado = 'Exitoso',
        RegistrosInsertados = v_Ins, RegistrosActualizados = v_Upd
    WHERE LogID = v_LogID;

    SELECT CONCAT('Dim_Empleado - Insertados: ', v_Ins, ' | SCD2 cerrados: ', v_Upd) AS Resultado;
END$$
DELIMITER ;

-- PROCEDIMIENTO MAESTRO: Ejecuta todas las dimensiones en orden

DROP PROCEDURE IF EXISTS sp_Cargar_Todas_Dimensiones;
DELIMITER $$
CREATE PROCEDURE sp_Cargar_Todas_Dimensiones()
BEGIN
    CALL sp_Cargar_Dim_Oficina();
    CALL sp_Cargar_Dim_Departamento();
    CALL sp_Cargar_Dim_Puesto();
    CALL sp_Cargar_Dim_Empleado();
    SELECT 'Todas las dimensiones cargadas exitosamente.' AS Resultado;
END$$
DELIMITER ;

-- EJECUTAR CARGA INICIAL
-- Se debe ejecutar para evitar error en la carga de todas las dimensiones-
SET SQL_SAFE_UPDATES = 0;

CALL sp_Cargar_Todas_Dimensiones();

-- Verificación rápida
SELECT 'Dim_Empleado' AS Dimension, COUNT(*) AS Filas FROM Dim_Empleado
UNION ALL
SELECT 'Dim_Departamento', COUNT(*) FROM Dim_Departamento
UNION ALL
SELECT 'Dim_Puesto', COUNT(*) FROM Dim_Puesto
UNION ALL
SELECT 'Dim_Oficina', COUNT(*) FROM Dim_Oficina;