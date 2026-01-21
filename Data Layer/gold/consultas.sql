-- ============================================================================
-- GOLD LAYER: CONSULTAS ANALÍTICAS
-- Queries para análise de performance e atrasos de voos
-- Dataset: Airline Delay and Cancellation Data (2013-2023)
-- ============================================================================

-- ============================================================================
-- 1. VERIFICAÇÃO DO SCHEMA GOLD
-- ============================================================================
-- Verificar contagem de registros em cada tabela
SELECT 'dim_carrier' AS tabela, COUNT(*) AS linhas FROM dw.dim_carrier
UNION ALL
SELECT 'dim_airport' AS tabela, COUNT(*) AS linhas FROM dw.dim_airport
UNION ALL
SELECT 'dim_time' AS tabela, COUNT(*) AS linhas FROM dw.dim_time
UNION ALL
SELECT 'fact_flight_delays' AS tabela, COUNT(*) AS linhas FROM dw.fact_flight_delays
ORDER BY tabela;

-- ============================================================================
-- 2. RANKING DE COMPANHIAS AÉREAS POR PONTUALIDADE
-- ============================================================================
-- Objetivo: Identificar as melhores e piores companhias em termos de pontualidade
WITH carrier_stats AS (
    SELECT
        c.carrier_code,
        c.carrier_name,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        AVG(f.delay_rate) AS taxa_atraso_pct,
        AVG(f.on_time_rate) AS taxa_pontualidade_pct,
        AVG(f.avg_delay_minutes) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos
    FROM dw.fact_flight_delays f
    JOIN dw.dim_carrier c ON f.carrier_srk = c.carrier_key
    GROUP BY c.carrier_code, c.carrier_name
    HAVING SUM(f.arr_flights) >= 1000  -- Apenas carriers com volume significativo
)
SELECT
    carrier_code,
    carrier_name,
    total_voos,
    total_atrasos,
    ROUND(taxa_atraso_pct, 2) AS taxa_atraso_pct,
    ROUND(taxa_pontualidade_pct, 2) AS taxa_pontualidade_pct,
    ROUND(atraso_medio_minutos, 2) AS atraso_medio_minutos,
    total_cancelamentos,
    ROUND(100.0 * total_cancelamentos / NULLIF(total_voos, 0), 2) AS taxa_cancelamento_pct
FROM carrier_stats
ORDER BY taxa_pontualidade_pct DESC;

-- ============================================================================
-- 3. TOP 20 AEROPORTOS MAIS PROBLEMÁTICOS
-- ============================================================================
-- Objetivo: Identificar aeroportos com maiores taxas de atraso e cancelamento
WITH airport_stats AS (
    SELECT
        a.airport_code,
        a.airport_name,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        AVG(f.delay_rate) AS taxa_atraso_pct,
        AVG(f.avg_delay_minutes) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        AVG(f.cancellation_rate) AS taxa_cancelamento_pct,
        SUM(f.arr_diverted) AS total_desvios,
        AVG(f.diversion_rate) AS taxa_desvio_pct
    FROM dw.fact_flight_delays f
    JOIN dw.dim_airport a ON f.airport_srk = a.airport_key
    GROUP BY a.airport_code, a.airport_name
    HAVING SUM(f.arr_flights) >= 500
)
SELECT
    airport_code,
    airport_name,
    total_voos,
    total_atrasos,
    ROUND(taxa_atraso_pct, 2) AS taxa_atraso_pct,
    ROUND(atraso_medio_minutos, 2) AS atraso_medio_minutos,
    total_cancelamentos,
    ROUND(taxa_cancelamento_pct, 2) AS taxa_cancelamento_pct,
    total_desvios,
    ROUND(taxa_desvio_pct, 2) AS taxa_desvio_pct
FROM airport_stats
ORDER BY taxa_atraso_pct DESC
LIMIT 20;

-- ============================================================================
-- 4. SAZONALIDADE MENSAL DE ATRASOS
-- ============================================================================
-- Objetivo: Identificar meses com maiores problemas operacionais
WITH monthly_aggregation AS (
    SELECT
        t.month,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        AVG(f.delay_rate) AS taxa_atraso_media,
        AVG(f.avg_delay_minutes) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        SUM(f.weather_ct) AS incidentes_meteorologicos,
        SUM(f.carrier_ct) AS incidentes_companhia,
        SUM(f.nas_ct) AS incidentes_nas
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.time_srk = t.time_key
    GROUP BY t.month
)
SELECT
    month AS mes,
    CASE month
        WHEN 1 THEN 'Janeiro'
        WHEN 2 THEN 'Fevereiro'
        WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Maio'
        WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro'
        WHEN 11 THEN 'Novembro'
        WHEN 12 THEN 'Dezembro'
    END AS mes_nome,
    total_voos,
    total_atrasos,
    ROUND(taxa_atraso_media, 2) AS taxa_atraso_media,
    ROUND(atraso_medio_minutos, 2) AS atraso_medio_minutos,
    total_cancelamentos,
    incidentes_meteorologicos,
    incidentes_companhia,
    incidentes_nas
FROM monthly_aggregation
ORDER BY month;

-- ============================================================================
-- 5. EVOLUÇÃO ANUAL DA PERFORMANCE DO SETOR
-- ============================================================================
-- Objetivo: Analisar tendências de longo prazo (2013-2023)
WITH yearly_performance AS (
    SELECT
        t.year,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        AVG(f.delay_rate) AS taxa_atraso_pct,
        AVG(f.on_time_rate) AS taxa_pontualidade_pct,
        AVG(f.avg_delay_minutes) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        SUM(f.arr_diverted) AS total_desvios
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.time_srk = t.time_key
    GROUP BY t.year
)
SELECT
    year AS ano,
    total_voos,
    total_atrasos,
    ROUND(taxa_atraso_pct, 2) AS taxa_atraso_pct,
    ROUND(taxa_pontualidade_pct, 2) AS taxa_pontualidade_pct,
    ROUND(atraso_medio_minutos, 2) AS atraso_medio_minutos,
    total_cancelamentos,
    ROUND(100.0 * total_cancelamentos / NULLIF(total_voos, 0), 2) AS taxa_cancelamento_pct,
    total_desvios
FROM yearly_performance
ORDER BY year;

-- ============================================================================
-- 6. ANÁLISE DE CAUSAS DE ATRASOS - BREAKDOWN PERCENTUAL
-- ============================================================================
-- Objetivo: Determinar a contribuição de cada causa no tempo total de atraso
WITH causa_totais AS (
    SELECT
        SUM(carrier_delay) AS total_carrier,
        SUM(weather_delay) AS total_weather,
        SUM(nas_delay) AS total_nas,
        SUM(security_delay) AS total_security,
        SUM(late_aircraft_delay) AS total_late_aircraft,
        SUM(arr_delay) AS total_geral
    FROM dw.fact_flight_delays
)
SELECT
    'Companhia Aérea' AS causa,
    total_carrier AS tempo_total_minutos,
    ROUND(100.0 * total_carrier / NULLIF(total_geral, 0), 2) AS percentual_contribuicao
FROM causa_totais
UNION ALL
SELECT
    'Meteorologia' AS causa,
    total_weather AS tempo_total_minutos,
    ROUND(100.0 * total_weather / NULLIF(total_geral, 0), 2) AS percentual_contribuicao
FROM causa_totais
UNION ALL
SELECT
    'NAS (Sistema Nacional)' AS causa,
    total_nas AS tempo_total_minutos,
    ROUND(100.0 * total_nas / NULLIF(total_geral, 0), 2) AS percentual_contribuicao
FROM causa_totais
UNION ALL
SELECT
    'Segurança' AS causa,
    total_security AS tempo_total_minutos,
    ROUND(100.0 * total_security / NULLIF(total_geral, 0), 2) AS percentual_contribuicao
FROM causa_totais
UNION ALL
SELECT
    'Aeronave Atrasada' AS causa,
    total_late_aircraft AS tempo_total_minutos,
    ROUND(100.0 * total_late_aircraft / NULLIF(total_geral, 0), 2) AS percentual_contribuicao
FROM causa_totais
ORDER BY tempo_total_minutos DESC;

-- ============================================================================
-- 7. IMPACTO METEOROLÓGICO POR MÊS
-- ============================================================================
-- Objetivo: Identificar períodos com maiores problemas climáticos
WITH weather_impact_monthly AS (
    SELECT
        t.month,
        SUM(f.weather_ct) AS total_incidentes_clima,
        SUM(f.weather_delay) AS total_minutos_clima,
        AVG(f.weather_delay) AS media_minutos_por_registro,
        SUM(f.arr_flights) AS total_voos
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.time_srk = t.time_key
    GROUP BY t.month
)
SELECT
    month AS mes,
    CASE month
        WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril' WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro'
    END AS mes_nome,
    total_incidentes_clima,
    total_minutos_clima,
    ROUND(media_minutos_por_registro, 2) AS media_minutos_por_registro,
    total_voos,
    ROUND(100.0 * total_incidentes_clima / NULLIF(total_voos, 0), 2) AS pct_voos_afetados
FROM weather_impact_monthly
ORDER BY total_minutos_clima DESC;

-- ============================================================================
-- 8. MATRIZ DE PERFORMANCE: CARRIER vs AEROPORTO (TOP 10x10)
-- ============================================================================
-- Objetivo: Identificar combinações críticas carrier-aeroporto
WITH top_carriers AS (
    SELECT carrier_key
    FROM dw.fact_flight_delays
    GROUP BY carrier_key
    ORDER BY SUM(arr_flights) DESC
    LIMIT 10
),
top_airports AS (
    SELECT airport_key
    FROM dw.fact_flight_delays
    GROUP BY airport_key
    ORDER BY SUM(arr_flights) DESC
    LIMIT 10
)
SELECT
    c.carrier_name,
    a.airport_name,
    SUM(f.arr_flights) AS total_voos,
    ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
    ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
    ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_pct
FROM dw.fact_flight_delays f
JOIN dw.dim_carrier c ON f.carrier_srk = c.carrier_key
JOIN dw.dim_airport a ON f.airport_srk = a.airport_key
WHERE f.carrier_srk IN (SELECT carrier_key FROM top_carriers)
  AND f.airport_srk IN (SELECT airport_key FROM top_airports)
GROUP BY c.carrier_name, a.airport_name
ORDER BY c.carrier_name, a.airport_name;

-- ============================================================================
-- 9. COMPARAÇÃO TRIMESTRAL
-- ============================================================================
-- Objetivo: Análise de performance por trimestre
WITH quarterly_stats AS (
    SELECT
        t.ano_trimestre,
        t.trimestre,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        AVG(f.delay_rate) AS taxa_atraso_pct,
        AVG(f.avg_delay_minutes) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        SUM(f.carrier_delay) AS total_carrier_delay,
        SUM(f.weather_delay) AS total_weather_delay,
        SUM(f.nas_delay) AS total_nas_delay,
        SUM(f.security_delay) AS total_security_delay,
        SUM(f.late_aircraft_delay) AS total_late_aircraft_delay
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.time_srk = t.time_key
    GROUP BY t.ano_trimestre, t.trimestre
)
SELECT
    ano_trimestre,
    trimestre,
    total_voos,
    total_atrasos,
    ROUND(taxa_atraso_pct, 2) AS taxa_atraso_pct,
    ROUND(atraso_medio_minutos, 2) AS atraso_medio_minutos,
    total_cancelamentos,
    GREATEST(
        total_carrier_delay,
        total_weather_delay,
        total_nas_delay,
        total_security_delay,
        total_late_aircraft_delay
    ) AS maior_causa_minutos
FROM quarterly_stats
ORDER BY ano_trimestre;

-- ============================================================================
-- 10. HIDDEN GEMS: AEROPORTOS COM BOA PERFORMANCE E BAIXO VOLUME
-- ============================================================================
-- Objetivo: Encontrar aeroportos eficientes mas menos conhecidos
WITH airport_performance AS (
    SELECT
        a.airport_code,
        a.airport_name,
        SUM(f.arr_flights) AS total_voos,
        AVG(f.on_time_rate) AS taxa_pontualidade_pct,
        AVG(f.delay_rate) AS taxa_atraso_pct,
        AVG(f.avg_delay_minutes) AS atraso_medio_minutos
    FROM dw.fact_flight_delays f
    JOIN dw.dim_airport a ON f.airport_srk = a.airport_key
    GROUP BY a.airport_code, a.airport_name
),
percentiles AS (
    SELECT
        percentile_cont(0.25) WITHIN GROUP (ORDER BY total_voos) AS q25_voos,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY taxa_pontualidade_pct) AS q75_pontualidade
    FROM airport_performance
)
SELECT
    ap.airport_code,
    ap.airport_name,
    ap.total_voos,
    ROUND(ap.taxa_pontualidade_pct, 2) AS taxa_pontualidade_pct,
    ROUND(ap.taxa_atraso_pct, 2) AS taxa_atraso_pct,
    ROUND(ap.atraso_medio_minutos, 2) AS atraso_medio_minutos
FROM airport_performance ap
CROSS JOIN percentiles p
WHERE ap.total_voos <= p.q25_voos
  AND ap.taxa_pontualidade_pct >= p.q75_pontualidade
ORDER BY ap.taxa_pontualidade_pct DESC
LIMIT 15;

-- ============================================================================
-- 11. PIOR DIA DE CADA ANO (MÁXIMO ATRASO)
-- ============================================================================
-- Objetivo: Identificar dias específicos com problemas extremos
WITH agregacao_mensal AS (
    SELECT
        t.year,
        t.month,
        t.mes_ano,
        SUM(f.arr_delay) AS total_atraso_minutos,
        SUM(f.arr_del15) AS total_voos_atrasados,
        SUM(f.arr_flights) AS total_voos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.time_srk = t.time_key
    GROUP BY t.year, t.month, t.mes_ano
),
ranked AS (
    SELECT
        year,
        mes_ano,
        total_atraso_minutos,
        total_voos_atrasados,
        total_voos,
        taxa_atraso,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY total_atraso_minutos DESC) AS rank
    FROM agregacao_mensal
)
SELECT
    year AS ano,
    mes_ano AS pior_mes,
    total_atraso_minutos,
    total_voos_atrasados,
    total_voos,
    taxa_atraso
FROM ranked
WHERE rank = 1
ORDER BY year;

-- ============================================================================
-- 12. CARRIER COM MELHOR PERFORMANCE POR CATEGORIA DE CAUSA
-- ============================================================================
-- Objetivo: Identificar qual carrier é o melhor em cada tipo de problema
WITH carrier_causas AS (
    SELECT
        c.carrier_code,
        c.carrier_name,
        SUM(f.carrier_delay) AS total_carrier_delay,
        SUM(f.weather_delay) AS total_weather_delay,
        SUM(f.nas_delay) AS total_nas_delay,
        SUM(f.security_delay) AS total_security_delay,
        SUM(f.late_aircraft_delay) AS total_late_aircraft_delay,
        SUM(f.arr_flights) AS total_voos
    FROM dw.fact_flight_delays f
    JOIN dw.dim_carrier c ON f.carrier_srk = c.carrier_key
    GROUP BY c.carrier_code, c.carrier_name
    HAVING SUM(f.arr_flights) >= 1000
)
SELECT
    'Menor Atraso - Companhia' AS categoria,
    carrier_name,
    ROUND(total_carrier_delay / NULLIF(total_voos, 0), 2) AS minutos_por_voo
FROM carrier_causas
ORDER BY minutos_por_voo ASC
LIMIT 1

UNION ALL

SELECT
    'Menor Atraso - Meteorologia' AS categoria,
    carrier_name,
    ROUND(total_weather_delay / NULLIF(total_voos, 0), 2) AS minutos_por_voo
FROM carrier_causas
ORDER BY minutos_por_voo ASC
LIMIT 1

UNION ALL

SELECT
    'Menor Atraso - NAS' AS categoria,
    carrier_name,
    ROUND(total_nas_delay / NULLIF(total_voos, 0), 2) AS minutos_por_voo
FROM carrier_causas
ORDER BY minutos_por_voo ASC
LIMIT 1

UNION ALL

SELECT
    'Menor Atraso - Aeronave' AS categoria,
    carrier_name,
    ROUND(total_late_aircraft_delay / NULLIF(total_voos, 0), 2) AS minutos_por_voo
FROM carrier_causas
ORDER BY minutos_por_voo ASC
LIMIT 1;

-- ============================================================================
-- 13. COMPARAÇÃO ANTES/DEPOIS PANDEMIA (2020)
-- ============================================================================
-- Objetivo: Medir impacto da COVID-19 na operação
WITH pandemic_periods AS (
    SELECT
        CASE 
            WHEN t.year < 2020 THEN 'Pré-Pandemia (2013-2019)'
            WHEN t.year = 2020 THEN 'Durante Pandemia (2020)'
            ELSE 'Pós-Pandemia (2021-2023)'
        END AS periodo,
        SUM(f.arr_flights) AS total_voos,
        AVG(f.delay_rate) AS taxa_atraso_media,
        AVG(f.on_time_rate) AS taxa_pontualidade_media,
        AVG(f.avg_delay_minutes) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.time_srk = t.time_key
    GROUP BY 
        CASE 
            WHEN t.year < 2020 THEN 'Pré-Pandemia (2013-2019)'
            WHEN t.year = 2020 THEN 'Durante Pandemia (2020)'
            ELSE 'Pós-Pandemia (2021-2023)'
        END
)
SELECT
    periodo,
    total_voos,
    ROUND(taxa_atraso_media, 2) AS taxa_atraso_media,
    ROUND(taxa_pontualidade_media, 2) AS taxa_pontualidade_media,
    ROUND(atraso_medio_minutos, 2) AS atraso_medio_minutos,
    total_cancelamentos,
    ROUND(100.0 * total_cancelamentos / NULLIF(total_voos, 0), 2) AS taxa_cancelamento_pct
FROM pandemic_periods
ORDER BY 
    CASE 
        WHEN periodo = 'Pré-Pandemia (2013-2019)' THEN 1
        WHEN periodo = 'Durante Pandemia (2020)' THEN 2
        ELSE 3
    END;

-- ============================================================================
-- 14. VOLUME E EFICIÊNCIA: ANÁLISE DE CORRELAÇÃO
-- ============================================================================
-- Objetivo: Verificar se aeroportos com mais voos têm pior performance
WITH airport_aggregation AS (
    SELECT
        f.airport_srk,
        SUM(f.arr_flights) AS total_voos,
        AVG(f.delay_rate) AS taxa_atraso,
        AVG(f.avg_delay_minutes) AS atraso_medio
    FROM dw.fact_flight_delays f
    GROUP BY f.airport_srk
),
volume_classification AS (
    SELECT
        airport_srk,
        total_voos,
        taxa_atraso,
        atraso_medio,
        CASE
            WHEN total_voos < 10000 THEN '1. < 10k voos'
            WHEN total_voos < 50000 THEN '2. 10k-50k voos'
            WHEN total_voos < 100000 THEN '3. 50k-100k voos'
            WHEN total_voos < 200000 THEN '4. 100k-200k voos'
            ELSE '5. > 200k voos'
        END AS faixa_volume
    FROM airport_aggregation
)
SELECT
    faixa_volume,
    COUNT(DISTINCT airport_srk) AS num_aeroportos,
    ROUND(AVG(taxa_atraso), 2) AS taxa_atraso_media,
    ROUND(AVG(atraso_medio), 2) AS atraso_medio_minutos
FROM volume_classification
GROUP BY faixa_volume
ORDER BY faixa_volume;

-- ============================================================================
-- 15. DASHBOARD SUMMARY - MÉTRICAS GLOBAIS
-- ============================================================================
-- Objetivo: KPIs principais para dashboard executivo
WITH global_metrics AS (
    SELECT
        SUM(arr_flights) AS total_voos,
        SUM(arr_del15) AS total_atrasos,
        AVG(delay_rate) AS taxa_atraso_media,
        AVG(on_time_rate) AS taxa_pontualidade_media,
        AVG(avg_delay_minutes) AS atraso_medio,
        SUM(arr_cancelled) AS total_cancelamentos,
        SUM(arr_diverted) AS total_desvios,
        COUNT(DISTINCT carrier_srk) AS total_carriers,
        COUNT(DISTINCT airport_srk) AS total_airports
    FROM dw.fact_flight_delays
)
SELECT
    'Total de Voos (2013-2023)' AS metrica,
    TO_CHAR(total_voos, 'FM999,999,999') AS valor
FROM global_metrics
UNION ALL
SELECT
    'Total de Atrasos ≥15min' AS metrica,
    TO_CHAR(total_atrasos, 'FM999,999,999') AS valor
FROM global_metrics
UNION ALL
SELECT
    'Taxa de Atraso Média (%)' AS metrica,
    TO_CHAR(ROUND(taxa_atraso_media, 2), 'FM999.99') AS valor
FROM global_metrics
UNION ALL
SELECT
    'Taxa de Pontualidade Média (%)' AS metrica,
    TO_CHAR(ROUND(taxa_pontualidade_media, 2), 'FM999.99') AS valor
FROM global_metrics
UNION ALL
SELECT
    'Atraso Médio (minutos)' AS metrica,
    TO_CHAR(ROUND(atraso_medio, 2), 'FM999.99') AS valor
FROM global_metrics
UNION ALL
SELECT
    'Total de Cancelamentos' AS metrica,
    TO_CHAR(total_cancelamentos, 'FM999,999,999') AS valor
FROM global_metrics
UNION ALL
SELECT
    'Total de Desvios' AS metrica,
    TO_CHAR(total_desvios, 'FM999,999') AS valor
FROM global_metrics
UNION ALL
SELECT
    'Companhias Aéreas Distintas' AS metrica,
    TO_CHAR(total_carriers, 'FM999') AS valor
FROM global_metrics
UNION ALL
SELECT
    'Aeroportos Distintos' AS metrica,
    TO_CHAR(total_airports, 'FM999') AS valor
FROM global_metrics;

-- ============================================================================
-- FIM DAS CONSULTAS
-- ============================================================================
