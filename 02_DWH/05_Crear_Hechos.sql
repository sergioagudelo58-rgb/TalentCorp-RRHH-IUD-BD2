-- ============================================================
-- SCRIPT 05: Creación de Tablas de Hechos
-- Proyecto: TalentCorp S.A.
-- Hechos: Ausencias, Evaluaciones, Capacitaciones, Nómina
-- ============================================================

USE RRHH_DW;

-- HECHO 1: Fact_Ausencias

CREATE TABLE Fact_Ausencias (
    AusenciaKey         INT             AUTO_INCREMENT PRIMARY KEY,
    -- Claves foráneas a dimensiones
    TiempoInicioKey     INT             NOT NULL,   -- FK Dim_Tiempo
    TiempoFinKey        INT             NOT NULL,   -- FK Dim_Tiempo
    EmpleadoKey         INT             NOT NULL,   -- FK Dim_Empleado
    DepartamentoKey     INT             NOT NULL,   -- FK Dim_Departamento
    OficinaKey          INT             NOT NULL,   -- FK Dim_Oficina
    -- Clave de negocio
    AusenciaID          INT             NOT NULL,
    TipoAusencia        VARCHAR(50)     NOT NULL,
    Justificada         BOOLEAN         NOT NULL,
    -- Métricas
    DiasTotales         INT             NOT NULL,
    CostoAproximado     DECIMAL(18,2)   NOT NULL,
    -- Campo para Auditoria
    FechaCarga          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TiempoInicioKey)   REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (TiempoFinKey)      REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (EmpleadoKey)       REFERENCES Dim_Empleado(EmpleadoKey),
    FOREIGN KEY (DepartamentoKey)   REFERENCES Dim_Departamento(DepartamentoKey),
    FOREIGN KEY (OficinaKey)        REFERENCES Dim_Oficina(OficinaKey)
);

CREATE INDEX idx_FA_Tiempo      ON Fact_Ausencias(TiempoInicioKey);
CREATE INDEX idx_FA_Empleado    ON Fact_Ausencias(EmpleadoKey);
CREATE INDEX idx_FA_Tipo        ON Fact_Ausencias(TipoAusencia);

-- HECHO 2: Fact_Evaluaciones

CREATE TABLE Fact_Evaluaciones (
    EvaluacionKey       INT             AUTO_INCREMENT PRIMARY KEY,
    -- Claves foráneas a dimensiones
    TiempoKey           INT             NOT NULL,   -- FK Dim_Tiempo 
    EmpleadoKey         INT             NOT NULL,   -- FK Dim_Empleado
    EvaluadorKey        INT             NOT NULL,   -- FK Dim_Empleado
    DepartamentoKey     INT             NOT NULL,
    PuestoKey           INT             NOT NULL,
    -- Clave de negocio
    EvaluacionID        INT             NOT NULL,
    PeriodoEvaluacion   VARCHAR(20)     NOT NULL, 
    -- Métricas
    Calificacion        DECIMAL(3,1)    NOT NULL,
    CalificacionNorm    DECIMAL(5,2)    NOT NULL,  
    EsAprobado          BOOLEAN         NOT NULL,
    -- Campo para Auditoria
    FechaCarga          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TiempoKey)         REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (EmpleadoKey)       REFERENCES Dim_Empleado(EmpleadoKey),
    FOREIGN KEY (EvaluadorKey)      REFERENCES Dim_Empleado(EmpleadoKey),
    FOREIGN KEY (DepartamentoKey)   REFERENCES Dim_Departamento(DepartamentoKey),
    FOREIGN KEY (PuestoKey)         REFERENCES Dim_Puesto(PuestoKey)
);

CREATE INDEX idx_FE_Tiempo          ON Fact_Evaluaciones(TiempoKey);
CREATE INDEX idx_FE_Empleado        ON Fact_Evaluaciones(EmpleadoKey);
CREATE INDEX idx_FE_Departamento    ON Fact_Evaluaciones(DepartamentoKey);

-- HECHO 3: Fact_Capacitaciones

CREATE TABLE Fact_Capacitaciones (
    CapacitacionKey     INT             AUTO_INCREMENT PRIMARY KEY,
    -- Claves foráneas a dimensiones
    TiempoInscripKey    INT             NOT NULL,   -- FK Dim_Tiempo
    TiempoFinalKey      INT             NULL,       -- FK Dim_Tiempo
    EmpleadoKey         INT             NOT NULL,
    DepartamentoKey     INT             NOT NULL,
    -- Clave de negocio
    CapacitacionID      INT             NOT NULL,
    NombreCapacitacion  VARCHAR(100)    NOT NULL,
    Proveedor           VARCHAR(100)    NOT NULL,
    Estado              VARCHAR(20)     NOT NULL,
    -- Métricas
    CostoCapacitacion   DECIMAL(18,2)   NOT NULL,
    CalificacionObtenida DECIMAL(5,2)  NULL,        
    DuracionDias        INT             NOT NULL,
    EsAprobado          BOOLEAN         NULL,       
    -- Campo para Auditoria
    FechaCarga          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TiempoInscripKey)  REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (TiempoFinalKey)    REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (EmpleadoKey)       REFERENCES Dim_Empleado(EmpleadoKey),
    FOREIGN KEY (DepartamentoKey)   REFERENCES Dim_Departamento(DepartamentoKey)
);

CREATE INDEX idx_FC_Tiempo      ON Fact_Capacitaciones(TiempoInscripKey);
CREATE INDEX idx_FC_Empleado    ON Fact_Capacitaciones(EmpleadoKey);
CREATE INDEX idx_FC_Estado      ON Fact_Capacitaciones(Estado);

-- HECHO 4: Fact_Nomina
-- Permite análisis salarial, distribución y evolución

CREATE TABLE Fact_Nomina (
    NominaKey           INT             AUTO_INCREMENT PRIMARY KEY,
    -- Claves foráneas
    TiempoKey           INT             NOT NULL,   -- FK Dim_Tiempo
    EmpleadoKey         INT             NOT NULL,
    DepartamentoKey     INT             NOT NULL,
    PuestoKey           INT             NOT NULL,
    OficinaKey          INT             NOT NULL,
    AnioMes             INT             NOT NULL,
    -- Métricas
    Salario             DECIMAL(18,2)   NOT NULL,
    SalarioMinPuesto    DECIMAL(18,2)   NOT NULL,
    SalarioMaxPuesto    DECIMAL(18,2)   NOT NULL,
    -- Indicadores calculados en ETL
    PorcentajeEnRango   DECIMAL(5,2)    NOT NULL,   -- (Salario - Min) / (Max - Min) * 100
    DesviacionDelPromedio DECIMAL(18,2) NOT NULL,   -- Salario - Promedio del puesto
    EsActivo            BOOLEAN         NOT NULL DEFAULT TRUE,
    -- Auditoria
    FechaCarga          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TiempoKey)         REFERENCES Dim_Tiempo(TiempoKey),
    FOREIGN KEY (EmpleadoKey)       REFERENCES Dim_Empleado(EmpleadoKey),
    FOREIGN KEY (DepartamentoKey)   REFERENCES Dim_Departamento(DepartamentoKey),
    FOREIGN KEY (PuestoKey)         REFERENCES Dim_Puesto(PuestoKey),
    FOREIGN KEY (OficinaKey)        REFERENCES Dim_Oficina(OficinaKey),
    -- Para Evitar duplicados: un empleado solo puede tener un registro por mes
    UNIQUE KEY uk_Nomina (EmpleadoKey, TiempoKey)
);

CREATE INDEX idx_FN_Tiempo          ON Fact_Nomina(TiempoKey);
CREATE INDEX idx_FN_Empleado        ON Fact_Nomina(EmpleadoKey);
CREATE INDEX idx_FN_AnioMes         ON Fact_Nomina(AnioMes);
CREATE INDEX idx_FN_Departamento    ON Fact_Nomina(DepartamentoKey);

SELECT 'Tablas de Hechos creadas correctamente' AS Resultado;
SHOW TABLES LIKE 'Fact_%';