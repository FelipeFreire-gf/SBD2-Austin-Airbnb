
-- 1. KPIs GERAIS - VISÃO CONSOLIDADA DO NEGÓCIO

-- Objetivo: Dashboard executivo com principais indicadores operacionais
SELECT 
    COUNT(DISTINCT f.SRK_CRE) AS total_companhias,
    COUNT(DISTINCT f.SRK_ARR) AS total_aeroportos,
    COUNT(DISTINCT f.SRK_TME) AS total_periodos,
    SUM(f.ARR_FIT) AS total_voos,
    SUM(f.ARR_DEL) AS total_atrasos,
    ROUND(AVG(f.DLY_RTE), 2) AS taxa_atraso_media_pct,
    ROUND(AVG(f.ONT_RTE), 2) AS taxa_pontualidade_media_pct,
    ROUND(AVG(f.AVG_DLY_MNE), 2) AS atraso_medio_minutos,
    SUM(f.ARR_CNL) AS total_cancelamentos,
    ROUND(AVG(f.CNL_RTE), 2) AS taxa_cancelamento_media_pct,
    SUM(f.ARR_DVR) AS total_desvios,
    ROUND(AVG(f.DVS_RTE), 2) AS taxa_desvio_media_pct,
    -- Breakdown de causas de atraso (tempo total)
    SUM(f.CRE_DLY) AS tempo_total_atraso_carrier,
    SUM(f.WAE_DLY) AS tempo_total_atraso_clima,
    SUM(f.NAS_DLY) AS tempo_total_atraso_nas,
    SUM(f.SCR_DLY) AS tempo_total_atraso_seguranca,
    SUM(f.LTE_ARA_DLY) AS tempo_total_atraso_aeronave,
    -- Breakdown de causas de atraso (contagem)
    ROUND(SUM(f.CRE_CT), 0) AS contagem_atraso_carrier,
    ROUND(SUM(f.WAE_CT), 0) AS contagem_atraso_clima,
    ROUND(SUM(f.NAS_CT), 0) AS contagem_atraso_nas,
    ROUND(SUM(f.SCR_CT), 0) AS contagem_atraso_seguranca,
    ROUND(SUM(f.LTE_ARA_CT), 0) AS contagem_atraso_aeronave
FROM dw.FCT_FIT_DLS f;


-- 2. ANÁLISE YEAR-OVER-YEAR (CRESCIMENTO E VARIAÇÃO ANUAL)

-- Objetivo: Identificar tendências de crescimento/declínio com variações percentuais
WITH yearly_metrics AS (
    SELECT
        t.YAR,
        SUM(f.ARR_FIT) AS total_voos,
        SUM(f.ARR_DEL) AS total_atrasos,
        ROUND(AVG(f.DLY_RTE), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.AVG_DLY_MNE), 2) AS atraso_medio_minutos,
        SUM(f.ARR_CNL) AS total_cancelamentos,
        ROUND(AVG(f.CNL_RTE), 2) AS taxa_cancelamento_pct
    FROM dw.FCT_FIT_DLS f
    JOIN dw.DIM_TME t ON f.SRK_TME = t.SRK_TME
    GROUP BY t.YAR
),
yoy_comparison AS (
    SELECT
        y1.YAR,
        y1.total_voos,
        y1.total_atrasos,
        y1.taxa_atraso_pct,
        y1.atraso_medio_minutos,
        y1.total_cancelamentos,
        y1.taxa_cancelamento_pct,
        ROUND(100.0 * (y1.total_voos - y2.total_voos) / NULLIF(y2.total_voos, 0), 2) AS variacao_voos_pct,
        ROUND(y1.taxa_atraso_pct - y2.taxa_atraso_pct, 2) AS variacao_taxa_atraso_pp,
        ROUND(y1.atraso_medio_minutos - y2.atraso_medio_minutos, 2) AS variacao_atraso_medio_min,
        ROUND(100.0 * (y1.total_cancelamentos - y2.total_cancelamentos) / NULLIF(y2.total_cancelamentos, 0), 2) AS variacao_cancelamentos_pct
    FROM yearly_metrics y1
    LEFT JOIN yearly_metrics y2 ON y1.YAR = y2.YAR + 1
)
SELECT * FROM yoy_comparison
ORDER BY YAR;


-- 3. TOP 10 ROTAS MAIS MOVIMENTADAS (CARRIER × AEROPORTO)

-- Objetivo: Identificar principais operações e sua performance (para análise de rotas críticas)
WITH route_performance AS (
    SELECT
        c.CRE_CDE,
        c.CRE_NME,
        a.ARR_CDE,
        a.ARR_NME,
        SUM(f.ARR_FIT) AS total_voos,
        SUM(f.ARR_DEL) AS total_atrasos,
        ROUND(AVG(f.DLY_RTE), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.ONT_RTE), 2) AS taxa_pontualidade_pct,
        ROUND(AVG(f.AVG_DLY_MNE), 2) AS atraso_medio_minutos,
        SUM(f.ARR_CNL) AS total_cancelamentos,
        ROUND(AVG(f.CNL_RTE), 2) AS taxa_cancelamento_pct,
        SUM(f.CRE_DLY) AS tempo_atraso_carrier,
        SUM(f.WAE_DLY) AS tempo_atraso_clima,
        SUM(f.NAS_DLY) AS tempo_atraso_nas,
        SUM(f.SCR_DLY) AS tempo_atraso_seguranca,
        SUM(f.LTE_ARA_DLY) AS tempo_atraso_aeronave,
        -- Identificar causa principal de atraso
        CASE
            WHEN SUM(f.CRE_DLY) >= GREATEST(SUM(f.WAE_DLY), SUM(f.NAS_DLY), SUM(f.SCR_DLY), SUM(f.LTE_ARA_DLY)) THEN 'Carrier'
            WHEN SUM(f.WAE_DLY) >= GREATEST(SUM(f.CRE_DLY), SUM(f.NAS_DLY), SUM(f.SCR_DLY), SUM(f.LTE_ARA_DLY)) THEN 'Clima'
            WHEN SUM(f.NAS_DLY) >= GREATEST(SUM(f.CRE_DLY), SUM(f.WAE_DLY), SUM(f.SCR_DLY), SUM(f.LTE_ARA_DLY)) THEN 'NAS'
            WHEN SUM(f.LTE_ARA_DLY) >= GREATEST(SUM(f.CRE_DLY), SUM(f.WAE_DLY), SUM(f.NAS_DLY), SUM(f.SCR_DLY)) THEN 'Aeronave Atrasada'
            ELSE 'Segurança'
        END AS causa_principal_atraso
    FROM dw.FCT_FIT_DLS f
    JOIN dw.DIM_CRE c ON f.SRK_CRE = c.SRK_CRE
    JOIN dw.DIM_ARR a ON f.SRK_ARR = a.SRK_ARR
    GROUP BY c.CRE_CDE, c.CRE_NME, a.ARR_CDE, a.ARR_NME
)
SELECT *
FROM route_performance
ORDER BY total_voos DESC
LIMIT 10;


-- 4. RANKING DE COMPANHIAS AÉREAS POR PONTUALIDADE

-- Objetivo: Identificar melhores e piores companhias (para gráfico de barras)
WITH carrier_stats AS (
    SELECT
        c.CRE_CDE,
        c.CRE_NME,
        SUM(f.ARR_FIT) AS total_voos,
        SUM(f.ARR_DEL) AS total_atrasos,
        ROUND(AVG(f.DLY_RTE), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.ONT_RTE), 2) AS taxa_pontualidade_pct,
        ROUND(AVG(f.AVG_DLY_MNE), 2) AS atraso_medio_minutos,
        SUM(f.ARR_CNL) AS total_cancelamentos,
        ROUND(AVG(f.CNL_RTE), 2) AS taxa_cancelamento_pct
    FROM dw.FCT_FIT_DLS f
    JOIN dw.DIM_CRE c ON f.SRK_CRE = c.SRK_CRE
    GROUP BY c.CRE_CDE, c.CRE_NME
    HAVING SUM(f.ARR_FIT) >= 1000
)
SELECT *
FROM carrier_stats
ORDER BY taxa_pontualidade_pct DESC;


-- 5. TOP 20 AEROPORTOS MAIS PROBLEMÁTICOS

-- Objetivo: Identificar aeroportos com maiores problemas (para matriz de performance)
WITH airport_stats AS (
    SELECT
        a.ARR_CDE,
        a.ARR_NME,
        SUM(f.ARR_FIT) AS total_voos,
        SUM(f.ARR_DEL) AS total_atrasos,
        ROUND(AVG(f.DLY_RTE), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.AVG_DLY_MNE), 2) AS atraso_medio_minutos,
        SUM(f.ARR_CNL) AS total_cancelamentos,
        ROUND(AVG(f.CNL_RTE), 2) AS taxa_cancelamento_pct,
        SUM(f.ARR_DVR) AS total_desvios,
        ROUND(AVG(f.DVS_RTE), 2) AS taxa_desvio_pct
    FROM dw.FCT_FIT_DLS f
    JOIN dw.DIM_ARR a ON f.SRK_ARR = a.SRK_ARR
    GROUP BY a.ARR_CDE, a.ARR_NME
    HAVING SUM(f.ARR_FIT) >= 500
)
SELECT *
FROM airport_stats
ORDER BY taxa_atraso_pct DESC
LIMIT 20;


-- 6. DISTRIBUIÇÃO DE SEVERIDADE DE ATRASOS

-- Objetivo: Classificar voos por faixas de atraso para análise de distribuição
WITH delay_severity AS (
    SELECT
        CASE 
            WHEN ARR_DEL = 0 THEN '1. No Horário (0-14 min)'
            WHEN AVG_DLY_MNE BETWEEN 15 AND 29 THEN '2. Atraso Leve (15-29 min)'
            WHEN AVG_DLY_MNE BETWEEN 30 AND 59 THEN '3. Atraso Moderado (30-59 min)'
            WHEN AVG_DLY_MNE BETWEEN 60 AND 119 THEN '4. Atraso Grave (60-119 min)'
            WHEN AVG_DLY_MNE >= 120 THEN '5. Atraso Crítico (120+ min)'
            ELSE '1. No Horário (0-14 min)'
        END AS faixa_atraso,
        COUNT(*) AS quantidade_registros,
        SUM(ARR_FIT) AS total_voos,
        SUM(ARR_DEL) AS total_atrasos,
        ROUND(AVG(AVG_DLY_MNE), 1) AS atraso_medio_faixa,
        SUM(ARR_CNL) AS total_cancelamentos,
        -- Breakdown de causas por severidade
        SUM(CRE_DLY) AS tempo_carrier,
        SUM(WAE_DLY) AS tempo_clima,
        SUM(NAS_DLY) AS tempo_nas,
        SUM(LTE_ARA_DLY) AS tempo_aeronave
    FROM dw.FCT_FIT_DLS
    GROUP BY 
        CASE 
            WHEN ARR_DEL = 0 THEN '1. No Horário (0-14 min)'
            WHEN AVG_DLY_MNE BETWEEN 15 AND 29 THEN '2. Atraso Leve (15-29 min)'
            WHEN AVG_DLY_MNE BETWEEN 30 AND 59 THEN '3. Atraso Moderado (30-59 min)'
            WHEN AVG_DLY_MNE BETWEEN 60 AND 119 THEN '4. Atraso Grave (60-119 min)'
            WHEN AVG_DLY_MNE >= 120 THEN '5. Atraso Crítico (120+ min)'
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


-- 7. ANÁLISE DE CAUSAS DE ATRASOS - BREAKDOWN PERCENTUAL

-- Objetivo: Contribuição de cada causa (para gráfico de pizza/donut)
WITH causa_agregada AS (
    SELECT
        'Companhia Aérea' AS causa,
        SUM(CRE_DLY) AS tempo_total_minutos,
        ROUND(SUM(CRE_CT), 0) AS contagem_incidentes
    FROM dw.FCT_FIT_DLS
    UNION ALL
    SELECT 'Clima', SUM(WAE_DLY), ROUND(SUM(WAE_CT), 0) FROM dw.FCT_FIT_DLS
    UNION ALL
    SELECT 'Sistema Nacional (NAS)', SUM(NAS_DLY), ROUND(SUM(NAS_CT), 0) FROM dw.FCT_FIT_DLS
    UNION ALL
    SELECT 'Segurança', SUM(SCR_DLY), ROUND(SUM(SCR_CT), 0) FROM dw.FCT_FIT_DLS
    UNION ALL
    SELECT 'Aeronave Atrasada', SUM(LTE_ARA_DLY), ROUND(SUM(LTE_ARA_CT), 0) FROM dw.FCT_FIT_DLS
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
        t.MNH,
        t.MES_NME,
        SUM(f.ARR_FIT) AS total_voos,
        SUM(f.ARR_DEL) AS total_atrasos,
        ROUND(AVG(f.DLY_RTE), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.AVG_DLY_MNE), 2) AS atraso_medio_minutos,
        SUM(f.ARR_CNL) AS total_cancelamentos,
        -- Breakdown de causas
        SUM(f.CRE_DLY) AS total_atraso_carrier,
        SUM(f.WAE_DLY) AS total_atraso_clima,
        SUM(f.NAS_DLY) AS total_atraso_nas,
        SUM(f.LTE_ARA_DLY) AS total_atraso_aeronave,
        -- Identificar causa dominante
        CASE
            WHEN SUM(f.CRE_DLY) >= GREATEST(SUM(f.WAE_DLY), SUM(f.NAS_DLY), SUM(f.LTE_ARA_DLY), SUM(f.SCR_DLY)) THEN 'Carrier'
            WHEN SUM(f.WAE_DLY) >= GREATEST(SUM(f.CRE_DLY), SUM(f.NAS_DLY), SUM(f.LTE_ARA_DLY), SUM(f.SCR_DLY)) THEN 'Clima'
            WHEN SUM(f.NAS_DLY) >= GREATEST(SUM(f.CRE_DLY), SUM(f.WAE_DLY), SUM(f.LTE_ARA_DLY), SUM(f.SCR_DLY)) THEN 'NAS'
            ELSE 'Aeronave'
        END AS causa_dominante
    FROM dw.FCT_FIT_DLS f
    JOIN dw.DIM_TME t ON f.SRK_TME = t.SRK_TME
    GROUP BY t.MNH, t.MES_NME
)
SELECT *
FROM monthly_causes
ORDER BY MNH;


-- 9. MATRIZ ANO × MÊS COM RANKING DE PERFORMANCE

-- Objetivo: Heatmap ano-mês mostrando evolução mensal ao longo dos anos
WITH monthly_yearly_performance AS (
    SELECT
        t.YAR,
        t.MNH,
        t.MES_NME,
        SUM(f.ARR_FIT) AS total_voos,
        ROUND(AVG(f.DLY_RTE), 2) AS taxa_atraso_pct,
        ROUND(AVG(f.ONT_RTE), 2) AS taxa_pontualidade_pct,
        ROUND(AVG(f.AVG_DLY_MNE), 2) AS atraso_medio_minutos,
        SUM(f.ARR_CNL) AS total_cancelamentos,
        -- Ranking do mês dentro do ano (1 = melhor mês do ano)
        RANK() OVER (PARTITION BY t.YAR ORDER BY AVG(f.ONT_RTE) DESC) AS rank_pontualidade_no_ano,
        -- Identifica melhor e pior mês de cada ano
        CASE 
            WHEN RANK() OVER (PARTITION BY t.YAR ORDER BY AVG(f.ONT_RTE) DESC) = 1 THEN 'Melhor Mês'
            WHEN RANK() OVER (PARTITION BY t.YAR ORDER BY AVG(f.ONT_RTE) ASC) = 1 THEN 'Pior Mês'
            ELSE 'Normal'
        END AS destaque_mes
    FROM dw.FCT_FIT_DLS f
    JOIN dw.DIM_TME t ON f.SRK_TME = t.SRK_TME
    GROUP BY t.YAR, t.MNH, t.MES_NME
)
SELECT
    YAR,
    MNH,
    MES_NME,
    total_voos,
    taxa_atraso_pct,
    taxa_pontualidade_pct,
    atraso_medio_minutos,
    total_cancelamentos,
    rank_pontualidade_no_ano,
    destaque_mes
FROM monthly_yearly_performance
ORDER BY YAR, MNH;


-- 10. COMPARAÇÃO PANDEMIA (PRÉ/DURANTE/PÓS COVID-19)

-- Objetivo: Medir impacto da COVID-19 na operação (análise comparativa)
WITH pandemic_periods AS (
    SELECT
        CASE 
            WHEN t.YAR < 2020 THEN 'Pré-Pandemia (2013-2019)'
            WHEN t.YAR = 2020 THEN 'Durante Pandemia (2020)'
            ELSE 'Pós-Pandemia (2021-2023)'
        END AS periodo,
        SUM(f.ARR_FIT) AS total_voos,
        ROUND(AVG(f.DLY_RTE), 2) AS taxa_atraso_media,
        ROUND(AVG(f.ONT_RTE), 2) AS taxa_pontualidade_media,
        ROUND(AVG(f.AVG_DLY_MNE), 2) AS atraso_medio_minutos,
        SUM(f.ARR_CNL) AS total_cancelamentos,
        ROUND(AVG(f.CNL_RTE), 2) AS taxa_cancelamento_media
    FROM dw.FCT_FIT_DLS f
    JOIN dw.DIM_TME t ON f.SRK_TME = t.SRK_TME
    GROUP BY 
        CASE 
            WHEN t.YAR < 2020 THEN 'Pré-Pandemia (2013-2019)'
            WHEN t.YAR = 2020 THEN 'Durante Pandemia (2020)'
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