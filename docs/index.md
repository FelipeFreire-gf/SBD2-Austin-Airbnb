# Análise de Atrasos de Voos em Aeroportos

---

**ETL pipeline seguindo a arquitetura Medallion (Raw, Silver, Gold) para análise de dados sobre atrasos de voos em aeroportos dos Estados Unidos.**

<div align="center">
<img src="/assets/logo.png" alt="Análise de Atrasos de Voos" style="max-width: 400px; height: auto; margin: 20px 0;">
</div>

<div align="center">

</div>

---

## Sobre o Projeto

Este repositório é dedicado à documentação de todos os artefatos criados pelo **Grupo 04** na disciplina de **Sistemas de Banco de Dados 2** da Faculdade de Ciências e Tecnologias em Engenharia da **Universidade de Brasília (FCTE-UnB)**.

### Objetivos

O projeto implementa um **pipeline ETL completo** utilizando a **Arquitetura Medallion** para análise de dados históricos de atrasos de voos nos Estados Unidos. Os principais objetivos são:

- **Arquitetura Lakehouse**: Implementar camadas Bronze (Raw), Silver (Curated) e Gold (Aggregated) para armazenamento e processamento

- **Modelagem de Dados**: Desenvolver representações conceitual (MER), lógica (DER) e física (DDL) do modelo de dados

- **Banco de Dados**: Construir e popular um banco PostgreSQL containerizado para consultas

- **Dashboard Analítico**: Desenvolver painéis interativos no Power BI para exploração de dados e geração de insights sobre:
     - Atrasos de voos por companhia aérea
     - Causas de atrasos (meteorologia, companhia, NAS, segurança, aeronave)
     - Padrões de sazonalidade
     - Cancelamentos e desvios
     - Tendências temporais

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

## Equipe

**Grupo 04 - Banco de Dados 2 | FCTE-UnB**

<div align="center">

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/FelipeFreire-gf">
        <sub><b>Felipe das Neves</b></sub>
      </a>
      <br>
      <sub>Desenvolvedor</sub>
    </td>
    <td align="center">
      <a href="https://github.com/leozinlima">
        <sub><b>Leonardo de Melo</b></sub>
      </a>
      <br>
      <sub>Desenvolvedor</sub>
    </td>
    <td align="center">
      <a href="https://github.com/MateuSansete">
        <sub><b>Mateus Bastos</b></sub>
      </a>
      <br>
      <sub>Desenvolvedor</sub>
    </td>
    <td align="center">
      <a href="https://github.com/Bessazs">
        <sub><b>Vitor Pereira</b></sub>
      </a>
      <br>
      <sub>Nosso Amigo <3 </sub>
    </td>
    <td align="center">
      <a href="https://github.com/gabriel-lima258">
        <sub><b>Gabriel Lima</b></sub>
      </a>
      <br>
      <sub>Nosso Amigo <3 </sub>
    </td>
  </tr>

<div align="center">
<img src="/assets/fotoFoto.jpeg" alt="Análise de Atrasos de Voos" style="max-width: 600px; height: auto; margin: 20px 0;">
</div>

<div align="center">

</table>

</div>

---

## Licença

Este projeto é parte de uma atividade acadêmica da disciplina de **Sistemas de Banco de Dados 2** da **Universidade de Brasília (UnB)**.

**Instituição**: Faculdade de Ciências e Tecnologias em Engenharia (FCTE)  
**Curso**: Engenharia de Software  
**Período**: 2025.4

---

<div align="center">

<sub>Desenvolvido pelo Grupo 04 | UnB - 2026</sub>

</div>
