
DROP SCHEMA IF EXISTS dw CASCADE;
CREATE SCHEMA dw;


-- DIMENSION 1: COMPANHIA AÉREA (CARRIER)

CREATE TABLE dw.dim_carrier (
    srk_carrier SERIAL PRIMARY KEY,
    carrier_code VARCHAR(10) UNIQUE NOT NULL,
    carrier_name VARCHAR(200),
    data_atualizacao TIMESTAMP DEFAULT NOW()
);


-- DIMENSION 2: AEROPORTO

CREATE TABLE dw.dim_airport (
    srk_airport SERIAL PRIMARY KEY,
    airport_code VARCHAR(10) UNIQUE NOT NULL,
    airport_name VARCHAR(200),
    data_atualizacao TIMESTAMP DEFAULT NOW()
);


-- DIMENSION 3: TEMPO

CREATE TABLE dw.dim_time (
    srk_time SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    trimestre INTEGER,
    semestre INTEGER,
    mes_nome VARCHAR(20),
    mes_ano VARCHAR(7),
    ano_trimestre VARCHAR(7),
    UNIQUE(year, month)
);


-- FACT TABLE: ATRASOS DE VOOS

CREATE TABLE dw.fact_flight_delays (
    srk_fact SERIAL PRIMARY KEY,
    srk_carrier INTEGER NOT NULL,
    srk_airport INTEGER NOT NULL,
    srk_time INTEGER NOT NULL,
    
    -- métricas operacionais
    arr_flights DECIMAL(10,2),
    arr_del15 DECIMAL(10,2),
    arr_cancelled DECIMAL(10,2),
    arr_diverted DECIMAL(10,2),
    arr_delay DECIMAL(10,2),
    
    -- contagem de atrasos por causa
    carrier_ct DECIMAL(10,2),
    weather_ct DECIMAL(10,2),
    nas_ct DECIMAL(10,2),
    security_ct DECIMAL(10,2),
    late_aircraft_ct DECIMAL(10,2),
    
    -- tempo de atraso por causa (minutos)
    carrier_delay DECIMAL(10,2),
    weather_delay DECIMAL(10,2),
    nas_delay DECIMAL(10,2),
    security_delay DECIMAL(10,2),
    late_aircraft_delay DECIMAL(10,2),
    
    -- métricas calculadas
    delay_rate DECIMAL(5,2),
    cancellation_rate DECIMAL(5,2),
    diversion_rate DECIMAL(5,2),
    avg_delay_minutes DECIMAL(10,2),
    on_time_rate DECIMAL(5,2),
    
    UNIQUE(srk_carrier, srk_airport, srk_time),
    FOREIGN KEY (srk_carrier) REFERENCES dw.dim_carrier(srk_carrier),
    FOREIGN KEY (srk_airport) REFERENCES dw.dim_airport(srk_airport),
    FOREIGN KEY (srk_time) REFERENCES dw.dim_time(srk_time)
);