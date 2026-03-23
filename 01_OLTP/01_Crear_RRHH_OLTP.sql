-- SCRIPT 01: Creación BD Operacional RRHH (OLTP)
-- Proyecto: TalentCorp S.A.

DROP DATABASE IF EXISTS RRHH;
CREATE DATABASE RRHH
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE RRHH;

-- 1. OFICINAS --

CREATE TABLE Oficinas (
    codigo          INT             AUTO_INCREMENT PRIMARY KEY,
    CodigoOficina   VARCHAR(20)     NOT NULL UNIQUE,   -- Ej: 'BOG-NORTE'
    Ciudad          VARCHAR(50)     NOT NULL,
    Pais            VARCHAR(50)     NOT NULL,
    Region          VARCHAR(50)     NOT NULL,
    CodigoPostal    VARCHAR(20)     NOT NULL,
    Telefono        VARCHAR(20)     NOT NULL,
    Direccion       VARCHAR(255)    NOT NULL
);

-- 2. DEPARTAMENTOS --

CREATE TABLE Departamentos (
    Id          INT             AUTO_INCREMENT PRIMARY KEY,
    NombreDpto  VARCHAR(50)     NOT NULL,
    Descripcion VARCHAR(255)    NULL,
    OficinaID   INT             NOT NULL,
    FOREIGN KEY (OficinaID) REFERENCES Oficinas(codigo)
);

-- 3. PUESTOS DE TRABAJO --

CREATE TABLE Puestos (
    Id              INT             AUTO_INCREMENT PRIMARY KEY,
    Nombre          VARCHAR(50)     NOT NULL,
    NivelSalarial   VARCHAR(60)     NOT NULL,    -- Junior / Mid-Level / Senior
    SalarioMinimo   DECIMAL(18,2)   NOT NULL,
    SalarioMaximo   DECIMAL(18,2)   NOT NULL,
    CHECK (SalarioMinimo > 0),
    CHECK (SalarioMaximo >= SalarioMinimo)
);


-- 4. EMPLEADOS --

CREATE TABLE Empleados (
    Id                  INT             AUTO_INCREMENT PRIMARY KEY,
    Nombres             VARCHAR(50)     NOT NULL,
    Apellidos           VARCHAR(50)     NOT NULL,
    FechaNacimiento     DATE            NOT NULL,
    Genero              VARCHAR(10)     NOT NULL,
    EstadoCivil         VARCHAR(20)     NOT NULL,
    Email               VARCHAR(100)    NOT NULL UNIQUE,
    Telefono            VARCHAR(20)     NOT NULL,
    FechaContratacion   DATE            NOT NULL,
    DepartamentoID      INT             NOT NULL,
    OficinaID           INT             NOT NULL,
    PuestoID            INT             NOT NULL,
    JefeID              INT             NULL,        -- Auto-referencia (jefe directo)
    Salario             DECIMAL(18,2)   NOT NULL,
    FechaCreacion       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (DepartamentoID)    REFERENCES Departamentos(Id),
    FOREIGN KEY (OficinaID)         REFERENCES Oficinas(codigo),
    FOREIGN KEY (PuestoID)          REFERENCES Puestos(Id),
    FOREIGN KEY (JefeID)            REFERENCES Empleados(Id)
);

-- 5. AUSENCIAS --

CREATE TABLE Ausencias (
    Id              INT             AUTO_INCREMENT PRIMARY KEY,
    EmpleadoID      INT             NOT NULL,
    TipoAusencia    VARCHAR(50)     NOT NULL,    -- Vacaciones / Enfermedad / Permiso Personal / Licencia Médica
    FechaInicio     DATE            NOT NULL,
    FechaFin        DATE            NOT NULL,
    DiasTotales     INT             GENERATED ALWAYS AS (DATEDIFF(FechaFin, FechaInicio) + 1) STORED,
    Justificada     BOOLEAN         NOT NULL,
    Comentarios     VARCHAR(200)    NULL,
    FechaCreacion   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(Id),
    CHECK (FechaFin >= FechaInicio)
);

-- 6. EVALUACIONES DE DESEMPEÑO --

CREATE TABLE Evaluaciones (
    EvaluacionID        INT             AUTO_INCREMENT PRIMARY KEY,
    EmpleadoID          INT             NOT NULL,
    FechaEvaluacion     DATE            NOT NULL,
    Calificacion        DECIMAL(3,1)    NOT NULL CHECK (Calificacion >= 1.0 AND Calificacion <= 5.0),
    EvaluadorID         INT             NOT NULL,
    Comentarios         VARCHAR(255)    NULL,
    FechaCreacion       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Empleado  FOREIGN KEY (EmpleadoID)  REFERENCES Empleados(Id),
    CONSTRAINT FK_Evaluador FOREIGN KEY (EvaluadorID) REFERENCES Empleados(Id)
);

-- 7. CAPACITACIONES --

CREATE TABLE Capacitaciones (
    CapacitacionID      INT             AUTO_INCREMENT PRIMARY KEY,
    NombreCapacitacion  VARCHAR(100)    NOT NULL,
    Descripcion         VARCHAR(255)    NULL,
    Proveedor           VARCHAR(100)    NOT NULL,
    Costo               DECIMAL(18,2)   NOT NULL,
    FechaInicio         DATE            NOT NULL,
    FechaFin            DATE            NOT NULL,
    Duracion            INT             GENERATED ALWAYS AS (DATEDIFF(FechaFin, FechaInicio) + 1) VIRTUAL,
    FechaCreacion       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (FechaFin >= FechaInicio)
);

-- 8. EMPLEADO_CAPACITACION (relación muchos a muchos) --

CREATE TABLE EmpleadoCapacitacion (
    EmpleadoID          INT             NOT NULL,
    CapacitacionID      INT             NOT NULL,
    FechaInscripcion    DATE            NOT NULL,
    FechaFinalizacion   DATE            NULL,
    Estado              VARCHAR(20)     NOT NULL,
    Calificacion        DECIMAL(5,2)    NULL CHECK (Calificacion >= 0 AND Calificacion <= 100),
    Comentarios         VARCHAR(255)    NULL,
    FechaCreacion       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (EmpleadoID, CapacitacionID),
    CONSTRAINT FK_EC_Empleado       FOREIGN KEY (EmpleadoID)
        REFERENCES Empleados(Id) ON DELETE CASCADE,
    CONSTRAINT FK_EC_Capacitacion   FOREIGN KEY (CapacitacionID)
        REFERENCES Capacitaciones(CapacitacionID) ON DELETE CASCADE
);

-- Verificación de tablas creadas --

SHOW TABLES;