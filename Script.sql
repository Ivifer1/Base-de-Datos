Integrantes:
- Ivifer Pita
- María Rebea López

Indice:
- Create Tables
- Triggers
- Inserts 
- Programas almacenados
- Consultas sql

--------------------------- CREATE TABLES ---------------------------------------
CREATE EXTENSION IF NOT EXISTS unaccent;
-- Tabla obra
CREATE SEQUENCE seq_id_obra
  START 1
  INCREMENT 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE obra (
  id_obra NUMERIC(3) PRIMARY KEY DEFAULT nextval('seq_id_obra'),
  nom_obra VARCHAR(100) NOT NULL,
  fecha_creacion_periodo VARCHAR(50) NOT NULL,
  dim_descrip VARCHAR(50) NOT NULL,
  est_art VARCHAR(100) NOT NULL,
  tecnica_mat VARCHAR(100) NOT NULL,
  tipo_obra VARCHAR(50) CHECK (tipo_obra IN ('pintura', 'escultura')),
  CONSTRAINT chk_id_obra_max CHECK (id_obra <= 999)
);

-- Tabla Empleado de Mantenimiento
CREATE SEQUENCE seq_emp_mant
  START 1
  INCREMENT 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE empleado_mantenimiento (
    id_emp_mant NUMERIC(3) PRIMARY KEY DEFAULT nextval('seq_emp_mant'),
    doc_identidad_man NUMERIC(12) UNIQUE NOT NULL,
    nom_emp_man VARCHAR(50) NOT NULL,
    ape_emp_man VARCHAR(50) NOT NULL,
    tipo VARCHAR(5) NOT NULL CHECK (tipo IN ('vigi', 'mant'))
);

-- Tabla Idioma
CREATE SEQUENCE seq_idioma
  START 1
  INCREMENT 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE idioma (
  id_idioma NUMERIC(3) PRIMARY KEY DEFAULT nextval('seq_idioma'),
  nom_idioma VARCHAR(15) NOT NULL
);


-- Tabla lugar geografico
CREATE SEQUENCE seq_lugar_geo
  START 1
  INCREMENT 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE lugar_geografico (
    id_lugar_geo NUMERIC(3) PRIMARY KEY DEFAULT nextval('seq_lugar_geo'),
    id_lugar_padre NUMERIC(3), -- Esta columna contendrá el ID del lugar geográfico padre
    nombre_lugar_geo VARCHAR(100) NOT NULL,
    tipo_lugar VARCHAR(10) NOT NULL CHECK (tipo_lugar IN ('p', 'c')),
    continente VARCHAR(20),
    CONSTRAINT fk_lugar_padre FOREIGN KEY (id_lugar_padre)
        REFERENCES lugar_geografico (id_lugar_geo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Museo
CREATE SEQUENCE seq_museo
  START 1
  INCREMENT 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE museo (
    id_museo NUMERIC(3) PRIMARY KEY DEFAULT nextval('seq_museo'),
    id_lugar_geo NUMERIC(3) NOT NULL,
    nombre_museo VARCHAR(100) NOT NULL,
    fecha_fundacion DATE NOT NULL,
    resumen_mision VARCHAR(200),
    CONSTRAINT fk_museo_lugar_geo FOREIGN KEY (id_lugar_geo)
        REFERENCES lugar_geografico (id_lugar_geo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Estructura Física
CREATE SEQUENCE seq_id_est_fisica
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE estructura_fisica (
	id_museo NUMERIC(3) NOT NULL,    
	id_est_fisica NUMERIC(3) NOT NULL DEFAULT nextval('seq_id_est_fisica'),
	id_est_padre NUMERIC(3), 
	nombre_est VARCHAR(50) NOT NULL,
	tipo_est VARCHAR(20) CHECK (tipo_est IN ('edi', 'piso_planta', 'area_seccion')) NOT NULL,
	descripcion_est VARCHAR(150),
	direccion_edificio VARCHAR(100),
    PRIMARY KEY (id_museo, id_est_fisica),
    	CONSTRAINT fk_est_padre
        FOREIGN KEY (id_museo, id_est_fisica) 
        REFERENCES estructura_fisica (id_museo, id_est_fisica)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    	CONSTRAINT fk_est_fisica_museo
        FOREIGN KEY (id_museo)
        REFERENCES museo (id_museo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Estructura Organizacional
CREATE SEQUENCE seq_id_est_org
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE estructura_organizacional (
    id_museo NUMERIC(3) NOT NULL,  
    id_est_org NUMERIC(3) NOT NULL DEFAULT nextval('seq_id_est_org'), 
    nombre_est_or VARCHAR(50) NOT NULL,
    tipo_est_org VARCHAR(20) CHECK(tipo_est_org IN('dire','depa','secc')) NOT NULL,
    nivel INT NOT NULL,
    descripcion VARCHAR(150),
    PRIMARY KEY ( id_museo, id_est_org),
    	CONSTRAINT fk_est_org_museo
        FOREIGN KEY (id_museo)
        REFERENCES museo (id_museo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- Tabla Empleado profesional
CREATE SEQUENCE seq_empleado_profesional
  START 1
  INCREMENT 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE empleado_profesional (
    id_emp_pro NUMERIC(3) PRIMARY KEY DEFAULT nextval('seq_empleado_profesional'),
    id_museo NUMERIC(3) NOT NULL,
    doc_identidad NUMERIC(12) UNIQUE NOT NULL,
    primer_nombre VARCHAR(20) NOT NULL,
    primer_apellido VARCHAR(20) NOT NULL,
    segundo_apellido VARCHAR(20) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero VARCHAR(10) NOT NULL CHECK (genero IN ('Fem', 'Mas')),
    telefono VARCHAR(20) NOT NULL,
    segundo_nombre VARCHAR(20),
    correo VARCHAR(100) UNIQUE,
    CONSTRAINT fk_empe_pro_museo FOREIGN KEY (id_museo)
        REFERENCES museo (id_museo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Titulo
CREATE SEQUENCE seq_id_titulo
  START 1
  INCREMENT 1
  MAXVALUE 150
  NO CYCLE;
CREATE TABLE titulo_formacion (
    -- Columnas que forman parte de la PK y otras NOT NULL primero
    id_emp_pro NUMERIC(3) NOT NULL, 
    id_titulo NUMERIC(3) NOT NULL DEFAULT nextval('seq_id_titulo'), 
    nombre_titulo VARCHAR(50) NOT NULL,
    momento DATE NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    especializacion VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_emp_pro, id_titulo),
        CONSTRAINT fk_titulo_emp_pro
        FOREIGN KEY (id_emp_pro)
        REFERENCES empleado_profesional (id_emp_pro)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla coleccion
CREATE SEQUENCE seq_id_coleccion
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE coleccion (
	id_museo NUMERIC(3) NOT NULL,     
	id_est_org NUMERIC(3) NOT NULL,   
	id_coleccion NUMERIC(3) NOT NULL DEFAULT nextval('seq_id_coleccion'), 
	nombre_coleccion VARCHAR(150) NOT NULL,
	descripcion_caracteristicas VARCHAR(150) NOT NULL,
	palabras_clave VARCHAR(150) NOT NULL,
	orden_recorrido NUMERIC(2) NOT NULL,
	PRIMARY KEY (id_museo, id_est_org, id_coleccion),
	CONSTRAINT fk_colecc_est_org
		FOREIGN KEY (id_museo, id_est_org)
		REFERENCES estructura_organizacional (id_museo, id_est_org)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

-- Tabla Sala Exposición
CREATE SEQUENCE seq_id_sala_exp
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE sala_exp (
	id_museo NUMERIC(3) NOT NULL,   
	id_est_fisica NUMERIC(3) NOT NULL,
	id_sala_exp NUMERIC(3) NOT NULL DEFAULT nextval('seq_id_sala_exp'), 
	nombre_sala_expo VARCHAR(50) NOT NULL,
	descripcion VARCHAR(150),
	PRIMARY KEY (id_museo, id_est_fisica, id_sala_exp),
	CONSTRAINT fk_sala_exp_est_fisica
		FOREIGN KEY (id_museo, id_est_fisica) 
		REFERENCES estructura_fisica (id_museo, id_est_fisica)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

-- Tabla EVENTO
CREATE SEQUENCE seq_id_evento
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE evento (
	id_museo NUMERIC(3) NOT NULL,   
	id_evento NUMERIC(3) NOT NULL DEFAULT nextval('seq_id_evento'),
	titulo_evento VARCHAR(50) NOT NULL,
	fecha_inicio_evento DATE NOT NULL,
	fecha_fin_evento DATE NOT NULL,
	lugar_exposicion VARCHAR(100) NOT NULL,
	costo NUMERIC(8, 2),
	cantidad_personas INT,
	institucion_educativa VARCHAR(100),
	PRIMARY KEY (id_museo, id_evento),
	CONSTRAINT fk_evento_museo
		FOREIGN KEY (id_museo)
		REFERENCES museo (id_museo)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

-- Tabla Ticket de entrada
CREATE SEQUENCE seq_id_ticket
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE ticket_de_entrada (
	id_museo NUMERIC(3) NOT NULL, 
	id_ticket NUMERIC(3) NOT NULL DEFAULT nextval('seq_id_ticket'),
	fecha_hora_emision TIMESTAMP NOT NULL,
	tipo_ticket_entrada VARCHAR(10) CHECK (tipo_ticket_entrada IN ('ad', 'ni', 'adm')) NOT NULL,
	monto_ticket_entrada NUMERIC(8, 2) NOT NULL,
	PRIMARY KEY (id_museo, id_ticket),
	CONSTRAINT fk_ticket_de_entrada_museo
		FOREIGN KEY (id_museo)
		REFERENCES museo (id_museo)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

-- Tabla Tipo ticket
CREATE TABLE tipo_ticket (
	id_museo NUMERIC(3) NOT NULL,          
	tipo_ticket VARCHAR(10) CHECK (tipo_ticket IN ('ad', 'ni', 'adm')) NOT NULL,
	fecha_inicio DATE NOT NULL,
	precio_ticket NUMERIC(8, 2) NOT NULL,
	fecha_fin DATE,
    PRIMARY KEY (id_museo, tipo_ticket, fecha_inicio),
    	CONSTRAINT fk_tipo_ticket_museo
        FOREIGN KEY (id_museo)
        REFERENCES museo (id_museo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Horario
CREATE TABLE horario (
    id_museo NUMERIC(3) NOT NULL,
    dia_museo NUMERIC(1) NOT NULL CHECK (dia_museo BETWEEN 1 AND 7),
    hora_apertura TIME NOT NULL,
    hora_cierre TIME NOT NULL,
    PRIMARY KEY (dia_museo, id_museo),
    CONSTRAINT fk_horario_museo
        FOREIGN KEY (id_museo)
        REFERENCES museo (id_museo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- Tabla Hecho historico
CREATE TABLE hecho_historico (
	id_museo NUMERIC(3) NOT NULL, 
	ano DATE NOT NULL,  
	descripcion_hecho VARCHAR(500) NOT NULL,
	
    PRIMARY KEY (id_museo, ano), 
    	CONSTRAINT fk_hechos_museo
        FOREIGN KEY (id_museo)
        REFERENCES museo (id_museo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Artista
CREATE SEQUENCE seq_artista
  START 1
  INCREMENT 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE artista (
    id_artista NUMERIC(3) PRIMARY KEY DEFAULT nextval('seq_artista'),
    resumen_carac_art VARCHAR(200) NOT NULL,
    nombre_artistico VARCHAR(50),
    nombre_artista VARCHAR(50),
    apellido VARCHAR(50),
    fecha_nacimiento_artista DATE,
    fecha_muerte_artista DATE,
    id_lugar_geo INT,
    
    CONSTRAINT fk_artista_lugar_geo
        FOREIGN KEY (id_lugar_geo)
        REFERENCES lugar_geografico (id_lugar_geo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Asignación mensual
CREATE TABLE asignacion_mensual (
	id_est_fisica NUMERIC(3) NOT NULL,    
	id_museo NUMERIC(3) NOT NULL,         
	id_emp_mant NUMERIC(3) NOT NULL,       
	fecha_inicio_asig DATE NOT NULL,
    turno VARCHAR(10) NOT NULL, 
    PRIMARY KEY ( id_museo,  id_est_fisica, id_emp_mant, fecha_inicio_asig),
    	CONSTRAINT fk_asign_men_est_fisi
        FOREIGN KEY (id_museo, id_est_fisica)
        REFERENCES estructura_fisica (id_museo, id_est_fisica)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    	CONSTRAINT fk_asign_emp_mant
        FOREIGN KEY (id_emp_mant)
        REFERENCES empleado_mantenimiento (id_emp_mant) 
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Historico cierre temporal
CREATE TABLE historico_cierre_temp (
	id_museo NUMERIC(3) NOT NULL,         
	id_est_fisica NUMERIC(3) NOT NULL,   
	id_sala_exp NUMERIC(3) NOT NULL,    
	fecha_inicio_hct DATE NOT NULL, 
	fecha_fin_hct DATE,
    PRIMARY KEY (id_museo, id_est_fisica, id_sala_exp,  fecha_inicio_hct),
    	CONSTRAINT fk_hct_sala_exp
        FOREIGN KEY (id_museo, id_est_fisica, id_sala_exp)
        REFERENCES sala_exp (id_museo, id_est_fisica, id_sala_exp)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Sala coleccion
CREATE TABLE sala_col (
	id_est_org NUMERIC(3) NOT NULL,   
	id_coleccion NUMERIC(3) NOT NULL, 
	id_museo NUMERIC(3) NOT NULL,      
	id_est_fisica NUMERIC(3) NOT NULL, 
	id_sala_exp NUMERIC(3) NOT NULL,
            orden_recorrido INT NOT NULL, 
    PRIMARY KEY (id_sala_exp, id_est_fisica, id_museo, id_coleccion, id_est_org),
    	CONSTRAINT fk_sala_col_sala_exp
        FOREIGN KEY ( id_museo,  id_est_fisica, id_sala_exp)
        REFERENCES sala_exp ( id_museo,  id_est_fisica, id_sala_exp)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    	CONSTRAINT fk_sala_col_coleccion
        FOREIGN KEY (id_coleccion, id_est_org, id_museo)
        REFERENCES coleccion (id_coleccion, id_est_org, id_museo)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Tabla Autor
CREATE TABLE autor (
    id_artista NUMERIC(3) NOT NULL,
    id_obra NUMERIC(3) NOT NULL,
    PRIMARY KEY (id_artista,id_obra),
    	CONSTRAINT fk_autor_artista
        FOREIGN KEY (id_artista)
        REFERENCES artista (id_artista)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    	CONSTRAINT fk_autor_obra
        FOREIGN KEY (id_obra)
        REFERENCES obra (id_obra)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Tabla Idioma hablado
CREATE TABLE idioma_hablado (
    id_idioma NUMERIC(3) NOT NULL,
	id_emp_pro NUMERIC(3) NOT NULL, 
    PRIMARY KEY (id_idioma, id_emp_pro),
    	CONSTRAINT fk_idioma_hablado_idioma
        FOREIGN KEY (id_idioma)
        REFERENCES idioma (id_idioma)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    	CONSTRAINT fk_idioma_hablado_empleado
        FOREIGN KEY (id_emp_pro)
        REFERENCES empleado_profesional (id_emp_pro)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Tabla Histórico empleado
CREATE TABLE historico_empleado (
    id_emp_pro NUMERIC(3) NOT NULL, 
    id_museo NUMERIC(3) NOT NULL,    
    id_est_org NUMERIC(3) NOT NULL, 
    fecha_inicio DATE NOT NULL,
    cargo VARCHAR(30) NOT NULL,
    fecha_fin DATE,
    PRIMARY KEY (id_emp_pro, id_museo, id_est_org, fecha_inicio),
    CONSTRAINT fk_historico_empleado
        FOREIGN KEY (id_emp_pro)
        REFERENCES empleado_profesional (id_emp_pro) 
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_historico_estructura
        FOREIGN KEY (id_est_org, id_museo)
        REFERENCES estructura_organizacional (id_est_org, id_museo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla Historico Movimiento de la obra
CREATE TABLE hist_obra_movimiento (
    id_obra NUMERIC(3) NOT NULL,
    id_cata_museo NUMERIC(3) NOT NULL,
    fecha_llegada DATE NOT NULL,
    tipo_adquisicion VARCHAR(15) CHECK (tipo_adquisicion IN ('comprada', 'donada', 'comprada_m', 'donada_m')) NOT NULL,
    destacada VARCHAR(2) CHECK (destacada IN ('si', 'no')) NOT NULL,
    fecha_fin DATE,
    orden_recorrido INT,
    valor_monetario NUMERIC(12, 2),
    id_emp_pro INT,
    id_museo INT,
    id_est_org INT,
    id_coleccion INT,
    id_est_fisica INT,
    id_sala_exp INT,

    PRIMARY KEY (id_obra, id_cata_museo),
    	CONSTRAINT fk_obra
        FOREIGN KEY (id_obra)
        REFERENCES obra (id_obra)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    	CONSTRAINT fk_empleado
        FOREIGN KEY (id_emp_pro)
        REFERENCES empleado_profesional (id_emp_pro)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    	CONSTRAINT fk_coleccion
        FOREIGN KEY (id_museo, id_est_org, id_coleccion)
        REFERENCES coleccion (id_museo, id_est_org, id_coleccion)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    	CONSTRAINT fk_sala
        FOREIGN KEY (id_museo, id_est_fisica, id_sala_exp)
        REFERENCES sala_exp (id_museo, id_est_fisica, id_sala_exp)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

   	 	CONSTRAINT chk_fechas
        CHECK (fecha_fin IS NULL OR fecha_fin > fecha_llegada)
);
-- Tabla Actividad conservación
CREATE SEQUENCE seq_conservacion
  START 1
  INCREMENT 1
  MAXVALUE 150
  NO CYCLE;

CREATE TABLE actividad_conservacion (
    id_obra NUMERIC(3) NOT NULL,
    id_cata_museo NUMERIC(3) NOT NULL,
    id_conservacion NUMERIC(3) DEFAULT nextval('seq_conservacion'),
    actividad VARCHAR(100) NOT NULL,
    frecuencia VARCHAR(50) NOT NULL,
    tipo_responsable VARCHAR(20) CHECK (tipo_responsable IN ('curador', 'restaurador', 'otro')) NOT NULL,
    PRIMARY KEY (id_obra, id_cata_museo, id_conservacion),
    CONSTRAINT fk_hist_obra_mov
        FOREIGN KEY (id_obra, id_cata_museo)
        REFERENCES hist_obra_movimiento (id_obra, id_cata_museo)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Tabla historico actividad conservacion
CREATE TABLE hist_conservacion (
    id_obra NUMERIC(3) NOT NULL,
    id_cata_museo NUMERIC(3) NOT NULL,
    id_conservacion NUMERIC(3) NOT NULL,
    id_emp_pro NUMERIC(3) NOT NULL,
    fecha_inicio_cons DATE NOT NULL,
    fecha_fin_cons DATE,
    descripcion TEXT,
    PRIMARY KEY (id_obra, id_cata_museo, id_conservacion, id_emp_pro, fecha_inicio_cons),
        CONSTRAINT fk_actividad_cons
        FOREIGN KEY (id_obra, id_cata_museo, id_conservacion)
        REFERENCES actividad_conservacion (id_obra, id_cata_museo, id_conservacion)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        CONSTRAINT fk_emp_prof_cons
        FOREIGN KEY (id_emp_pro)
        REFERENCES empleado_profesional (id_emp_pro)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


------------------------------------------ TRIGGERS --------------------------------------------------------

--------------------- GENERAR UN TICKET EN EL HORARIO PERMITIDO

CREATE OR REPLACE FUNCTION validar_precio_ticket()
RETURNS TRIGGER AS $$
DECLARE
  precio_oficial NUMERIC(8,2);
  hora_cierre TIME;
BEGIN
  -- Buscar precio oficial vigente para el tipo de ticket y museo en la fecha del ticket
  SELECT tt.precio_ticket INTO precio_oficial
  FROM tipo_ticket tt
  WHERE tt.id_museo = NEW.id_museo
    AND tt.tipo_ticket = NEW.tipo_ticket_entrada
    AND NEW.fecha_hora_emision::DATE BETWEEN tt.fecha_inicio AND COALESCE(tt.fecha_fin, '9999-12-31')
  ORDER BY tt.fecha_inicio DESC
  LIMIT 1;

  IF precio_oficial IS NULL THEN
    RAISE EXCEPTION 'No hay precio definido para este tipo de ticket en el museo % en la fecha %', NEW.id_museo, NEW.fecha_hora_emision::DATE;
  END IF;

  IF precio_oficial <> NEW.monto_ticket_entrada THEN
    RAISE EXCEPTION 'El monto del ticket (%) no coincide con el precio oficial (%) para este tipo de ticket en el museo %',
      NEW.monto_ticket_entrada, precio_oficial, NEW.id_museo;
  END IF;

  SELECT h.hora_cierre INTO hora_cierre
  FROM horario h
  WHERE h.id_museo = NEW.id_museo
    AND h.dia_museo = EXTRACT(ISODOW FROM CURRENT_TIMESTAMP)
  LIMIT 1;

  IF hora_cierre IS NULL THEN
    RAISE EXCEPTION 'No se encontró horario para el museo % en el día %', NEW.id_museo, EXTRACT(ISODOW FROM CURRENT_TIMESTAMP);
  END IF;

  -- Verificar que la hora actual no sea dentro de la última hora antes del cierre
  IF CURRENT_TIME > (hora_cierre - INTERVAL '1 hour') THEN
    RAISE EXCEPTION 'No se pueden emitir tickets dentro de la última hora antes del cierre. Hora de cierre: %, hora actual: %',
      hora_cierre, CURRENT_TIME;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_precio_ticket ON ticket_de_entrada;

CREATE TRIGGER trg_validar_precio_ticket
BEFORE INSERT ON ticket_de_entrada
FOR EACH ROW
EXECUTE FUNCTION validar_precio_ticket();

--------------------- CALCULO DE RANKING

CREATE OR REPLACE FUNCTION obtener_ranking_museos(
    p_anio_param INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INT
)
RETURNS TABLE (
    id_museo NUMERIC(3,0),
    nombre_museo VARCHAR(100),
    visitantes_anuales NUMERIC(10),
    promedio_permanencia NUMERIC(5,2),
    puntaje_rotacion INTEGER,
    ranking NUMERIC(6,2)
)
AS $$
BEGIN
    RETURN QUERY
    WITH visitas_por_museo AS (
        SELECT 
            tde.id_museo,
            COUNT(*)::NUMERIC(10) AS total_visitas
        FROM ticket_de_entrada tde
        WHERE EXTRACT(YEAR FROM tde.fecha_hora_emision) = p_anio_param
        GROUP BY tde.id_museo
    ),
    max_visitas AS (
        SELECT MAX(total_visitas) AS max_visitas FROM visitas_por_museo
    ),
    rotacion_por_museo AS (
        SELECT 
            he.id_museo,
            ROUND(AVG((he.fecha_fin - he.fecha_inicio) / 365.0), 2) AS promedio_permanencia
        FROM historico_empleado he
        WHERE he.fecha_fin IS NOT NULL
        GROUP BY he.id_museo
    ),
    puntaje_rotacion_calc AS (
        SELECT 
            rpm.id_museo,
            rpm.promedio_permanencia,
            CASE 
                WHEN rpm.promedio_permanencia > 10 THEN 1
                WHEN rpm.promedio_permanencia BETWEEN 5 AND 10 THEN 2
                ELSE 3
            END AS puntaje_rotacion
        FROM rotacion_por_museo rpm
    )
    SELECT 
        m.id_museo,
        m.nombre_museo,
        COALESCE(v.total_visitas, 0) AS visitantes_anuales,
        r.promedio_permanencia,
        r.puntaje_rotacion,
        ROUND(
            (
                (1.0 / NULLIF(r.puntaje_rotacion, 0)) * 0.5 + 
                (COALESCE(v.total_visitas::DECIMAL / NULLIF(mx.max_visitas, 0), 0)) * 0.5
            ) * 100, 2
        ) AS ranking
    FROM museo m
    LEFT JOIN visitas_por_museo v ON m.id_museo = v.id_museo
    LEFT JOIN puntaje_rotacion_calc r ON m.id_museo = r.id_museo
    CROSS JOIN max_visitas mx
    ORDER BY ranking DESC;
END;
$$ LANGUAGE plpgsql;

---------------------Trigger para validar la jerarquia en estructura fisica

CREATE OR REPLACE FUNCTION validar_estructura_fisica_reglas()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_parent_type character varying(20); 
    v_parent_exists boolean;             
BEGIN
    IF NEW.tipo_est = 'edi' THEN
        IF NEW.id_est_padre IS NOT NULL THEN
            RAISE EXCEPTION 'Error: Una estructura de tipo "edi" (edificio) no puede tener una estructura padre.';
        END IF;
    ELSE
        IF NEW.direccion_edificio IS NOT NULL AND TRIM(NEW.direccion_edificio) != '' THEN
            RAISE EXCEPTION 'Error: La dirección del edificio solo aplica para estructuras de tipo "edi".';
        END IF;
        IF NEW.id_est_padre IS NULL THEN
            RAISE EXCEPTION 'Error: Una estructura de tipo "%" debe tener una estructura padre.', NEW.tipo_est;
        END IF;

        SELECT EXISTS (SELECT 1 FROM public.estructura_fisica WHERE id_museo = NEW.id_museo AND id_est_fisica = NEW.id_est_padre)
        INTO v_parent_exists;

        IF NOT v_parent_exists THEN
            RAISE EXCEPTION 'Error: La estructura padre con ID % para el museo % no existe.', NEW.id_est_padre, NEW.id_museo;
        END IF;

        SELECT tipo_est
        INTO v_parent_type
        FROM public.estructura_fisica
        WHERE id_museo = NEW.id_museo AND id_est_fisica = NEW.id_est_padre;

        IF NEW.tipo_est = 'piso_planta' THEN
            -- Un piso/planta solo puede tener un edificio como padre
            IF v_parent_type != 'edi' THEN
                RAISE EXCEPTION 'Error: Una estructura de tipo "piso_planta" solo puede tener un padre de tipo "edi". El padre actual es de tipo "%".', v_parent_type;
            END IF;
        ELSIF NEW.tipo_est = 'area_seccion' THEN
            IF v_parent_type NOT IN ('edi', 'piso_planta') THEN
                RAISE EXCEPTION 'Error: Una estructura de tipo "area_seccion" solo puede tener un padre de tipo "edi" o "piso_planta". El padre actual es de tipo "%".', v_parent_type;
            END IF;
        END IF;
    END IF;

    IF NEW.id_est_fisica = NEW.id_est_padre AND NEW.id_museo = NEW.id_museo THEN
        RAISE EXCEPTION 'Error: Una estructura no puede ser su propia padre.';
    END IF;

    RETURN NEW; 
END;
$$;


CREATE TRIGGER trg_validar_estructura_fisica
BEFORE INSERT OR UPDATE ON public.estructura_fisica
FOR EACH ROW
EXECUTE FUNCTION validar_estructura_fisica_reglas();

---------------------Trigger para validar fechas en hechos historicos–

CREATE OR REPLACE FUNCTION public.validar_fecha_hecho_historico()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    fecha_fundacion_museo date;
BEGIN
    -- Obtener la fecha de fundación del museo correspondiente
    SELECT fecha_fundacion INTO fecha_fundacion_museo FROM museo WHERE id_museo = NEW.id_museo;

    IF NEW.ano < fecha_fundacion_museo THEN
        RAISE EXCEPTION 'La fecha del hecho histórico (%) no puede ser anterior a la fecha de fundación del museo (%)',
            NEW.ano, fecha_fundacion_museo;
    END IF;

    RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER trg_validar_fecha_hecho_historico
    BEFORE INSERT OR UPDATE 
    ON public.hecho_historico
    FOR EACH ROW
    EXECUTE FUNCTION public.validar_fecha_hecho_historico();


---------------------Trigger para validar fechas en el historico de conservacion–
CREATE OR REPLACE FUNCTION public.validar_fechas()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF NEW.fecha_fin_cons IS NOT NULL AND NEW.fecha_inicio_cons IS NOT NULL THEN
        IF NEW.fecha_fin_cons < NEW.fecha_inicio_cons THEN
            RAISE EXCEPTION 'La fecha de fin de conservación (%) no puede ser anterior a la fecha de inicio (%).', NEW.fecha_fin_cons, NEW.fecha_inicio_cons;
        END IF;
    END IF;
    RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER validar_fechas
    BEFORE INSERT OR UPDATE 
    ON public.hist_conservacion
    FOR EACH ROW
    EXECUTE FUNCTION public.validar_fechas();

---------------------Trigger para validar fechas en el historico de movimiento de la obra
CREATE OR REPLACE FUNCTION public.validar_fechas_hm()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF NEW.fecha_fin IS NOT NULL AND NEW.fecha_llegada IS NOT NULL THEN
        IF NEW.fecha_fin < NEW.fecha_llegada THEN
            RAISE EXCEPTION 'La fecha de fin (%) no puede ser menor que la fecha de llegada (%).', NEW.fecha_fin, NEW.fecha_llegada;
        END IF;
    END IF;
    RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER validar_fechas_hm
    BEFORE INSERT OR UPDATE 
    ON public.hist_obra_movimiento
    FOR EACH ROW
    EXECUTE FUNCTION public.validar_fechas_hm();

--------------------- Trigger para validar fechas en el historico de cierre temporal
CREATE OR REPLACE FUNCTION public.validar_fechas_hstc()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF NEW.fecha_fin_hct IS NOT NULL AND NEW.fecha_inicio_hct IS NOT NULL THEN
        IF NEW.fecha_fin_hct < NEW.fecha_inicio_hct THEN
            RAISE EXCEPTION 'La fecha_fin (% ) no puede ser menor que fecha_inicio (%)', NEW.fecha_fin_hct, NEW.fecha_inicio_hct;
        END IF;
    END IF;
    RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER validar_fechas_hstc
    BEFORE INSERT OR UPDATE 
    ON public.historico_cierre_temp
    FOR EACH ROW
    EXECUTE FUNCTION public.validar_fechas_hstc();

--------------------- Trigger en el historico de empleado

CREATE OR REPLACE FUNCTION public.validar_fechas_te()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF NEW.fecha_fin IS NOT NULL AND NEW.fecha_inicio IS NOT NULL THEN
        IF NEW.fecha_fin < NEW.fecha_inicio THEN
            -- Mensaje de error corregido y uso de la columna correcta (fecha_inicio)
            RAISE EXCEPTION 'La fecha_fin (%) no puede ser menor que la fecha_inicio (%).', NEW.fecha_fin, NEW.fecha_inicio;
        END IF;
    END IF;
    RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER validar_fechas_hse
    BEFORE INSERT OR UPDATE 
    ON public.historico_empleado
    FOR EACH ROW
    EXECUTE FUNCTION public.validar_fechas_te();

CREATE OR REPLACE TRIGGER validar_fechas_tipo_ticket
    BEFORE INSERT OR UPDATE 
    ON public.tipo_ticket
    FOR EACH ROW
    EXECUTE FUNCTION public.validar_fechas_te();

-- trigger para validar que la hora de cierre del museo no sea menor que la hora de apertura–
CREATE OR REPLACE FUNCTION public.validar_hora_cierre()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF NEW.hora_cierre < NEW.hora_apertura THEN
        RAISE EXCEPTION 'La hora de cierre (%) no puede ser menor que la hora de apertura (%)',
            NEW.hora_cierre, NEW.hora_apertura;
    END IF;

    RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER trg_validar_hora_cierre
    BEFORE INSERT OR UPDATE 
    ON public.horario
    FOR EACH ROW
    EXECUTE FUNCTION public.validar_hora_cierre();

---------------------Trigger verificación de actividad de conservación activa, cierre automatico de historico

CREATE OR REPLACE FUNCTION validar_actividad_conservacion_unica_por_empleado_obra()
RETURNS TRIGGER AS $$
DECLARE
    fecha_cierre DATE;
    actividades_cerradas INT;
BEGIN
    IF NEW.fecha_fin_cons IS NULL THEN
        fecha_cierre := NEW.fecha_inicio_cons;
    ELSE
        fecha_cierre := NEW.fecha_fin_cons;
    END IF;
	
    UPDATE hist_conservacion
    SET fecha_fin_cons = fecha_cierre
    WHERE id_obra = NEW.id_obra
      AND id_cata_museo = NEW.id_cata_museo
      AND id_emp_pro = NEW.id_emp_pro
      AND fecha_fin_cons IS NULL
      AND NOT (
        id_obra = COALESCE(OLD.id_obra, -1)
        AND id_cata_museo = COALESCE(OLD.id_cata_museo, -1)
        AND id_emp_pro = COALESCE(OLD.id_emp_pro, -1)
        AND fecha_inicio_cons = COALESCE(OLD.fecha_inicio_cons, '1900-01-01')
      )
    RETURNING 1 INTO actividades_cerradas;

    IF actividades_cerradas > 0 THEN
        RAISE NOTICE 'Se ha cerrado la actividad anterior con fecha: %', fecha_cierre;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_actividad_unica ON hist_conservacion;

CREATE TRIGGER trg_validar_actividad_unica
BEFORE INSERT OR UPDATE ON hist_conservacion
FOR EACH ROW
EXECUTE FUNCTION validar_actividad_conservacion_unica_por_empleado_obra();

--------------------------- INSERTS ---------------------------------------

-- INSERTS OBRA --

INSERT INTO obra (nom_obra, fecha_creacion_periodo, dim_descrip, est_art, tecnica_mat, tipo_obra) VALUES
('Northern Lake', '1912', '71.7 × 102.4 cm', 'paisaje canadiense de estilo posimpresionista (Grupo de los Siete)', 'Óleo sobre lienzo', 'pintura'),
('The West Wind', '1917', '120.7 × 137.9', 'paisajismo canadiense (posimpresionista)', 'Óleo sobre lienzo', 'pintura'),
('Standing Figure', '1956', '32.1 × 8.3 × 11.8 cm', 'escultura moderna/expresionista', 'Bronce', 'escultura'),
('Figure décorative', '1908', 'aprox. 73 cm de altura', 'escultura modernista/de estilo Art Nouveau', 'Bronce', 'escultura');

INSERT INTO obra (nom_obra, fecha_creacion_periodo, dim_descrip, est_art, tecnica_mat, tipo_obra) VALUES
('The Death of General Wolfe', '1770', '151 × 213 cm', 'pintura histórica de estilo neoclásico', 'Óleo sobre lienzo', 'pintura'),
('The Jack Pine', '1916–17', '127.9 × 139.8 cm', 'paisaje canadiense (icono del Grupo de los Siete)', 'Óleo sobre lienzo', 'pintura'),
('Age of Bronze', '1876–77', 'tamaño natural (~1.8 m)', 'escultura realista', 'Bronce', 'escultura'),
('The Storm', '1920', '33.9 × 21.5 × 38.9 cm', 'pequeña figura alegórica modernista', 'Bronce', 'escultura');

INSERT INTO obra (nom_obra, fecha_creacion_periodo, dim_descrip, est_art, tecnica_mat, tipo_obra) VALUES
('The Last Supper', '2001', '200 x 300 cm', 'Arte contemporáneo con influencia islámica', 'Acrílico sobre lienzo', 'pintura'),
('Desert Landscape I', '1998', '120 x 180 cm', 'Expresionismo abstracto', 'Óleo sobre lienzo', 'pintura'),
('Calligraphy Chair', '2007', '100 x 60 x 60 cm', 'Arte islámico contemporáneo', 'Madera tallada e inscripciones caligráficas', 'escultura'),
('Dhow', '2004', '150 x 300 x 100 cm', 'Arte marítimo tradicional reinterpretado', 'Fibra de vidrio y madera', 'escultura');

INSERT INTO obra (nom_obra, fecha_creacion_periodo, dim_descrip, est_art, tecnica_mat, tipo_obra) VALUES
('Purple Robe and Anemones', '1937', '73 × 60 cm', 'Expresionismo', 'Óleo sobre lienzo', 'pintura'),
('La Coiffure', '1905', '82 × 65 cm', 'Cubismo', 'Óleo y carboncillo sobre lienzo', 'pintura'),
('Dancer Looking at the Sole of Her Right Foot', '1885', '110 x 40 x 30 cm', 'Academicismo', 'Bronce', 'escultura'),
('Three Piece Reclining Figure', '1962', '172.72 x 279.035 x 137.16 cm', 'Modernismo', 'Bronce', 'escultura');

INSERT INTO obra (nom_obra, fecha_creacion_periodo, dim_descrip, est_art, tecnica_mat, tipo_obra) VALUES
('Devi Mahatmya (Iluminación de Manuscrito)', 'Siglo XVII', '45 x 30 cm', 'Miniatura hindú (escuela Rajput)', 'Temple y oro sobre papel', 'pintura'),
('Retrato de un Sufí', 'Siglo XVII', '25 x 18 cm', 'Miniatura persa (escuela Safávida)', 'Temple y oro sobre papel', 'pintura'),
('Busto de Buda', 'Siglo XII', '60 x 30 x 30 cm', 'Arte khmer (Camboya)', 'Piedra arenisca tallada', 'escultura'),
('Figura de Vishnu acostado', 'Siglo XI', '120 x 40 x 30 cm', 'Arte Champa (actual Vietnam)', 'Bronce dorado', 'escultura');

INSERT INTO obra (nom_obra, fecha_creacion_periodo, dim_descrip, est_art, tecnica_mat, tipo_obra) VALUES
('Birds and Flowers of the Four Seasons', 'Siglo XVIII', '180 x 90 cm', 'Rimpa', 'Pigmentos naturales y oro sobre papel', 'pintura'),
('Landscape by the River', 'Siglo XVII', '130 x 60 cm', 'Escuela Kanō', 'Ink wash painting (sumi-e) sobre seda', 'pintura'),
('Busto de Buda Amida', '1928', '80 x 40 x 40 cm', 'Escultura moderna japonesa', 'Madera tallada y pintada', 'escultura'),
('Figura de Kannon Bosatsu', '1935', '90 x 35 x 35 cm', 'Escultura contemporánea inspirada en el budismo', 'Bronce fundido', 'escultura');

INSERT INTO obra (nom_obra, fecha_creacion_periodo, dim_descrip, est_art, tecnica_mat, tipo_obra) VALUES
('White Umbrella', '1989', '162 x 130 cm', 'Danwon-gyeongjeong (Danwon School) / Abstracción geométrica', 'Óleo sobre lienzo', 'pintura'),
('Untitled (Red and Blue)', '1980', '91 x 116.7 cm', 'Tansaekhwa (escuela monocromática coreana)', 'Óleo sobre lienzo', 'pintura'),
('Stone Circle', '1985', '180 x 180 x 60 cm', 'Arte conceptual inspirado en cultura ancestral', 'Piedra natural', 'escultura'),
('The Shadow of Time', '2003', '200 x 100 x 100 cm', 'Arte contemporáneo abstracto', 'Hierro oxidado', 'escultura');

INSERT INTO obra (nom_obra, fecha_creacion_periodo, dim_descrip, est_art, tecnica_mat, tipo_obra) VALUES
('Blue Poles', '1952', '212 × 489 cm', 'Expresionismo abstracto', 'Esmalte y pintura de aluminio sobre lienzo', 'pintura'),
('Warlugulong', '1977', '202 × 337.5 cm', 'Arte indígena australiano contemporáneo', 'Pintura acrílica sobre lienzo', 'pintura'),
('Bird in Space', 'Circa 1931–1936', 'Aproximadamente 184 cm de altura', 'Escultura modernista', 'Mármol blanco con base de piedra arenisca', 'escultura'),
('Ouroboros', '2023', '9 metros de largo × 4.5 metros de alto', 'Arte contemporáneo, escultura pública monumental', 'Acero inoxidable reciclado, perforado con 46,000 orificios', 'escultura');

-------- INSERT EMPLEADO MANTENIMIENTO --------

INSERT INTO empleado_mantenimiento (doc_identidad_man, nom_emp_man, ape_emp_man, tipo) VALUES
(100100101, 'John', 'Mitchell', 'vigi'),
(100100102, 'Robert', 'Harris', 'vigi'),
(100100103, 'Michael', 'Clark', 'mant'),
(100100104, 'David', 'Robinson', 'mant');

INSERT INTO empleado_mantenimiento (doc_identidad_man, nom_emp_man, ape_emp_man, tipo) VALUES
(100100201, 'James', 'Owen', 'vigi'),
(100100202, 'William', 'Turner', 'vigi'),
(100100203, 'Richard', 'Bennett', 'mant'),
(100100204, 'Thomas', 'Ellis', 'mant');

INSERT INTO empleado_mantenimiento (doc_identidad_man, nom_emp_man, ape_emp_man, tipo) VALUES
(200200101, 'Park', 'Jin-Woo', 'vigi'),
(200200102, 'Kim', 'Min-Ho', 'vigi'),
(200200103, 'Lee', 'Sang-Chul', 'mant'),
(200200104, 'Choi', 'Kwang-Sik', 'mant');

INSERT INTO empleado_mantenimiento (doc_identidad_man, nom_emp_man, ape_emp_man, tipo) VALUES
(300300101, 'Ahmed', 'Al-Fahim', 'vigi'),
(300300102, 'Khalid', 'Al-Maktoum', 'vigi'),
(300300103, 'Mohammed', 'Al-Nuaimi', 'mant'),
(300300104, 'Ali', 'Al-Dhaheri', 'mant');

INSERT INTO empleado_mantenimiento (doc_identidad_man, nom_emp_man, ape_emp_man, tipo) VALUES
(400400101, 'Hans', 'Meier', 'vigi'),
(400400102, 'Peter', 'Müller', 'vigi'),
(400400103, 'Urs', 'Zimmermann', 'mant'),
(400400104, 'Markus', 'Weber', 'mant');

INSERT INTO empleado_mantenimiento (doc_identidad_man, nom_emp_man, ape_emp_man, tipo) VALUES
(500500101, 'John', 'Williams', 'vigi'),
(500500102, 'Simon', 'Thompson', 'vigi'),
(500500103, 'Daniel', 'Anderson', 'mant'),
(500500104, 'Andrew', 'Wilson', 'mant');

INSERT INTO empleado_mantenimiento (doc_identidad_man, nom_emp_man, ape_emp_man, tipo) VALUES
(600600101, 'Carlos', 'Rojas', 'vigi'),
(600600102, 'Luis', 'Vega', 'vigi'),
(600600103, 'Mario', 'Delgado', 'mant'),
(600600104, 'Fernando', 'Ortega', 'mant');

INSERT INTO empleado_mantenimiento (doc_identidad_man, nom_emp_man, ape_emp_man, tipo) VALUES
(700700101, 'Takashi', 'Sato', 'vigi'),
(700700102, 'Kazuki', 'Tanaka', 'vigi'),
(700700103, 'Yoshio', 'Fujimoto', 'mant'),
(700700104, 'Shun', 'Nakamura', 'mant');

--------------INSERTS DE IDIOMA ------------
INSERT INTO idioma (nom_idioma) VALUES
('Mandarín'),
('Español'),
('Inglés'),
('Hindi'),
('Árabe'),
('Francés'),
('Ruso'),
('Portugués'),
('Bengalí'),
('Italiano'),
('Japonés'),
('Alemán'),
('Coreano');

----------- INSERTS LUGAR GEOGRAFICO -----------
INSERT INTO lugar_geografico (nombre_lugar_geo, tipo_lugar, continente) VALUES
('Suiza', 'p', 'Europa'),
('Japon', 'p', 'Asia'),
('Australia', 'p', 'Oceania'),
('Canada', 'p','America'),
('Corea del Sur', 'p', 'Asia'),
('Emiratos Arabes Unidos', 'p', 'Asia'),
('Estados Unidos','p','America'),
('Francia','p','Europa'),
('Arabia Saudita','p','Asia'),
('Irak','p','Asia'),
('Kuwait','p','Asia'),
('Alemania','p','Europa'),
('Rumania','p','Europa'),
('Espana','p','Europa'),
('Reino Unido','p','Europa'),
('India','p','Asia'),
('Iran','p','Asia'),
('Camboya','p','Asia'),
('Vietnam','p','Asia');

INSERT INTO lugar_geografico (id_lugar_padre, nombre_lugar_geo, tipo_lugar)
SELECT id_lugar_geo, 'Toronto', 'c'
FROM lugar_geografico WHERE nombre_lugar_geo = 'Canada';

INSERT INTO lugar_geografico (id_lugar_padre, nombre_lugar_geo, tipo_lugar)
SELECT id_lugar_geo, 'Ottawa', 'c'
FROM lugar_geografico WHERE nombre_lugar_geo = 'Canada';

INSERT INTO lugar_geografico (id_lugar_padre, nombre_lugar_geo, tipo_lugar)
SELECT id_lugar_geo, 'Seul', 'c'
FROM lugar_geografico WHERE nombre_lugar_geo = 'Corea del Sur';

INSERT INTO lugar_geografico (id_lugar_padre, nombre_lugar_geo, tipo_lugar)
SELECT id_lugar_geo, 'Sharjah', 'c'
FROM lugar_geografico WHERE nombre_lugar_geo = 'Emiratos Arabes Unidos';

INSERT INTO lugar_geografico (id_lugar_padre, nombre_lugar_geo, tipo_lugar)
SELECT id_lugar_geo, 'Zúrich', 'c'
FROM lugar_geografico WHERE nombre_lugar_geo = 'Suiza';

INSERT INTO lugar_geografico (id_lugar_padre, nombre_lugar_geo, tipo_lugar)
SELECT id_lugar_geo, 'Baltimore', 'c'
FROM lugar_geografico WHERE nombre_lugar_geo = 'Estados Unidos'; 

INSERT INTO lugar_geografico (id_lugar_padre, nombre_lugar_geo, tipo_lugar)
SELECT id_lugar_geo, 'Canberra', 'c'
FROM lugar_geografico WHERE nombre_lugar_geo = 'Australia';

INSERT INTO lugar_geografico (id_lugar_padre, nombre_lugar_geo, tipo_lugar)
SELECT id_lugar_geo, 'Shiga', 'c'
FROM lugar_geografico WHERE nombre_lugar_geo = 'Japon';

--------------- INSERTS MUSEO -----------------

INSERT INTO museo (id_lugar_geo, nombre_museo, fecha_fundacion, resumen_mision)
SELECT id_lugar_geo, 'Galería de arte de Ontario', '1900-01-01', 'Promover el arte canadiense e internacional' 
FROM lugar_geografico 
WHERE nombre_lugar_geo = 'Toronto';

INSERT INTO museo (id_lugar_geo, nombre_museo, fecha_fundacion, resumen_mision)
SELECT id_lugar_geo, 'Galería nacional de arte de Canadá', '1880-05-23', 'Colecciones de arte canadiense y europeo' 
FROM lugar_geografico 
WHERE nombre_lugar_geo = 'Ottawa';

INSERT INTO museo (id_lugar_geo, nombre_museo, fecha_fundacion, resumen_mision)
SELECT id_lugar_geo, 'SeMA Seoul Museum of Art', '1985-01-01', 'Arte contemporáneo en Corea del Sur' 
FROM lugar_geografico 
WHERE nombre_lugar_geo = 'Seul';

INSERT INTO museo (id_lugar_geo, nombre_museo, fecha_fundacion, resumen_mision)
SELECT id_lugar_geo, 'Museo de arte de Sharjah', '1971-01-01', 'Promoción del arte árabe y multicultural' 
FROM lugar_geografico 
WHERE nombre_lugar_geo = 'Sharjah';

INSERT INTO museo (id_lugar_geo, nombre_museo, fecha_fundacion, resumen_mision)
SELECT id_lugar_geo, 'Museum Rietberg', '1951-04-13', 'Colecciones de arte no europeo' 
FROM lugar_geografico 
WHERE nombre_lugar_geo = 'Zúrich';

INSERT INTO museo (id_lugar_geo, nombre_museo, fecha_fundacion, resumen_mision)
SELECT id_lugar_geo, 'Baltimore Museum of Art', '1914-01-01', 'Conecta el arte con Baltimore y el mundo, promoviendo excelencia artística y equidad sociall' 
FROM lugar_geografico 
WHERE nombre_lugar_geo = 'Baltimore';

INSERT INTO museo (id_lugar_geo, nombre_museo, fecha_fundacion, resumen_mision)
SELECT id_lugar_geo, 'Galería Nacional de Australia', '1967-01-01', 'Institución cultural nacional para las artes visuales de Australia' 
FROM lugar_geografico 
WHERE nombre_lugar_geo = 'Canberra';

INSERT INTO museo (id_lugar_geo, nombre_museo, fecha_fundacion, resumen_mision)
SELECT id_lugar_geo, 'Museo Miho', '1996-11-01', 'Arte antiguo y arquitectura contemporánea' 
FROM lugar_geografico 
WHERE nombre_lugar_geo = 'Shiga';

----------INSERTS ESTRUCUTURA FISICA ---------
INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Edificio Grange Park', 'edi', 'Edificio principal del AGO', '111 Queen’s Park, Toronto', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 1', 'piso_planta', 'Primer nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Grange Park')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Welcome Desk', 'area_seccion', 'Área de recepción y atención al público',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 1')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Tienda de Regalos', 'area_seccion', 'Venta de productos relacionados con el museo',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 1')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 2', 'piso_planta', 'Segundo nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Grange Park')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Walker Court', 'area_seccion', 'Espacio central del museo',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 2')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Edificio Galería Nacional de arte de Canadá', 'edi', 'Edificio principal del museo', '380 Sussex Dr, Ottawa', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 1', 'piso_planta', 'Primer nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Galería Nacional de arte de Canadá')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Welcome Desk', 'area_seccion', 'Área de recepción y atención al público',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 1')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Sala de exposición temporal', 'area_seccion', 'Espacio para exposiciones temporales',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 1')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 2', 'piso_planta', 'Segundo nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Galería Nacional de arte de Canadá')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Biblioteca y archivos', 'area_seccion', 'Acceso a documentos históricos y artísticos',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 2')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Edificio Museo de Arte de Sharjah', 'edi', 'Edificio principal del museo', 'Sharjah Art Museum, UAE', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Welcome Desk', 'area_seccion', 'Recepción general del museo',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Museo de Arte de Sharjah')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Edificio Museo de Arte de Baltimore', 'edi', 'Edificio principal del museo', '10 Art Museum Drive, Baltimore', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 1', 'piso_planta', 'Primer nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Museo de Arte de Baltimore')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Quiet Room', 'area_seccion', 'Espacio para reflexión y meditación',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 1')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 2', 'piso_planta', 'Segundo nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Museo de Arte de Baltimore')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Auditorium', 'area_seccion', 'Espacio para eventos y conferencias',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 2')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Wurtzburger Garden', 'edi', 'Jardín escultórico del museo', '10 Art Museum Drive, Baltimore', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Edificio Villa Wesendonck', 'edi', 'Edificio principal del museo', 'Gablerstrasse 15, Zurich', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 1', 'piso_planta', 'Primer nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Villa Wesendonck')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Café', 'area_seccion', 'Área de descanso y servicios',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 1')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 2', 'piso_planta', 'Segundo nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Villa Wesendonck')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Edificio Main Hall', 'edi', 'Edificio principal del museo', 'Miho Museum, Shiga, Japón', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Welcome Desk', 'area_seccion', 'Área de recepción y atención al público',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Main Hall')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Edificio B1F', 'edi', 'Nivel subterráneo del museo', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Sala Audiovisual', 'area_seccion', 'Espacio para presentaciones multimedia',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio B1F')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Sede principal de Seosomun', 'edi', 'Edificio principal del museo', 'Seoul Museum of Art, Seosomun', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 1', 'piso_planta', 'Primer nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Sede principal de Seosomun')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'SeMa Café', 'area_seccion', 'Área de descanso y servicios',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'piso_planta' AND nombre_est = 'Piso 1')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 2', 'piso_planta', 'Segundo nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Sede principal de Seosomun')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Edificio Galería Nacional de Australia', 'edi', 'Edificio principal del museo', 'Parkes Pl, Canberra', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Planta baja', 'piso_planta', 'Primer nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Galería Nacional de Australia')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre)
SELECT 
    id_museo, 'Sculpture Garden', 'edi', 'Espacio al aire libre con esculturas', 'Parkes Pl, Canberra', NULL
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 1', 'piso_planta', 'Segundo nivel del edificio',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Galería Nacional de Australia')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));
INSERT INTO estructura_fisica (id_museo, nombre_est, tipo_est, descripcion_est, id_est_padre)
SELECT 
    id_museo, 'Piso 2', 'piso_planta', 'Mezzanine',
    (SELECT id_est_fisica FROM estructura_fisica 
     WHERE id_museo = m.id_museo AND tipo_est = 'edi' AND nombre_est = 'Edificio Galería Nacional de Australia')
FROM museo m
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

------------ INSERTS ESTRUCTURA ORGANIZACIONAL --------------

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Dirección General', 'dire', 1, 'Responsable de liderazgo ejecutivo y visión estratégica'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Curaduría', 'depa', 2, 'Coordina colecciones artísticas del museo'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Exposiciones, Colecciones y Conservación', 'depa', 2, 'Organización de exposiciones y cuidado de obras'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Finanzas y Operaciones', 'depa', 2, 'Contabilidad, presupuestos y administración operacional'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Tecnologías de la Información', 'secc', 3, 'Soporte técnico y sistemas informáticos'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Servicios de Instalaciones', 'secc', 3, 'Mantenimiento de edificios e infraestructura'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Desarrollo y Recaudación de Fondos', 'depa', 2, 'Captación de recursos y relaciones con donantes'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Recursos Humanos', 'depa', 2, 'Gestión del talento humano'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));


INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Dirección General', 'dire', 1, 'Liderazgo ejecutivo del museo'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Curaduría y Colecciones', 'depa', 2, 'Departamentos dedicados al arte'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Conservación', 'depa', 2, 'Preservación y restauración de obras'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Educación y Programas Públicos', 'depa', 2, 'Actividades educativas y guiadas'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Investigación y Biblioteca', 'depa', 2, 'Archivos, biblioteca y documentación'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Marketing y Comunicaciones', 'depa', 2, 'Difusión pública y promoción'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Desarrollo y Donaciones', 'depa', 2, 'Relaciones con patrocinadores y recaudación'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Administración', 'depa', 2, 'Finanzas, RR.HH., logística y sistemas'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));


INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Director de SeMA', 'dire', 1, 'Máximo responsable del museo'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Management Bureau', 'depa', 2, 'Planificación estratégica y coordinación'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'División Administrativa', 'depa', 2, 'Planificación operativa y control interno'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'División de Instalaciones', 'depa', 2, 'Mantenimiento y seguridad'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'División de Asuntos Públicos', 'depa', 2, 'Relaciones públicas y marketing'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Bureau Curatorial', 'depa', 2, 'Colecciones, adquisiciones y préstamo'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'División de Exposiciones y Educación', 'depa', 2, 'Planificación de exposiciones y programas educativos'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Equipo de Intercambio Internacional', 'secc', 3, 'Coordinación de eventos internacionales'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Dirección Ejecutiva', 'dire', 1, 'Dirección del museo y consejo directivo'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Curaduría', 'depa', 2, 'Colecciones permanentes y exposiciones temporales'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Conservación', 'depa', 2, 'Preservación de obras de arte'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Educación y Programas Comunitarios', 'depa', 2, 'Programas educativos y comunitarios'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Administración General', 'depa', 2, 'Finanzas, RR.HH. y logística'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));


INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Dirección Ejecutiva', 'dire', 1, 'Dirección del museo y consejo directivo'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Curaduría', 'depa', 2, 'Arte de Asia, África, América y Oceanía'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Servicios de Colección y Conservación', 'depa', 2, 'Registradores, conservación y mantenimiento'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Educación y Programación Cultural', 'depa', 2, 'Talleres, visitas guiadas y actividades didácticas'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Administración', 'depa', 2, 'Finanzas, RR.HH., TI, comunicación institucional'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Soporte al Visitante', 'secc', 3, 'Ventas, cafetería, seguridad'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Oficina del Director', 'dire', 1, 'Liderazgo ejecutivo y equipo de dirección'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Recursos Humanos y Operaciones', 'depa', 2, 'Senior HR y COO'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Curaduría', 'depa', 2, 'Chief Curator y equipos por departamentos'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Educación y Participación', 'depa', 2, 'Programas comunitarios y talleres'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Advancement y Desarrollo', 'depa', 2, 'Recaudación de fondos y membresías'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Comunicaciones', 'depa', 2, 'Prensa, marketing y redes sociales'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Conservación', 'secc', 3, 'Departamento de conservación de colecciones'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Administración', 'depa', 2, 'Finanzas, IT, seguridad y mantenimiento'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Dirección General', 'dire', 1, 'Director Ejecutivo y equipo senior'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Asistentes de Dirección', 'depa', 2, 'Cargos ejecutivos clave'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Curaduría', 'depa', 2, 'Departamentos especializados en arte'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Exposiciones y Colecciones', 'depa', 2, 'Adquisiciones y manejo de colecciones'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Conservación', 'depa', 2, 'Conservación preventiva e interventiva'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Educación y Programas Públicos', 'depa', 2, 'Actividades educativas y talleres'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Marketing y Comunicación', 'depa', 2, 'Promoción institucional y redes sociales'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Finanzas y Administración', 'depa', 2, 'Contabilidad, RR.HH., logística'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Operaciones', 'depa', 2, 'Infraestructura, instalaciones y servicios'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Programas Especiales', 'depa', 2, 'Iniciativas indígenas y digitales'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));


INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Dirección General', 'dire', 1, 'Lidera la institución. Supervisión global, planificación estratégica y gestión presupuestaria bajo la Fundación Shumei'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Departamento de Curaduría', 'depa', 2, 'Responsable de colecciones artísticas y arqueológicas. Selecciona, estudia y organiza piezas para exhibición'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Departamento de Conservación', 'depa', 2, 'Encargado de preservar y restaurar el acervo del museo'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Departamento de Educación', 'depa', 2, 'Diseña y gestiona programas didácticos y actividades educativas'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Departamento de Comunicación y Prensa', 'depa', 2, 'Manejo de relaciones públicas, marketing, redes sociales y publicaciones'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Departamento Administrativo y de Finanzas', 'depa', 2, 'Gestión de contabilidad, recursos humanos, presupuesto y aspectos legales'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Operaciones y Mantenimiento', 'depa', 2, 'Responsable del soporte técnico e infraestructura del museo'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO estructura_organizacional (id_museo, nombre_est_or, tipo_est_org, nivel, descripcion)
SELECT 
    id_museo, 'Servicios al Visitante', 'secc', 3, 'Atención directa al público, información y experiencia del visitante'
FROM museo 
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

----------- INSERTS EMPLEADO PROFESIONAL ----------------

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000001, 'Julian', 'Posada', 'Cox', '1960-05-15', 'Mas', '+14165550123', 'Anne', 'emily.smith@artegaleriaontario.ca'
FROM museo WHERE nombre_museo = 'Galería de arte de Ontario';

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000002, 'James', 'Brown', 'Williams', '1985-08-22', 'Mas', '+14165550456', 'Robert', 'james.brown@artegaleriaontario.ca'
FROM museo WHERE nombre_museo = 'Galería de arte de Ontario';

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, correo
)
SELECT 
    id_museo, 10000003, 'Sophia', 'Lee', 'Chen', '1995-03-10', 'Fem', '+14165550789', 'sophia.lee@artegaleriaontario.ca'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

--Galeria nacional de arte de canadá
INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000004, 'Luc', 'Martin', 'Gagnon', '1988-11-30', 'Mas', '+16135550123', 'Pierre', 'luc.martin@galerianacionalcanada.org'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('galeria nacional de arte de canada'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, correo
)
SELECT 
    id_museo, 10000005, 'Amina', 'Diop', 'Sow', '1992-07-25', 'Fem', '+16135550456', 'amina.diop@galerianacionalcanada.org'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('galeria nacional de arte de canada'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000006, 'Carlos', 'Rodríguez', 'López', '1983-02-18', 'Mas', '+16135550789', 'Andrés', 'carlos.rodriguez@galerianacionalcanada.org'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('galeria nacional de arte de canada'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000007, 'Kim', 'Minsu', 'Lee', '1993-09-05', 'Mas', '+8225550123', 'Joonho', 'kim.minsu@sema-seoul.kr'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, correo
)
SELECT 
    id_museo, 10000008, 'Park', 'Jiyeong', 'Kim', '1987-12-14', 'Fem', '+8225550456', 'park.jiyeong@sema-seoul.kr'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000009, 'Jeong', 'Hyeonwoo', 'Park', '1991-04-30', 'Mas', '+8225550789', 'Dohyeon', 'jeong.hyeonwoo@sema-seoul.kr'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000010, 'Ahmed', 'Al-Maktoum', 'Al-Falasi', '1989-10-20', 'Mas', '+97165550123', 'Saeed', 'ahmed.al-maktoum@sharjahart.ae'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, correo
)
SELECT 
    id_museo, 10000011, 'Fatima', 'Al-Nuaimi', 'Al-Suwaidi', '1994-06-12', 'Fem', '+97165550456', 'fatima.al-nuaimi@sharjahart.ae'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000012, 'Youssef', 'El-Sayed', 'Hassan', '1986-01-28', 'Mas', '+97165550789', 'Karim', 'youssef.elsayed@sharjahart.ae'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000013, 'Anna', 'Müller', 'Schneider', '1990-03-08', 'Fem', '+41445550123', 'Sophie', 'anna.mueller@rietberg.ch'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, correo
)
SELECT 
    id_museo, 10000014, 'Lars', 'Weber', 'Meier', '1984-11-17', 'Mas', '+41445550456', 'lars.weber@rietberg.ch'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000015, 'Clara', 'Dubois', 'Fischer', '1996-09-22', 'Fem', '+41445550789', 'Marie', 'clara.dubois@rietberg.ch'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000016, 'Yamada', 'Taro', 'Sato', '1987-02-14', 'Mas', '+81775550123', 'Ken', 'yamada.tarou@miho.jp'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, correo
)
SELECT 
    id_museo, 10000017, 'Satoko', 'Hanako', 'Suzuki', '1993-08-30', 'Fem', '+81775550456', 'satoko.hanako@miho.jp'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000018, 'Tanaka', 'Ichiro', 'Takahashi', '1982-05-07', 'Mas', '+81775550789', 'Jiro', 'tanaka.ichiro@miho.jp'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000019, 'John', 'Doe', 'Smith', '1986-07-19', 'Mas', '+14435550123', 'Michael', 'john.doe@baltimoremuseum.art'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, correo
)
SELECT 
    id_museo, 10000020, 'Maria', 'Garcia', 'Lopez', '1991-12-04', 'Fem', '+14435550456', 'maria.garcia@baltimoremuseum.art'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000021, 'David', 'Wilson', 'Brown', '1989-04-16', 'Mas', '+14435550789', 'James', 'david.wilson@baltimoremuseum.art'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000022, 'Emma', 'Taylor', 'Anderson', '1992-10-11', 'Fem', '+6125550123', 'Grace', 'emma.taylor@nga.gov.au'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, correo
)
SELECT 
    id_museo, 10000023, 'Liam', 'Nguyen', 'Tran', '1985-01-29', 'Mas', '+6125550456', 'liam.nguyen@nga.gov.au'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO empleado_profesional (
    id_museo, doc_identidad, primer_nombre, primer_apellido, segundo_apellido, 
    fecha_nacimiento, genero, telefono, segundo_nombre, correo
)
SELECT 
    id_museo, 10000024, 'Olivia', 'White', 'Martin', '1994-06-03', 'Fem', '+6125550789', 'Rose', 'olivia.white@nga.gov.au'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

-------- INSERT TITULO FORMACION ---------

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Licenciatura en Bellas Artes', '1982-06-15', 'Título universitario en Bellas Artes, enfocado en pintura y escultura', 'Pintura'
FROM empleado_profesional
WHERE primer_nombre = 'Julian' AND primer_apellido = 'Posada';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Ingeniería de Sistemas', '2008-07-30', 'Título universitario en Ingeniería, especialización en sistemas computacionales', 'Sistemas Computacionales'
FROM empleado_profesional
WHERE primer_nombre = 'James' AND primer_apellido = 'Brown';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Maestría en Historia del Arte', '2015-09-10', 'Estudios avanzados en Historia del Arte con énfasis en arte contemporáneo', 'Historia del Arte'
FROM empleado_profesional
WHERE primer_nombre = 'Sophia' AND primer_apellido = 'Lee';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Doctorado en Ciencias Sociales', '2012-11-20', 'Doctorado en ciencias sociales con investigación en cultura y arte', 'Ciencias Sociales'
FROM empleado_profesional
WHERE primer_nombre = 'Luc' AND primer_apellido = 'Martin';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Licenciatura en Gestión Cultural', '2014-05-10', 'Gestión de proyectos culturales y museológicos', 'Gestión Cultural'
FROM empleado_profesional
WHERE primer_nombre = 'Amina' AND primer_apellido = 'Diop';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Especialización en Conservación de Arte', '2013-03-15', 'Especialización en técnicas para conservar obras de arte', 'Conservación'
FROM empleado_profesional
WHERE primer_nombre = 'Carlos' AND primer_apellido = 'Rodríguez';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Licenciatura en Artes Visuales', '2010-07-01', 'Formación en artes visuales y diseño', 'Artes Visuales'
FROM empleado_profesional
WHERE primer_nombre = 'Kim' AND primer_apellido = 'Minsu';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Maestría en Curaduría', '2017-09-12', 'Programas avanzados en curaduría y exposiciones', 'Curaduría'
FROM empleado_profesional
WHERE primer_nombre = 'Park' AND primer_apellido = 'Jiyeong';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Diplomado en Historia del Arte Asiático', '2016-01-22', 'Diplomado especializado en arte asiático', 'Historia del Arte'
FROM empleado_profesional
WHERE primer_nombre = 'Jeong' AND primer_apellido = 'Hyeonwoo';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Licenciatura en Arte y Cultura', '2011-06-17', 'Estudios en arte y cultura contemporánea', 'Arte y Cultura'
FROM empleado_profesional
WHERE primer_nombre = 'Ahmed' AND primer_apellido = 'Al-Maktoum';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Maestría en Administración Cultural', '2018-08-05', 'Administración de instituciones culturales y museos', 'Administración Cultural'
FROM empleado_profesional
WHERE primer_nombre = 'Fatima' AND primer_apellido = 'Al-Nuaimi';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Especialización en Patrimonio Cultural', '2014-10-10', 'Protección y valorización del patrimonio cultural', 'Patrimonio Cultural'
FROM empleado_profesional
WHERE primer_nombre = 'Youssef' AND primer_apellido = 'El-Sayed';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Licenciatura en Historia del Arte Europeo', '2012-04-20', 'Formación en historia del arte europeo clásico', 'Historia del Arte'
FROM empleado_profesional
WHERE primer_nombre = 'Anna' AND primer_apellido = 'Müller';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Diplomado en Museología', '2015-07-25', 'Técnicas museológicas y exhibición', 'Museología'
FROM empleado_profesional
WHERE primer_nombre = 'Lars' AND primer_apellido = 'Weber';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Maestría en Gestión de Museos', '2019-03-19', 'Gestión administrativa y cultural de museos', 'Gestión Museística'
FROM empleado_profesional
WHERE primer_nombre = 'Clara' AND primer_apellido = 'Dubois';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Licenciatura en Historia del Arte Asiático', '2010-11-30', 'Formación en arte y cultura asiática', 'Historia del Arte Asiático'
FROM empleado_profesional
WHERE primer_nombre = 'Yamada' AND primer_apellido = 'Taro';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Maestría en Conservación', '2016-12-08', 'Técnicas avanzadas de conservación de arte', 'Conservación'
FROM empleado_profesional
WHERE primer_nombre = 'Satoko' AND primer_apellido = 'Hanako';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Especialización en Arte Japonés', '2013-05-14', 'Especialización en arte y cultura japonesa', 'Arte Japonés'
FROM empleado_profesional
WHERE primer_nombre = 'Tanaka' AND primer_apellido = 'Ichiro';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Licenciatura en Bellas Artes', '2011-02-22', 'Formación integral en bellas artes', 'Bellas Artes'
FROM empleado_profesional
WHERE primer_nombre = 'John' AND primer_apellido = 'Doe';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Diplomado en Historia del Arte Norteamericano', '2017-04-30', 'Estudios sobre arte norteamericano contemporáneo', 'Historia del Arte'
FROM empleado_profesional
WHERE primer_nombre = 'Maria' AND primer_apellido = 'Garcia';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Maestría en Gestión Cultural', '2019-09-10', 'Administración de proyectos culturales', 'Gestión Cultural'
FROM empleado_profesional
WHERE primer_nombre = 'David' AND primer_apellido = 'Wilson';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Licenciatura en Artes Visuales', '2010-08-19', 'Estudios en artes visuales y diseño', 'Artes Visuales'
FROM empleado_profesional
WHERE primer_nombre = 'Emma' AND primer_apellido = 'Taylor';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Maestría en Curaduría', '2018-11-03', 'Curaduría y gestión de exposiciones', 'Curaduría'
FROM empleado_profesional
WHERE primer_nombre = 'Liam' AND primer_apellido = 'Nguyen';

INSERT INTO titulo_formacion (id_emp_pro, nombre_titulo, momento, descripcion, especializacion)
SELECT 
    id_emp_pro, 'Licenciatura en Bellas Artes', '2012-05-23', 'Formación integral en bellas artes', 'Bellas Artes'
FROM empleado_profesional
WHERE primer_nombre = 'Olivia' AND primer_apellido = 'White';

-------------- INSERTS COLECCION --------------

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Canadiense', 'Obras emblemáticas de la identidad visual de Canadá', 'Paisaje, Grupo de los Siete, identidad, indígena (histórico), regionalismo', 1
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Moderno', 'Explora el arte europeo y estadounidense de principios a mediados del siglo XX', 'Vanguardias, siglo XX, abstracción, expresionismo, surrealismo, cubismo', 2
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Europeo', 'Se enfoca en maestros italianos del siglo XVII, arte francés del siglo XIX, y obras históricas y realistas', 'Viejos Maestros, Barroco, Impresionismo, Neoclásico, Italia, Francia', 2
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría y Colecciones';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Canadiense', 'Obras emblemáticas de la identidad visual de Canadá', 'Paisaje, Grupo de los Siete, identidad, indígena (histórico), regionalismo', 1
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría y Colecciones';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Contemporáneo Árabe', 'Obras modernas y actuales de artistas de la región árabe, explorando diversas temáticas, estilos y medios', 'Moderno, actual, Oriente Medio, Norte de África, experimental, diversidad, identidad', 1
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Islámico Contemporáneo', 'Se inspira, reinterpreta o dialoga con las ricas tradiciones artísticas islámicas', 'Caligrafía, geometría, espiritualidad, tradición, reinterpretación', 2
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Americano', 'Arte creado en Estados Unidos desde el período colonial hasta el siglo XX', 'EE.UU., colonial, siglo XIX, paisajes, retratos, bodegones, identidad americana', 1
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Europeo del Siglo XIX', 'Corrientes artísticas europeas del siglo XIX, como el Impresionismo, el Post-Impresionismo y el Realismo', 'Francia, Impresionismo, Realismo, Degas, Rodin, siglo XIX, academicismo', 2
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Moderno', 'Arte vanguardista y experimental del siglo XX', 'vanguardia, cubismo, Picasso, modernismo, Henry Moore, abstracción, experimentación', 3
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte de la India', 'Expresiones artísticas de la India y regiones circundantes', 'Hindú, budista, miniatura, Rajput, Mughal, deidad, ritual, subcontinente', 2
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte del Cercano Oriente', 'Culturas islámicas, destacando la caligrafía, miniaturas persas...', 'Persa, Safávida, Otomano, caligrafía, miniatura, sufí, mezquita', 1
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte del Sudeste Asiático', 'Países como Tailandia, Camboya, Vietnam e Indonesia...', 'Khmer, Champa, budista, hindú, templos, bronce, piedra, ritual, Mekong', 3
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Japonés Clásico', 'Herencia artística de Japón desde períodos antiguos hasta el pre-moderno', 'Muromachi, Rimpa, Kanō, Ukiyo-e, tinta, seda, biombos, caligrafía, samurai, paisaje', 1
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo Miho'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Departamento de Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Japonés Moderno', 'Incluye obras de artistas japoneses del siglo XX que fusionan tradiciones clásicas con influencias modernas', 'modernismo, reinterpretación, fusión, posguerra, experimentación', 2
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo Miho'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Departamento de Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Coreano Contemporáneo', 'Expresiones artísticas modernas y actuales de Corea del Sur', 'Posguerra, siglo XX, siglo XXI, abstracción, Tansaekhwa, conceptual, monocromático', 1
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Bureau Curatorial';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Pintura Abstracta Coreana', 'Diversas corrientes y desarrollos de la pintura abstracta en Corea', 'Abstracción, geométrica, Tansaekhwa, minimalismo, materia, gesto, monocromo', 2
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Bureau Curatorial';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Escultura Coreana Contemporánea', 'Exploran materiales diversos, conceptos y a menudo dialogan con la cultura tradicional', 'Volumen, espacio, materialidad, conceptual, ancestral, moderno, figurativo', 3
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Bureau Curatorial';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Moderno Internacional', 'Fuera de Australia, con una notable colección de Expresionismo Abstracto', 'vanguardia, abstracción, Pollock, Brâncuși, Modernismo, Europa, América, posguerra', 2
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Indígena Australiano', 'Arte creado por los pueblos originarios de Australia', 'Aborigen, Primeras Naciones, desierto, Dreaming, tierra, narrativa', 1
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

INSERT INTO coleccion (id_museo, id_est_org, nombre_coleccion, descripcion_caracteristicas, palabras_clave, orden_recorrido)
SELECT 
    m.id_museo, eo.id_est_org, 'Arte Australiano Contemporáneo', 'Obras de artistas australianos desde la segunda mitad del siglo XX hasta hoy', 'Australia, actual, Lindy Lee, instalación, concepto, materiales', 3
FROM museo m
JOIN estructura_organizacional eo ON eo.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  AND eo.tipo_est_org = 'depa'
  AND eo.nombre_est_or = 'Curaduría';

------------------------ INSERTS SALA EXPOSICION ------------------------
INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Thomson Canadian - 216',
    'Sala dedicada al arte canadiense'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 1';

-- Sala: Margaret Eaton - 137 (Piso 2)
INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Margaret Eaton - 137',
    'Sala dedicada al arte canadiense'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 2';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'A106',
    'Espacio para exposiciones temporales'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 1';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'A108',
    'Exposiciones del patrimonio artístico canadiense'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 1';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'C218',
    'Arte europeo clásico y renacentista'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 2';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'C208',
    'Arte europeo moderno'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 2';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Beaux Arts 101',
    'Área para arte contemporáneo árabe'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND ef.tipo_est = 'edi'
  AND ef.nombre_est = 'Edificio Museo de Arte de Sharjah';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Beaux Arts 102',
    'Área para arte contemporáneo árabe'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND ef.tipo_est = 'edi'
  AND ef.nombre_est = 'Edificio Museo de Arte de Sharjah';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Other Modernities 103',
    'Arte islámico contemporáneo'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND ef.tipo_est = 'edi'
  AND ef.nombre_est = 'Edificio Museo de Arte de Sharjah';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Other Modernities 104',
    'Arte islámico contemporáneo'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND ef.tipo_est = 'edi'
  AND ef.nombre_est = 'Edificio Museo de Arte de Sharjah';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Cone Wing - Gallery 4',
    'Arte americano histórico'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 2';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Cone Wing - Gallery 5',
    'Arte europeo del siglo XIX'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 2';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'A24',
    'Arte de la India'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 1';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'B33',
    'Arte del sudeste asiático'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 2';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'C42',
    'Arte del cercano oriente'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 2';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'E101',
    'Arte japonés clásico'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo Miho'))
  AND ef.tipo_est = 'edi'
  AND ef.nombre_est = 'Edificio B1F';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'E103',
    'Arte japonés clásico'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo Miho'))
  AND ef.tipo_est = 'edi'
  AND ef.nombre_est = 'Edificio B1F';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'E105',
    'Arte japonés moderno'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo Miho'))
  AND ef.tipo_est = 'edi'
  AND ef.nombre_est = 'Edificio B1F';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'E106',
    'Arte japonés moderno'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Museo Miho'))
  AND ef.tipo_est = 'edi'
  AND ef.nombre_est = 'Edificio B1F';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Gallery 1F',
    'Arte coreano contemporáneo'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 1';


INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Gallery 2F',
    'Escultura coreana contemporánea'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 2';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Gallery 7',
    'Arte moderno internacional'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 1'; 

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Gallery 10',
    'Arte indígena australiano'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 1';

INSERT INTO sala_exp (id_museo, id_est_fisica, nombre_sala_expo, descripcion)
SELECT 
    m.id_museo,
    ef.id_est_fisica,
    'Gallery 20',
    'Arte australiano contemporáneo'
FROM museo m
JOIN estructura_fisica ef ON ef.id_museo = m.id_museo
WHERE unaccent(UPPER(m.nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  AND ef.tipo_est = 'piso_planta'
  AND ef.nombre_est = 'Piso 2';

------------- INSERTS EVENTO ----------------

INSERT INTO evento (id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento, lugar_exposicion, costo, cantidad_personas, institucion_educativa)
SELECT 
    id_museo,'Exposicion de Arte moderno', '2025-01-15', '2025-02-20', 'Sala Thomson Canadian - 216', 20.00, 80, NULL
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO evento (id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento, lugar_exposicion, costo, cantidad_personas, institucion_educativa)
SELECT 
    id_museo,'Exposicion de Arte Canadiense','2025-03-18','2025-03-29','Sala: Margaret Eaton - 137', 30.00, 180,'Royal High School'
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO evento (id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento, lugar_exposicion, costo, cantidad_personas, institucion_educativa)
SELECT 
    id_museo,'Exposicion de Arte Canadiense', '2025-02-27', '2025-03-10', 'Sala A108', 15.00, 40, NULL
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO evento (id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento, lugar_exposicion, costo, cantidad_personas, institucion_educativa)
SELECT 
    id_museo, 'Exposicion de Arte Europeo', '2025-01-19', '2025-01-20', 'Sala C208', NULL, 190, 'Colegio Clayton Hights'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO evento (id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento, lugar_exposicion, costo, cantidad_personas, institucion_educativa)
SELECT 
    id_museo, 'Exposicion de Pintura Abstracta Coreana', '2025-04-16', '2025-04-20', 'Sala: Gallery 1F', 20.00, 40, NULL
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO evento (id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento, lugar_exposicion, costo, cantidad_personas, institucion_educativa)
SELECT 
    id_museo, 'Exposicion de Escultura Coreana Contemporanea', '2025-03-15', '2025-03-18', 'Sala: Gallery 2F', 20.00,  25, NULL
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO evento (id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento, lugar_exposicion, costo, cantidad_personas, institucion_educativa)
SELECT 
    id_museo, 'Exposicion de Arte COntemporaneo Arabe', '2025-05-05', '2025-05-08', 'Sala: Beaux 101', 50.00, 60, NULL
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO evento (id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento, lugar_exposicion, costo, cantidad_personas, institucion_educativa)
SELECT 
    id_museo, 'Exposicion de Arte Islamico Contemporaneo', '2025-01-09', '2025-01-20', 'Sala: Other Modernities', NULL, 150, 'Colegio: International Schools Group'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO evento (id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento, lugar_exposicion, costo, cantidad_personas, institucion_educativa)
SELECT 
    id_museo, 'Exposicion de Arte de la India', '2025-02-13', '2025-02-20', 'Sala: A24', 20.00, 50, NULL
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

-----------INSERTS HECHO HISTORICO-------------

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1900-01-01', 'La Galería de Arte de Ontario fue fundada como el "Art Museum of Toronto" por ciudadanos privados.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1911-01-01', 'La galería adquirió el edificio y la propiedad de "The Grange" mediante un legado privado, estableciéndose en su hogar de larga data en el centro de Toronto.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '2008-01-01', 'Se inauguró una dramática y compleja remodelación y expansión del museo, liderada por el renombrado arquitecto Frank Gehry.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1880-05-23', 'La Galería Nacional de Arte de Canadá fue creada, convirtiéndose en una de las instituciones culturales nacionales más antiguas de Canadá.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1913-01-01', 'El Gobierno de Canadá aprobó la Ley de la Galería Nacional, formalizando el mandato de la institución como museo nacional de arte.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1988-01-01', 'La Galería se trasladó a un nuevo y distintivo complejo diseñado por el arquitecto israelí Moshe Safdie, su actual hogar.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1985-01-01', 'El Museo de Arte de Seúl comenzó a adquirir obras de arte con el objetivo de formar una colección que reflejara el flujo del arte coreano desde la década de 1950.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1988-01-01', 'SeMA abrió sus puertas por primera vez en el área del Palacio Gyeonghuigung, con seis salas de exposición y un parque de esculturas al aire libre.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '2002-01-01', 'Se inauguró una sede principal más grande detrás del Palacio Deoksugung, reemplazando la sucursal de Gyeonghuigung como la sede principal.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1995-01-01', 'El Museo de Arte de Sharjah abrió inicialmente en la mansión Bait Al Serkal del siglo XIX, en el área de Al Shuwaihean.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1997-01-01', 'Se inauguró un nuevo edificio para el museo durante la 3ª Bienal de Sharjah, bajo el patrocinio del Jeque Sultan bin Mohammed Al Qasimi.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '2006-01-01', 'Se estableció la Autoridad de Museos de Sharjah (SMA), como un departamento gubernamental independiente para supervisar los museos de Sharjah.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1951-04-13', 'El Barón Eduard von der Heydt donó su colección de arte a la ciudad de Zúrich, sentando las bases para la creación del museo.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1952-01-01', 'El Museo Rietberg fue inaugurado tras la conversión de la Villa Wesendonck en un museo, con Johannes Itten como su primer director.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '2007-01-01', 'Se abrió una nueva y gran extensión subterránea, diseñada por Alfred Grazioli y Adolf Krischanitz, conectando con el edificio antiguo sin alterarlo.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1914-01-01', 'El Museo de Arte de Baltimore fue fundado con una sola pintura, con la creencia de que el acceso al arte es integral para una vida cívica vibrante.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1929-01-01', 'El edificio de tres pisos del museo, diseñado por John Russell Pope, abrió en abril, inspirado en el Metropolitan Art Museum.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1949-01-01', 'La icónica Colección Cone fue legada al BMA tras la muerte de Etta Cone, consolidando su reputación en el arte moderno.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1967-01-01', 'El Primer Ministro Harold Holt anunció formalmente que el gobierno construiría la Galería Nacional de Australia como un museo de arte público nacional.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1973-01-01', 'Comenzó la construcción del edificio de la Galería Nacional de Australia, diseñado por Colin Madigan.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1982-01-01', 'El edificio de la Galería Nacional de Australia fue oficialmente inaugurado por Su Majestad la Reina Isabel II.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1996-12-01', 'El Museo Miho, un proyecto conjunto japonés y americano, fue completado en agosto por el arquitecto I. M. Pei y Kibowkan International, Inc.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)
SELECT id_museo, '1997-01-01', 'El Museo Miho abrió sus puertas, diseñado por I. M. Pei, con más del 80% del edificio sumergido bajo tierra para preservar el entorno natural.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));
INSERT INTO hecho_historico (id_museo, ano, descripcion_hecho)

SELECT id_museo, '1997-01-02', 'La colección del museo, iniciada por la fundadora Mihoko Koyama con arte japonés, se expandió para abarcar arte antiguo de todo el mundo, incluyendo piezas de Egipto, Grecia, Roma, China y Asia Occidental, como parte integral de la visión del museo desde su apertura.'
FROM museo WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

----------------INSERTS ARTISTA---------------
INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Posimpresionismo, paisajismo canadiense, color expresivo, pincelada gestual.','Tom Thomson','Thomas John','Thomson','1877-08-05','1917-07-08',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Canada')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Expresionismo, surrealismo, figuras alargadas y esbeltas, enfoque existencialista, esculturas en bronce con texturas rugosas.','Alberto Giacometti','Alberto','Giacometti','1901-10-10','1966-01-11',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Suiza')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES
('Fauvismo, modernismo, uso vibrante del color, formas simplificadas, innovador en pintura y escultura.','Henri Matisse','Henri Émile Benoît','Matisse','1869-12-31','1954-11-03',
	(SELECT id_lugar_geo
	FROM lugar_geografico
	WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Francia')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES
('Pintura histórica, neoclasicismo, composiciones dramáticas, influencia académica.','Benjamin West','Benjamin','West','1738-10-10','1820-03-11',
	(SELECT id_lugar_geo
	FROM lugar_geografico
	WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Estados Unidos')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES
('Escultura realista, expresionismo, detallismo anatómico, innovación en textura y forma.','Auguste Rodin','François Auguste René','Rodin','1840-11-12','1917-11-17',
	(SELECT id_lugar_geo
	FROM lugar_geografico
	WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Francia')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES
('Escultura monumental, modernismo, simbolismo, uso de líneas limpias y formas abstractas.','Walter S. Allward','Walter Seymour','Allward','1874-08-18','1955-04-24',
	(SELECT id_lugar_geo
	FROM lugar_geografico
	WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Canadá')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES
('Arte contemporáneo, influencia islámica, temas sociales y culturales, multimedia y pintura.','Ahmed Mater','Ahmed Abdulrazaq','Mater','1979-01-01', NULL,
	(SELECT id_lugar_geo
	FROM lugar_geografico
	WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Arabia Saudita')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES
('Caligrafía contemporánea, arte islámico moderno, uso expresivo de tinta y formas tradicionales.','Hassan Massoudy','Hassan','Massoudy','1934-01-01', NULL,
	(SELECT id_lugar_geo
	FROM lugar_geografico
	WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Irak')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES
('Arte contemporáneo, arte islámico, instalaciones multimedia, crítica social y cultural.','Monira Al Qadiri','Monira','Al Qadiri','1983-01-01', NULL,
	(SELECT id_lugar_geo
	FROM lugar_geografico
	WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Kuwait')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES
('Arte contemporáneo, pintura y escultura, temas marítimos tradicionales, uso mixto de materiales.','Abdul Qader Al Rais','Abdul Qader','Al Rais','1951-01-01', NULL,
	(SELECT id_lugar_geo
	FROM lugar_geografico
	WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Emiratos Árabes Unidos')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES
('Cubismo, surrealismo, arte moderno, versatilidad estilística, ruptura con la tradición.','Pablo Picasso','Pablo','Picasso','1881-10-25','1973-04-08',
	(SELECT id_lugar_geo
	FROM lugar_geografico
	WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('España')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Impresionismo, escenas de ballet, retrato realista, dibujo preciso, movimiento y luz.','Edgar Degas','Edgar','Degas','1834-07-19','1917-09-27',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Francia')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Escultura moderna, formas orgánicas, figuras abstractas, materiales naturales, monumentalismo.','Henry Moore','Henry','Moore','1898-07-30','1986-08-31',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Reino Unido')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Miniaturismo indio, escuela Rajput, color vibrante, arte religioso hindú, manuscritos ilustrados.','Sahibdin','Sahibdin','',
    NULL,NULL,
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('India')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Miniatura persa, escuela safávida, líneas refinadas, retratos poéticos, elegancia ornamental.','Reza Abbasi','Reza','Abbasi','1565-01-01','1635-01-01',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Iran')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Arte jemer, escultura religiosa, piedra tallada, influencias budistas e hinduistas, estilo clásico camboyano.','Khot Vichetr','Khot','Vichetr',NULL,NULL,
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Camboya')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Arte Champa, escultura religiosa, bronce dorado, iconografía hindú, estilo tradicional vietnamita.','Trân Văn Lộc','Trân','Văn Lộc',NULL,NULL,
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Vietnam')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Rimpa, pintura decorativa, naturaleza estilizada, tinta y oro sobre papel, estética refinada japonesa.','Sakai Hōitsu','Sakai','Hōitsu','1761-01-01','1828-01-01',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Japon')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Escuela Kanō, sumi-e, paisajismo clásico japonés, tinta sobre seda, estilo tradicional aristocrático.','Kanō Tan''yū','Kanō','Tan''yū','1602-01-01','1674-01-01',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Japon')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Grabado en madera (sōsaku hanga), escultura moderna japonesa, líneas audaces, estilo expresionista.','Un''ichi Hiratsuka','Un''ichi','Hiratsuka','1895-11-17','1997-11-18',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Japon')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Escultura contemporánea japonesa, influencia budista, bronce fundido, formas realistas y expresivas.','Takamura Kōun','Takamura','Kōun','1852-01-01','1934-01-01',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Japon')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Abstracción geométrica, Danwon School, pintura moderna coreana, óleo sobre lienzo.','Kwon Young-woo','Kwon','Young-woo','1946-01-01',NULL,
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Corea del Sur')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Tansaekhwa (escuela monocromática coreana), pintura minimalista, óleo sobre lienzo.','Park Seo-bo','Park','Seo-bo','1931-01-01',NULL,
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Corea del Sur')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Arte conceptual, escultura inspirada en cultura ancestral, piedra natural.','Kim Jong-suk','Kim','Jong-suk','1943-01-01',NULL,
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Corea del Sur')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Arte contemporáneo abstracto, escultura, hierro oxidado.','Choi Jeong-hwa','Choi','Jeong-hwa','1961-01-01',NULL,
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Corea del Sur')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Expresionismo abstracto, pintura gestual, técnica de goteo.','Jackson Pollock','Jackson','Pollock','1912-01-28','1956-08-11',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Estados Unidos')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Arte indígena australiano contemporáneo, pintura acrílica sobre lienzo, motivos tradicionales y contemporáneos.','Clifford Possum Tjapaltjarri','Clifford Possum','Tjapaltjarri','1932-01-01','2002-01-01',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Australia')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Escultura modernista, formas simplificadas, materiales variados (mármol, bronce).','Constantin Brâncuși','Constantin','Brâncuși','1876-02-19','1957-03-16',
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Rumania')))
);

INSERT INTO artista (resumen_carac_art, nombre_artistico, nombre_artista, apellido, fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo)VALUES 
('Arte contemporáneo, escultura pública monumental, técnicas mixtas, influencia cultural asiática.','Lindy Lee','Lindy','Lee','1956-01-01', NULL,
    (SELECT id_lugar_geo 
     FROM lugar_geografico 
     WHERE unaccent(UPPER(nombre_lugar_geo)) = unaccent(UPPER('Australia')))
);

--------------INSERTS SALA COL------------

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org,  c.id_coleccion,  c.id_museo,  s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Galería de arte de Ontario'))
  AND c.nombre_coleccion ILIKE '%Arte Moderno%'
  AND s.nombre_sala_expo ILIKE '%Thomson%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT 
    c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Galería de arte de Ontario'))
  AND c.nombre_coleccion ILIKE '%Arte Canadiense%'
  AND s.nombre_sala_expo ILIKE '%Margaret%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  AND c.nombre_coleccion ILIKE '%Arte Canadiense%'
  AND s.nombre_sala_expo ILIKE '%A108%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion,  c.id_museo,  s.id_est_fisica,  s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  AND c.nombre_coleccion ILIKE '%Arte Europeo%'
  AND s.nombre_sala_expo ILIKE '%C208%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND c.nombre_coleccion ILIKE '%Contemporáneo Árabe%'
  AND s.nombre_sala_expo ILIKE '%Beaux Arts 101%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND c.nombre_coleccion ILIKE '%Islámico Contemporáneo%'
  AND s.nombre_sala_expo ILIKE '%Other Modernities 104%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion,  c.id_museo, s.id_est_fisica,  s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND c.nombre_coleccion ILIKE '%Contemporáneo Árabe%'
  AND s.nombre_sala_expo ILIKE '%Beaux Arts 102%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museo de arte de Sharjah'))
  AND c.nombre_coleccion ILIKE '%Islámico Contemporáneo%'
  AND s.nombre_sala_expo ILIKE '%Beaux Arts 103%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Baltimore Museum of Art'))
  AND c.nombre_coleccion ILIKE '%Arte Americano%'
  AND s.nombre_sala_expo ILIKE '%Gallery 4%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT c.id_est_org, c.id_coleccion, c.id_museo,  s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Baltimore Museum of Art'))
  AND c.nombre_coleccion ILIKE '%Arte Europeo del Siglo XIX%'
  AND s.nombre_sala_expo ILIKE '%Gallery 5%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Baltimore Museum of Art'))
  AND c.nombre_coleccion ILIKE '%Arte Moderno%'
  AND s.nombre_sala_expo ILIKE '%Gallery 5%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museum Rietberg'))
  AND c.nombre_coleccion ILIKE '%Arte de la India%'
  AND s.nombre_sala_expo ILIKE '%A24%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museum Rietberg'))
  AND c.nombre_coleccion ILIKE '%Arte del Cercano Oriente%'
  AND s.nombre_sala_expo ILIKE '%C42%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museum Rietberg'))
  AND c.nombre_coleccion ILIKE '%Arte del Sudeste Asiático%'
  AND s.nombre_sala_expo ILIKE '%B33%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org,  c.id_coleccion,  c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museo Miho'))
  AND c.nombre_coleccion ILIKE '%Japonés Clásico%'
  AND s.nombre_sala_expo ILIKE '%E101%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org,  c.id_coleccion,  c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museo Miho'))
  AND c.nombre_coleccion ILIKE '%Japonés Clásico%'
  AND s.nombre_sala_expo ILIKE '%E103%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museo Miho'))
  AND c.nombre_coleccion ILIKE '%Japonés Moderno%'
  AND s.nombre_sala_expo ILIKE '%E105%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Museo Miho'))
  AND c.nombre_coleccion ILIKE '%Japonés Moderno%'
  AND s.nombre_sala_expo ILIKE '%E106%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  AND c.nombre_coleccion ILIKE '%Arte Coreano Contemporáneo%'
  AND s.nombre_sala_expo ILIKE '%Gallery 1F%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion, c.id_museo,  s.id_est_fisica,  s.id_sala_exp,  c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  AND c.nombre_coleccion ILIKE '%Pintura Abstracta Coreana%'
  AND s.nombre_sala_expo ILIKE '%Gallery 1F%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  AND c.nombre_coleccion ILIKE '%Escultura Coreana Contemporánea%'
  AND s.nombre_sala_expo ILIKE '%Gallery 2F%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Galería Nacional de Australia'))
  AND c.nombre_coleccion ILIKE '%Indígena Australiano%'
  AND s.nombre_sala_expo ILIKE '%Gallery 7%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT  c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Galería Nacional de Australia'))
  AND c.nombre_coleccion ILIKE '%Moderno Internacional%'
  AND s.nombre_sala_expo ILIKE '%Gallery 10%';

INSERT INTO sala_col (id_est_org, id_coleccion, id_museo, id_est_fisica, id_sala_exp, orden_recorrido)
SELECT c.id_est_org, c.id_coleccion, c.id_museo, s.id_est_fisica, s.id_sala_exp, c.orden_recorrido
FROM coleccion c
JOIN sala_exp s ON c.id_museo = s.id_museo
WHERE unaccent(UPPER((SELECT nombre_museo FROM museo WHERE id_museo = c.id_museo))) = unaccent(UPPER('Galería Nacional de Australia'))
  AND c.nombre_coleccion ILIKE '%Australiano Contemporáneo%'
  AND s.nombre_sala_expo ILIKE '%Gallery 20%';

----------------------INSERTS AUTOR -----------

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista,  o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Northern Lake' AND o.fecha_creacion_periodo = '1912'
WHERE 
    a.nombre_artistico = 'Tom Thomson';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'The West Wind' AND o.fecha_creacion_periodo = '1917'
WHERE 
    a.nombre_artistico = 'Tom Thomson';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Standing Figure' AND o.fecha_creacion_periodo = '1956'
WHERE 
    a.nombre_artistico = 'Alberto Giacometti';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Figure décorative' AND o.fecha_creacion_periodo = '1908'
WHERE 
    a.nombre_artistico = 'Henri Matisse';

INSERT INTO autor (id_artista, id_obra)
SELECT  a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'The Death of General Wolfe' AND o.fecha_creacion_periodo = '1770'
WHERE 
    a.nombre_artistico = 'Benjamin West';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'The Jack Pine' AND o.fecha_creacion_periodo = '1916–17'
WHERE 
    a.nombre_artistico = 'Tom Thomson';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Age of Bronze' AND o.fecha_creacion_periodo = '1876–77'
WHERE 
    a.nombre_artistico = 'Auguste Rodin';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'The Storm' AND o.fecha_creacion_periodo = '1920'
WHERE 
    a.nombre_artistico = 'Walter S. Allward';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'The Last Supper' AND o.fecha_creacion_periodo = '2001'
WHERE 
    a.nombre_artistico = 'Ahmed Mater';

-- Desert Landscape I (1998) – Hassan Massoudy
INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Desert Landscape I' AND o.fecha_creacion_periodo = '1998'
WHERE 
    a.nombre_artistico = 'Hassan Massoudy';


INSERT INTO autor (id_artista, id_obra)
SELECT  a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Calligraphy Chair' AND o.fecha_creacion_periodo = '2007'
WHERE 
    a.nombre_artistico = 'Monira Al Qadiri';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Dhow' AND o.fecha_creacion_periodo = '2004'
WHERE 
    a.nombre_artistico = 'Abdul Qader Al Rais';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Purple Robe and Anemones' AND o.fecha_creacion_periodo = '1937'
WHERE 
    a.nombre_artistico = 'Henri Matisse';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'La Coiffure' AND o.fecha_creacion_periodo = '1905'
WHERE 
    a.nombre_artistico = 'Pablo Picasso';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Dancer Looking at the Sole of Her Right Foot' AND o.fecha_creacion_periodo = '1885'
WHERE 
    a.nombre_artistico = 'Edgar Degas';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Three Piece Reclining Figure' AND o.fecha_creacion_periodo = '1962'
WHERE 
    a.nombre_artistico = 'Henry Moore';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Devi Mahatmya (Iluminación de Manuscrito)' AND o.fecha_creacion_periodo = 'Siglo XVII'
WHERE 
    a.nombre_artistico = 'Sahibdin';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Retrato de un Sufí' AND o.fecha_creacion_periodo = 'Siglo XVII'
WHERE 
    a.nombre_artistico = 'Reza Abbasi';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Busto de Buda' AND o.fecha_creacion_periodo = 'Siglo XII'
WHERE 
    a.nombre_artistico = 'Khot Vichetr';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Figura de Vishnu acostado' AND o.fecha_creacion_periodo = 'Siglo XI'
WHERE 
    a.nombre_artistico = 'Trân Văn Lộc';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Birds and Flowers of the Four Seasons' AND o.fecha_creacion_periodo = 'Siglo XVIII'
WHERE 
    a.nombre_artistico = 'Sakai Hōitsu';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Landscape by the River' AND o.fecha_creacion_periodo = 'Siglo XVII'
WHERE 
    a.nombre_artistico = 'Kanō Tan''yū';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Busto de Buda Amida' AND o.fecha_creacion_periodo = '1928'
WHERE 
    a.nombre_artistico = 'Un''ichi Hiratsuka';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Figura de Kannon Bosatsu' AND o.fecha_creacion_periodo = '1935'
WHERE 
    a.nombre_artistico = 'Takamura Kōun';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'White Umbrella' AND o.fecha_creacion_periodo = '1989'
WHERE 
    a.nombre_artistico = 'Kwon Young-woo';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Untitled (Red and Blue)' AND o.fecha_creacion_periodo = '1980'
WHERE 
    a.nombre_artistico = 'Park Seo-bo';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Stone Circle' AND o.fecha_creacion_periodo = '1985'
WHERE 
    a.nombre_artistico = 'Kim Jong-suk';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'The Shadow of Time' AND o.fecha_creacion_periodo = '2003'
WHERE 
    a.nombre_artistico = 'Choi Jeong-hwa';

INSERT INTO autor (id_artista, id_obra)
SELECT  a.id_artista,  o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Blue Poles' AND o.fecha_creacion_periodo = '1952'
WHERE 
    a.nombre_artistico = 'Jackson Pollock';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Warlugulong' AND o.fecha_creacion_periodo = '1977'
WHERE 
    a.nombre_artistico = 'Clifford Possum Tjapaltjarri';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Bird in Space' AND o.fecha_creacion_periodo = 'Circa 1931–1936'
WHERE 
    a.nombre_artistico = 'Constantin Brâncuși';

INSERT INTO autor (id_artista, id_obra)
SELECT a.id_artista, o.id_obra
FROM 
    artista a
INNER JOIN 
    obra o ON o.nom_obra = 'Ouroboros' AND o.fecha_creacion_periodo = '2023'
WHERE 
    a.nombre_artistico = 'Lindy Lee';

------------ INSERTS IDIOMA HABLADO ------------

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Julian'
  AND e.primer_apellido = 'Posada';
INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Francés'
  AND e.primer_nombre = 'Julian'
  AND e.primer_apellido = 'Posada';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'James'
  AND e.primer_apellido = 'Brown';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Francés'
  AND e.primer_nombre = 'James'
  AND e.primer_apellido = 'Brown';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Sophia'
  AND e.primer_apellido = 'Lee';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Francés'
  AND e.primer_nombre = 'Sophia'
  AND e.primer_apellido = 'Lee';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Francés'
  AND e.primer_nombre = 'Luc'
  AND e.primer_apellido = 'Martin';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Luc'
  AND e.primer_apellido = 'Martin';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Francés'
  AND e.primer_nombre = 'Amina'
  AND e.primer_apellido = 'Diop';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Amina'
  AND e.primer_apellido = 'Diop';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Francés'
  AND e.primer_nombre = 'Carlos'
  AND e.primer_apellido = 'Rodríguez';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Carlos'
  AND e.primer_apellido = 'Rodríguez';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Coreano'
  AND e.primer_nombre = 'Kim'
  AND e.primer_apellido = 'Minsu';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Kim'
  AND e.primer_apellido = 'Minsu';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Coreano'
  AND e.primer_nombre = 'Park'
  AND e.primer_apellido = 'Jiyeong';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Park'
  AND e.primer_apellido = 'Jiyeong';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Coreano'
  AND e.primer_nombre = 'Jeong'
  AND e.primer_apellido = 'Hyeonwoo';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Jeong'
  AND e.primer_apellido = 'Hyeonwoo';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Árabe'
  AND e.primer_nombre = 'Ahmed'
  AND e.primer_apellido = 'Al-Maktoum';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Ahmed'
  AND e.primer_apellido = 'Al-Maktoum';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Árabe'
  AND e.primer_nombre = 'Fatima'
  AND e.primer_apellido = 'Al-Nuaimi';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Fatima'
  AND e.primer_apellido = 'Al-Nuaimi';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Árabe'
  AND e.primer_nombre = 'Youssef'
  AND e.primer_apellido = 'El-Sayed';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Youssef'
  AND e.primer_apellido = 'El-Sayed';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Alemán'
  AND e.primer_nombre = 'Anna'
  AND e.primer_apellido = 'Müller';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Anna'
  AND e.primer_apellido = 'Müller';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Alemán'
  AND e.primer_nombre = 'Lars'
  AND e.primer_apellido = 'Weber';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Lars'
  AND e.primer_apellido = 'Weber';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Alemán'
  AND e.primer_nombre = 'Clara'
  AND e.primer_apellido = 'Dubois';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Clara'
  AND e.primer_apellido = 'Dubois';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Japonés'
  AND e.primer_nombre = 'Yamada'
  AND e.primer_apellido = 'Taro';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Yamada'
  AND e.primer_apellido = 'Taro';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Japonés'
  AND e.primer_nombre = 'Satoko'
  AND e.primer_apellido = 'Hanako';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Satoko'
  AND e.primer_apellido = 'Hanako';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Japonés'
  AND e.primer_nombre = 'Tanaka'
  AND e.primer_apellido = 'Ichiro';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Tanaka'
  AND e.primer_apellido = 'Ichiro';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'John'
  AND e.primer_apellido = 'Doe';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Español'
  AND e.primer_nombre = 'John'
  AND e.primer_apellido = 'Doe';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Maria'
  AND e.primer_apellido = 'Garcia';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Español'
  AND e.primer_nombre = 'Maria'
  AND e.primer_apellido = 'Garcia';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'David'
  AND e.primer_apellido = 'Wilson';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Español'
  AND e.primer_nombre = 'David'
  AND e.primer_apellido = 'Wilson';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Emma'
  AND e.primer_apellido = 'Taylor';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Italiano'
  AND e.primer_nombre = 'Emma'
  AND e.primer_apellido = 'Taylor';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Liam'
  AND e.primer_apellido = 'Nguyen';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Italiano'
  AND e.primer_nombre = 'Liam'
  AND e.primer_apellido = 'Nguyen';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Inglés'
  AND e.primer_nombre = 'Olivia'
  AND e.primer_apellido = 'White';

INSERT INTO idioma_hablado (id_idioma, id_emp_pro)
SELECT i.id_idioma, e.id_emp_pro
FROM idioma i, empleado_profesional e
WHERE i.nom_idioma = 'Italiano'
  AND e.primer_nombre = 'Olivia'
  AND e.primer_apellido = 'White';

--------------------  INSERTS HORARIO ---------------------

INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 1, '10:30:00', '17:00:00' FROM museo WHERE nombre_museo = 'Galería de arte de Ontario';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 2, '10:30:00', '21:00:00' FROM museo WHERE nombre_museo = 'Galería de arte de Ontario';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 3, '10:30:00', '17:00:00' FROM museo WHERE nombre_museo = 'Galería de arte de Ontario';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 4, '10:30:00', '21:00:00' FROM museo WHERE nombre_museo = 'Galería de arte de Ontario';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 5, '10:30:00', '17:30:00' FROM museo WHERE nombre_museo = 'Galería de arte de Ontario';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 6, '10:30:00', '17:30:00' FROM museo WHERE nombre_museo = 'Galería de arte de Ontario';

INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 1, '09:30:00', '17:00:00' FROM museo WHERE nombre_museo = 'Galería nacional de arte de Canadá';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)  
SELECT id_museo, 2, '09:30:00', '17:00:00' FROM museo WHERE nombre_museo = 'Galería nacional de arte de Canadá';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)  
SELECT id_museo, 3, '09:30:00', '17:00:00' FROM museo WHERE nombre_museo = 'Galería nacional de arte de Canadá';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 4, '09:30:00', '20:00:00' FROM museo WHERE nombre_museo = 'Galería nacional de arte de Canadá';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 5, '09:30:00', '17:00:00' FROM museo WHERE nombre_museo = 'Galería nacional de arte de Canadá';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
 SELECT id_museo, 6, '09:30:00', '17:00:00' FROM museo WHERE nombre_museo = 'Galería nacional de arte de Canadá';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 7, '09:30:00', '17:00:00' FROM museo WHERE nombre_museo = 'Galería nacional de arte de Canadá';

INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 2, '10:00:00', '20:00:00' FROM museo WHERE nombre_museo = 'SeMA Seoul Museum of Art';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 3, '10:00:00', '20:00:00' FROM museo WHERE nombre_museo = 'SeMA Seoul Museum of Art';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 4, '10:00:00', '20:00:00' FROM museo WHERE nombre_museo = 'SeMA Seoul Museum of Art';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 5, '10:00:00', '20:00:00' FROM museo WHERE nombre_museo = 'SeMA Seoul Museum of Art';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 6, '10:00:00', '20:30:00' FROM museo WHERE nombre_museo = 'SeMA Seoul Museum of Art';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 7, '10:00:00', '20:30:00' FROM museo WHERE nombre_museo = 'SeMA Seoul Museum of Art';

INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 1, '09:00:00', '21:00:00' FROM museo WHERE nombre_museo = 'Museo de arte de Sharjah'; 
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 2, '09:00:00', '21:00:00' FROM museo WHERE nombre_museo = 'Museo de arte de Sharjah'; 
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 3, '09:00:00', '21:00:00' FROM museo WHERE nombre_museo = 'Museo de arte de Sharjah'; 
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 4, '09:00:00', '21:00:00' FROM museo WHERE nombre_museo = 'Museo de arte de Sharjah'; 
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 5, '09:00:00', '21:00:00' FROM museo WHERE nombre_museo = 'Museo de arte de Sharjah'; 
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 6, '09:00:00', '21:00:00' FROM museo WHERE nombre_museo = 'Museo de arte de Sharjah'; 
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 7, '16:00:00', '21:00:00' FROM museo WHERE nombre_museo = 'Museo de arte de Sharjah'; 

INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 3, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museum Rietberg';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 4, '10:00:00', '20:00:00' FROM museo WHERE nombre_museo = 'Museum Rietberg';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo,5, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museum Rietberg';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 6, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museum Rietberg';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 7, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museum Rietberg';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 1, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museum Rietberg';

INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo,2, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Baltimore Museum of Art';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 3, '10:00:00', '21:00:00' FROM museo WHERE nombre_museo = 'Baltimore Museum of Art';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 4, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Baltimore Museum of Art';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 5, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Baltimore Museum of Art';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 6, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Baltimore Museum of Art';

INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 1, '10:00', '17:00' FROM museo WHERE nombre_museo = 'Galería Nacional de Australia';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 2, '10:00', '17:00' FROM museo WHERE nombre_museo = 'Galería Nacional de Australia';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 3, '10:00', '17:00' FROM museo WHERE nombre_museo = 'Galería Nacional de Australia';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 4, '10:00', '17:00' FROM museo WHERE nombre_museo = 'Galería Nacional de Australia';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 5, '10:00', '17:00' FROM museo WHERE nombre_museo = 'Galería Nacional de Australia';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 6, '10:00', '17:00' FROM museo WHERE nombre_museo = 'Galería Nacional de Australia';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre)
SELECT id_museo, 7, '10:00', '17:00' FROM museo WHERE nombre_museo = 'Galería Nacional de Australia';

INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 2, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museo Miho';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 3, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museo Miho';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 4, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museo Miho';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 5, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museo Miho';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 6, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museo Miho';
INSERT INTO horario (id_museo, dia_museo, hora_apertura, hora_cierre) 
SELECT id_museo, 7, '10:00:00', '17:00:00' FROM museo WHERE nombre_museo = 'Museo Miho';

--------------- INSERTS TIPO TICKET -------------

INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ad', '2025-01-01', 25.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Galería de arte de Ontario'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ni', '2025-01-01', 12.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Galería de arte de Ontario'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'adm', '2025-01-01', 5.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Galería de arte de Ontario'));

INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ad', '2025-01-01', 22.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Galería nacional de arte de Canadá'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ni', '2025-01-01', 11.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Galería nacional de arte de Canadá'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'adm', '2025-01-01', 0.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Galería nacional de arte de Canadá'));

INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ad', '2025-01-01', 20.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('SeMA Seoul Museum of Art'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ni', '2025-01-01', 8.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('SeMA Seoul Museum of Art'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'adm', '2025-01-01', 0.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('SeMA Seoul Museum of Art'));

INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ad', '2025-01-01', 18.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Museo de arte de Sharjah'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ni', '2025-01-01', 7.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Museo de arte de Sharjah'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'adm', '2025-01-01', 3.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Museo de arte de Sharjah'));

INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ad', '2025-01-01', 30.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Museum Rietberg'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ni', '2025-01-01', 15.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Museum Rietberg'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'adm', '2025-01-01', 8.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Museum Rietberg'));

INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ad', '2025-01-01', 28.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Baltimore Museum of Art'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ni', '2025-01-01', 12.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Baltimore Museum of Art'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'adm', '2025-01-01', 5.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Baltimore Museum of Art'));

INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ad', '2025-01-01', 26.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Galería Nacional de Australia'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ni', '2025-01-01', 13.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Galería Nacional de Australia'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'adm', '2025-01-01', 0.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Galería Nacional de Australia'));

INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ad', '2025-01-01', 35.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Museo Miho'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'ni', '2025-01-01', 17.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Museo Miho'));
INSERT INTO tipo_ticket (id_museo, tipo_ticket, fecha_inicio, precio_ticket)
SELECT id_museo, 'adm', '2025-01-01', 10.00 FROM museo 
WHERE unaccent(upper(nombre_museo)) = unaccent(upper('Museo Miho'));

------------ INSERTS TICKETS DE ENTRADA -----------


INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-01 10:15:00', 'ad', 25.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-02 11:00:00', 'ni', 12.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-03 12:30:00', 'adm', 5.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'));


INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-01 09:00:00', 'ad', 22.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-02 10:30:00', 'ni', 11.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-03 14:00:00', 'adm', 0.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-04 15:15:00', 'ad', 22.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'));


INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-01 10:00:00', 'ad', 20.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-02 11:30:00', 'ni', 8.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-03 13:00:00', 'adm', 0.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-04 14:45:00', 'ad', 20.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-05 16:00:00', 'ni', 8.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'));


INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-01 10:30:00', 'ad', 18.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-02 12:00:00', 'ni', 7.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-03 13:30:00', 'adm', 3.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'));


INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-01 13:45:00', 'ad', 30.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-02 11:15:00', 'ni', 15.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-04 14:45:00', 'adm', 8.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-04 16:00:00', 'ad', 30.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'));


INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-01 10:00:00', 'ad', 28.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-02 11:30:00', 'ni', 12.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-03 13:00:00', 'adm', 5.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-04 15:00:00', 'ad', 28.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-05 16:30:00', 'ni', 12.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'));


INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-01 09:30:00', 'ad', 26.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-02 11:00:00', 'ni', 13.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-03 12:30:00', 'adm', 0.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-04 14:00:00', 'ad', 26.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'));


INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-01 10:45:00', 'ad', 35.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-02 12:15:00', 'ni', 17.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-03 13:45:00', 'adm', 10.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

INSERT INTO ticket_de_entrada (id_museo, fecha_hora_emision, tipo_ticket_entrada, monto_ticket_entrada)
SELECT 
    id_museo, '2025-06-04 15:30:00', 'ad', 35.00
FROM museo
WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'));

----------- INSERTS ASIGNACION MENSUAL ------------------

INSERT INTO asignacion_mensual (id_est_fisica, id_museo, id_emp_mant, fecha_inicio_asig, turno) VALUES
(2, 1, 1, '2025-06-01', 'Mañana'),
(3, 1, 2, '2025-06-01', 'Tarde'),
(4, 1, 3, '2025-06-01', 'Mañana');

INSERT INTO asignacion_mensual (id_est_fisica, id_museo, id_emp_mant, fecha_inicio_asig, turno) VALUES
(8, 2, 7, '2025-06-01', 'Mañana'),
(12, 2, 5, '2025-06-01', 'Tarde'),
(11, 2, 8, '2025-06-01', 'Noche');

INSERT INTO asignacion_mensual (id_est_fisica, id_museo, id_emp_mant, fecha_inicio_asig, turno) VALUES
(30, 3, 9, '2025-06-01', 'Mañana'),
(31, 3, 10, '2025-06-01', 'Tarde');

INSERT INTO asignacion_mensual (id_est_fisica, id_museo, id_emp_mant, fecha_inicio_asig, turno) VALUES
(13, 4, 12, '2025-06-01', 'Mañana'),
(13, 4, 13, '2025-06-01', 'Tarde');

INSERT INTO asignacion_mensual (id_est_fisica, id_museo, id_emp_mant, fecha_inicio_asig, turno) VALUES
(22, 5, 16, '2025-06-01', 'Mañana'),
(22, 5, 17, '2025-06-01', 'Noche'),
(24, 5, 18, '2025-06-01', 'Mañana');

INSERT INTO asignacion_mensual (id_est_fisica, id_museo, id_emp_mant, fecha_inicio_asig, turno) VALUES
(17, 6, 19, '2025-06-01', 'Mañana'),
(20, 6, 20, '2025-06-01', 'Noche');

INSERT INTO asignacion_mensual (id_est_fisica, id_museo, id_emp_mant, fecha_inicio_asig, turno) VALUES
(34, 7, 25, '2025-06-01', 'Mañana'),
(35, 7, 26, '2025-06-01', 'Tarde'),
(36, 7, 27, '2025-06-01', 'Noche');

INSERT INTO asignacion_mensual (id_est_fisica, id_museo, id_emp_mant, fecha_inicio_asig, turno) VALUES
(25, 8, 32, '2025-06-01', 'Mañana'),
(25, 8, 31, '2025-06-01', 'Tarde'),
(27, 8, 30, '2025-06-01', 'Mañana');

----------- INSERTS HISTORICO CIERRE TEMPORAL ----------------

INSERT INTO historico_cierre_temp (id_museo, id_est_fisica, id_sala_exp, fecha_inicio_hct, fecha_fin_hct) VALUES
(1, 2, 1, '2020-01-01', '2020-06-30'),
(1, 5, 2, '2021-03-15', NULL);

INSERT INTO historico_cierre_temp (id_museo, id_est_fisica, id_sala_exp, fecha_inicio_hct, fecha_fin_hct) VALUES
(2, 8, 3, '2019-05-10', '2020-05-09'),
(2, 8, 4, '2021-07-01', NULL),
(2, 11, 5, '2018-11-01', '2019-04-30'),
(2, 11, 6, '2019-05-01', '2019-10-31');

INSERT INTO historico_cierre_temp (id_museo, id_est_fisica, id_sala_exp, fecha_inicio_hct, fecha_fin_hct) VALUES
(3, 30, 20, '2022-01-01', NULL),
(3, 32, 21, '2017-02-01', '2018-01-31');

INSERT INTO historico_cierre_temp (id_museo, id_est_fisica, id_sala_exp, fecha_inicio_hct, fecha_fin_hct) VALUES
(4, 13, 7, '2017-06-01', '2018-06-01'),
(4, 13, 8, '2018-07-01', '2019-06-30'),
(4, 13, 9, '2019-07-01', '2020-06-30'),
(4, 13, 10, '2020-07-01', NULL);

INSERT INTO historico_cierre_temp (id_museo, id_est_fisica, id_sala_exp, fecha_inicio_hct, fecha_fin_hct) VALUES
(5, 22, 13, '2020-09-01', '2021-02-28'),
(5, 24, 14, '2021-03-01', '2021-08-31'),
(5, 24, 15, '2021-09-01', NULL);

INSERT INTO historico_cierre_temp (id_museo, id_est_fisica, id_sala_exp, fecha_inicio_hct, fecha_fin_hct) VALUES
(6, 18, 11, '2019-01-01', '2019-12-31'),
(6, 18, 12, '2020-01-01', NULL);

INSERT INTO historico_cierre_temp (id_museo, id_est_fisica, id_sala_exp, fecha_inicio_hct, fecha_fin_hct) VALUES
(7, 36, 22, '2018-03-01', '2019-02-28'),
(7, 36, 23, '2019-03-01', '2020-02-29'),
(7, 37, 24, '2020-03-01', NULL);

INSERT INTO historico_cierre_temp (id_museo, id_est_fisica, id_sala_exp, fecha_inicio_hct, fecha_fin_hct) VALUES
(8, 27, 17, '2017-05-01', '2018-04-30'),
(8, 27, 16, '2018-05-01', '2019-04-30'),
(8, 27, 18, '2019-05-01', '2020-04-30'),
(8, 27, 19, '2020-05-01', NULL);


----------- INSERTS HISTORICO EMPLEADOS --------------
INSERT INTO historico_empleado (id_emp_pro, id_museo, id_est_org, fecha_inicio, cargo, fecha_fin) VALUES
(1, 1, 2, '1987-02-13', 'Curador', '1989-06-14'),
(1, 1, 3, '1990-05-21', 'Restaurador', NULL),
(2, 1, 5, '2012-06-14', 'Tecnico de computacion', '2020-03-15'),
(2, 1, 3, '2020-04-18', 'Conservador', NULL),
(3, 1, 2, '2004-11-03','Curador',NULL),

(4, 2, 14, '2010-02-18', 'Jefe de prensa', '2016-02-18'),
(4, 2, 10, '2016-03-18', 'Restaurador', NULL),
(5, 2, 12, '2014-05-19', 'Coordinador de eventos', '2021-06-18'),
(5, 2, 10, '2015-08-28', 'Curador', NULL),
(6, 2, 10, '2012-07-17', 'Curador', NULL),

(7, 3, 22, '1995-11-11', 'Curador', '2000-01-30'),
(7, 3, 19, '1999-02-15', 'Auxiliar administrativo', NULL),
(8, 3, 17, '2020-01-28', 'Director de museo', '2024-02-19'),
(8, 3, 22, '2010-06-25', 'Restaurador',NULL),
(9, 3, 19, '2010-01-09', 'Admisitrador general', '2011-05-16'),
(9, 3, 22, '2011-07-09', 'Curador', NULL),

(10, 4, 28, '2016-04-17', 'Coordinador de eventos', '2022-12-18'),
(10, 4, 27, '2023-03-14', 'Restaurador', NULL),
(11, 4, 29, '2005-02-02', 'Administrador general', NULL),
(12, 4, 28, '2012-12-16', 'Educador cultural', '2014-06-18'),
(12, 4, 26, '2015-03-18', 'Curador', NULL),

(13, 5, 34, '2015-05-05', 'Administrador de finanzas', '2021-06-15'),
(13, 5, 32, '2021-12-01', 'Restaurador', NULL),
(14, 5, 32, '2010-12-20', 'Restaurador', '2012-08-19'),
(14, 5, 31, '2013-11-15', 'Curador', NULL),
(15, 5, 33, '2007-12-06', 'Organizador de Eventos', NULL),

(16, 8, 59, '2015-05-16', 'Administrador de finanzas', NULL),
(17, 8, 56, '2019-02-17', 'Restaurador', NULL),
(18, 8, 55, '2006-10-06', 'Curador', NULL),

(19, 6, 38, '2020-10-19', 'Curador', '2023-05-18'),
(19, 6, 42, '2024-11-06', 'Restaurador', NULL),
(20, 6, 38, '2013-08-08', 'Curador', NULL),
(21, 6, 40, '2009-05-18', 'Desarrollador', NULL),

(22, 7, 48, '2004-12-03', 'Restaurador', NULL),
(23, 7, 50, '2011-06-05', 'Jefe de marketing', NULL),
(24, 7, 46, '2011-06-05', 'Curador', NULL);

------------- INSERTS HISTORICO OBRA MOVIMIENTO ------------
INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2020-01-15',
    'comprada',
    'si',
    NULL,
    sc.orden_recorrido,
    500000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte Canadiense'  
	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Northern Lake'
LIMIT 1;


INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2020-01-20',
    'donada',
    'si',
    NULL,
    sc.orden_recorrido,
    750000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte Canadiense'  
	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'The West Wind'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2021-02-10',
    'comprada_m',
    'no',
    NULL,
    sc.orden_recorrido,
    300000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte Moderno'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Standing Figure'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2021-02-15',
    'donada_m',
    'no',
    NULL,
    sc.orden_recorrido,
    400000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte Moderno'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería de arte de Ontario'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Figure décorative'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)

SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2020-03-15',
    'donada',
    'si',
    NULL,
    sc.orden_recorrido,
    1500000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte Europeo'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'The Death of General Wolfe'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2020-04-10',
    'comprada',
    'si',
    NULL,
    sc.orden_recorrido,
    2000000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte Canadiense'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'The Jack Pine'
LIMIT 1;

-- Age of Bronze
INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2020-05-05',
    'donada',
    'no',
    NULL,
    sc.orden_recorrido,
    1200000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte Europeo'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Age of Bronze'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2020-06-01',
    'donada',
    'no',
    NULL,
    sc.orden_recorrido,
    400000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte Canadiense'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería nacional de arte de Canadá'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'The Storm'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2010-01-15',
    'comprada',
    'si',
    NULL,
    sc.orden_recorrido,
    100500.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Pintura Abstracta Coreana'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'White Umbrella'
LIMIT 1;


INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2005-01-20',
    'donada',
    'si',
    NULL,
    sc.orden_recorrido,
    750500.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte Coreano Contemporáneo'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Untitled (Red and Blue)'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2012-04-10',
    'comprada_m',
    'no',
    NULL,
    sc.orden_recorrido,
    350500.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Escultura Coreana Contemporánea' 
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Stone Circle'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2015-04-17',
    'donada',
    'no',
    NULL,
    sc.orden_recorrido,
    105000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Escultura Coreana Contemporánea'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('SeMA Seoul Museum of Art'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'The Shadow of Time'
LIMIT 1;


INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2021-05-10',
    'donada',
    'si',
    NULL,
    sc.orden_recorrido,
    600000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
    ON c.nombre_coleccion = 'Arte Contemporáneo Árabe'
  	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'The Last Supper'
LIMIT 1;


INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2021-06-12',
    'comprada',
    'si',
    NULL,
    sc.orden_recorrido,
    800000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Contemporáneo Árabe'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Desert Landscape I'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2021-07-20',
    'comprada',
    'no',
    NULL,
    sc.orden_recorrido,
    450000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Islámico Contemporáneo'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Calligraphy Chair'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2021-08-15',
    'donada',
    'no',
    NULL,
    sc.orden_recorrido,
    900000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Islámico Contemporáneo'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo de arte de Sharjah'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Dhow'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)

SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2010-03-15',
    'donada_m',
    'si',
    NULL,
    sc.orden_recorrido,
    150000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte de la India'
  	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Devi Mahatmya (Iluminación de Manuscrito)'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2009-04-10',
    'comprada',
    'si',
    NULL,
    sc.orden_recorrido,
    20500.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte del Cercano Oriente'
  	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Retrato de un Sufí'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2012-05-05',
    'donada_m',
    'no',
    NULL,
    sc.orden_recorrido,
    120000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte del Sudeste Asiático'
  	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Busto de Buda'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2014-06-12',
    'donada',
    'no',
    NULL,
    sc.orden_recorrido,
    45000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c ON c.nombre_coleccion = 'Arte del Sudeste Asiático'
  	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museum Rietberg'))
  )
JOIN sala_col sc ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Figura de Vishnu acostado'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2013-05-13',
    'donada',
    'si',
    NULL,
    sc.orden_recorrido,
    605000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
    ON c.nombre_coleccion = 'Arte Americano'
  	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Purple Robe and Anemones'
LIMIT 1;


INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2018-06-12',
    'comprada_m',
    'si',
    NULL,
    sc.orden_recorrido,
    1150500.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Europeo del Siglo XIX'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'La Coiffure'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2011-07-20',
    'comprada',
    'no',
    NULL,
    sc.orden_recorrido,
    45000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Europeo del Siglo XIX'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Dancer Looking at the Sole of Her Right Foot'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra, c.id_coleccion, '2015-08-15', 'comprada_m', 'si', NULL, c.orden_recorrido, 900500.00, he.id_emp_pro, ef.id_museo, c.id_est_org, c.id_coleccion, ef.id_est_fisica,
    NULL 
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Europeo del Siglo XIX'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Baltimore Museum of Art'))
  )
JOIN estructura_fisica ef 
  ON ef.nombre_est ILIKE '%Wurtzburger Garden%' AND ef.id_museo = c.id_museo
JOIN historico_empleado he 
  ON he.id_museo = c.id_museo AND he.id_est_org = c.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Three Piece Reclining Figure'
LIMIT 1;



INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra, sc.id_coleccion, '2015-05-13', 'donada_m', 'si',NULL,
    sc.orden_recorrido,
    105400.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
    ON c.nombre_coleccion = 'Arte Australiano Contemporáneo'
  	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Blue Poles'
LIMIT 1;


INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2016-05-12',
    'comprada_m',
    'no',
    NULL,
    sc.orden_recorrido,
    11500.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Indígena Australiano'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Warlugulong'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2010-03-20',
    'comprada',
    'si',
    NULL,
    sc.orden_recorrido,
    450600.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Moderno Internacional'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Bird in Space'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2024-08-15',
    'comprada',
    'si',
    NULL,
    c.orden_recorrido, 
    100400.00,
    he.id_emp_pro,
    ef.id_museo,
    c.id_est_org,
    c.id_coleccion,
    ef.id_est_fisica,
    NULL 
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Australiano Contemporáneo'
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Galería Nacional de Australia'))
  )
JOIN estructura_fisica ef 
  ON ef.nombre_est ILIKE '%Sculpture Garden%' AND ef.id_museo = c.id_museo
JOIN historico_empleado he 
  ON he.id_museo = c.id_museo AND he.id_est_org = c.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Ouroboros'
LIMIT 1;


INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    sc.id_coleccion,
    '2006-05-13',
    'donada',
    'si',
    NULL,
    sc.orden_recorrido,
    101000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
    ON c.nombre_coleccion = 'Arte Japonés Clásico'
  	AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Birds and Flowers of the Four Seasons'
LIMIT 1;


INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2002-04-12',
    'comprada',
    'si',
    NULL,
    sc.orden_recorrido,
    115000.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Japonés Clásico' 
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Landscape by the River'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2012-03-21',
    'comprada',
    'no',
    NULL,
    sc.orden_recorrido,
    50600.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Japonés Moderno' 
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Busto de Buda Amida'
LIMIT 1;

INSERT INTO hist_obra_movimiento (
    id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, fecha_fin,
    orden_recorrido, valor_monetario, id_emp_pro, id_museo, id_est_org, id_coleccion,
    id_est_fisica, id_sala_exp
)
SELECT 
    o.id_obra,
    c.id_coleccion,
    '2010-08-15',
    'comprada_m',
    'si',
    NULL,
    c.orden_recorrido, 
    150500.00,
    he.id_emp_pro,
    sc.id_museo,
    sc.id_est_org,
    sc.id_coleccion,
    sc.id_est_fisica,
    sc.id_sala_exp
FROM obra o
JOIN coleccion c 
  ON c.nombre_coleccion = 'Arte Japonés Moderno' 
  AND c.id_museo = (
      SELECT id_museo FROM museo 
      WHERE unaccent(UPPER(nombre_museo)) = unaccent(UPPER('Museo Miho'))
  )
JOIN sala_col sc 
    ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
JOIN historico_empleado he 
    ON he.id_museo = sc.id_museo AND he.id_est_org = sc.id_est_org AND he.fecha_fin IS NULL
WHERE o.nom_obra = 'Figura de Kannon Bosatsu'
LIMIT 1;

-------- INSERTS ACTIVIDAD CONSERVACION ----------

INSERT INTO actividad_conservacion (id_obra, id_cata_museo, actividad, frecuencia, tipo_responsable)
VALUES
(1, 1,'Mantenimiento', 'Trimestral', 'restaurador'),
(2, 1,'Restauracion anual','Anual','curador'),
(3, 2,'Limpieza','Anual','curador'),
(4, 2,'Retocado','Semestal','curador'),

(5, 3,'Estabilizacion de grietas','Anual','restaurador'),
(6, 4,'Refuerzo de bastidor','Anual','restaurador'),
(7, 3,'Limpieza','Trimestral','curador'),
(8, 4,'Limpieza','Trimestral','curador'),

(25, 16,'Monitoreo de plagas','Semestral','curador'),
(26, 15,'Retocado','Anual','curador'),
(27, 17,'Limpieza','Anual','curador'),
(28, 17,'Restauracion anual','Anual','restaurador'),

(9, 5,'Limpieza','Semestral','curador'),
(10, 5,'Restauracion de grietas','Anual','curador'),
(11, 6,'Limpieza','Trimestral','curador'),
(12, 6,'Limpieza','Trimestral','curador'),

(17, 10,'Limpieza','Anual','curador'),
(18, 11,'Limpieza','Semestral','curador'),
(19, 12,'Analisis estructural','Trimestral','curador'),
(20, 12,'Restauracion','Anual','restaurador'),

(13, 7,'Refuerzo de bastidor','Trimestral','curador'),
(14, 8,'Monitoreo de plagas','Trimestral','curador'),
(15, 8,'Restauracion anual','Anual','restaurador'),
(16, 8,'Limpieza','Trimestral','curador'),

(29, 20,'Reparacion de grietas','Trimestral','restaurador'),
(30, 19,'Aplicacion de covertor','Trimestral','curador'),
(31, 18,'Limpieza','Trimestral','curador'),
(32, 20,'Limpieza','Trimestral','curador'),

(21, 13,'Mantenimiento','Trimestral','restaurador'),
(22, 13,'Aplicacion de covertor','Anual','restaurador'),
(23, 14,'Limpieza','Trimestral','curador'),
(24, 14,'Limpieza','Trimestral','curador');


-------- INSERTS HISTORICO CONSERVACION ---------

INSERT INTO hist_conservacion (id_obra, id_cata_museo, id_conservacion, id_emp_pro, fecha_inicio_cons, fecha_fin_cons, descripcion)
VALUES 
(1, 1, 1, 1, '2020-01-15', NULL, 'Mantenimiento general'),
(2, 1, 2, 3, '2020-01-20', NULL, 'Revisión anual'),
(3, 2, 3, 3, '2021-02-10', NULL, 'Limpieza preventiva'),
(4, 2, 4, 3, '2021-02-15', NULL, 'Retocado de pintura'),

(5, 3, 5, 4, '2020-03-15', NULL, 'Estabilización estructural'),
(6, 4, 6, 4, '2020-04-10', NULL, 'Refuerzo del bastidor'),
(7, 3, 7, 5, '2020-05-05', NULL, 'Limpieza trimestral'),
(8, 4, 8, 6, '2020-06-01', NULL, 'Limpieza profunda'),

(25, 16, 9, 9, '2010-01-15', NULL, 'Monitoreo de plagas'),
(26, 15, 10, 8, '2005-01-20', NULL, 'Retocado general'),
(27, 17, 11, 9, '2012-04-10', NULL, 'Limpieza general'),
(28, 17, 12, 8, '2015-04-17', NULL, 'Restauración avanzada'),

(9, 5, 13, 12, '2021-05-10', NULL, 'Limpieza semestral'),
(10, 5, 14, 10, '2021-06-12', NULL, 'Restauración de grietas'),
(11, 6, 15, 12, '2021-07-20', NULL, 'Limpieza trimestral'),
(12, 6, 16, 12, '2021-08-15', NULL, 'Limpieza trimestral'),

(17, 10, 17, 14, '2010-03-15', NULL, 'Limpieza anual'),
(18, 11, 18, 14, '2009-04-10', NULL, 'Limpieza semestral'),
(19, 12, 19, 14, '2012-05-05', NULL, 'Análisis estructural'),
(20, 12, 20, 13, '2014-06-12', NULL, 'Restauración detallada'),

(13, 7, 21, 20, '2013-05-13', NULL, 'Refuerzo de bastidor'),
(14, 8, 22, 20, '2018-06-12', NULL, 'Monitoreo de plagas'),
(15, 8, 23, 19, '2011-07-20', NULL, 'Restauración anual'),
(16, 8, 24, 20, '2015-08-15', NULL, 'Limpieza trimestral'),

(29, 20, 25, 22, '2015-05-13', NULL, 'Reparación de grietas'),
(30, 19, 26, 22, '2016-05-12', NULL, 'Aplicación de cobertor'),
(31, 18, 27, 24, '2010-03-20', NULL, 'Limpieza trimestral'),
(32, 20, 28, 24, '2024-08-15', NULL, 'Limpieza trimestral'),

(21, 13, 29, 17, '2006-05-13', NULL, 'Mantenimiento especializado'),
(22, 13, 30, 17, '2002-04-12', NULL, 'Aplicación de cobertor'),
(23, 14, 31, 18, '2012-03-21', NULL, 'Limpieza trimestral'),
(24, 14, 32, 18, '2010-08-15', NULL, 'Limpieza trimestral');


---------------------------------------------------- PROGRAMAS ALMACENADOS --------------------------------------------------------

--------------------- Función para insertar un nuevo empleado profesional, su registro histórico inicial, los idiomas que habla y los títulos de formación que posee

CREATE OR REPLACE FUNCTION insertar_empleado_profesional_con_historico(
    p_id_museo numeric,
    p_doc_identidad numeric,
    p_primer_nombre character varying,
    p_primer_apellido character varying,
    p_segundo_apellido character varying,
    p_fecha_nacimiento date,
    p_genero character varying,
    p_telefono character varying,
    p_id_est_org numeric,                                  
    p_cargo character varying,                            
    p_segundo_nombre character varying DEFAULT NULL,      
    p_correo character varying DEFAULT NULL,              
    p_nombres_idiomas character varying[] DEFAULT '{}',  
    p_titulos_info JSONB DEFAULT '[]'::jsonb           
)
RETURNS numeric 
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_emp_pro numeric(3,0);           
    v_nom_idioma character varying;      
    v_id_idioma numeric(3,0);            
    v_titulo_obj JSONB;                  
    v_next_id_titulo numeric(3,0);       
BEGIN
    
    INSERT INTO public.empleado_profesional (
        id_museo,
        doc_identidad,
        primer_nombre,
        primer_apellido,
        segundo_apellido,
        fecha_nacimiento,
        genero,
        telefono,
        segundo_nombre,
        correo
    )
    VALUES (
        p_id_museo,
        p_doc_identidad,
        p_primer_nombre,
        p_primer_apellido,
        p_segundo_apellido,
        p_fecha_nacimiento,
        p_genero,
        p_telefono,
        p_segundo_nombre,
        p_correo
    )
    RETURNING id_emp_pro INTO v_id_emp_pro;

    INSERT INTO public.historico_empleado (
        id_emp_pro,
        id_museo,
        id_est_org,
        fecha_inicio,
        cargo,
        fecha_fin -- fecha_fin
    )
    VALUES (
        v_id_emp_pro,
        p_id_museo,
        p_id_est_org,
        CURRENT_DATE, -- La fecha de inicio es la fecha actual
        p_cargo,
        NULL -- Inicialmente, la fecha de fin es nula
    );

    IF p_nombres_idiomas IS NOT NULL AND array_length(p_nombres_idiomas, 1) > 0 THEN
        FOREACH v_nom_idioma IN ARRAY p_nombres_idiomas LOOP
            -- Intentar obtener el id_idioma del idioma por su nombre
            SELECT id_idioma
            INTO v_id_idioma
            FROM public.idioma
            WHERE nom_idioma = v_nom_idioma;

            IF v_id_idioma IS NULL THEN
                RAISE EXCEPTION 'Error: El idioma "%" no existe en la tabla public.idioma.', v_nom_idioma;
            END IF;

            INSERT INTO public.idioma_hablado (id_idioma, id_emp_pro)
            VALUES (v_id_idioma, v_id_emp_pro);

            -- Resetear v_id_idioma para la próxima iteración
            v_id_idioma := NULL;
        END LOOP;
    END IF;
"descripcion", "especializacion".

    IF p_titulos_info IS NOT NULL AND jsonb_array_length(p_titulos_info) > 0 THEN
        FOR v_titulo_obj IN SELECT * FROM jsonb_array_elements(p_titulos_info) LOOP
            
            -- Esto asume que id_titulo es una secuencia lógica por empleado y no un SERIAL global.
            SELECT COALESCE(MAX(id_titulo), 0) + 1
            INTO v_next_id_titulo
            FROM public.titulo_formacion
            WHERE id_emp_pro = v_id_emp_pro;

            INSERT INTO public.titulo_formacion (
                id_emp_pro,
                id_titulo,          
                nombre_titulo,
                momento,
                descripcion,
                especializacion
            )
            VALUES (
                v_id_emp_pro,
                v_next_id_titulo,
                v_titulo_obj->>'nombre_titulo',
                (v_titulo_obj->>'momento')::date,
                v_titulo_obj->>'descripcion',
                v_titulo_obj->>'especializacion'
            );
        END LOOP;
    END IF;

    -- 5. Retornar el ID del empleado profesional recién insertado.
    RETURN v_id_emp_pro;

END;
$$;

--------------------- Función para asignar un turno y una ubicación específica a un empleado de mantenimiento.

CREATE OR REPLACE FUNCTION asignar_turno_y_ubicacion(
    p_id_emp_mant numeric,           
    p_id_museo numeric,              
    p_id_est_fisica numeric,         
    p_turno character varying,       
    p_fecha_inicio_asig date DEFAULT CURRENT_DATE 
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_empleado_existe boolean;   
    v_estructura_existe boolean; 
BEGIN

    SELECT EXISTS (
        SELECT 1
        FROM public.empleado_mantenimiento
        WHERE id_emp_mant = p_id_emp_mant
    ) INTO v_empleado_existe;

    IF NOT v_empleado_existe THEN
        RAISE EXCEPTION 'Error: El empleado de mantenimiento con ID % no existe.', p_id_emp_mant;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM public.estructura_fisica
        WHERE id_museo = p_id_museo AND id_est_fisica = p_id_est_fisica
    ) INTO v_estructura_existe;

    IF NOT v_estructura_existe THEN
        RAISE EXCEPTION 'Error: La estructura física con ID de museo % e ID de estructura % no existe.', p_id_museo, p_id_est_fisica;
    END IF;

    IF p_turno NOT IN ('mañana', 'tarde', 'noche') THEN
        RAISE EXCEPTION 'Error: El valor del turno "%" no es válido. Debe ser "mañana", "tarde" o "noche".', p_turno;
    END IF;

    INSERT INTO public.asignacion_mensual (
        id_est_fisica,
        id_museo,
        id_emp_mant,
        fecha_inicio_asig,
        turno
    )
    VALUES (
        p_id_est_fisica,
        p_id_museo,
        p_id_emp_mant,
        p_fecha_inicio_asig,
        p_turno
    );

END;
$$;

--------------------- Procedimiento para actualizar el cargo de un empleado
CREATE OR REPLACE PROCEDURE cambiar_cargo_empleado(
    p_id_emp_pro NUMERIC,
    p_id_museo NUMERIC,
    p_id_est_org NUMERIC,
    p_fecha_inicio DATE,
    p_nuevo_cargo VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE historico_empleado
    SET fecha_fin = p_fecha_inicio
    WHERE id_emp_pro = p_id_emp_pro
      AND fecha_fin IS NULL;
    INSERT INTO historico_empleado (
        id_emp_pro, id_museo, id_est_org, fecha_inicio, cargo, fecha_fin
    ) VALUES (
        p_id_emp_pro, p_id_museo, p_id_est_org, p_fecha_inicio, p_nuevo_cargo, NULL
    );
END;
$$;


--------------------- Funcion para insertar una colección, asignarle una sala y crear la relacion

CREATE OR REPLACE FUNCTION insertar_coleccion_con_sala(
    p_id_museo NUMERIC,
    p_nombre_sala VARCHAR,
    p_id_est_org NUMERIC,
    p_nombre_coleccion VARCHAR,
    p_descripcion_caracteristicas VARCHAR,
    p_palabras_clave VARCHAR,
    p_orden_recorrido NUMERIC
)
RETURNS TEXT AS $$
DECLARE
    v_id_sala_exp NUMERIC;
    v_id_est_fisica NUMERIC;
    v_id_coleccion NUMERIC;
    v_next_id NUMERIC;
BEGIN

    IF EXISTS (
        SELECT 1 FROM coleccion
        WHERE id_museo = p_id_museo
          AND id_est_org = p_id_est_org
          AND nombre_coleccion = p_nombre_coleccion
    ) THEN
        RAISE EXCEPTION 'Ya existe una colección con ese nombre para ese museo y departamento.';
    END IF;

    UPDATE coleccion
    SET orden_recorrido = orden_recorrido + 1
    WHERE id_museo = p_id_museo
      AND orden_recorrido >= p_orden_recorrido;

    SELECT COALESCE(MAX(id_coleccion), 0) + 1
    INTO v_next_id
    FROM coleccion;

    INSERT INTO coleccion (
        id_museo, id_est_org, id_coleccion, nombre_coleccion,
        descripcion_caracteristicas, palabras_clave, orden_recorrido
    )
    VALUES (
        p_id_museo, p_id_est_org, v_next_id, p_nombre_coleccion,
        p_descripcion_caracteristicas, p_palabras_clave, p_orden_recorrido
    )
    RETURNING id_coleccion INTO v_id_coleccion;

    SELECT id_sala_exp, id_est_fisica
    INTO v_id_sala_exp, v_id_est_fisica
    FROM sala_exp
    WHERE id_museo = p_id_museo
      AND nombre_sala_expo = p_nombre_sala;

    IF v_id_sala_exp IS NULL THEN
        RAISE EXCEPTION 'Sala no encontrada.';
    END IF;

    -- Verificar sala_col y crearla si falta
    IF NOT EXISTS (
        SELECT 1 FROM sala_col
        WHERE id_museo = p_id_museo
          AND id_coleccion = v_id_coleccion
          AND id_sala_exp = v_id_sala_exp
    ) THEN
        INSERT INTO sala_col (
            id_est_org, id_coleccion, id_museo,
            id_est_fisica, id_sala_exp, orden_recorrido
        ) VALUES (
            p_id_est_org, v_id_coleccion, p_id_museo,
            v_id_est_fisica, v_id_sala_exp, p_orden_recorrido
        );
    END IF;

    RETURN 'Colección y sala_col insertadas correctamente con id_coleccion ' || v_id_coleccion;
END;
$$ LANGUAGE plpgsql;

--------------------- Funcion para insertar una obra y abrir su historico automaticamente.-------------
CREATE OR REPLACE FUNCTION insertar_obra_completa(
    p_id_museo NUMERIC,
    p_nombre_coleccion VARCHAR,
    p_nombre_sala VARCHAR,
    p_nombre_obra VARCHAR,
    p_periodo_creacion VARCHAR,
    p_dimensiones VARCHAR,
    p_estilo_art VARCHAR,
    p_tecnica VARCHAR,
    p_tipo_obra VARCHAR,
    p_tipo_adquisicion VARCHAR,
    p_destacada VARCHAR,
    p_fecha_adquisicion DATE,
    p_actividad_conservacion VARCHAR,
    p_frecuencia VARCHAR,
    p_valor_monetario NUMERIC 
) RETURNS VOID AS $$
DECLARE
    v_id_est_org NUMERIC;
    v_id_coleccion NUMERIC;
    v_id_est_fisica NUMERIC;
    v_id_sala_exp NUMERIC;
    v_id_obra NUMERIC;
    v_id_emp_pro NUMERIC;
    v_cargo_emp VARCHAR;
    v_id_cata_museo NUMERIC;
    v_tipo_responsable VARCHAR;
    v_id_conservacion NUMERIC;
    v_orden_recorrido NUMERIC; 
BEGIN
    SELECT id_est_org, id_coleccion, orden_recorrido
    INTO v_id_est_org, v_id_coleccion, v_orden_recorrido
    FROM coleccion
    WHERE id_museo = p_id_museo AND nombre_coleccion = p_nombre_coleccion
    LIMIT 1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Colección no encontrada para museo % y nombre %', p_id_museo, p_nombre_coleccion;
    END IF;
    SELECT s.id_est_fisica, s.id_sala_exp
    INTO v_id_est_fisica, v_id_sala_exp
    FROM sala_exp s
    JOIN sala_col sc ON sc.id_sala_exp = s.id_sala_exp AND sc.id_est_fisica = s.id_est_fisica AND sc.id_museo = s.id_museo
    WHERE s.id_museo = p_id_museo AND s.nombre_sala_expo = p_nombre_sala
    AND sc.id_coleccion = v_id_coleccion AND sc.id_est_org = v_id_est_org
    LIMIT 1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sala no encontrada o no coincide con la colección dada.';
    END IF;
    INSERT INTO obra (nom_obra, fecha_creacion_periodo, dim_descrip, est_art, tecnica_mat, tipo_obra)
    VALUES (p_nombre_obra, p_periodo_creacion, p_dimensiones, p_estilo_art, p_tecnica, p_tipo_obra)
    RETURNING id_obra INTO v_id_obra;
    SELECT he.id_emp_pro, he.cargo
    INTO v_id_emp_pro, v_cargo_emp
    FROM historico_empleado he
    WHERE he.id_museo = p_id_museo
      AND he.id_est_org = v_id_est_org
      AND he.fecha_fin IS NULL 
    LIMIT 1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No hay empleado activo en departamento % para museo %', v_id_est_org, p_id_museo;
    END IF;
    SELECT COALESCE(MAX(id_cata_museo), 0) + 1
    INTO v_id_cata_museo
    FROM hist_obra_movimiento
    WHERE id_obra = v_id_obra;
    INSERT INTO hist_obra_movimiento (
        id_obra, id_cata_museo, fecha_llegada, tipo_adquisicion, destacada, 
        id_museo, id_est_org, id_coleccion, id_est_fisica, id_sala_exp, id_emp_pro,
        orden_recorrido, valor_monetario
    ) VALUES (
        v_id_obra, v_id_cata_museo, p_fecha_adquisicion, p_tipo_adquisicion, p_destacada,
        p_id_museo, v_id_est_org, v_id_coleccion, v_id_est_fisica, v_id_sala_exp, v_id_emp_pro,
        v_orden_recorrido, p_valor_monetario
    );

    IF LOWER(v_cargo_emp) LIKE '%curador%' THEN
        v_tipo_responsable := 'curador';
    ELSIF LOWER(v_cargo_emp) LIKE '%restaurador%' THEN
        v_tipo_responsable := 'restaurador';
    ELSE
        v_tipo_responsable := 'otro';
    END IF;

    INSERT INTO actividad_conservacion (
        id_obra, id_cata_museo, actividad, frecuencia, tipo_responsable
    ) VALUES (
        v_id_obra, v_id_cata_museo, p_actividad_conservacion, p_frecuencia, v_tipo_responsable
    )
    RETURNING id_conservacion INTO v_id_conservacion;

    INSERT INTO hist_conservacion (
        id_obra, id_cata_museo, id_conservacion, id_emp_pro, fecha_inicio_cons, descripcion
    ) VALUES (
        v_id_obra, v_id_cata_museo, v_id_conservacion, v_id_emp_pro, CURRENT_DATE, 'Actividad inicial asignada automáticamente'
    );

END;
$$ LANGUAGE plpgsql;

--------------------- Procedimiento para cerrar el historico de cierre temporal

CREATE OR REPLACE PROCEDURE gestionar_cierre_temporal(
    p_id_museo numeric,
    p_id_est_fisica numeric,
    p_id_sala_exp numeric,
    p_fecha_inicio date,
    p_fecha_fin date DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM historico_cierre_temp
        WHERE id_museo = p_id_museo
          AND id_est_fisica = p_id_est_fisica
          AND id_sala_exp = p_id_sala_exp
          AND fecha_fin_hct IS NULL
    ) INTO v_exists;

    IF v_exists THEN
        UPDATE historico_cierre_temp
        SET fecha_fin_hct = p_fecha_fin
        WHERE id_museo = p_id_museo
          AND id_est_fisica = p_id_est_fisica
          AND id_sala_exp = p_id_sala_exp
          AND fecha_fin_hct IS NULL;

        RAISE NOTICE 'Cierre temporal activo cerrado correctamente para sala %/%/%', p_id_museo, p_id_est_fisica, p_id_sala_exp;

    ELSE
        INSERT INTO historico_cierre_temp (id_museo, id_est_fisica, id_sala_exp, fecha_inicio_hct, fecha_fin_hct)
        VALUES (p_id_museo, p_id_est_fisica, p_id_sala_exp, p_fecha_inicio, p_fecha_fin);

        RAISE NOTICE 'Nuevo cierre temporal registrado para sala %/%/%', p_id_museo, p_id_est_fisica, p_id_sala_exp;
    END IF;
END;
$$;

--------------------------------------CONSULTAS PARA LOS REPORTES---------------------------------------------

--Reporte estructura organizacional--
--Consulta 1: Obtener Museos
SELECT id_museo, nombre_museo FROM museo ORDER BY id_museo 
--Consulta 2: Obtener Estructura Organizacional
SELECT nombre_est_or, tipo_est_org, nivel
FROM estructura_organizacional
WHERE id_museo = %s
ORDER BY nivel, nombre_est_or;

--Ficha empleado profesional--
--Consulta 1: Cargar Museos
SELECT id_museo, nombre_museo FROM museo ORDER BY id_museo

Consulta 2: Cargar Empleados por Museo y Cargo
SELECT DISTINCT ep.id_emp_pro, ep.primer_nombre, ep.segundo_nombre, ep.primer_apellido, ep.segundo_apellido,
ep.doc_identidad, ep.correo, ep.telefono, ep.fecha_nacimiento, ep.genero
FROM empleado_profesional ep
JOIN historico_empleado he ON ep.id_emp_pro = he.id_emp_pro
WHERE ep.id_museo = %s AND he.cargo = %s

--Consulta 3: Obtener Idiomas Hablados por Empleado
SELECT i.nom_idioma
FROM idioma_hablado ih
JOIN idioma i ON ih.id_idioma = i.id_idioma
WHERE ih.id_emp_pro = %s

--Consulta 4: Obtener Título y Especialización del Empleado
SELECT nombre_titulo, especializacion
FROM titulo_formacion
WHERE id_emp_pro = %s

Consulta 5: Obtener Historial Laboral del Empleado
SELECT cargo, fecha_inicio, fecha_fin
FROM historico_empleado
WHERE id_emp_pro = %s ORDER BY fecha_inicio

Consulta 6: Obtener Departamento Actual del Empleado
SELECT eo.nombre_est_or
FROM historico_empleado he
JOIN estructura_organizacional eo
ON he.id_est_org = eo.id_est_org AND he.id_museo = eo.id_museo
WHERE he.id_emp_pro = %s
AND eo.tipo_est_org = 'depa'
ORDER BY he.fecha_inicio DESC
LIMIT 1

--Ficha museo--
--Consulta 1: Obtener Museos Disponibles
SELECT id_museo, nombre_museo FROM museo ORDER BY id_museo

--Consulta 2: Obtener Ranking de Museos
SELECT nombre_museo, posicion FROM obtener_ranking_museos()

--Consulta 3: Obtener Datos Base y Ubicación del Museo
SELECT
    m.nombre_museo,
    m.fecha_fundacion,
    m.resumen_mision,
    ciudad.nombre_lugar_geo AS ciudad,
    pais.nombre_lugar_geo AS pais,
    pais.continente
FROM museo m
JOIN lugar_geografico ciudad ON m.id_lugar_geo = ciudad.id_lugar_geo
LEFT JOIN lugar_geografico pais ON ciudad.id_lugar_padre = pais.id_lugar_geo
WHERE m.id_museo = %s;

--Consulta 4: Obtener Resumen Histórico del Museo
SELECT ano, descripcion_hecho
FROM hecho_historico
WHERE id_museo = %s
ORDER BY ano

--SELECT ano, descripcion_hecho
FROM hecho_historico
WHERE id_museo = %s
ORDER BY ano

--Reporte estructura fisica--
--Consulta 1: Obtener Museos Disponibles
SELECT id_museo, nombre_museo FROM museo ORDER BY id_museo

--Consulta 2: Obtener Pisos/Plantas de un Museo
SELECT nombre_est FROM estructura_fisica WHERE id_museo = %s AND tipo_est = 'piso_planta' ORDER BY nombre_est

--Consulta 3: Obtener ID del Piso/Planta (cuando se filtra por piso)
SELECT id_est_fisica FROM estructura_fisica WHERE id_museo = %s AND nombre_est = %s AND tipo_est = 'piso_planta'

--Consulta 4: obtener la estructura física del museo
SELECT
    ef.id_est_fisica,
    ef.nombre_est,
    ef.tipo_est,
    ef.descripcion_est,
    ef.direccion_edificio,
    ef.id_est_padre,
    se.id_sala_exp,
    se.nombre_sala_expo,
    se.descripcion AS desc_sala,
    c.id_coleccion,
    c.nombre_coleccion,
    sc.orden_recorrido
FROM
    estructura_fisica ef
LEFT JOIN
    sala_exp se ON ef.id_est_fisica = se.id_est_fisica AND ef.id_museo = se.id_museo
LEFT JOIN
    sala_col sc ON se.id_sala_exp = sc.id_sala_exp AND se.id_est_fisica = sc.id_est_fisica AND se.id_museo = sc.id_museo
LEFT JOIN
    coleccion c ON sc.id_coleccion = c.id_coleccion AND sc.id_museo = c.id_museo
WHERE
    ef.id_museo = %s
    -- Opcional: Para filtrar por un piso/planta específico, añade esta línea:
    -- AND ef.id_est_fisica IN (SELECT id_est_fisica FROM estructura_fisica WHERE nombre_est = %s AND tipo_est = 'piso_planta' AND id_museo = %s)
ORDER BY
    ef.id_est_padre NULLS FIRST, -- Esto ayuda a agrupar los elementos raíz primero
    ef.id_est_fisica,
    se.id_sala_exp,
    sc.orden_recorrido;
