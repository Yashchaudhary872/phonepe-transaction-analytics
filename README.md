<div align="center">

# 📱 PhonePe Transaction Analytics

### End-to-end analysis of 300K+ PhonePe transactions using Python, SQL & Power BI —  
### uncovering payment behaviour, service revenue concentration, MoM growth & customer segmentation

<br>

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://github.com/Yashchaudhary872/phonepe-transaction-analytics/blob/main/phonepe_powerbi.pdf)
[![Pandas](https://img.shields.io/badge/Pandas-EDA-150458?style=for-the-badge&logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat-square)](https://github.com/Yashchaudhary872/phonepe-transaction-analytics)

<br>

[📌 Overview](#-project-overview) •
[🗃️ Dataset](#️-dataset--schema) •
[🐍 Python EDA](#-python-eda-highlights) •
[🔍 SQL Analysis](#-sql-analysis) •
[📊 Power BI](#-power-bi-dashboard) •
[💡 Key Insights](#-key-insights) •
[🚀 Setup](#️-setup--usage) •
[👤 About Me](#-about-me)

</div>

---

## 📌 Project Overview

**PhonePe** is India's largest UPI-based payments platform, processing billions of transactions across money transfers, recharges, loans, and insurance. This project performs a complete **three-layer analysis** — Python EDA, advanced SQL queries, and a Power BI dashboard — on a 300K+ transaction dataset to surface payment health, revenue drivers, and customer behaviour patterns.

| Layer | Tool | What It Covers |
|---|---|---|
| 🐍 **EDA & Cleaning** | Python (Pandas, Matplotlib, Seaborn) | Data profiling, null checks, feature engineering, visualizations |
| 🔍 **Business Queries** | SQL (PostgreSQL) | 15 queries: KPIs, MoM growth, LAG analysis, Pareto, customer segmentation |
| 📊 **Dashboard** | Power BI | Interactive KPI cards, service revenue breakdown, success rate trends |

---

## ❓ Business Problem

> *"Which services drive PhonePe's revenue, who are the highest-value users, what is causing payment failures, and how is GMV trending month-over-month?"*

This analysis answers across **4 dimensions:**

```
Payment Health    →  96% success rate | failure breakdown by type & service
Revenue Analysis  →  ₹3.47B GMV | Loans = 72.8% of total revenue (Pareto)
Customer Intel    →  VIP segmentation | top 10 users | dormant user detection
Growth Tracking   →  MoM revenue % | running cumulative GMV | seasonal patterns
```

---

## 🗃️ Dataset & Schema

**6 datasets** covering the full PhonePe product suite:

| File | Records | Description |
|---|---|---|
| `all_transactions.csv` | **300,000** | Core transaction log — amount, service, status, date |
| `all_users.csv` | **107,658** | User profiles — ID, name, age, join date |
| `money_transfer.csv` | — | P2P and merchant transfer records |
| `recharge_bills.csv` | — | Mobile, DTH, FASTag, cable recharge records |
| `insurance.csv` | — | Insurance premium payment records |
| `loans.csv` | — | Loan disbursal and repayment records |

### Transactions Schema

```sql
CREATE TABLE all_transactions (
    transaction_id    VARCHAR(30) PRIMARY KEY,   -- e.g. "RCG_0C338474B366"
    amount            NUMERIC(12,2),             -- Transaction value in ₹
    user_id           VARCHAR(20),               -- Foreign key → all_users
    service           VARCHAR(50),               -- Loans | Insurance | Money_Transfer | Recharge_Bills
    service_type      VARCHAR(50),               -- Sub-category (DTH, FASTag, etc.)
    payment_status    VARCHAR(30),               -- Successful | Failed | Wrong Pin | etc.
    reason            VARCHAR(100),              -- Status reason detail
    transaction_date  DATE                       -- Transaction date
);

CREATE TABLE all_users (
    user_id    VARCHAR(20) PRIMARY KEY,          -- e.g. "PP0000001"
    name       VARCHAR(100),
    age        INTEGER,                          -- Range: 18–60
    join_date  DATE
);
```

---

## 🐍 Python EDA Highlights

### Data Quality Checks

```python
# Shape
transactions.shape  # (300000, 8) — zero nulls, zero duplicates
users.shape         # (107658, 4) — zero nulls, zero duplicates

# Payment status normalization
transactions['Payment_Status'] = transactions['Payment_Status'].str.strip().str.title()
# Unique values: ['Successful', 'Failed', 'Wrong Pin', 'Server Error', 'Insufficient Amount']
```

### Feature Engineering

```python
# Date features for time-series analysis
transactions['Month']   = transactions['Transaction_Date'].dt.month_name()
transactions['Year']    = transactions['Transaction_Date'].dt.year
transactions['Quarter'] = transactions['Transaction_Date'].dt.quarter

# Transaction value bucketing
transactions['Transaction_Category'] = pd.cut(
    transactions['Amount'],
    bins=[0, 500, 2000, 5000, 100000],
    labels=['Low', 'Medium', 'High', 'VIP']
)

# User tenure (days since join)
users['Tenure_Days'] = (pd.Timestamp.today() - users['Join_Date']).dt.days
```

### Key EDA Findings

| Metric | Value |
|---|---|
| Total Transactions | 300,000 |
| Total Platform GMV | **₹3,474,321,934** (~₹3.47 Billion) |
| Average Transaction Value | **₹11,581** |
| Max Single Transaction | **₹99,999** |
| Successful Transactions | **287,993 (96.0%)** |
| Failed Transactions | 12,007 (4.0%) |
| Total Registered Users | 107,658 |
| User Age Range | 18 – 60 years (median: 39) |

### Visualizations

**Revenue by Service** — Bar chart showing Loans >> Insurance > Money Transfer > Recharge

**Payment Status Distribution** — Pie chart: 96% Successful, 3.3% Failed, 0.7% other failure modes

**Monthly Revenue Trend** — Line chart: steady ₹283M–₹304M range with July peak

**User Age Distribution** — Histogram: normal distribution centred at age 39

---

## 🔍 SQL Analysis

15 business queries across 3 difficulty levels — all with business context and real insights.

### 🟢 Basic (Q1–Q4)

---

**Q1 · Platform-Level KPIs**
```sql
SELECT
    COUNT(*)                      AS total_transactions,
    ROUND(SUM(amount), 2)         AS total_revenue,
    ROUND(AVG(amount), 2)         AS avg_transaction_value,
    ROUND(MAX(amount), 2)         AS max_transaction_value
FROM all_transactions;
```
> 💡 **Insight:** ₹3.47B GMV | ₹11,581 avg value | ₹99,999 max — headline numbers for any executive report.

---

**Q2 · Payment Success vs Failure Breakdown**
```sql
SELECT
    payment_status,
    COUNT(*)                                              AS transaction_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2)    AS percentage
FROM all_transactions
GROUP BY payment_status
ORDER BY transaction_count DESC;
```
> 💡 **Insight:** 96% success rate is strong, but 4% failure = ~₹139M unrecovered revenue. Server errors and wrong PINs are fixable via infra and UX improvements.

---

**Q3 · Revenue by Service Category**
```sql
SELECT service,
       COUNT(*)                AS transaction_count,
       ROUND(SUM(amount), 2)   AS total_revenue,
       ROUND(AVG(amount), 2)   AS avg_transaction_value
FROM all_transactions
GROUP BY service
ORDER BY total_revenue DESC;
```
> 💡 **Insight:** Loans = ₹2.53B (72.8% of GMV). Massive concentration risk — and opportunity to invest in this service's reliability above all others.

---

**Q4 · Dormant User Detection**
```sql
SELECT u.user_id, u.name, u.age, u.join_date
FROM all_users u
LEFT JOIN all_transactions t ON u.user_id = t.user_id
WHERE t.transaction_id IS NULL
ORDER BY u.join_date DESC;
```
> 💡 **Insight:** Users who registered but never transacted — prime target for first-transaction incentive campaigns (cashback, zero-fee transfer).

---

### 🟡 Intermediate (Q5–Q10)

---

**Q5 · Monthly Revenue Trend**
```sql
SELECT
    DATE_TRUNC('month', transaction_date)  AS month,
    COUNT(*)                               AS transaction_count,
    ROUND(SUM(amount), 2)                  AS monthly_revenue
FROM all_transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;
```
> 💡 **Insight:** July peaks at ₹304M vs April low of ₹283M — 7.4% seasonal swing. Consistent band signals a stable, mature platform.

---

**Q6 · Top 10 High-Value Customers (with JOIN)**
```sql
SELECT u.user_id, u.name, u.age,
       COUNT(t.transaction_id)    AS total_transactions,
       ROUND(SUM(t.amount), 2)    AS total_spent
FROM all_users u
JOIN all_transactions t ON u.user_id = t.user_id
GROUP BY u.user_id, u.name, u.age
ORDER BY total_spent DESC
LIMIT 10;
```
> 💡 **Insight:** Top user spent ₹349,167 — 30x the platform average. These users need VIP-tier treatment: priority support, exclusive rates, dedicated relationship managers.

---

**Q7 · Above-Average Spenders (Subquery)**
```sql
SELECT user_id, COUNT(transaction_id) AS total_transactions,
       ROUND(SUM(amount), 2) AS total_spent
FROM all_transactions
GROUP BY user_id
HAVING SUM(amount) > (SELECT AVG(amount) FROM all_transactions)
ORDER BY total_spent DESC;
```
> 💡 **Insight:** The above-average spending segment drives disproportionate platform revenue — the core cohort for retention campaigns.

---

**Q8 · Payment Failure Rate by Service (Conditional Aggregation)**
```sql
SELECT
    service,
    COUNT(*)                                                               AS total_txns,
    SUM(CASE WHEN payment_status != 'Successful' THEN 1 ELSE 0 END)       AS failed_txns,
    ROUND(100.0 * SUM(CASE WHEN payment_status != 'Successful' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                                   AS failure_rate_pct
FROM all_transactions
GROUP BY service
ORDER BY failure_rate_pct DESC;
```
> 💡 **Insight:** Failure rate varies by service. A 4% failure rate on Loans (₹2.53B base) = ₹101M in failed disbursals. This metric should alert daily.

---

**Q9 · Customer Segmentation by Spending Tier (CTE + CASE WHEN)**
```sql
WITH user_spending AS (
    SELECT user_id, ROUND(SUM(amount), 2) AS total_spent
    FROM all_transactions GROUP BY user_id
)
SELECT
    CASE
        WHEN total_spent < 5000  THEN '🔵 Low Value    (< ₹5K)'
        WHEN total_spent < 15000 THEN '🟡 Medium Value (₹5K–₹15K)'
        WHEN total_spent < 30000 THEN '🟠 High Value   (₹15K–₹30K)'
        ELSE                          '🔴 VIP Customer (> ₹30K)'
    END                          AS customer_segment,
    COUNT(*)                     AS user_count,
    ROUND(AVG(total_spent), 2)   AS avg_spend_in_segment,
    ROUND(SUM(total_spent), 2)   AS segment_total_revenue
FROM user_spending
GROUP BY customer_segment
ORDER BY avg_spend_in_segment DESC;
```
> 💡 **Insight:** 4-tier segmentation powers different campaign strategies — VIP retention, high-value upsell, medium activation, low re-engagement.

---

**Q10 · Complete Customer Spending Profile (CTE + JOIN)**
```sql
WITH customer_spending AS (
    SELECT t.user_id, u.name, u.age,
           COUNT(t.transaction_id)  AS transaction_count,
           ROUND(SUM(t.amount), 2)  AS total_spent,
           ROUND(AVG(t.amount), 2)  AS avg_transaction
    FROM all_transactions t
    JOIN all_users u ON t.user_id = u.user_id
    GROUP BY t.user_id, u.name, u.age
)
SELECT * FROM customer_spending ORDER BY total_spent DESC LIMIT 10;
```
> 💡 **Insight:** Full profile (name, age, frequency, avg spend) of top customers — richer than a raw ID list and directly actionable for account managers.

---

### 🔴 Advanced (Q11–Q15)

---

**Q11 · Spending Rank + Percentile for Every User** *(Window Function)*
```sql
SELECT
    user_id,
    ROUND(SUM(amount), 2)                        AS total_spent,
    RANK() OVER (ORDER BY SUM(amount) DESC)       AS spending_rank,
    NTILE(100) OVER (ORDER BY SUM(amount) DESC)   AS spending_percentile
FROM all_transactions
GROUP BY user_id
ORDER BY spending_rank;
```
> 💡 **Insight:** `NTILE(100)` gives each user a percentile. Top-10th-percentile users likely drive 50%+ of GMV — the exact cut-off threshold for loyalty program design.

---

**Q12 · Cumulative Revenue Over Time** *(Running Total)*
```sql
SELECT
    transaction_date,
    ROUND(SUM(amount), 2)                                        AS daily_revenue,
    ROUND(SUM(SUM(amount)) OVER (ORDER BY transaction_date), 2)  AS cumulative_revenue
FROM all_transactions
GROUP BY transaction_date
ORDER BY transaction_date;
```
> 💡 **Insight:** Running GMV curve visualizes growth trajectory. Inflection points correspond to product launches or marketing campaigns — critical for post-campaign attribution.

---

**Q13 · Month-over-Month Revenue Growth Rate** *(LAG Function)*
```sql
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', transaction_date) AS month,
           ROUND(SUM(amount), 2) AS revenue
    FROM all_transactions
    GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT
    month,
    revenue                                           AS current_month_revenue,
    LAG(revenue) OVER (ORDER BY month)                AS previous_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2
    )                                                 AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;
```
> 💡 **Insight:** MoM% is the single most-asked fintech metric in DA interviews and on business reviews. `NULLIF` prevents division-by-zero on row 1 — a real-world defensive pattern.

---

**Q14 · Service Revenue Pareto Analysis** *(Chained CTEs + Running Share)*
```sql
WITH service_revenue AS (
    SELECT service, ROUND(SUM(amount), 2) AS total_revenue, COUNT(*) AS transaction_count
    FROM all_transactions GROUP BY service
),
pareto AS (
    SELECT *,
           SUM(total_revenue) OVER ()                           AS grand_total,
           SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS running_total
    FROM service_revenue
)
SELECT service, transaction_count, total_revenue,
       ROUND(100.0 * total_revenue / grand_total, 2)  AS revenue_share_pct,
       ROUND(100.0 * running_total / grand_total, 2)  AS cumulative_pct
FROM pareto ORDER BY total_revenue DESC;
```
> 💡 **Insight:** Loans (72.8%) + Insurance (14.8%) = 87.6% of GMV — the Pareto threshold in just 2 services. Cumulative % column makes this unmissable in any review.

---

**Q15 · Reusable User Health View** *(CREATE VIEW + Full Profile)*
```sql
CREATE OR REPLACE VIEW user_transaction_summary AS
SELECT
    t.user_id, u.name, u.age,
    COUNT(t.transaction_id)                                          AS total_transactions,
    ROUND(SUM(t.amount), 2)                                          AS total_spent,
    ROUND(AVG(t.amount), 2)                                          AS avg_transaction_value,
    MIN(t.transaction_date)                                          AS first_transaction,
    MAX(t.transaction_date)                                          AS last_transaction,
    ROUND(100.0 * SUM(CASE WHEN payment_status = 'Successful' THEN 1 ELSE 0 END)
          / NULLIF(COUNT(t.transaction_id), 0), 2)                   AS success_rate_pct,
    CASE
        WHEN SUM(t.amount) > 30000 THEN '🔴 VIP'
        WHEN SUM(t.amount) > 15000 THEN '🟠 High Value'
        WHEN SUM(t.amount) > 5000  THEN '🟡 Medium Value'
        ELSE                            '🔵 Low Value'
    END                                                              AS customer_tier
FROM all_transactions t
JOIN all_users u ON t.user_id = u.user_id
GROUP BY t.user_id, u.name, u.age;

SELECT * FROM user_transaction_summary ORDER BY total_spent DESC;
```
> 💡 **Insight:** A reusable VIEW that any BI tool or downstream query can call without re-writing aggregation logic. 8 health metrics per user in one object — production-grade thinking.

---

## ⚙️ SQL Concepts Demonstrated

| Concept | Queries | Purpose |
|---|---|---|
| `COUNT`, `SUM`, `AVG`, `MAX` | Q1, Q3, Q5 | Platform KPIs and category aggregation |
| `LEFT JOIN` + `IS NULL` | Q4 | Dormant user detection |
| `JOIN` across tables | Q6, Q10, Q15 | Enrich transactions with user profile |
| Subquery in `HAVING` | Q7 | Above-average spender filter |
| **Conditional Aggregation** | Q8, Q15 | `SUM(CASE WHEN ...)` — failure rate per service |
| `DATE_TRUNC` | Q5, Q13 | Monthly time-series grouping |
| **CTE** (`WITH`) | Q9, Q10, Q13, Q14 | Multi-step readable logic |
| **`RANK() OVER`** | Q11 | Spending leaderboard |
| **`NTILE() OVER`** | Q11 | Percentile bucketing |
| **`SUM() OVER (ORDER BY)`** | Q12, Q14 | Running totals / cumulative GMV |
| **`LAG() OVER`** | Q13 | Month-over-Month growth rate |
| **Chained CTEs + Pareto** | Q14 | 80-20 service revenue analysis |
| **`CREATE OR REPLACE VIEW`** | Q15 | Reusable production-grade summary object |

---

## 📊 Power BI Dashboard

The interactive dashboard (`phonepe_powerbi.pdf`) consolidates all analysis into a single view:

- **KPI Cards** — Total GMV, Success Rate, Avg Transaction Value, Total Users
- **Revenue by Service** — Bar chart showing Loans >> Insurance >> Money Transfer >> Recharge
- **Payment Status Donut** — 96% Successful | 3.3% Failed | 0.7% other failures
- **Monthly Revenue Trend** — Line chart across all 12 months
- **Customer Tier Distribution** — Breakdown of VIP / High / Medium / Low users
- **Top 10 Users Table** — Name, total spent, transaction count

> 📎 [View Dashboard PDF](https://github.com/Yashchaudhary872/phonepe-transaction-analytics/blob/main/phonepe_powerbi.pdf)

---

## 💡 Key Insights

| # | Finding | Business Impact |
|---|---|---|
| 💰 | **Loans drives 72.8% of GMV** (₹2.53B of ₹3.47B) | Pareto concentration — protect this service above all others |
| ✅ | **96% payment success rate** across 300K transactions | Strong platform reliability — monitor daily to maintain |
| ❌ | **4% failure rate = ~₹139M** in unrecovered transaction value | Each failure type (PIN/Server/Funds) has a different fix |
| 📅 | **July peaks at ₹304M**, April lows at ₹283M | 7.4% seasonal swing — plan campaigns to lift the trough months |
| 👑 | **Top user spent ₹349,167** — 30x the platform average | Extreme VIP concentration; these users need dedicated support |
| 🧑‍🤝‍🧑 | **User age 18–60**, median 39 | Broad demographic — segment campaigns by age cohort |
| 📈 | **Consistent MoM growth** with no major negative months | Healthy GMV trajectory with predictable seasonal patterns |
| 🔍 | **Dormant users detected** via LEFT JOIN anti-pattern | Quantify and target with first-transaction cashback offers |

---

## 🔄 Project Workflow

```
6 Raw CSV Files (300K transactions + 107K users)
        │
        ▼
Python EDA ──→ Null checks · Duplicate removal · Date parsing
        │       Feature engineering (Month/Quarter/Category/Tenure)
        │       Visualizations (4 charts)
        ▼
SQL Analysis ──→ 15 queries: Basic KPIs → JOINs → CTEs → Window Functions
        │         MoM LAG · Running totals · Pareto · CREATE VIEW
        ▼
Power BI ──→ Interactive dashboard: KPI cards · trend lines · tier breakdown
        │
        ▼
Business Recommendations ──→ VIP retention · failure fix · seasonal campaigns
```

---

## 🛠️ Setup & Usage

### Prerequisites
- Python 3.10+ with `pandas`, `numpy`, `matplotlib`, `seaborn`
- PostgreSQL 13+ (or MySQL 8+)
- Power BI Desktop (to open `.pbix`) or view `phonepe_powerbi.pdf`

### Python Setup
```bash
# Clone the repo
git clone https://github.com/Yashchaudhary872/phonepe-transaction-analytics.git
cd phonepe-transaction-analytics

# Install dependencies
pip install pandas numpy matplotlib seaborn jupyter

# Run the notebook
jupyter notebook phonepe-transaction-analytics.ipynb
```

### SQL Setup
```sql
-- Create database
CREATE DATABASE phonepe_analytics;
\c phonepe_analytics

-- Run the SQL file (creates tables + all 15 queries)
\i phonepe_transactions.sql

-- Import data (adjust path)
COPY all_users FROM '/path/to/all_users.csv' DELIMITER ',' CSV HEADER;
COPY all_transactions FROM '/path/to/all_transactions.csv' DELIMITER ',' CSV HEADER;
```

---

## 📁 Repository Structure

```
phonepe-transaction-analytics/
├── README.md                              ← You are here
├── phonepe-transaction-analytics.ipynb   ← Python EDA: cleaning, features, charts
├── phonepe_transactions.sql              ← 15 SQL business queries (Basic → Advanced)
├── phonepe_powerbi.pdf                   ← Power BI dashboard export
├── all_transactions.csv                  ← 300K transaction records
├── all_users.csv                         ← 107K user profiles
├── money_transfer.csv                    ← Money transfer sub-dataset
├── recharge_bills.csv                    ← Recharge & bills sub-dataset
├── insurance.csv                         ← Insurance payments sub-dataset
└── loans.csv                             ← Loans sub-dataset
```

---

## 🚀 What's Next

- [ ] Cohort retention analysis — month-wise user retention curves
- [ ] Fraud detection pattern — flag outlier transaction amounts per user
- [ ] User lifetime value (LTV) prediction using spending trajectory
- [ ] City-wise transaction heatmap (if location data available)
- [ ] Automated Python pipeline to refresh SQL summary tables

---

## 👤 About Me

**Yash Chaudhary** — B.Tech IT Student | Data Analytics Enthusiast

This is my most comprehensive project — combining Python EDA, production-grade SQL (window functions, CTEs, LAG, Pareto), and a business dashboard. Built to reflect how a data analyst actually works: clean the data, ask the right business questions, answer them rigorously, and present findings clearly.

<div align="center">

[![Portfolio](https://img.shields.io/badge/Portfolio-Visit-FF6B35?style=for-the-badge&logo=firefox&logoColor=white)](https://yashchaudharyportfolio.netlify.app/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/yash--chaudhary--/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Yashchaudhary872)
[![Email](https://img.shields.io/badge/Email-Contact-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:chaudharyyash872@gmail.com)

</div>

---

<div align="center">

*If this project helped you, a ⭐ on GitHub goes a long way!*

**Made with Python · PostgreSQL · Power BI · Business Thinking**

</div>
