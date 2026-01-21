-- ============================================================================
-- GOLD LAYER: STAR SCHEMA - DDL
-- Business Objective: Airline Operations Manager - Flight Delay Analysis
-- Dataset: Airline Delay and Cancellation Data (2013-2023)
-- ============================================================================

DROP SCHEMA IF EXISTS dw CASCADE;
CREATE SCHEMA dw;

COMMENT ON SCHEMA dw IS 'Camada Gold - Dados agregados e otimizados para análise de atrasos de voos';

-- ============================================================================
-- DIMENSION 1: COMPANHIA AÉREA (CARRIER)
-- ============================================================================
CREATE TABLE dw.dim_carrier (
    carrier_key SERIAL PRIMARY KEY,
    carrier_code VARCHAR(10) UNIQUE NOT NULL,
    carrier_name VARCHAR(200),
    
    -- Metadata
    data_atualizacao TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_carrier_code ON dw.dim_carrier(carrier_code);
CREATE INDEX idx_carrier_name ON dw.dim_carrier(carrier_name);

COMMENT ON TABLE dw.dim_carrier IS 'Dimensão Companhia Aérea - Informações sobre carriers';
COMMENT ON COLUMN dw.dim_carrier.carrier_key IS 'Chave primária surrogate';
COMMENT ON COLUMN dw.dim_carrier.carrier_code IS 'Código IATA da companhia (ex: AA, DL, UA)';

-- ============================================================================
-- DIMENSION 2: AEROPORTO
-- ============================================================================
CREATE TABLE dw.dim_airport (
    airport_key SERIAL PRIMARY KEY,
    airport_code VARCHAR(10) UNIQUE NOT NULL,
    airport_name VARCHAR(200),
    
    -- Metadata
    data_atualizacao TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_airport_code ON dw.dim_airport(airport_code);
CREATE INDEX idx_airport_name ON dw.dim_airport(airport_name);

COMMENT ON TABLE dw.dim_airport IS 'Dimensão Aeroporto - Informações sobre aeroportos';
COMMENT ON COLUMN dw.dim_airport.airport_key IS 'Chave primária surrogate';
COMMENT ON COLUMN dw.dim_airport.airport_code IS 'Código IATA do aeroporto (3 letras)';

-- ============================================================================
-- DIMENSION 3: TEMPO
-- ============================================================================
CREATE TABLE dw.dim_time (
    time_key SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    trimestre INTEGER,
    semestre INTEGER,
    mes_nome VARCHAR(20),
    mes_ano VARCHAR(7),  -- '2023-08'
    ano_trimestre VARCHAR(7),  -- '2023-Q3'
    
    UNIQUE(year, month)
);

CREATE INDEX idx_time_year ON dw.dim_time(year);
CREATE INDEX idx_time_month ON dw.dim_time(month);
CREATE INDEX idx_time_mes_ano ON dw.dim_time(mes_ano);
CREATE INDEX idx_time_trimestre ON dw.dim_time(ano_trimestre);

COMMENT ON TABLE dw.dim_time IS 'Dimensão Tempo - Hierarquia temporal para análises';
COMMENT ON COLUMN dw.dim_time.time_key IS 'Chave primária surrogate';
COMMENT ON COLUMN dw.dim_time.trimestre IS 'Trimestre do ano (1-4)';
COMMENT ON COLUMN dw.dim_time.semestre IS 'Semestre do ano (1-2)';

-- ============================================================================
-- FACT TABLE: ATRASOS DE VOOS
-- ============================================================================
CREATE TABLE dw.fact_flight_delays (
    flight_delay_key SERIAL PRIMARY KEY,
    
    -- Foreign Keys (Surrogate Keys)
    carrier_srk INTEGER NOT NULL REFERENCES dw.dim_carrier(carrier_key),
    airport_srk INTEGER NOT NULL REFERENCES dw.dim_airport(airport_key),
    time_srk INTEGER NOT NULL REFERENCES dw.dim_time(time_key),
    
    -- Métricas Operacionais
    arr_flights DECIMAL(10,2),          -- Total de voos de chegada
    arr_del15 DECIMAL(10,2),            -- Voos atrasados ≥15 minutos
    arr_cancelled DECIMAL(10,2),        -- Voos cancelados
    arr_diverted DECIMAL(10,2),         -- Voos desviados
    
    -- Contagem de Atrasos por Causa
    carrier_ct DECIMAL(10,2),           -- Atrasos por causa da companhia
    weather_ct DECIMAL(10,2),           -- Atrasos por meteorologia
    nas_ct DECIMAL(10,2),               -- Atrasos por NAS
    security_ct DECIMAL(10,2),          -- Atrasos por segurança
    late_aircraft_ct DECIMAL(10,2),     -- Atrasos por aeronave atrasada
    
    -- Tempo de Atraso por Causa (minutos)
    arr_delay DECIMAL(10,2),            -- Tempo total de atraso
    carrier_delay DECIMAL(10,2),        -- Tempo de atraso da companhia
    weather_delay DECIMAL(10,2),        -- Tempo de atraso meteorológico
    nas_delay DECIMAL(10,2),            -- Tempo de atraso NAS
    security_delay DECIMAL(10,2),       -- Tempo de atraso segurança
    late_aircraft_delay DECIMAL(10,2),  -- Tempo de atraso aeronave
    
    -- Métricas Calculadas (para otimização)
    delay_rate DECIMAL(5,2),            -- Taxa de atraso (%)
    cancellation_rate DECIMAL(5,2),     -- Taxa de cancelamento (%)
    diversion_rate DECIMAL(5,2),        -- Taxa de desvio (%)
    avg_delay_minutes DECIMAL(10,2),    -- Atraso médio por voo (min)
    on_time_rate DECIMAL(5,2),          -- Taxa de pontualidade (%)
    
    UNIQUE(carrier_srk, airport_srk, time_srk)
);

CREATE INDEX idx_fact_carrier ON dw.fact_flight_delays(carrier_srk);
CREATE INDEX idx_fact_airport ON dw.fact_flight_delays(airport_srk);
CREATE INDEX idx_fact_time ON dw.fact_flight_delays(time_srk);
CREATE INDEX idx_fact_delay_rate ON dw.fact_flight_delays(delay_rate);
CREATE INDEX idx_fact_arr_flights ON dw.fact_flight_delays(arr_flights);

COMMENT ON TABLE dw.fact_flight_delays IS 'Fato Atrasos de Voos - Métricas de performance operacional';
COMMENT ON COLUMN dw.fact_flight_delays.flight_delay_key IS 'Chave primária surrogate';
COMMENT ON COLUMN dw.fact_flight_delays.carrier_srk IS 'FK surrogate para dim_carrier';
COMMENT ON COLUMN dw.fact_flight_delays.airport_srk IS 'FK surrogate para dim_airport';
COMMENT ON COLUMN dw.fact_flight_delays.time_srk IS 'FK surrogate para dim_time';
COMMENT ON COLUMN dw.fact_flight_delays.delay_rate IS 'Percentual de voos atrasados ≥15min';
COMMENT ON COLUMN dw.fact_flight_delays.on_time_rate IS 'Percentual de voos no horário';

-- ============================================================================
-- VIEWS ANALÍTICAS
-- ============================================================================

-- View: Resumo por Companhia Aérea
CREATE OR REPLACE VIEW dw.vw_performance_carrier AS
SELECT
    c.carrier_code,
    c.carrier_name,
    SUM(f.arr_flights) AS total_voos,
    SUM(f.arr_del15) AS total_atrasos,
    ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_media,
    ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_media,
    ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
    SUM(f.arr_cancelled) AS total_cancelamentos,
    ROUND(AVG(f.cancellation_rate), 2) AS taxa_cancelamento_media,
    SUM(f.arr_diverted) AS total_desvios
FROM dw.fact_flight_delays f
JOIN dw.dim_carrier c ON f.carrier_srk = c.carrier_key
GROUP BY c.carrier_code, c.carrier_name
ORDER BY total_voos DESC;

COMMENT ON VIEW dw.vw_performance_carrier IS 'Performance agregada por companhia aérea';

-- View: Resumo por Aeroporto
CREATE OR REPLACE VIEW dw.vw_performance_airport AS
SELECT
    a.airport_code,
    a.airport_name,
    SUM(f.arr_flights) AS total_voos,
    SUM(f.arr_del15) AS total_atrasos,
    ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_media,
    ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_media,
    ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
    SUM(f.arr_cancelled) AS total_cancelamentos,
    SUM(f.arr_diverted) AS total_desvios
FROM dw.fact_flight_delays f
JOIN dw.dim_airport a ON f.airport_srk = a.airport_key
GROUP BY a.airport_code, a.airport_name
ORDER BY total_voos DESC;

COMMENT ON VIEW dw.vw_performance_airport IS 'Performance agregada por aeroporto';

-- View: Tendência Temporal
CREATE OR REPLACE VIEW dw.vw_temporal_trend AS
SELECT
    t.year,
    t.month,
    t.mes_ano,
    t.trimestre,
    t.ano_trimestre,
    SUM(f.arr_flights) AS total_voos,
    SUM(f.arr_del15) AS total_atrasos,
    ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_media,
    ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
    SUM(f.arr_cancelled) AS total_cancelamentos,
    SUM(f.arr_diverted) AS total_desvios,
    -- Breakdown de causas
    SUM(f.carrier_delay) AS total_carrier_delay,
    SUM(f.weather_delay) AS total_weather_delay,
    SUM(f.nas_delay) AS total_nas_delay,
    SUM(f.security_delay) AS total_security_delay,
    SUM(f.late_aircraft_delay) AS total_late_aircraft_delay
FROM dw.fact_flight_delays f
JOIN dw.dim_time t ON f.time_srk = t.time_key
GROUP BY t.year, t.month, t.mes_ano, t.trimestre, t.ano_trimestre
ORDER BY t.year, t.month;

COMMENT ON VIEW dw.vw_temporal_trend IS 'Tendências temporais de atrasos e causas';

-- View: Causas de Atrasos Agregadas
CREATE OR REPLACE VIEW dw.vw_delay_causes_breakdown AS
SELECT
    'Carrier' AS causa,
    SUM(carrier_delay) AS tempo_total_minutos,
    SUM(carrier_ct) AS contagem_incidentes
FROM dw.fact_flight_delays
UNION ALL
SELECT
    'Weather' AS causa,
    SUM(weather_delay) AS tempo_total_minutos,
    SUM(weather_ct) AS contagem_incidentes
FROM dw.fact_flight_delays
UNION ALL
SELECT
    'NAS' AS causa,
    SUM(nas_delay) AS tempo_total_minutos,
    SUM(nas_ct) AS contagem_incidentes
FROM dw.fact_flight_delays
UNION ALL
SELECT
    'Security' AS causa,
    SUM(security_delay) AS tempo_total_minutos,
    SUM(security_ct) AS contagem_incidentes
FROM dw.fact_flight_delays
UNION ALL
SELECT
    'Late Aircraft' AS causa,
    SUM(late_aircraft_delay) AS tempo_total_minutos,
    SUM(late_aircraft_ct) AS contagem_incidentes
FROM dw.fact_flight_delays
ORDER BY tempo_total_minutos DESC;

COMMENT ON VIEW dw.vw_delay_causes_breakdown IS 'Breakdown agregado de todas as causas de atraso';

-- View: Top Combinações Carrier-Airport
CREATE OR REPLACE VIEW dw.vw_top_carrier_airport_routes AS
SELECT
    c.carrier_name,
    a.airport_name,
    SUM(f.arr_flights) AS total_voos,
    ROUND(AVG(f.delay_rate), 2) AS taxa_atraso,
    ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos
FROM dw.fact_flight_delays f
JOIN dw.dim_carrier c ON f.carrier_srk = c.carrier_key
JOIN dw.dim_airport a ON f.airport_srk = a.airport_key
GROUP BY c.carrier_name, a.airport_name
HAVING SUM(f.arr_flights) >= 100
ORDER BY total_voos DESC
LIMIT 100;

COMMENT ON VIEW dw.vw_top_carrier_airport_routes IS 'Top 100 combinações carrier-aeroporto por volume';

-- ============================================================================
-- GRANTS (opcional - para usuários BI)
-- ============================================================================
-- GRANT SELECT ON ALL TABLES IN SCHEMA gold TO powerbi_user;
-- GRANT SELECT ON ALL SEQUENCES IN SCHEMA gold TO powerbi_user;
-- GRANT USAGE ON SCHEMA gold TO powerbi_user;

-- ============================================================================
-- FIM DO DDL GOLD
-- ============================================================================
