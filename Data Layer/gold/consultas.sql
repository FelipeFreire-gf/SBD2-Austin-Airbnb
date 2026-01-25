
-- 1. ANÁLISE YEAR-OVER-YEAR (CRESCIMENTO E VARIAÇÃO ANUAL)

-- Objetivo: Identificar tendências de crescimento/declínio com variações percentuais
WITH yearly_metrics AS (
    SELECT
        t.year,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        ROUND(AVG(f.cancellation_rate), 2) AS taxa_cancelamento_pct
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.srk_time = t.srk_time
    GROUP BY t.year
),
yoy_comparison AS (
    SELECT
        y1.year,
        y1.total_voos,
        y1.total_atrasos,
        y1.taxa_atraso_pct,
        y1.atraso_medio_minutos,
        y1.total_cancelamentos,
        y1.taxa_cancelamento_pct,
        ROUND(100.0 * (y1.total_voos - COALESCE(y2.total_voos, 0)) / NULLIF(y2.total_voos, 0), 2) AS variacao_voos_pct,
        ROUND(y1.taxa_atraso_pct - COALESCE(y2.taxa_atraso_pct, 0), 2) AS variacao_taxa_atraso_pp,
        ROUND(y1.atraso_medio_minutos - COALESCE(y2.atraso_medio_minutos, 0), 2) AS variacao_atraso_medio_min,
        ROUND(100.0 * (y1.total_cancelamentos - COALESCE(y2.total_cancelamentos, 0)) / NULLIF(y2.total_cancelamentos, 0), 2) AS variacao_cancelamentos_pct
    FROM yearly_metrics y1
    LEFT JOIN yearly_metrics y2 ON y1.year = y2.year - 1
)
SELECT * FROM yoy_comparison
ORDER BY year;


-- 2. TOP 10 ROTAS MAIS MOVIMENTADAS (CARRIER × AEROPORTO)

-- Objetivo: Identificar principais operações e sua performance (para análise de rotas críticas)
WITH route_performance AS (
    SELECT
        c.carrier_code,
        c.carrier_name,
        a.airport_code,
        a.airport_name,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        ROUND(AVG(f.cancellation_rate), 2) AS taxa_cancelamento_pct,
        SUM(f.carrier_delay) AS tempo_atraso_carrier,
        SUM(f.weather_delay) AS tempo_atraso_clima,
        SUM(f.nas_delay) AS tempo_atraso_nas,
        -- Identificar causa principal de atraso
        CASE
            WHEN SUM(f.carrier_delay) >= GREATEST(SUM(f.weather_delay), SUM(f.nas_delay), SUM(f.security_delay), SUM(f.late_aircraft_delay)) THEN 'Carrier'
            WHEN SUM(f.weather_delay) >= GREATEST(SUM(f.carrier_delay), SUM(f.nas_delay), SUM(f.security_delay), SUM(f.late_aircraft_delay)) THEN 'Clima'
            WHEN SUM(f.nas_delay) >= GREATEST(SUM(f.carrier_delay), SUM(f.weather_delay), SUM(f.security_delay), SUM(f.late_aircraft_delay)) THEN 'NAS'
            WHEN SUM(f.late_aircraft_delay) >= GREATEST(SUM(f.carrier_delay), SUM(f.weather_delay), SUM(f.nas_delay), SUM(f.security_delay)) THEN 'Aeronave Atrasada'
            ELSE 'Segurança'
        END AS causa_principal_atraso
    FROM dw.fact_flight_delays f
    JOIN dw.dim_carrier c ON f.srk_carrier = c.srk_carrier
    JOIN dw.dim_airport a ON f.srk_airport = a.srk_airport
    GROUP BY c.carrier_code, c.carrier_name, a.airport_code, a.airport_name
)
SELECT *
FROM route_performance
ORDER BY total_voos DESC
LIMIT 10;


-- 3. RANKING DE COMPANHIAS AÉREAS POR PONTUALIDADE

-- Objetivo: Identificar melhores e piores companhias (para gráfico de barras)
WITH carrier_stats AS (
    SELECT
        c.carrier_code,
        c.carrier_name,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        ROUND(AVG(f.cancellation_rate), 2) AS taxa_cancelamento_pct
    FROM dw.fact_flight_delays f
    JOIN dw.dim_carrier c ON f.srk_carrier = c.srk_carrier
    GROUP BY c.carrier_code, c.carrier_name
    HAVING SUM(f.arr_flights) >= 1000
)
SELECT *
FROM carrier_stats
ORDER BY taxa_pontualidade_pct DESC;


-- 4. TOP 20 AEROPORTOS MAIS PROBLEMÁTICOS

-- Objetivo: Identificar aeroportos com maiores problemas (para matriz de performance)
WITH airport_stats AS (
    SELECT
        a.airport_code,
        a.airport_name,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        ROUND(AVG(f.cancellation_rate), 2) AS taxa_cancelamento_pct,
        SUM(f.arr_diverted) AS total_desvios,
        ROUND(AVG(f.diversion_rate), 2) AS taxa_desvio_pct
    FROM dw.fact_flight_delays f
    JOIN dw.dim_airport a ON f.srk_airport = a.srk_airport
    GROUP BY a.airport_code, a.airport_name
    HAVING SUM(f.arr_flights) >= 500
)
SELECT *
FROM airport_stats
ORDER BY taxa_atraso_pct DESC
LIMIT 20;


-- 5. DISTRIBUIÇÃO DE SEVERIDADE DE ATRASOS

-- Objetivo: Classificar voos por faixas de atraso para análise de distribuição
WITH delay_severity AS (
    SELECT
        CASE 
            WHEN arr_del15 = 0 THEN '1. No Horário (0-14 min)'
            WHEN avg_delay_minutes BETWEEN 15 AND 29 THEN '2. Atraso Leve (15-29 min)'
            WHEN avg_delay_minutes BETWEEN 30 AND 59 THEN '3. Atraso Moderado (30-59 min)'
            WHEN avg_delay_minutes BETWEEN 60 AND 119 THEN '4. Atraso Grave (60-119 min)'
            WHEN avg_delay_minutes >= 120 THEN '5. Atraso Crítico (120+ min)'
            ELSE '1. No Horário (0-14 min)'
        END AS faixa_atraso,
        COUNT(*) AS quantidade_registros,
        SUM(arr_flights) AS total_voos,
        SUM(arr_del15) AS total_atrasos,
        ROUND(AVG(avg_delay_minutes), 1) AS atraso_medio_faixa,
        SUM(arr_cancelled) AS total_cancelamentos,
        -- Breakdown de causas por severidade
        SUM(carrier_delay) AS tempo_carrier,
        SUM(weather_delay) AS tempo_clima,
        SUM(nas_delay) AS tempo_nas,
        SUM(late_aircraft_delay) AS tempo_aeronave
    FROM dw.fact_flight_delays
    GROUP BY 
        CASE 
            WHEN arr_del15 = 0 THEN '1. No Horário (0-14 min)'
            WHEN avg_delay_minutes BETWEEN 15 AND 29 THEN '2. Atraso Leve (15-29 min)'
            WHEN avg_delay_minutes BETWEEN 30 AND 59 THEN '3. Atraso Moderado (30-59 min)'
            WHEN avg_delay_minutes BETWEEN 60 AND 119 THEN '4. Atraso Grave (60-119 min)'
            WHEN avg_delay_minutes >= 120 THEN '5. Atraso Crítico (120+ min)'
            ELSE '1. No Horário (0-14 min)'
        END
)
SELECT
    faixa_atraso,
    quantidade_registros,
    total_voos,
    total_atrasos,
    atraso_medio_faixa,
    total_cancelamentos,
    tempo_carrier,
    tempo_clima,
    tempo_nas,
    tempo_aeronave,
    ROUND(100.0 * total_voos / SUM(total_voos) OVER(), 2) AS percentual_voos
FROM delay_severity
ORDER BY faixa_atraso;


-- 6. CONCENTRAÇÃO DE MERCADO E MARKET SHARE POR CARRIER

-- Objetivo: Analisar distribuição de market share e concentração de mercado
WITH carrier_market_share AS (
    SELECT
        c.carrier_code,
        c.carrier_name,
        SUM(f.arr_flights) AS total_voos,
        ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_pct,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        SUM(f.arr_diverted) AS total_desvios,
        -- Cálculo de market share
        ROUND(100.0 * SUM(f.arr_flights) / SUM(SUM(f.arr_flights)) OVER(), 2) AS market_share_pct,
        -- Ranking por volume
        RANK() OVER (ORDER BY SUM(f.arr_flights) DESC) AS ranking_volume,
        -- Classificação de tamanho
        CASE 
            WHEN RANK() OVER (ORDER BY SUM(f.arr_flights) DESC) <= 3 THEN 'Top 3 - Major'
            WHEN RANK() OVER (ORDER BY SUM(f.arr_flights) DESC) <= 10 THEN 'Top 10 - Grande'
            WHEN RANK() OVER (ORDER BY SUM(f.arr_flights) DESC) <= 20 THEN 'Top 20 - Média'
            ELSE 'Demais - Pequena'
        END AS categoria_tamanho
    FROM dw.fact_flight_delays f
    JOIN dw.dim_carrier c ON f.srk_carrier = c.srk_carrier
    GROUP BY c.carrier_code, c.carrier_name
),
market_concentration AS (
    SELECT 
        SUM(CASE WHEN ranking_volume <= 3 THEN market_share_pct ELSE 0 END) AS concentracao_top3,
        SUM(CASE WHEN ranking_volume <= 5 THEN market_share_pct ELSE 0 END) AS concentracao_top5,
        SUM(CASE WHEN ranking_volume <= 10 THEN market_share_pct ELSE 0 END) AS concentracao_top10
    FROM carrier_market_share
)
SELECT
    cms.carrier_code,
    cms.carrier_name,
    cms.total_voos,
    cms.market_share_pct,
    cms.ranking_volume,
    cms.categoria_tamanho,
    cms.taxa_pontualidade_pct,
    cms.taxa_atraso_pct,
    cms.atraso_medio_minutos,
    cms.total_cancelamentos,
    cms.total_desvios,
    mc.concentracao_top3,
    mc.concentracao_top5,
    mc.concentracao_top10
FROM carrier_market_share cms
CROSS JOIN market_concentration mc
ORDER BY cms.ranking_volume;


-- 7. ANÁLISE DE CAUSAS DE ATRASOS - BREAKDOWN PERCENTUAL

-- Objetivo: Contribuição de cada causa (para gráfico de pizza/donut)
WITH causa_agregada AS (
    SELECT
        'Companhia Aérea' AS causa,
        SUM(carrier_delay) AS tempo_total_minutos,
        SUM(carrier_ct) AS contagem_incidentes
    FROM dw.fact_flight_delays
    UNION ALL
    SELECT 'Clima', SUM(weather_delay), SUM(weather_ct) FROM dw.fact_flight_delays
    UNION ALL
    SELECT 'Sistema Nacional (NAS)', SUM(nas_delay), SUM(nas_ct) FROM dw.fact_flight_delays
    UNION ALL
    SELECT 'Segurança', SUM(security_delay), SUM(security_ct) FROM dw.fact_flight_delays
    UNION ALL
    SELECT 'Aeronave Atrasada', SUM(late_aircraft_delay), SUM(late_aircraft_ct) FROM dw.fact_flight_delays
)
SELECT
    causa,
    tempo_total_minutos,
    contagem_incidentes,
    ROUND(100.0 * tempo_total_minutos / SUM(tempo_total_minutos) OVER(), 2) AS percentual_contribuicao,
    ROUND(tempo_total_minutos * 1.0 / NULLIF(contagem_incidentes, 0), 1) AS minutos_por_incidente
FROM causa_agregada
WHERE tempo_total_minutos > 0
ORDER BY tempo_total_minutos DESC;


-- 8. SAZONALIDADE MENSAL E CAUSAS DE ATRASO

-- Objetivo: Identificar padrões sazonais e principais causas por mês
WITH monthly_causes AS (
    SELECT
        t.month,
        t.mes_nome,
        SUM(f.arr_flights) AS total_voos,
        SUM(f.arr_del15) AS total_atrasos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        -- Breakdown de causas
        SUM(f.carrier_delay) AS total_atraso_carrier,
        SUM(f.weather_delay) AS total_atraso_clima,
        SUM(f.nas_delay) AS total_atraso_nas,
        SUM(f.late_aircraft_delay) AS total_atraso_aeronave,
        -- Identificar causa dominante
        CASE
            WHEN SUM(f.carrier_delay) >= GREATEST(SUM(f.weather_delay), SUM(f.nas_delay), SUM(f.late_aircraft_delay), SUM(f.security_delay)) THEN 'Carrier'
            WHEN SUM(f.weather_delay) >= GREATEST(SUM(f.carrier_delay), SUM(f.nas_delay), SUM(f.late_aircraft_delay), SUM(f.security_delay)) THEN 'Clima'
            WHEN SUM(f.nas_delay) >= GREATEST(SUM(f.carrier_delay), SUM(f.weather_delay), SUM(f.late_aircraft_delay), SUM(f.security_delay)) THEN 'NAS'
            ELSE 'Aeronave'
        END AS causa_dominante
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.srk_time = t.srk_time
    GROUP BY t.month, t.mes_nome
)
SELECT *
FROM monthly_causes
ORDER BY month;


-- 9. MATRIZ ANO × MÊS COM RANKING DE PERFORMANCE

-- Objetivo: Heatmap ano-mês mostrando evolução mensal ao longo dos anos
WITH monthly_yearly_performance AS (
    SELECT
        t.year,
        t.month,
        t.mes_nome,
        SUM(f.arr_flights) AS total_voos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_pct,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        -- Ranking do mês dentro do ano (1 = melhor mês do ano)
        RANK() OVER (PARTITION BY t.year ORDER BY AVG(f.on_time_rate) DESC) AS rank_pontualidade_no_ano,
        -- Identifica melhor e pior mês de cada ano
        CASE 
            WHEN RANK() OVER (PARTITION BY t.year ORDER BY AVG(f.on_time_rate) DESC) = 1 THEN 'Melhor Mês'
            WHEN RANK() OVER (PARTITION BY t.year ORDER BY AVG(f.on_time_rate) ASC) = 1 THEN 'Pior Mês'
            ELSE 'Normal'
        END AS destaque_mes
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.srk_time = t.srk_time
    GROUP BY t.year, t.month, t.mes_nome
)
SELECT
    year,
    month,
    mes_nome,
    total_voos,
    taxa_atraso_pct,
    taxa_pontualidade_pct,
    atraso_medio_minutos,
    total_cancelamentos,
    rank_pontualidade_no_ano,
    destaque_mes
FROM monthly_yearly_performance
ORDER BY year, month;


-- 10. COMPARAÇÃO PANDEMIA (PRÉ/DURANTE/PÓS COVID-19)

-- Objetivo: Medir impacto da COVID-19 na operação (análise comparativa)
WITH pandemic_periods AS (
    SELECT
        CASE 
            WHEN t.year < 2020 THEN 'Pré-Pandemia (2013-2019)'
            WHEN t.year = 2020 THEN 'Durante Pandemia (2020)'
            ELSE 'Pós-Pandemia (2021-2023)'
        END AS periodo,
        SUM(f.arr_flights) AS total_voos,
        ROUND(AVG(f.delay_rate), 2) AS taxa_atraso_media,
        ROUND(AVG(f.on_time_rate), 2) AS taxa_pontualidade_media,
        ROUND(AVG(f.avg_delay_minutes), 2) AS atraso_medio_minutos,
        SUM(f.arr_cancelled) AS total_cancelamentos,
        ROUND(AVG(f.cancellation_rate), 2) AS taxa_cancelamento_media
    FROM dw.fact_flight_delays f
    JOIN dw.dim_time t ON f.srk_time = t.srk_time
    GROUP BY 
        CASE 
            WHEN t.year < 2020 THEN 'Pré-Pandemia (2013-2019)'
            WHEN t.year = 2020 THEN 'Durante Pandemia (2020)'
            ELSE 'Pós-Pandemia (2021-2023)'
        END
)
SELECT *
FROM pandemic_periods
ORDER BY 
    CASE 
        WHEN periodo = 'Pré-Pandemia (2013-2019)' THEN 1
        WHEN periodo = 'Durante Pandemia (2020)' THEN 2
        ELSE 3
    END;