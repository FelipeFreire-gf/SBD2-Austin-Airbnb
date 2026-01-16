# Bem-vindo ao Projeto Análise de Atrasos de Voos

Esta é a documentação oficial do projeto de **Análise de Atrasos de Voos em Aeroportos dos Estados Unidos** desenvolvido pelo **Grupo 04** na disciplina de Banco de Dados 2 da **UnB**. Aqui você encontrará toda a documentação técnica, modelagens, análises e guias de desenvolvimento.

## 📋 Estrutura do Projeto

* **📚 Entrega 0 - Base de Dados**: Coleta e armazenamento dos dados brutos (Camada Bronze)
* **🔄 Entrega 1 - Raw → Silver**: Pipeline ETL, limpeza e carga no PostgreSQL
* **📊 Entrega 2 - Gold Layer**: Agregações, métricas e visualizações analíticas
* **📈 Entrega 3 - Power BI**: Dashboard interativo e publicação

## 🗂️ Sobre o Dataset

**Dataset**: [Airline Delay and Cancellation Data (2013-2023)](https://www.kaggle.com/datasets/sriharshaeedala/airline-delay)  
**Fonte**: Bureau of Transportation Statistics (BTS) - U.S. Government  
**Período**: Agosto 2013 - Agosto 2023 (10 anos)  
**Tamanho**: 28.73 MB | **Licença**: U.S. Government Works | **Usabilidade**: 10.0/10

### Propósito do Dataset

O dataset oferece insights detalhados sobre a performance operacional de companhias aéreas americanas em diversos aeroportos durante 10 anos. Permite análises de:

- ✈️ **Performance de Companhias**: Pontualidade, cancelamentos e eficiência operacional
- 📊 **Tendências Temporais**: Padrões sazonais, evolução anual e períodos críticos
- 🔍 **Análise de Causa-Raiz**: Identificação dos principais fatores de atrasos
- 📈 **Benchmarking**: Comparação entre carriers e aeroportos
- 🤖 **Modelagem Preditiva**: Previsão de atrasos e estratégias de mitigação

### Estrutura dos Dados (21 Colunas)

**Dimensões Temporais e Identificadores:**
- `year`, `month` - Dimensões temporais
- `carrier`, `carrier_name` - Código e nome da companhia aérea
- `airport`, `airport_name` - Código e nome do aeroporto

**Métricas Operacionais:**
- `arr_flights` - Total de voos de chegada
- `arr_del15` - Voos atrasados ≥15 minutos
- `arr_cancelled` - Voos cancelados
- `arr_diverted` - Voos desviados

**Contagem de Atrasos por Causa:**
- `carrier_ct` - Atrasos devido à companhia aérea
- `weather_ct` - Atrasos devido a condições meteorológicas
- `nas_ct` - Atrasos devido ao NAS (National Airspace System)
- `security_ct` - Atrasos devido a segurança
- `late_aircraft_ct` - Atrasos devido a aeronave atrasada

**Tempo de Atraso por Causa (minutos):**
- `arr_delay` - Tempo total de atraso
- `carrier_delay` - Tempo atribuído à companhia
- `weather_delay` - Tempo atribuído ao clima
- `nas_delay` - Tempo atribuído ao NAS
- `security_delay` - Tempo atribuído à segurança
- `late_aircraft_delay` - Tempo atribuído a aeronave atrasada

## 🏗️ Arquitetura do Projeto

**Arquitetura Medallion (Lakehouse)**

- **🥉 Bronze (Raw)**: Dados brutos do Kaggle sem transformações
- **🥈 Silver (Curated)**: Dados limpos, normalizados e armazenados no PostgreSQL
- **🥇 Gold (Aggregated)**: Métricas agregadas, KPIs e visualizações analíticas

## 🛠️ Tecnologias

- **Processamento**: PySpark, Pandas, NumPy
- **Banco de Dados**: PostgreSQL (v15) com psycopg2-binary
- **Container**: Docker & Docker Compose
- **Visualização**: Matplotlib, Seaborn, Power BI
- **Machine Learning**: scikit-learn, SciPy
- **Documentação**: MkDocs, Markdown
- **Controle de Versão**: Git, GitHub

Para começar a contribuir, leia o [Guia de Contribuição](CONTRIBUTING.md).
