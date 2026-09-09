# 🏭 ERP Manufacturing Data Analytics & Pipeline Optimization

[![SQL Server](https://img.shields.io/badge/Database-MS%20SQL%20Server-red?logo=microsoftsqlserver)](https://www.microsoft.com/en-us/sql-server/)
[![Power BI](https://img.shields.io/badge/Visualization-Power%20BI-yellow?logo=powerbi)](https://powerbi.microsoft.com/)
[![DAX](https://img.shields.io/badge/Analytics-DAX-blue)](#-data-modeling--dax)

## 📌 Project Overview
An end-to-end manufacturing analytics pipeline that transforms messy, raw ERP text exports into an automated SQL cleaning pipeline and an executive Power BI dashboard for tracking **Yield %, Scrap Rates, and Work Order Execution**.

### Key Issues Resolved
- **Data Hygiene:** Eliminated `NULL` text values, empty strings, and trailing spaces.
- **Date Integrity:** Applied fallback logic (`COALESCE`) for missing creation dates (`WODate`) to maintain unbroken relationships with `Dim_Date`.
- **Logic Correction:** Prevented `#DIV/0!` errors on yield metrics and fixed negative inventory loss values.

---

## 🏗️ Architecture
```
Raw ERP Output (.txt) ──> MS SQL Server Staging ──> Fact_Production_Clean Table ──> Power BI Dashboard
```

---

## 🛠️ Core SQL Transformation
```sql
SELECT 
    ISNULL(NULLIF(TRIM([WONumber]), ''), 'N/A') AS [WONumber],
    ISNULL(NULLIF(TRIM([WorkCenter]), ''), 'Unassigned') AS [WorkCenter],
    
    -- Date Fallback Logic
    COALESCE(TRY_CAST([WODate] AS DATE), TRY_CAST([FiscalDate] AS DATE)) AS [WODate],
    TRY_CAST([SODeliveryDate] AS DATE) AS [SODeliveryDate], -- Preserved NULL for Make-to-Stock

    -- Quantities & Material Balance
    ISNULL([WOQty], 0) AS [WOQty],
    ISNULL([ProducedQty], 0) AS [ProducedQty],
    ISNULL([RejectedQty], 0) AS [RejectedQty],
    ([WOQty] - ISNULL([ProducedQty], 0)) AS [RemainingWOQty],

    -- Zero-Division Protection & Status Flag
    CASE 
        WHEN ISNULL([ProducedQty], 0) > 0 
        THEN ROUND((CAST([ProducedQty] - ISNULL([RejectedQty], 0) AS FLOAT) / [ProducedQty]) * 100, 2)
        ELSE 0.0 
    END AS [YieldPercentage],

    CASE 
        WHEN ISNULL([ProducedQty], 0) > [WOQty] THEN 'Over-Production'
        ELSE 'Normal'
    END AS [ProductionStatus]
INTO [Fact_Production_Clean]
FROM [Raw_ERP_Data];
```

---

## 📐 Data Modeling & DAX

Structured as a **Star Schema** with active single-direction relationships between `Dim_Date[Date]` and `Fact_Production_Clean[WODate]`.

```dax
// Overall Yield Rate (%)
Overall Yield % = DIVIDE(SUM(Fact_Production_Clean[GoodQty]), SUM(Fact_Production_Clean[ProducedQty]), 0)

// Scrap Rate (%)
Reject Rate % = DIVIDE(SUM(Fact_Production_Clean[RejectedQty]), SUM(Fact_Production_Clean[ProducedQty]), 0)

// Over-Production Alert
Over Production WO Count = 
CALCULATE(
    COUNTROWS(Fact_Production_Clean),
    Fact_Production_Clean[ProductionStatus] = "Over-Production"
)
```

---

## 📊 Dashboard & Key Impact
1. **Yield & Progress Tracking:** Visualizes production vs. target quantities alongside first-pass yield percentages per operation (Weaving, Cutting, Packing).
2. **Quality Alert System:** Automatically flags work orders with scrap rates exceeding 3% or flagged as over-production.
3. **100% Data Integrity:** Zero `#DIV/0!` errors or blank slicer values, reducing manual reporting latency to zero.