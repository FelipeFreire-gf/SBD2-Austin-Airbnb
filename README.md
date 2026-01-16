# Análise de Atrasos de Voos em Aeroportos

<div align="center">

![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PySpark](https://img.shields.io/badge/PySpark-4.0+-E25A1C?style=for-the-badge&logo=apache-spark&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)

[![GitHub](https://img.shields.io/badge/GitHub-Repositório-181717?style=for-the-badge&logo=github)](https://github.com/FelipeFreire-gf/SBD2-Austin-Airbnb)
[![Documentação](https://img.shields.io/badge/Docs-MkDocs-526CFE?style=for-the-badge&logo=materialformkdocs&logoColor=white)](https://felipefreire-gf.github.io/SBD2-Austin-Airbnb/)
[![MIRO](https://img.shields.io/badge/MIRO-Board-050038?style=for-the-badge&logo=miro&logoColor=FFD02F)](https://miro.com/app/board/uXjVGSwQ8Ok=/?share_link_id=465202330329)

</div>

---

**ETL pipeline seguindo a arquitetura Medallion (Bronze, Silver, Gold) para análise de dados sobre atrasos de voos em aeroportos dos Estados Unidos.**

<div align="center">
<img src="docs/assets/logo.png" alt="Análise de Atrasos de Voos" style="max-width: 400px; height: auto; margin: 20px 0;">
</div>

<div align="center">

</div>

---

## Sobre o Projeto

Este repositório é dedicado à documentação de todos os artefatos criados pelo **Grupo 04** na disciplina de **Banco de Dados 2** da Faculdade de Ciências e Tecnologias em Engenharia da **Universidade de Brasília (FCTE-UnB)**.

### Objetivos

O projeto implementa um **pipeline ETL completo** utilizando a **Arquitetura Medallion** para análise de dados históricos de atrasos de voos nos Estados Unidos. Os principais objetivos são:

- **Arquitetura Lakehouse**: Implementar camadas Bronze (Raw), Silver (Curated) e Gold (Aggregated) para armazenamento e processamento otimizado

- **Modelagem de Dados**: Desenvolver representações conceitual (MER), lógica (DER) e física (DDL) do modelo de dados

- **Banco de Dados**: Construir e popular um banco PostgreSQL containerizado para consultas eficientes

- **Dashboard Analítico**: Desenvolver painéis interativos no Power BI para exploração de dados e geração de insights sobre:
  - Atrasos de voos por companhia aérea
  - Causas de atrasos (meteorologia, companhia, NAS, segurança, aeronave)
  - Padrões de sazonalidade
  - Cancelamentos e desvios
  - Tendências temporais

### Fonte de Dados

**Dataset**: [Airline Delay and Cancellation Data (2013-2023)](https://www.kaggle.com/datasets/sriharshaeedala/airline-delay)  
**Licença**: U.S. Government Works  
**Tamanho**: 28.73 MB | **Atualização**: Anual | **Usabilidade**: 10.0/10

Os dados são provenientes do **Bureau of Transportation Statistics (BTS)** do governo dos Estados Unidos, disponibilizados no Kaggle. O dataset cobre o período de **agosto de 2013 a agosto de 2023** (10 anos de dados históricos) e fornece informações granulares sobre performance operacional de companhias aéreas em aeroportos dos EUA.

#### Estrutura do Dataset

O dataset possui **formato tabular** com **21 colunas** organizadas por combinações únicas de ano, mês, companhia aérea e aeroporto:

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
- `arr_delay` - Tempo total de atraso de chegada
- `carrier_delay` - Tempo de atraso atribuído à companhia
- `weather_delay` - Tempo de atraso atribuído ao clima
- `nas_delay` - Tempo de atraso atribuído ao NAS
- `security_delay` - Tempo de atraso atribuído à segurança
- `late_aircraft_delay` - Tempo de atraso atribuído a aeronave atrasada

#### Casos de Uso

Este dataset permite realizar:

✈️ **Análise de Performance**: Avaliar pontualidade de companhias em aeroportos específicos  
📊 **Identificação de Tendências**: Descobrir padrões sazonais e períodos críticos  
🔍 **Análise de Causa-Raiz**: Investigar os principais fatores de atrasos  
📈 **Benchmarking**: Comparar performance entre companhias e aeroportos  
🤖 **Modelagem Preditiva**: Desenvolver modelos de previsão de atrasos  
💡 **Insights Estratégicos**: Informar decisões operacionais e estratégias de mitigação

Para mais detalhes veja a documentação:

## Documentação

**Site de Documentação**: [https://felipefreire-gf.github.io/SBD2-Austin-Airbnb/](https://felipefreire-gf.github.io/SBD2-Austin-Airbnb/)

A documentação completa inclui:
- Estrutura das camadas Bronze, Silver e Gold
- Pipeline ETL detalhado
- Modelagem de dados e schema do banco
- Guia de instalação e execução
- Análises e visualizações implementadas

## Dashboard Power BI

**Em desenvolvimento** - Dashboard interativo para análise de atrasos de voos

**Páginas e Features Planejadas:**

📊 **Overview (KPIs Principais)**
- Total de voos, taxa de atrasos ≥15min, cancelamentos e desvios
- Performance geral do setor aéreo (2013-2023)
- Principais métricas comparativas

✈️ **Análise por Companhia Aérea**
- Ranking de performance (pontualidade, cancelamentos)
- Comparativo entre carriers (benchmarking)
- Volume operacional vs. eficiência

🔍 **Análise de Causas de Atrasos**
- Breakdown das 5 causas (Carrier, Weather, NAS, Security, Late Aircraft)
- Contribuição relativa e absoluta de cada fator
- Análise de causa-raiz por companhia e aeroporto

📈 **Análise Temporal e Sazonalidade**
- Tendências anuais e mensais
- Padrões sazonais e períodos críticos
- Evolução histórica da performance

🌍 **Análise por Aeroporto**
- Performance dos principais hubs
- Comparativo geográfico
- Aeroportos mais afetados por cada tipo de atraso

## MIRO - Gestão do Projeto

**Board Colaborativo**: [Acessar MIRO](https://miro.com/app/board/uXjVGSwQ8Ok=/?share_link_id=465202330329)

Utilize o board do MIRO para:
- Acompanhar o progresso das entregas
- Visualizar diagramas e modelagens
- Colaborar em tempo real com a equipe
- Organizar tarefas e sprints

---

## Como Executar

### Pré-requisitos

- Python 3.8+
- Docker e Docker Compose
- Jupyter Notebook
- PostgreSQL (via Docker)
- psycopg2-binary (conexão Python-PostgreSQL)

### 1. Clone o repositório

```bash
git clone https://github.com/FelipeFreire-gf/SBD2-Austin-Airbnb.git
cd SBD2-Austin-Airbnb
```

### 2. Instale as dependências

### 2. Instale as dependências

```bash
pip install -r requirements.txt
```

### 3. Inicie o banco de dados PostgreSQL

```bash
docker-compose up -d
```

Aguarde alguns segundos para o container inicializar. Verifique o status:

```bash
docker-compose ps
```

### 4. Execute o pipeline ETL

Abra o Jupyter Notebook:

```bash
jupyter notebook
```

Execute os notebooks na seguinte ordem:
1. `Transformer/etl_raw_to_silver.ipynb` - Processa dados brutos para a camada Silver
2. `Data Layer/silver/analytics.ipynb` - Gera análises e visualizações

### 5. Visualize a documentação localmente

```bash
mkdocs serve
```

Acesse: `http://localhost:8000`

---

## Estrutura do Projeto

```
SBD2-Austin-Airbnb/
├── Data Layer/
│   ├── raw/                    # Camada Bronze (dados brutos)
│   │   ├── dados_brutos.csv
│   │   ├── analytics.ipynb
│   │   └── dicionario_de_dados.pdf
│   └── silver/                 # Camada Silver (dados limpos)
│       ├── analytics.ipynb
│       └── ddl.sql
├── Transformer/
│   └── etl_raw_to_silver.ipynb # Pipeline ETL
├── docs/                       # Documentação MkDocs
│   ├── index.md
│   ├── assets/
│   └── pages/
│       ├── entrega0/           # Base de Dados
│       ├── entrega1/           # Raw → Silver
│       ├── entrega2/           # Gold Layer
│       └── entrega3/           # Power BI
├── site/                       # Site estático gerado
├── docker-compose.yml          # Configuração do PostgreSQL
├── requirements.txt            # Dependências Python
├── mkdocs.yml                  # Configuração da documentação
└── README.md
```

---

## Tecnologias Utilizadas

| Categoria | Tecnologias |
|-----------|-------------|
| **Processamento de Dados** | ![PySpark](https://img.shields.io/badge/PySpark-E25A1C?style=flat&logo=apache-spark&logoColor=white) ![Pandas](https://img.shields.io/badge/Pandas-150458?style=flat&logo=pandas&logoColor=white) |
| **Banco de Dados** | ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white) ![psycopg2](https://img.shields.io/badge/psycopg2-316192?style=flat&logo=postgresql&logoColor=white) ![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white) |
| **Visualização** | ![Matplotlib](https://img.shields.io/badge/Matplotlib-11557c?style=flat) ![Seaborn](https://img.shields.io/badge/Seaborn-3776AB?style=flat) ![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=flat&logo=powerbi&logoColor=black) |
| **Machine Learning** | ![scikit-learn](https://img.shields.io/badge/scikit--learn-F7931E?style=flat&logo=scikit-learn&logoColor=white) ![SciPy](https://img.shields.io/badge/SciPy-8CAAE6?style=flat&logo=scipy&logoColor=white) |
| **Desenvolvimento** | ![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white) ![Jupyter](https://img.shields.io/badge/Jupyter-F37626?style=flat&logo=jupyter&logoColor=white) ![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white) |
| **Documentação** | ![MkDocs](https://img.shields.io/badge/MkDocs-526CFE?style=flat&logo=materialformkdocs&logoColor=white) ![Markdown](https://img.shields.io/badge/Markdown-000000?style=flat&logo=markdown&logoColor=white) |

---

## Principais Análises

**13 Visualizações Implementadas:**

**Análises de Correlação e Causas:**
1. Matriz de Correlação entre tipos de atrasos (Carrier, Weather, NAS, Security, Late Aircraft)
2. Breakdown por causa de atraso - Grid 2x2 (contribuição relativa de cada fator)
3. Contribuição percentual média de cada causa de atraso

**Performance de Companhias Aéreas:**
4. Ranking de companhias aéreas por atraso médio (TOP/BOTTOM performers)
5. Taxa de cancelamento e desvio por companhia
6. Volume de operações vs. eficiência operacional

**Análises Temporais:**
7. Sazonalidade mensal - identificação de picos de atrasos
8. Tendências anuais (2013-2023) - evolução da performance
9. Decomposição sazonal (STL) - padrões cíclicos e tendências
10. Agregações temporais (dia/semana/mês/ano)

**Análises de Distribuição:**
11. Distribuições estatísticas de atrasos (histogramas e boxplots)
12. Impacto das condições meteorológicas na operação
13. Top rankings por aeroporto - hubs mais afetados por atrasos

---

## Entregas do Projeto

| Entrega | Título | Status | Descrição |
|---------|--------|--------|-----------|
| **0** | Base de Dados | Concluído | Coleta e armazenamento dos dados brutos (Bronze) |
| **1** | Raw → Silver | Concluído | Pipeline ETL, limpeza e carga no PostgreSQL |
| **2** | Gold Layer | Em desenvolvimento | Agregações, métricas e visualizações analíticas |
| **3** | Power BI | Em desenvolvimento | Dashboard interativo e publicação |

---

## Equipe

**Grupo 04 - Banco de Dados 2 | FCTE-UnB**

<div align="center">

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/FelipeFreire-gf">
        <img style="border-radius: 50%;" src="https://github.com/FelipeFreire-gf.png" width="120px;" alt="Felipe das Neves"/>
        <br>
        <sub><b>Felipe das Neves</b></sub>
      </a>
      <br>
      <sub>Desenvolvedor</sub>
    </td>
    <td align="center">
      <a href="https://github.com/leozinlima">
        <img style="border-radius: 50%;" src="https://github.com/leozinlima.png" width="120px;" alt="Leonardo de Melo"/>
        <br>
        <sub><b>Leonardo de Melo</b></sub>
      </a>
      <br>
      <sub>Desenvolvedor</sub>
    </td>
    <td align="center">
      <a href="https://github.com/MateuSansete">
        <img style="border-radius: 50%;" src="https://github.com/MateuSansete.png" width="120px;" alt="Mateus Bastos"/>
        <br>
        <sub><b>Mateus Bastos</b></sub>
      </a>
      <br>
      <sub>Desenvolvedor</sub>
    </td>
  </tr>
</table>

</div>

---

## Licença

Este projeto é parte de uma atividade acadêmica da disciplina de **Banco de Dados 2** da **Universidade de Brasília (UnB)**.

**Instituição**: Faculdade de Ciências e Tecnologias em Engenharia (FCTE)  
**Curso**: Engenharia de Software  
**Período**: 2025.4

---

<div align="center">

<sub>Desenvolvido pelo Grupo 04 | UnB - 2026</sub>

</div>