-- ============================================================
-- SCRIPT 02: Poblar BD Operacional RRHH (OLTP)
-- Proyecto: TalentCorp S.A.
-- ============================================================

USE RRHH;

-- 1. OFICINAS

INSERT INTO Oficinas (CodigoOficina, Ciudad, Pais, Region, CodigoPostal, Telefono, Direccion) VALUES
('BOG-NORTE', 'Bogotá', 'Colombia', 'Cundinamarca', '110111', '+57-1-3001000', 'Calle 100 #15-20, Piso 8'),
('BOG-SUR', 'Bogotá', 'Colombia', 'Cundinamarca', '111611', '+57-1-3002000', 'Autopista Sur #40-80, Oficina 301'),
('MED-CENTRO', 'Medellín', 'Colombia', 'Antioquia', '050001', '+57-4-4441000', 'Carrera 43A #1-50, Torre Empresarial'),
('CAL-NORTE', 'Cali', 'Colombia', 'Valle del Cauca', '760001', '+57-2-5551000', 'Av. 6 Norte #25-30'),
('BAR-CENTRO', 'Barranquilla', 'Colombia', 'Atlántico', '080001', '+57-5-3501000', 'Calle 72 #54-35'),
('CAR-BOCAGRANDE', 'Cartagena', 'Colombia', 'Bolívar', '130001', '+57-5-6501000', 'Av. San Martín #7-120'),
('BUC-CENTRO', 'Bucaramanga', 'Colombia', 'Santander', '680001', '+57-7-6301000', 'Carrera 27 #36-14'),
('PER-CENTRO', 'Pereira', 'Colombia', 'Risaralda', '660001', '+57-6-3401000', 'Calle 19 #8-34');

-- 2. DEPARTAMENTOS

INSERT INTO Departamentos (NombreDpto, Descripcion, OficinaID) VALUES
('Recursos Humanos', 'Gestión del talento, nómina y bienestar', 1),
('Tecnología', 'Desarrollo de software y soporte tecnológico', 1),
('Ventas', 'Gestión comercial, clientes y cumplimiento de cuotas de venta', 2),
('Finanzas', 'Contabilidad, tesorería, presupuesto y control financiero', 1),
('Marketing', 'Estrategia de marca y publicidad digital', 3);

-- 3. PUESTOS

INSERT INTO Puestos (Nombre, NivelSalarial, SalarioMinimo, SalarioMaximo) VALUES
('Gerente RRHH',           'Senior',    6000000.00, 12000000.00),
('Analista RRHH',          'Mid-Level', 2500000.00,  4500000.00),
('Auxiliar RRHH',          'Junior',    1800000.00,  2800000.00),
('Gerente de Tecnología',  'Senior',    8000000.00, 18000000.00),
('Desarrollador Senior',   'Senior',    7000000.00, 15000000.00),
('Desarrollador Junior',   'Junior',    2500000.00,  4500000.00),
('Gerente de Ventas',      'Senior',    6000000.00, 12000000.00),
('Analista de Ventas',     'Mid-Level', 2200000.00,  4200000.00),
('Gerente de Finanzas',    'Senior',    7000000.00, 15000000.00),
('Analista Financiero',    'Mid-Level', 3000000.00,  5500000.00),
('Gerente de Marketing',   'Senior',    6000000.00, 11000000.00),
('Analista de Marketing',  'Mid-Level', 2200000.00,  4200000.00);

-- 4. EMPLEADOS
-- Primero se insertan jefes (JefeID = NULL), luego el resto

-- Gerentes / Jefes
INSERT INTO Empleados (Nombres, Apellidos, FechaNacimiento, Genero, EstadoCivil, Email, Telefono, FechaContratacion, DepartamentoID, OficinaID, PuestoID, JefeID, Salario) VALUES
('Laura','Martínez','1980-03-15','Femenino','Casada','laura.martinez@talentcorp.com','3001111111','2018-01-10',1,1,1,NULL,11500000.00),
('Andrés','Ospina','1978-07-22','Masculino','Casado','andres.ospina@talentcorp.com','3002222222','2017-03-01',2,1,4,NULL,16500000.00),
('Claudia','Herrera','1982-11-08','Femenino','Soltera','claudia.herrera@talentcorp.com','3003333333','2019-02-15',3,2,7,NULL,11000000.00),
('Jorge','Ramírez','1976-05-30','Masculino','Casado','jorge.ramirez@talentcorp.com','3004444444','2016-06-01',4,1,9,NULL,14500000.00),
('Sofía','Valencia','1984-09-12','Femenino','Casada','sofia.valencia@talentcorp.com','3005555555','2020-01-05',5,3,11,NULL,10000000.00);

-- RRHH
INSERT INTO Empleados (Nombres, Apellidos, FechaNacimiento, Genero, EstadoCivil, Email, Telefono, FechaContratacion, DepartamentoID, OficinaID, PuestoID, JefeID, Salario) VALUES
('Camila','Gómez','1992-04-18','Femenino','Soltera','camila.gomez@talentcorp.com','3101111111','2021-03-01',1,1,2,1,4200000.00),
('Felipe','Torres','1990-08-25','Masculino','Soltero','felipe.torres@talentcorp.com','3102222222','2021-07-15',1,1,2,1,4400000.00),
('Marcela','Ríos','1995-01-30','Femenino','Soltera','marcela.rios@talentcorp.com','3103333333','2022-02-01',1,1,3,1,2600000.00),
('Sebastián','Cruz','1993-06-14','Masculino','Casado','sebastian.cruz@talentcorp.com','3104444444','2022-08-10',1,4,3,1,2500000.00),
('Diana','Morales','1991-12-05','Femenino','Casada','diana.morales@talentcorp.com','3105555555','2020-11-01',1,1,2,1,4500000.00),
('Juan','Castillo','1994-09-12','Masculino','Soltero','juan.castillo@talentcorp.com','3111111111','2022-05-10',1,1,2,1,4000000.00),
('Paola','Herrera','1996-03-27','Femenino','Soltera','paola.herrera@talentcorp.com','3112222222','2023-01-15',1,2,3,1,2400000.00),
('Andrés','Vega','1991-11-05','Masculino','Casado','andres.vega@talentcorp.com','3113333333','2021-09-01',1,3,2,1,4300000.00);

-- Tecnología
INSERT INTO Empleados (Nombres, Apellidos, FechaNacimiento, Genero, EstadoCivil, Email, Telefono, FechaContratacion, DepartamentoID, OficinaID, PuestoID, JefeID, Salario) VALUES
('Carlos','Mendoza','1988-03-22','Masculino','Casado','carlos.mendoza@talentcorp.com','3201111111','2019-05-01',2,1,5,2,12500000.00),
('Valentina','Cárdenas','1991-07-15','Femenino','Soltera','valentina.cardenas@talentcorp.com','3202222222','2020-02-15',2,1,5,2,11000000.00),
('Daniel','Pereira','1994-11-08','Masculino','Soltero','daniel.pereira@talentcorp.com','3203333333','2021-01-10',2,1,6,2,4200000.00),
('Alejandra','Suárez','1996-04-25','Femenino','Soltera','alejandra.suarez@talentcorp.com','3204444444','2021-09-01',2,1,6,2,4000000.00),
('Ricardo','Jiménez','1989-08-18','Masculino','Casado','ricardo.jimenez@talentcorp.com','3205555555','2019-11-15',2,5,5,2,12000000.00),
('Natalia','Vargas','1992-02-10','Femenino','Casada','natalia.vargas@talentcorp.com','3206666666','2020-06-01',2,1,5,2,10500000.00),
('Esteban','Muñoz','1997-06-30','Masculino','Soltero','esteban.munoz@talentcorp.com','3207777777','2022-03-15',2,1,6,2,3800000.00),
('Paola','Castillo','1995-10-22','Femenino','Soltera','paola.castillo@talentcorp.com','3208888888','2022-07-01',2,6,6,2,4100000.00),
('Mateo','Aguilar','1998-01-14','Masculino','Soltero','mateo.aguilar@talentcorp.com','3209999999','2023-01-10',2,1,6,2,3500000.00),
('Isabel','Rojas','1990-05-07','Femenino','Casada','isabel.rojas@talentcorp.com','3210101010','2019-08-01',2,7,5,2,11500000.00);

-- Ventas
INSERT INTO Empleados (Nombres, Apellidos, FechaNacimiento, Genero, EstadoCivil, Email, Telefono, FechaContratacion, DepartamentoID, OficinaID, PuestoID, JefeID, Salario) VALUES
('Julián','Parra','1987-09-03','Masculino','Casado','julian.parra@talentcorp.com','3301111111','2018-04-01',3,2,8,3,4200000.00),
('Andrea','Espinosa','1990-12-18','Femenino','Casada','andrea.espinosa@talentcorp.com','3302222222','2019-01-15',3,2,8,3,4500000.00),
('Tomás','Restrepo','1993-04-25','Masculino','Soltero','tomas.restrepo@talentcorp.com','3303333333','2020-07-01',3,2,8,3,4000000.00),
('Luisa','Bermúdez','1991-08-10','Femenino','Soltera','luisa.bermudez@talentcorp.com','3304444444','2021-02-15',3,4,8,3,3800000.00),
('Mauricio','Salazar','1988-01-28','Masculino','Casado','mauricio.salazar@talentcorp.com','3305555555','2018-10-01',3,2,8,3,4800000.00),
('Gabriela','Ortiz','1994-05-15','Femenino','Soltera','gabriela.ortiz@talentcorp.com','3306666666','2022-04-01',3,3,8,3,3500000.00),
('Santiago','Mejía','1996-09-20','Masculino','Soltero','santiago.mejia@talentcorp.com','3307777777','2022-09-15',3,2,8,3,3300000.00),
('Viviana','López','1992-11-07','Femenino','Casada','viviana.lopez@talentcorp.com','3308888888','2020-03-01',3,2,8,3,4100000.00),
('Nicolás','Castro','1989-03-14','Masculino','Casado','nicolas.castro@talentcorp.com','3309999999','2019-06-01',3,4,8,3,4400000.00),
('Paula','Acosta','1995-07-28','Femenino','Soltera','paula.acosta@talentcorp.com','3310101010','2023-03-01',3,2,8,3,3000000.00);

-- Finanzas
INSERT INTO Empleados (Nombres, Apellidos, FechaNacimiento, Genero, EstadoCivil, Email, Telefono, FechaContratacion, DepartamentoID, OficinaID, PuestoID, JefeID, Salario) VALUES
('Roberto','Navarro','1985-02-10','Masculino','Casado','roberto.navarro@talentcorp.com','3401111111','2017-09-01',4,1,10,4,5400000.00),
('Patricia','Mora','1988-06-25','Femenino','Casada','patricia.mora@talentcorp.com','3402222222','2018-12-01',4,1,10,4,5200000.00),
('Alejandro','Silva','1991-10-14','Masculino','Soltero','alejandro.silva@talentcorp.com','3403333333','2020-05-01',4,1,10,4,4800000.00),
('Carolina','Medina','1993-03-08','Femenino','Soltera','carolina.medina@talentcorp.com','3404444444','2021-01-15',4,1,10,4,4600000.00),
('Hernando','Pineda','1987-07-19','Masculino','Casado','hernando.pineda@talentcorp.com','3405555555','2019-03-01',4,1,10,4,5000000.00),
('Beatriz','Guerrero','1990-11-30','Femenino','Casada','beatriz.guerrero@talentcorp.com','3406666666','2020-08-15',4,5,10,4,4900000.00),
('Álvaro','Ángel','1994-04-22','Masculino','Soltero','alvaro.angel@talentcorp.com','3407777777','2022-06-01',4,1,10,4,4200000.00),
('Mónica','Sepúlveda','1992-08-16','Femenino','Casada','monica.sepulveda@talentcorp.com','3408888888','2021-11-01',4,1,10,4,4700000.00);

-- Marketing
INSERT INTO Empleados (Nombres, Apellidos, FechaNacimiento, Genero, EstadoCivil, Email, Telefono, FechaContratacion, DepartamentoID, OficinaID, PuestoID, JefeID, Salario) VALUES
('Ximena','Ramos','1989-05-04','Femenino','Casada','ximena.ramos@talentcorp.com','3501111111','2020-04-01',5,3,12,5,4200000.00),
('Guillermo','Sandoval','1992-09-17','Masculino','Soltero','guillermo.sandoval@talentcorp.com','3502222222','2020-10-15',5,3,12,5,4000000.00),
('Tatiana','Fuentes','1994-01-28','Femenino','Soltera','tatiana.fuentes@talentcorp.com','3503333333','2021-05-01',5,3,12,5,3800000.00),
('Rodrigo','Pinto','1991-06-11','Masculino','Casado','rodrigo.pinto@talentcorp.com','3504444444','2021-08-15',5,3,12,5,3900000.00),
('Fernanda','Cabrera','1996-10-24','Femenino','Soltera','fernanda.cabrera@talentcorp.com','3505555555','2022-01-10',5,3,12,5,3500000.00),
('Iván','Montoya','1988-02-15','Masculino','Casado','ivan.montoya@talentcorp.com','3506666666','2020-07-01',5,3,12,5,4300000.00),
('Lina','Castellanos','1993-07-06','Femenino','Soltera','lina.castellanos@talentcorp.com','3507777777','2021-12-01',5,3,12,5,3700000.00),
('Cristian','Orozco','1997-11-19','Masculino','Soltero','cristian.orozco@talentcorp.com','3508888888','2023-06-01',5,3,12,5,3200000.00),
('Manuela','Vergara','1990-04-30','Femenino','Casada','manuela.vergara@talentcorp.com','3509999999','2020-09-15',5,3,12,5,4100000.00),
('Sergio','Quintero','1985-08-22','Masculino','Casado','sergio.quintero@talentcorp.com','3510101010','2019-02-01',5,3,12,5,4500000.00);

SELECT * FROM empleados;

-- 5. AUSENCIAS (Año 2023-2024)

INSERT INTO Ausencias (EmpleadoID, TipoAusencia, FechaInicio, FechaFin, Justificada, Comentarios) VALUES
-- 2023
(1,  'Vacaciones',       '2023-01-09', '2023-01-20', TRUE,  'Vacaciones anuales aprobadas'),
(2,  'Vacaciones',       '2023-02-06', '2023-02-17', TRUE,  'Vacaciones planificadas'),
(3,  'Vacaciones',       '2023-01-23', '2023-02-03', TRUE,  'Período vacacional'),
(4,  'Vacaciones',       '2023-03-06', '2023-03-17', TRUE,  'Vacaciones primer semestre'),
(5,  'Vacaciones',       '2023-04-03', '2023-04-14', TRUE,  'Semana Santa y vacaciones'),
(6,  'Enfermedad',       '2023-01-16', '2023-01-18', TRUE,  'Gripa con incapacidad médica'),
(7,  'Permiso Personal', '2023-02-13', '2023-02-13', FALSE, NULL),
(8,  'Enfermedad',       '2023-03-06', '2023-03-10', TRUE,  'Gastroenteritis'),
(9,  'Licencia Médica',  '2023-04-17', '2023-05-12', TRUE,  'Cirugía programada - recuperación'),
(10, 'Vacaciones',       '2023-05-22', '2023-06-02', TRUE,  'Vacaciones aprobadas'),
(11, 'Enfermedad',       '2023-01-09', '2023-01-11', TRUE,  'Diagnóstico respiratorio'),
(12, 'Vacaciones',       '2023-06-26', '2023-07-07', TRUE,  'Vacaciones mitad de año'),
(13, 'Permiso Personal', '2023-02-06', '2023-02-07', FALSE, NULL),
(14, 'Enfermedad',       '2023-03-20', '2023-03-22', TRUE,  'Malestar general'),
(15, 'Vacaciones',       '2023-07-24', '2023-08-04', TRUE,  'Vacaciones de verano'),
(16, 'Licencia Médica',  '2023-05-08', '2023-06-02', TRUE,  'Licencia de maternidad parcial'),
(17, 'Vacaciones',       '2023-08-21', '2023-09-01', TRUE,  'Vacaciones tercer trimestre'),
(18, 'Enfermedad',       '2023-04-10', '2023-04-12', TRUE,  'Infección viral'),
(19, 'Permiso Personal', '2023-05-15', '2023-05-15', TRUE,  'Diligencia bancaria urgente'),
(20, 'Vacaciones',       '2023-09-18', '2023-09-29', TRUE,  'Vacaciones anuales'),
(21, 'Enfermedad',       '2023-06-05', '2023-06-07', TRUE,  'COVID-19 confirmado'),
(22, 'Vacaciones',       '2023-10-16', '2023-10-27', TRUE,  'Vacaciones fin de año anticipadas'),
(23, 'Permiso Personal', '2023-07-03', '2023-07-04', FALSE, NULL),
(24, 'Enfermedad',       '2023-08-14', '2023-08-16', TRUE,  'Dolor lumbar agudo'),
(25, 'Vacaciones',       '2023-11-13', '2023-11-24', TRUE,  'Vacaciones aprobadas'),
(26, 'Licencia Médica',  '2023-09-04', '2023-09-29', TRUE,  'Fractura de muñeca - recuperación'),
(27, 'Vacaciones',       '2023-12-11', '2023-12-22', TRUE,  'Vacaciones diciembre'),
(28, 'Enfermedad',       '2023-10-09', '2023-10-11', TRUE,  'Gastritis severa'),
(29, 'Permiso Personal', '2023-11-06', '2023-11-06', FALSE, NULL),
(30, 'Vacaciones',       '2023-01-16', '2023-01-27', TRUE,  'Vacaciones inicio de año'),
(31, 'Enfermedad',       '2023-12-04', '2023-12-06', TRUE,  'Bronquitis aguda'),
(32, 'Vacaciones',       '2023-02-20', '2023-03-03', TRUE,  'Vacaciones primer semestre'),
(33, 'Permiso Personal', '2023-03-13', '2023-03-14', TRUE,  'Evento familiar urgente'),
(34, 'Enfermedad',       '2023-04-24', '2023-04-26', TRUE,  'Infección de vías urinarias'),
(35, 'Vacaciones',       '2023-05-29', '2023-06-09', TRUE,  'Vacaciones aprobadas'),
(36, 'Licencia Médica',  '2023-07-17', '2023-08-11', TRUE,  'Licencia por paternidad extendida'),
(37, 'Vacaciones',       '2023-08-28', '2023-09-08', TRUE,  'Vacaciones agosto'),
(38, 'Enfermedad',       '2023-09-18', '2023-09-20', TRUE,  'Resfriado común con fiebre'),
(39, 'Permiso Personal', '2023-10-23', '2023-10-24', FALSE, NULL),
(40, 'Vacaciones',       '2023-11-20', '2023-12-01', TRUE,  'Vacaciones fin de año'),
(41, 'Enfermedad',       '2023-01-23', '2023-01-25', TRUE,  'Alergia respiratoria'),
(42, 'Vacaciones',       '2023-03-27', '2023-04-07', TRUE,  'Semana Santa'),
(43, 'Permiso Personal', '2023-05-22', '2023-05-22', FALSE, NULL),
(44, 'Enfermedad',       '2023-06-19', '2023-06-21', TRUE,  'Conjuntivitis viral'),
(45, 'Vacaciones',       '2023-07-31', '2023-08-11', TRUE,  'Vacaciones julio'),
(46, 'Licencia Médica',  '2023-09-11', '2023-10-06', TRUE,  'Cirugía de emergencia'),
(47, 'Vacaciones',       '2023-10-30', '2023-11-10', TRUE,  'Vacaciones cuarto trimestre'),
(48, 'Enfermedad',       '2023-12-11', '2023-12-13', TRUE,  'Amigdalitis bacteriana'),
(49, 'Permiso Personal', '2023-02-27', '2023-02-28', FALSE, NULL),
(50, 'Vacaciones',       '2023-04-24', '2023-05-05', TRUE,  'Vacaciones aprobadas'),
(51, 'Enfermedad',       '2023-06-26', '2023-06-28', TRUE,  'Migraña intensa'),

-- 2024
(1,  'Vacaciones',       '2024-01-08', '2024-01-19', TRUE,  'Vacaciones anuales 2024'),
(2,  'Enfermedad',       '2024-02-05', '2024-02-07', TRUE,  'Gripa estacional'),
(3,  'Vacaciones',       '2024-03-04', '2024-03-15', TRUE,  'Vacaciones primer semestre'),
(4,  'Permiso Personal', '2024-04-08', '2024-04-09', FALSE, NULL),
(5,  'Vacaciones',       '2024-05-06', '2024-05-17', TRUE,  'Vacaciones aprobadas'),
(6,  'Licencia Médica',  '2024-01-15', '2024-02-09', TRUE,  'Reposo médico post-operatorio'),
(7,  'Vacaciones',       '2024-02-19', '2024-03-01', TRUE,  'Vacaciones aprobadas'),
(8,  'Enfermedad',       '2024-03-18', '2024-03-20', TRUE,  'Gastroenteritis aguda'),
(9,  'Vacaciones',       '2024-04-22', '2024-05-03', TRUE,  'Vacaciones primer semestre'),
(10, 'Permiso Personal', '2024-05-27', '2024-05-28', FALSE, NULL),
(11, 'Vacaciones',       '2024-06-10', '2024-06-21', TRUE,  'Vacaciones mitad de año'),
(12, 'Enfermedad',       '2024-02-12', '2024-02-14', TRUE,  'Infección respiratoria'),
(13, 'Vacaciones',       '2024-07-08', '2024-07-19', TRUE,  'Vacaciones julio 2024'),
(14, 'Licencia Médica',  '2024-03-25', '2024-04-19', TRUE,  'Reposo por embarazo de alto riesgo'),
(15, 'Vacaciones',       '2024-08-05', '2024-08-16', TRUE,  'Vacaciones agosto'),
(16, 'Enfermedad',       '2024-05-13', '2024-05-15', TRUE,  'Sinusitis aguda'),
(17, 'Permiso Personal', '2024-06-03', '2024-06-04', TRUE,  'Graduación familiar'),
(18, 'Vacaciones',       '2024-09-02', '2024-09-13', TRUE,  'Vacaciones tercer trimestre'),
(19, 'Enfermedad',       '2024-07-15', '2024-07-17', TRUE,  'COVID-19 positivo'),
(20, 'Vacaciones',       '2024-10-07', '2024-10-18', TRUE,  'Vacaciones octubre'),
(21, 'Licencia Médica',  '2024-08-19', '2024-09-13', TRUE,  'Fractura de clavícula'),
(22, 'Vacaciones',       '2024-11-04', '2024-11-15', TRUE,  'Vacaciones noviembre'),
(23, 'Enfermedad',       '2024-09-23', '2024-09-25', TRUE,  'Malestar digestivo'),
(24, 'Permiso Personal', '2024-10-14', '2024-10-15', FALSE, NULL),
(25, 'Vacaciones',       '2024-12-02', '2024-12-13', TRUE,  'Vacaciones diciembre'),
(26, 'Enfermedad',       '2024-01-22', '2024-01-24', TRUE,  'Resfriado con fiebre'),
(27, 'Vacaciones',       '2024-03-11', '2024-03-22', TRUE,  'Vacaciones aprobadas'),
(28, 'Permiso Personal', '2024-04-29', '2024-04-30', FALSE, NULL),
(29, 'Vacaciones',       '2024-06-17', '2024-06-28', TRUE,  'Vacaciones mitad de año'),
(30, 'Enfermedad',       '2024-07-29', '2024-07-31', TRUE,  'Dolor de espalda agudo'),
(31, 'Vacaciones',       '2024-09-09', '2024-09-20', TRUE,  'Vacaciones tercer trimestre'),
(32, 'Licencia Médica',  '2024-05-20', '2024-06-14', TRUE,  'Licencia de maternidad'),
(33, 'Vacaciones',       '2024-10-21', '2024-11-01', TRUE,  'Vacaciones aprobadas'),
(34, 'Enfermedad',       '2024-08-26', '2024-08-28', TRUE,  'Infección viral aguda'),
(35, 'Permiso Personal', '2024-12-02', '2024-12-03', TRUE,  'Diligencia judicial'),
(36, 'Vacaciones',       '2024-02-26', '2024-03-08', TRUE,  'Vacaciones primer trimestre'),
(37, 'Enfermedad',       '2024-04-15', '2024-04-17', TRUE,  'Alergia severa'),
(38, 'Vacaciones',       '2024-07-22', '2024-08-02', TRUE,  'Vacaciones julio'),
(39, 'Permiso Personal', '2024-09-16', '2024-09-17', FALSE, NULL),
(40, 'Vacaciones',       '2024-11-18', '2024-11-29', TRUE,  'Vacaciones fin de año'),
(41, 'Enfermedad',       '2024-01-29', '2024-01-31', TRUE,  'Bronquitis'),
(42, 'Vacaciones',       '2024-03-18', '2024-03-29', TRUE,  'Semana Santa 2024'),
(43, 'Licencia Médica',  '2024-06-24', '2024-07-19', TRUE,  'Cirugía programada - rodilla'),
(44, 'Vacaciones',       '2024-08-12', '2024-08-23', TRUE,  'Vacaciones agosto'),
(45, 'Enfermedad',       '2024-10-07', '2024-10-09', TRUE,  'Otitis media'),
(46, 'Permiso Personal', '2024-11-11', '2024-11-12', FALSE, NULL),
(47, 'Vacaciones',       '2024-12-16', '2024-12-27', TRUE,  'Vacaciones navideñas'),
(48, 'Enfermedad',       '2024-05-06', '2024-05-08', TRUE,  'Fiebre viral'),
(49, 'Vacaciones',       '2024-09-30', '2024-10-11', TRUE,  'Vacaciones cuarto trimestre'),
(50, 'Permiso Personal', '2024-07-08', '2024-07-09', FALSE, NULL),
(51, 'Vacaciones',       '2024-11-25', '2024-12-06', TRUE,  'Vacaciones fin de año');

-- 6. EVALUACIONES, Evaluadores = Jefes directos

INSERT INTO Evaluaciones (EmpleadoID, FechaEvaluacion, Calificacion, EvaluadorID, Comentarios) VALUES
-- Evaluados por Laura (ID 1) -- jefa de RRHH
(6,  '2023-06-30', 4.2, 1, 'Excelente gestión de procesos de selección. Proactiva y organizada.'),
(7,  '2023-06-30', 3.8, 1, 'Buen desempeño en nómina. Debe mejorar comunicación con otras áreas.'),
(8,  '2023-06-30', 3.5, 1, 'Cumple con las tareas asignadas. Necesita mayor iniciativa.'),
(9,  '2023-06-30', 3.2, 1, 'En proceso de adaptación. Puntual y responsable.'),
(10, '2023-06-30', 4.5, 1, 'Desempeño sobresaliente en bienestar laboral. Muy valorada.'),
(6,  '2023-12-31', 4.4, 1, 'Mantuvo alto rendimiento segundo semestre. Lidera proyectos.'),
(7,  '2023-12-31', 4.0, 1, 'Mejora notable en comunicación y trabajo en equipo.'),
(8,  '2023-12-31', 3.7, 1, 'Progreso constante. Completó capacitaciones requeridas.'),
(9,  '2023-12-31', 3.5, 1, 'Ha mejorado su integración. Cumple objetivos.'),
(10, '2023-12-31', 4.7, 1, 'Referente del departamento. Gestiona clima laboral excepcional.'),
(6,  '2024-06-30', 4.5, 1, 'Lideró la implementación del nuevo proceso de onboarding exitosamente.'),
(7,  '2024-06-30', 4.1, 1, 'Automatizó reportes de nómina. Gran aporte tecnológico.'),
(8,  '2024-06-30', 3.9, 1, 'Significativa mejora. Apoya en proyectos de mayor complejidad.'),
(9,  '2024-06-30', 3.8, 1, 'Crecimiento sostenido. Maneja bien la presión.'),
(10, '2024-06-30', 4.8, 1, 'Impacto muy positivo en cultura organizacional.'),

-- Evaluados por Andrés (ID 2) -- jefe de Tecnología
(11, '2023-06-30', 4.6, 2, 'Arquitectura de microservicios excelente. Referente técnico del equipo.'),
(12, '2023-06-30', 4.3, 2, 'Gran habilidad en desarrollo frontend. Entrega de calidad.'),
(13, '2023-06-30', 3.4, 2, 'Aprendizaje rápido. Buen manejo de tecnologías nuevas.'),
(14, '2023-06-30', 3.1, 2, 'Cumple entregas. Requiere reforzar buenas prácticas de código.'),
(15, '2023-06-30', 4.4, 2, 'Excelente en desarrollo backend. Soluciona problemas complejos.'),
(16, '2023-06-30', 4.0, 2, 'Muy buena ingeniería de software. Aporta soluciones innovadoras.'),
(17, '2023-06-30', 3.3, 2, 'En proceso de aprendizaje. Actitud positiva y disposición.'),
(18, '2023-06-30', 3.6, 2, 'Buen nivel técnico. Completa tareas en tiempo y forma.'),
(19, '2023-06-30', 2.9, 2, 'Requiere acompañamiento. Curva de aprendizaje más lenta.'),
(20, '2023-06-30', 4.7, 2, 'Habilidades full-stack destacadas. Muy valiosa para el equipo.'),
(11, '2023-12-31', 4.8, 2, 'Lideró migración a la nube exitosamente. Resultados sobresalientes.'),
(12, '2023-12-31', 4.5, 2, 'Implementó nuevo sistema de diseño. Excelente trabajo.'),
(13, '2023-12-31', 3.7, 2, 'Mejora sostenida. Ya trabaja con autonomía en módulos medios.'),
(14, '2023-12-31', 3.4, 2, 'Progreso en calidad de código. Completó cursos de buenas prácticas.'),
(15, '2023-12-31', 4.6, 2, 'Excelente cierre de año. Líder técnico informal del equipo.'),
(16, '2023-12-31', 4.2, 2, 'Contribuciones técnicas de alto nivel. Muy motivado.'),
(17, '2023-12-31', 3.5, 2, 'Mejor integración. Contribuye en code reviews.'),
(18, '2023-12-31', 3.8, 2, 'Avance notable en productividad y calidad.'),
(19, '2023-12-31', 3.2, 2, 'Ha mejorado con mentoría. Necesita continuar reforzando.'),
(20, '2023-12-31', 4.9, 2, 'La mejor evaluación del semestre. Impacto excepcional.'),
(11, '2024-06-30', 4.9, 2, 'Obtuvo certificación AWS. Referente en el área tecnológica.'),
(12, '2024-06-30', 4.6, 2, 'Lideró rediseño de UI. Impacto positivo en experiencia usuario.'),
(13, '2024-06-30', 4.0, 2, 'Avance significativo. Ya gestiona proyectos pequeños.'),
(14, '2024-06-30', 3.6, 2, 'Mejora continua. Buen manejo de frameworks modernos.'),
(15, '2024-06-30', 4.7, 2, 'Consistentemente excelente. Mentoriza a juniors.'),
(16, '2024-06-30', 4.3, 2, 'Sólido desempeño. Aporta innovación técnica constante.'),
(17, '2024-06-30', 3.8, 2, 'Crecimiento notable. Ya aporta en diseño de soluciones.'),
(18, '2024-06-30', 4.0, 2, 'Consistente. Buen candidato para rol mid-level.'),
(19, '2024-06-30', 3.5, 2, 'Ha superado los retos. Trabaja bien en equipo.'),
(20, '2024-06-30', 5.0, 2, 'Desempeño perfecto. Invaluable para el equipo tecnológico.'),

-- Evaluados por Claudia (ID 3) -- jefa de Ventas
(21, '2023-12-31', 4.1, 3, 'Cumplió cuota de ventas 112%. Excelente relación con clientes.'),
(22, '2023-12-31', 4.3, 3, 'Superó objetivos. Captó 5 nuevos clientes estratégicos.'),
(23, '2023-12-31', 3.6, 3, 'Buen manejo de CRM. Requiere mejorar cierre de negocios.'),
(24, '2023-12-31', 3.3, 3, 'Cumple metas básicas. Potencial de crecimiento identificado.'),
(25, '2023-12-31', 4.6, 3, 'Mejor vendedor del año. Referente del equipo comercial.'),
(26, '2023-12-31', 3.8, 3, 'Buen desempeño. Gestiona bien el territorio asignado.'),
(27, '2023-12-31', 3.0, 3, 'En adaptación. Necesita más entrenamiento en negociación.'),
(28, '2023-12-31', 4.0, 3, 'Sólida gestión de cuentas. Cliente satisfechos.'),
(29, '2023-12-31', 4.2, 3, 'Alta efectividad. Retención de clientes del 95%.'),
(30, '2023-12-31', 3.1, 3, 'Reciente ingreso. Progreso adecuado para su antigüedad.'),
(21, '2024-06-30', 4.3, 3, 'Excelente primer semestre. Supera objetivos consistentemente.'),
(22, '2024-06-30', 4.5, 3, 'Candidata a líder de equipo. Extraordinario rendimiento.'),
(23, '2024-06-30', 3.9, 3, 'Ha mejorado en cierre de negocios. Más seguridad.'),
(24, '2024-06-30', 3.6, 3, 'Progreso constante. Maneja cartera con mayor autonomía.'),
(25, '2024-06-30', 4.8, 3, 'Número 1 en ventas del semestre. Excelente gestión.'),
(26, '2024-06-30', 4.0, 3, 'Mantiene buen nivel. Buena gestión del pipeline.'),
(27, '2024-06-30', 3.4, 3, 'Mejoró cierre de ventas. Aún en desarrollo.'),
(28, '2024-06-30', 4.2, 3, 'Consistente y confiable. Excelente con cuentas clave.'),
(29, '2024-06-30', 4.4, 3, 'Desempeño alto y sostenido. Gran activo del equipo.'),
(30, '2024-06-30', 3.5, 3, 'Buen avance. Se integró bien al equipo comercial.'),

-- Evaluados por Jorge (ID 4) -- jefe de Finanzas
(31, '2023-12-31', 4.2, 4, 'Excelente análisis financiero. Reportes de alta calidad.'),
(32, '2023-12-31', 4.0, 4, 'Muy buena gestión presupuestaria. Puntual y metódica.'),
(33, '2023-12-31', 3.7, 4, 'Buen manejo de costos. Aporta análisis útiles.'),
(34, '2023-12-31', 3.5, 4, 'Cumple con las metas. Debe reforzar análisis de riesgo.'),
(35, '2023-12-31', 4.4, 4, 'Detectó ahorros importantes. Muy valioso para el área.'),
(36, '2023-12-31', 4.1, 4, 'Excelente gestión de tesorería. Precisa y eficiente.'),
(37, '2023-12-31', 3.3, 4, 'Buen trabajo en auditorías internas. En crecimiento.'),
(38, '2023-12-31', 3.8, 4, 'Responsable y comprometida. Muy buena actitud.'),
(31, '2024-06-30', 4.5, 4, 'Optimizó modelos de proyección. Gran impacto en decisiones.'),
(32, '2024-06-30', 4.3, 4, 'Implementó nuevo proceso de cierre mensual. Excelente.'),
(33, '2024-06-30', 4.0, 4, 'Significativa mejora. Maneja con autonomía proyectos complejos.'),
(34, '2024-06-30', 3.8, 4, 'Ha fortalecido análisis de riesgo. Buen progreso.'),
(35, '2024-06-30', 4.6, 4, 'Altamente recomendado para promoción. Excelente desempeño.'),
(36, '2024-06-30', 4.2, 4, 'Consolida gestión de tesorería multimoneda. Muy bueno.'),
(37, '2024-06-30', 3.6, 4, 'Mayor confianza en sus análisis. Crecimiento sostenido.'),
(38, '2024-06-30', 4.0, 4, 'Apoya a nuevos analistas. Buena evolución profesional.'),

-- Evaluados por Sofía (ID 5) -- jefa de Marketing
(39, '2023-12-31', 3.9, 5, 'Excelente manejo de redes sociales. Incrementó engagement.'),
(40, '2023-12-31', 4.1, 5, 'Campañas creativas con alto impacto. Muy talentoso.'),
(41, '2023-12-31', 3.6, 5, 'Buen manejo de contenido. Cumple con las entregas.'),
(42, '2023-12-31', 3.7, 5, 'Gestión correcta de proyectos de marca. Mejora continua.'),
(43, '2023-12-31', 3.2, 5, 'Nueva en el equipo. Aprendizaje rápido.'),
(44, '2023-12-31', 4.3, 5, 'Excelente estratega de contenidos. Aporta creatividad.'),
(45, '2023-12-31', 3.5, 5, 'Coordina bien con otras áreas. Enfoque en resultados.'),
(46, '2023-12-31', 2.8, 5, 'Dificultades con plazos. Requiere acompañamiento.'),
(47, '2023-12-31', 3.8, 5, 'Buen trabajo en email marketing. Resultados medibles.'),
(48, '2023-12-31', 4.4, 5, 'Mejor analista del equipo. Datos convierten en insights.'),
(39, '2024-06-30', 4.1, 5, 'Mejoró estrategia de paid media. Reducción de CPL del 20%.'),
(40, '2024-06-30', 4.3, 5, 'Lideró rebranding exitoso. Excelente impacto visual.'),
(41, '2024-06-30', 3.8, 5, 'Manejo correcto de calendario editorial. Mejora constante.'),
(42, '2024-06-30', 4.0, 5, 'Fortalecida en gestión de proyectos. Entrega puntual.'),
(43, '2024-06-30', 3.6, 5, 'Progreso significativo. Ya maneja campañas con autonomía.'),
(44, '2024-06-30', 4.5, 5, 'Estratega destacada. Sus campañas generan ROI positivo.'),
(45, '2024-06-30', 3.8, 5, 'Buena gestión de proyectos. Mayor enfoque en métricas.'),
(46, '2024-06-30', 3.3, 5, 'Ha mejorado gestión del tiempo. Avance apreciable.'),
(47, '2024-06-30', 4.0, 5, 'Domina marketing automation. Aporte muy valioso.'),
(48, '2024-06-30', 4.6, 5, 'Análisis de datos excepcional. Candidato a líder del equipo.');

-- 7. CAPACITACIONES (8 registros)

INSERT INTO Capacitaciones (NombreCapacitacion, Descripcion, Proveedor, Costo, FechaInicio, FechaFin) VALUES
('Liderazgo y Gestión de Equipos',   'Desarrollo de habilidades de liderazgo, comunicación y gestión de personas', 'Escuela de Negocios EAN', 2500000.00, '2023-02-01', '2023-02-10'),
('Excel Avanzado y Power Query',     'Manejo avanzado de Excel, tablas dinámicas, Power Query y macros básicas',    'Sena Virtual',           800000.00,  '2023-03-15', '2023-03-24'),
('Power BI para Análisis de Datos',  'Creación de dashboards interactivos, DAX y modelado de datos en Power BI',   'Platzi Empresas',        1200000.00, '2023-05-08', '2023-05-19'),
('Python para Análisis de Datos',    'Programación con Python, Pandas, NumPy y visualización con Matplotlib',      'Coursera Business',      1500000.00, '2023-08-07', '2023-08-25'),
('Marketing Digital Integral',       'SEO, SEM, redes sociales, email marketing y analítica web',                  'Digital House',          1800000.00, '2023-10-02', '2023-10-20'),
('Negociación y Cierre de Ventas',   'Técnicas de negociación, manejo de objeciones y cierre efectivo de ventas',  'Centro de Ventas PRO',   2000000.00, '2024-02-05', '2024-02-16'),
('Gestión Financiera para Gerentes', 'Análisis financiero, presupuesto, flujo de caja y toma de decisiones',       'Universidad de los Andes',3000000.00,'2024-04-01', '2024-04-12'),
('Seguridad de la Información',      'Ciberseguridad, protección de datos, GDPR y mejores prácticas TI',           'ISACA Colombia',         2200000.00, '2024-06-03', '2024-06-14');

-- 8. Registros EMPLEADO CAPACITACION

INSERT INTO EmpleadoCapacitacion (EmpleadoID, CapacitacionID, FechaInscripcion, FechaFinalizacion, Estado, Calificacion, Comentarios) VALUES
-- Capacitación 1: Liderazgo
(1,  1, '2023-01-25', '2023-02-10', 'Completado', 92.0, 'Excelente participación. Aplicará técnicas en su equipo.'),
(2,  1, '2023-01-25', '2023-02-10', 'Completado', 95.0, 'Mejor calificación del grupo. Liderazgo natural.'),
(3,  1, '2023-01-25', '2023-02-10', 'Completado', 88.0, 'Muy buen desempeño. Aplica inmediatamente lo aprendido.'),
(4,  1, '2023-01-25', '2023-02-10', 'Completado', 91.0, 'Excelente. Comprende bien los modelos de liderazgo.'),
(5,  1, '2023-01-25', '2023-02-10', 'Completado', 89.0, 'Buena participación. Enfoque en liderazgo creativo.'),
(10, 1, '2023-01-25', '2023-02-10', 'Completado', 85.0, 'Aprovechó el curso. Implementa técnicas de motivación.'),
(22, 1, '2023-01-25', '2023-02-10', 'Completado', 78.0, 'Completó satisfactoriamente. Aplicará en su equipo comercial.'),

-- Capacitación 2: Excel Avanzado
(6,  2, '2023-03-10', '2023-03-24', 'Completado', 87.0, 'Domina Power Query. Automatizó reportes del área.'),
(7,  2, '2023-03-10', '2023-03-24', 'Completado', 93.0, 'Destacada. Creó tablero de nómina con Excel avanzado.'),
(31, 2, '2023-03-10', '2023-03-24', 'Completado', 96.0, 'Mejor nota. Creó modelos financieros muy completos.'),
(32, 2, '2023-03-10', '2023-03-24', 'Completado', 90.0, 'Excelente manejo de tablas dinámicas y fórmulas complejas.'),
(33, 2, '2023-03-10', '2023-03-24', 'Completado', 84.0, 'Buen desempeño. Automatizó proceso de consolidación.'),
(34, 2, '2023-03-10', '2023-03-24', 'Completado', 79.0, 'Completó el curso. Aplica las herramientas básicas.'),
(8,  2, '2023-03-10', '2023-03-24', 'Completado', 75.0, 'Pasó el curso. Requiere más práctica con macros.'),

-- Capacitación 3: Power BI
(2,  3, '2023-05-03', '2023-05-19', 'Completado', 98.0, 'Sobresaliente. Creó dashboard de seguimiento de proyectos.'),
(4,  3, '2023-05-03', '2023-05-19', 'Completado', 94.0, 'Excelente. Dashboard financiero presentado a directivos.'),
(5,  3, '2023-05-03', '2023-05-19', 'Completado', 91.0, 'Muy bueno. Dashboard de KPIs de marketing listo.'),
(31, 3, '2023-05-03', '2023-05-19', 'Completado', 97.0, 'Nivel experto. Diseñó reportes para todo el equipo.'),
(48, 3, '2023-05-03', '2023-05-19', 'Completado', 99.0, 'La mejor del grupo. Domina DAX y modelado avanzado.'),
(35, 3, '2023-05-03', '2023-05-19', 'Completado', 88.0, 'Buen manejo de visualizaciones. Aporta análisis al área.'),
(10, 3, '2023-05-03', '2023-05-19', 'Completado', 82.0, 'Completó satisfactoriamente. Usa para reportes de RRHH.'),

-- Capacitación 4: Python
(11, 4, '2023-08-02', '2023-08-25', 'Completado', 97.0, 'Excelente. Ya aplicaba Python; profundizó en análisis de datos.'),
(12, 4, '2023-08-02', '2023-08-25', 'Completado', 94.0, 'Muy buena. Integró Python con desarrollo frontend.'),
(15, 4, '2023-08-02', '2023-08-25', 'Completado', 96.0, 'Sobresaliente. Automatizó procesos del backend con Python.'),
(16, 4, '2023-08-02', '2023-08-25', 'Completado', 91.0, 'Excelente rendimiento. Muy fuerte en análisis.'),
(20, 4, '2023-08-02', '2023-08-25', 'Completado', 98.0, 'Máximo nivel. Lideró ejercicio final del grupo.'),
(48, 4, '2023-08-02', '2023-08-25', 'Completado', 95.0, 'Impresionante dominio. Combina Python con herramientas BI.'),
(13, 4, '2023-08-02', '2023-08-25', 'Completado', 82.0, 'Buen avance para su nivel junior. Muy dedicado.'),
(14, 4, '2023-08-02', NULL,         'En Progreso', NULL, 'Retomó el curso en 2024. Avanza bien.'),

-- Capacitación 5: Marketing Digital
(5,  5, '2023-09-27', '2023-10-20', 'Completado', 93.0, 'Lideró el grupo. Diseñó estrategia completa como proyecto.'),
(39, 5, '2023-09-27', '2023-10-20', 'Completado', 89.0, 'Excelente en paid media y analítica. Muy aplicada.'),
(40, 5, '2023-09-27', '2023-10-20', 'Completado', 91.0, 'Destacado en creatividad y estrategia de contenido.'),
(41, 5, '2023-09-27', '2023-10-20', 'Completado', 78.0, 'Completó el curso. Aplica herramientas de SEO.'),
(42, 5, '2023-09-27', '2023-10-20', 'Completado', 83.0, 'Buen desempeño. Domina gestión de campañas.'),
(43, 5, '2023-09-27', '2023-10-20', 'Completado', 76.0, 'Pasó satisfactoriamente. Reforzará con práctica.'),
(44, 5, '2023-09-27', '2023-10-20', 'Completado', 95.0, 'Sobresaliente. Diseñó una estrategia que fue implementada.'),
(45, 5, '2023-09-27', '2023-10-20', 'Completado', 80.0, 'Buena base en email marketing. Aplica en campañas.'),
(46, 5, '2023-09-27', NULL,         'Cancelado',  NULL, 'Canceló por ausencia médica. Reprogramado para 2024.'),
(47, 5, '2023-09-27', '2023-10-20', 'Completado', 87.0, 'Muy bueno en automatización de marketing.'),
(48, 5, '2023-09-27', '2023-10-20', 'Completado', 92.0, 'Excelente en analítica. Sus insights mejoraron campañas.'),

-- Capacitación 6: Negociación y Ventas (2024)
(3,  6, '2024-02-01', '2024-02-16', 'Completado', 96.0, 'Excelente. Implementó nuevas técnicas con el equipo.'),
(21, 6, '2024-02-01', '2024-02-16', 'Completado', 88.0, 'Muy buena participación. Mejoró tasa de cierre.'),
(22, 6, '2024-02-01', '2024-02-16', 'Completado', 92.0, 'Sobresaliente. Incrementó sus ventas en un 18%.'),
(23, 6, '2024-02-01', '2024-02-16', 'Completado', 85.0, 'Buen desempeño. Mejoró en manejo de objeciones.'),
(24, 6, '2024-02-01', '2024-02-16', 'Completado', 80.0, 'Completó el curso. Aplica gradualmente las técnicas.'),
(25, 6, '2024-02-01', '2024-02-16', 'Completado', 97.0, 'El mejor del grupo. Referente en el equipo comercial.'),
(26, 6, '2024-02-01', '2024-02-16', 'Completado', 83.0, 'Buena actitud de aprendizaje. Mejora sostenida.'),
(27, 6, '2024-02-01', '2024-02-16', 'Completado', 74.0, 'Pasó el curso. Necesita más práctica en campo.'),
(28, 6, '2024-02-01', '2024-02-16', 'Completado', 89.0, 'Sólido. Mejor gestión de cuentas clave post-curso.'),

-- Capacitación 7: Gestión Financiera (2024)
(1,  7, '2024-03-27', '2024-04-12', 'Completado', 90.0, 'Muy buena. Aplica conceptos financieros en gestión de RRHH.'),
(4,  7, '2024-03-27', '2024-04-12', 'Completado', 98.0, 'Excelente. Conocimiento profundo del área. Exposición notable.'),
(31, 7, '2024-03-27', '2024-04-12', 'Completado', 95.0, 'Sobresaliente. Diseñó nuevo modelo de forecast financiero.'),
(35, 7, '2024-03-27', '2024-04-12', 'Completado', 93.0, 'Muy bueno. Optimizó procesos de proyección presupuestal.'),
(36, 7, '2024-03-27', '2024-04-12', 'Completado', 91.0, 'Excelente comprensión de gestión de liquidez.'),
(37, 7, '2024-03-27', NULL,         'En Progreso', NULL, 'Inscrito en 2024 pero aún finalizando el módulo final.'),

-- Capacitación 8: Seguridad de la Información (2024)
(2,  8, '2024-05-29', '2024-06-14', 'Completado', 97.0, 'Excelente. Lideró implementación de nuevas políticas de seguridad.'),
(11, 8, '2024-05-29', '2024-06-14', 'Completado', 95.0, 'Muy bueno. Auditoría de seguridad completada post-curso.'),
(15, 8, '2024-05-29', '2024-06-14', 'Completado', 92.0, 'Sólido. Aplica prácticas seguras en el desarrollo.'),
(16, 8, '2024-05-29', '2024-06-14', 'Completado', 88.0, 'Buen rendimiento. Buen manejo de GDPR y política de datos.'),
(17, 8, '2024-05-29', NULL,         'En Progreso', NULL, 'Avanzando en el último módulo de certificación.'),
(18, 8, '2024-05-29', '2024-06-14', 'Completado', 84.0, 'Completó el curso. Aplica controles básicos de seguridad.');

-- Verificación final
SELECT 'Oficinas'             AS Tabla, COUNT(*) AS Registros FROM Oficinas
UNION ALL
SELECT 'Departamentos',       COUNT(*) FROM Departamentos
UNION ALL
SELECT 'Puestos',             COUNT(*) FROM Puestos
UNION ALL
SELECT 'Empleados',           COUNT(*) FROM Empleados
UNION ALL
SELECT 'Ausencias',           COUNT(*) FROM Ausencias
UNION ALL
SELECT 'Evaluaciones',        COUNT(*) FROM Evaluaciones
UNION ALL
SELECT 'Capacitaciones',      COUNT(*) FROM Capacitaciones
UNION ALL
SELECT 'EmpleadoCapacitacion',COUNT(*) FROM EmpleadoCapacitacion;
