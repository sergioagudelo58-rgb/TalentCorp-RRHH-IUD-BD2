-- ============================================================
-- SCRIPT 04: Creación de Dimensiones con SCD Tipo 2
-- Proyecto: TalentCorp S.A.
-- Dimensiones: Tiempo, Empleado, Departamento, Puesto, Oficina
-- SCD Tipo 2 en: Empleado, Departamento, Puesto, Oficina
-- ============================================================

USE RRHH_DW;

-- DIMENSIÓN 1: Dim_Tiempo

CREATE TABLE Dim_Tiempo (
    TiempoKey       INT             PRIMARY KEY,     
    Fecha           DATE            NOT NULL UNIQUE,
    Anio            INT             NOT NULL,
    Trimestre       INT             NOT NULL,        
    NombreTrimestre VARCHAR(10)     NOT NULL,        
    Mes             INT             NOT NULL,        
    NombreMes       VARCHAR(20)     NOT NULL,        
    AbreviaturaMes  VARCHAR(5)      NOT NULL,        
    Semana          INT             NOT NULL,        
    DiaMes          INT             NOT NULL,        
    DiaSemana       INT             NOT NULL,        
    NombreDiaSemana VARCHAR(15)     NOT NULL,        
    EsFinDeSemana   BOOLEAN         NOT NULL,
    EsFestivoColombia BOOLEAN       NOT NULL DEFAULT FALSE,
    AnioMes         INT             NOT NULL,        
    AnioTrimestre   VARCHAR(10)     NOT NULL         
);

-- DIMENSIÓN 2: Dim_Empleado (SCD Tipo 2)
-- Rastrea cambios en: Departamento, Puesto, Salario, Oficina, Jefe

CREATE TABLE Dim_Empleado (
    EmpleadoKey         INT             AUTO_INCREMENT PRIMARY KEY,
    EmpleadoID          INT             NOT NULL,
    Nombres             VARCHAR(50)     NOT NULL,
    Apellidos           VARCHAR(50)     NOT NULL,
    NombreCompleto      VARCHAR(105)    NOT NULL,
    FechaNacimiento     DATE            NOT NULL,
    Genero              VARCHAR(10)     NOT NULL,
    EstadoCivil         VARCHAR(20)     NOT NULL,
    Email               VARCHAR(100)    NOT NULL,
    Telefono            VARCHAR(20)     NOT NULL,
    FechaContratacion   DATE            NOT NULL,
    DepartamentoNombre  VARCHAR(50)     NOT NULL,
    PuestoNombre        VARCHAR(50)     NOT NULL,
    NivelSalarial       VARCHAR(30)     NOT NULL,
    OficinaCiudad       VARCHAR(50)     NOT NULL,
    OficinaPais         VARCHAR(50)     NOT NULL,
    Salario             DECIMAL(18,2)   NOT NULL,
    NombreJefe          VARCHAR(105)    NULL,
    FechaInicioVigencia DATE            NOT NULL,
    FechaFinVigencia    DATE            NULL,
    EsActual            BOOLEAN         NOT NULL DEFAULT TRUE,
    VersionRegistro     INT             NOT NULL DEFAULT 1,
    FechaCarga          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Índices para búsquedas frecuentes
CREATE INDEX idx_DimEmpleado_ID        ON Dim_Empleado(EmpleadoID);
CREATE INDEX idx_DimEmpleado_Activo    ON Dim_Empleado(EmpleadoID, EsActual);
CREATE INDEX idx_DimEmpleado_Vigencia  ON Dim_Empleado(FechaInicioVigencia, FechaFinVigencia);

-- DIMENSIÓN 3: Dim_Departamento (SCD Tipo 2)
-- Rastrea cambios en: Nombre, Descripción, Oficina

CREATE TABLE Dim_Departamento (
    DepartamentoKey     INT             AUTO_INCREMENT PRIMARY KEY,
    DepartamentoID      INT             NOT NULL,
    NombreDpto          VARCHAR(50)     NOT NULL,
    Descripcion         VARCHAR(255)    NULL,
    OficinaCiudad       VARCHAR(50)     NOT NULL,
    OficinaPais         VARCHAR(50)     NOT NULL,
    FechaInicioVigencia DATE            NOT NULL,
    FechaFinVigencia    DATE            NULL,
    EsActual            BOOLEAN         NOT NULL DEFAULT TRUE,
    VersionRegistro     INT             NOT NULL DEFAULT 1,
    FechaCarga          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_DimDpto_ID     ON Dim_Departamento(DepartamentoID);
CREATE INDEX idx_DimDpto_Activo ON Dim_Departamento(DepartamentoID, EsActual);

-- DIMENSIÓN 4: Dim_Puesto (SCD Tipo 2)
-- Rastrea cambios en: Nombre, NivelSalarial, SalarioMin, SalarioMax

CREATE TABLE Dim_Puesto (
    PuestoKey           INT             AUTO_INCREMENT PRIMARY KEY,
    PuestoID            INT             NOT NULL,
    NombrePuesto        VARCHAR(50)     NOT NULL,
    NivelSalarial       VARCHAR(60)     NOT NULL,
    SalarioMinimo       DECIMAL(18,2)   NOT NULL,
    SalarioMaximo       DECIMAL(18,2)   NOT NULL,
    RangaSalarial       VARCHAR(50)     NOT NULL,
    FechaInicioVigencia DATE            NOT NULL,
    FechaFinVigencia    DATE            NULL,
    EsActual            BOOLEAN         NOT NULL DEFAULT TRUE,
    VersionRegistro     INT             NOT NULL DEFAULT 1,
    FechaCarga          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_DimPuesto_ID     ON Dim_Puesto(PuestoID);
CREATE INDEX idx_DimPuesto_Activo ON Dim_Puesto(PuestoID, EsActual);

-- DIMENSIÓN 5: Dim_Oficina (SCD Tipo 2)
-- Rastrea cambios en: Dirección, Teléfono, Ciudad, País

CREATE TABLE Dim_Oficina (
    OficinaKey          INT             AUTO_INCREMENT PRIMARY KEY,
    OficinaID           INT             NOT NULL,
    CodigoOficina       VARCHAR(20)     NOT NULL,
    Ciudad              VARCHAR(50)     NOT NULL,
    Pais                VARCHAR(50)     NOT NULL,
    Region              VARCHAR(50)     NOT NULL,
    CodigoPostal        VARCHAR(20)     NOT NULL,
    Telefono            VARCHAR(20)     NOT NULL,
    Direccion           VARCHAR(255)    NOT NULL,
    FechaInicioVigencia DATE            NOT NULL,
    FechaFinVigencia    DATE            NULL,
    EsActual            BOOLEAN         NOT NULL DEFAULT TRUE,
    VersionRegistro     INT             NOT NULL DEFAULT 1,
    FechaCarga          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_DimOficina_ID     ON Dim_Oficina(OficinaID);
CREATE INDEX idx_DimOficina_Activo ON Dim_Oficina(OficinaID, EsActual);

-- Verificación
SELECT 'Dimensiones creadas correctamente' AS Resultado;
SHOW TABLES LIKE 'Dim_%';