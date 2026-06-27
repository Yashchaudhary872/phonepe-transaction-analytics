-- ============================================================
-- PHONEPE TRANSACTION ANALYTICS — SQL ANALYSIS
-- 15 Business Queries | Beginner → Intermediate → Advanced
-- Dataset: 300K transactions | 107K users | Tool: PostgreSQL
-- ============================================================

-- ─────────────────────────────────────────────
-- SECTION 1: TABLE SETUP
-- ─────────────────────────────────────────────

DROP TABLE IF EXISTS all_transactions;
DROP TABLE IF EXISTS all_users;

CREATE TABLE all_users (
    user_id    VARCHAR(20) PRIMARY KEY,
    name       VARCHAR(100),
    age        INTEGER,
    join_date  DATE
);

CREATE TABLE all_transactions (
    transaction_id   VARCHAR(30) PRIMARY KEY,
    amount           NUMERIC(12,2),
    user_id          VARCHAR(20),
    service          VARCHAR(50),
    service_type     VARCHAR(50),
    payment_status   VARCHAR(30),
    reason           VARCHAR(100),
    transaction_date DATE
);

-- ─────────────────────────────────────────────
-- SECTION 2: DATA EXPLORATION
-- ─────────────────────────────────────────────

-- Total users on the platform
SELECT COUNT(*) AS total_users FROM all_users;
-- Result: 107,658 users

-- Total transactions
SELECT COUNT(*) AS total_transactions FROM all_transactions;
-- Result: 300,000 transactions

-- Check for NULLs
SELECT
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END)           AS null_user_id,
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END)            AS null_amount,
    SUM(CASE WHEN payment_status IS NULL THEN 1 ELSE 0 END)    AS null_status,
    SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END)  AS null_date
FROM all_transactions;

-- Distinct payment statuses
SELECT DISTINCT payment_status FROM all_transactions ORDER BY payment_status;
-- Result: Successful | Failed | Wrong Pin | Server Error | Insufficient Amount

-- Distinct services
SELECT DISTINCT service FROM all_transactions ORDER BY service;
-- Result: Loans | Insurance | Money_Transfer | Recharge_Bills


-- ============================================================
-- SECTION 3: BUSINESS ANALYSIS
-- ============================================================

-- ─────────────────────────────────────────────
-- 🟢 BEGINNER QUERIES (Q1 – Q4)
-- ─────────────────────────────────────────────

-- Q1. Platform-Level KPIs: Total Revenue, Avg Transaction, Max Transaction
-- Business use: Headline metrics for executive dashboard
-- SQL: SUM, AVG, MAX aggregates

SELECT
    COUNT(*)                          AS total_transactions,
    ROUND(SUM(amount), 2)             AS total_revenue,
    ROUND(AVG(amount), 2)             AS avg_transaction_value,
    ROUND(MAX(amount), 2)             AS max_transaction_value
FROM all_transactions;

/*
Insight: Total platform GMV = ₹3.47B across 300K transactions.
Avg transaction of ₹11,581 is driven upward by high-value loan disbursals.
Monitoring these 4 KPIs daily catches revenue anomalies instantly.
*/


-- Q2. Payment Success vs Failure Distribution
-- Business use: Measure platform reliability; failures = lost revenue + bad UX
-- SQL: GROUP BY, COUNT, ORDER BY

SELECT
    payment_status,
    COUNT(*)                                        AS transaction_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM all_transactions
GROUP BY payment_status
ORDER BY transaction_count DESC;

/*
Insight: 287,993 successful (96.0%) vs 12,007 failed transactions.
Failed transactions alone represent ~₹139M in unrecovered revenue potential.
Server errors and wrong PINs are fixable via UX/infra improvements.
*/


-- Q3. Revenue by Service Category
-- Business use: Identify top revenue-generating services for investment prioritization
-- SQL: GROUP BY, SUM, ORDER BY

SELECT
    service,
    COUNT(*)                            AS transaction_count,
    ROUND(SUM(amount), 2)               AS total_revenue,
    ROUND(AVG(amount), 2)               AS avg_transaction_value
FROM all_transactions
GROUP BY service
ORDER BY total_revenue DESC;

/*
Insight: Loans dominates at ₹2.53B (72.8% of GMV), followed by Insurance ₹512M.
Money Transfers are highest volume but lower value.
This 80/20 concentration means Loans deserves the most reliability investment.
*/


-- Q4. Users Who Have Never Transacted (Dormant User Detection)
-- Business use: Identify users to target with re-engagement campaigns
-- SQL: LEFT JOIN, IS NULL

SELECT
    u.user_id,
    u.name,
    u.age,
    u.join_date
FROM all_users u
LEFT JOIN all_transactions t ON u.user_id = t.user_id
WHERE t.transaction_id IS NULL
ORDER BY u.join_date DESC;

/*
Insight: Dormant users are registered but never converted.
Segmenting by join_date reveals if drop-off is worsening over time —
a critical retention metric for growth teams.
*/


-- ─────────────────────────────────────────────
-- 🟡 INTERMEDIATE QUERIES (Q5 – Q10)
-- ─────────────────────────────────────────────

-- Q5. Monthly Revenue Trend (Time-Series Analysis)
-- Business use: Seasonality detection, forecasting, anomaly identification
-- SQL: DATE_TRUNC, GROUP BY, ORDER BY

SELECT
    DATE_TRUNC('month', transaction_date)   AS month,
    COUNT(*)                                AS transaction_count,
    ROUND(SUM(amount), 2)                   AS monthly_revenue,
    ROUND(AVG(amount), 2)                   AS avg_transaction_value
FROM all_transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;

/*
Insight: July peaks at ₹304M vs April low of ₹283M — a 7.4% seasonal swing.
Consistent monthly revenue ~₹285-305M shows a mature, stable platform.
Outlier months should trigger investigation into campaign or external factors.
*/


-- Q6. Total Spending per User — Top 10 High-Value Customers
-- Business use: VIP identification for loyalty programs and dedicated support
-- SQL: JOIN, GROUP BY, SUM, ORDER BY, LIMIT

SELECT
    u.user_id,
    u.name,
    u.age,
    COUNT(t.transaction_id)         AS total_transactions,
    ROUND(SUM(t.amount), 2)         AS total_spent
FROM all_users u
JOIN all_transactions t ON u.user_id = t.user_id
GROUP BY u.user_id, u.name, u.age
ORDER BY total_spent DESC
LIMIT 10;

/*
Insight: Top user spent ₹349,167 — 30x the platform average.
These VIP customers warrant white-glove service: priority support,
exclusive offers, and dedicated account managers.
*/


-- Q7. Users Who Spent Above Average (High-Value Segment)
-- Business use: Define the "power user" segment for targeted campaigns
-- SQL: Subquery in HAVING, GROUP BY

SELECT
    user_id,
    COUNT(transaction_id)           AS total_transactions,
    ROUND(SUM(amount), 2)           AS total_spent,
    ROUND(AVG(amount), 2)           AS avg_per_transaction
FROM all_transactions
GROUP BY user_id
HAVING SUM(amount) > (SELECT AVG(amount) FROM all_transactions)
ORDER BY total_spent DESC;

/*
Insight: Users spending above the ₹11,581 platform average are the growth lever.
This segment likely drives disproportionate revenue share and retention value.
*/


-- Q8. Payment Failure Analysis by Service
-- Business use: Pinpoint which services have reliability issues
-- SQL: Conditional aggregation, ROUND, GROUP BY

SELECT
    service,
    COUNT(*)                                                                AS total_transactions,
    SUM(CASE WHEN payment_status = 'Successful' THEN 1 ELSE 0 END)        AS successful,
    SUM(CASE WHEN payment_status != 'Successful' THEN 1 ELSE 0 END)       AS failed,
    ROUND(
        100.0 * SUM(CASE WHEN payment_status != 'Successful' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    )                                                                       AS failure_rate_pct
FROM all_transactions
GROUP BY service
ORDER BY failure_rate_pct DESC;

/*
Insight: If a high-value service like Loans has even a 4% failure rate,
it translates to ₹101M in failed disbursals. Failure rate by service
should be a daily monitored metric on the ops dashboard.
*/


-- Q9. Customer Segmentation by Spending Tier (RFM-style)
-- Business use: Tiered marketing — different campaigns per segment
-- SQL: CASE WHEN on aggregated value, GROUP BY summary

WITH user_spending AS (
    SELECT
        user_id,
        COUNT(transaction_id)   AS total_transactions,
        ROUND(SUM(amount), 2)   AS total_spent
    FROM all_transactions
    GROUP BY user_id
)
SELECT
    CASE
        WHEN total_spent < 5000    THEN '🔵 Low Value    (< ₹5K)'
        WHEN total_spent < 15000   THEN '🟡 Medium Value (₹5K–₹15K)'
        WHEN total_spent < 30000   THEN '🟠 High Value   (₹15K–₹30K)'
        ELSE                            '🔴 VIP Customer (> ₹30K)'
    END                         AS customer_segment,
    COUNT(*)                    AS user_count,
    ROUND(AVG(total_spent), 2)  AS avg_spend_in_segment,
    ROUND(SUM(total_spent), 2)  AS segment_total_revenue
FROM user_spending
GROUP BY customer_segment
ORDER BY avg_spend_in_segment DESC;

/*
Insight: VIP customers (> ₹30K) are a small % of users but drive outsized revenue.
Low-value users need activation nudges; VIPs need retention protection.
This segmentation drives different communication strategies per tier.
*/


-- Q10. Top 10 Customers by Total Spending (Fixed — Complete Query)
-- Business use: Leaderboard for loyalty program rewards
-- SQL: CTE, GROUP BY, ORDER BY, LIMIT

WITH customer_spending AS (
    SELECT
        t.user_id,
        u.name,
        u.age,
        COUNT(t.transaction_id)     AS transaction_count,
        ROUND(SUM(t.amount), 2)     AS total_spent,
        ROUND(AVG(t.amount), 2)     AS avg_transaction
    FROM all_transactions t
    JOIN all_users u ON t.user_id = u.user_id
    GROUP BY t.user_id, u.name, u.age
)
SELECT *
FROM customer_spending
ORDER BY total_spent DESC
LIMIT 10;

/*
Insight: Full customer profile (name, age, transaction count, avg spend) of top 10.
Richer than just a user_id leaderboard — actionable for account managers.
*/


-- ─────────────────────────────────────────────
-- 🔴 ADVANCED QUERIES (Q11 – Q15)
-- ─────────────────────────────────────────────

-- Q11. Rank All Users by Total Spending (Window Function)
-- Business use: Percentile-based loyalty tier assignment
-- SQL: RANK() OVER, NTILE() OVER

SELECT
    user_id,
    ROUND(SUM(amount), 2)                           AS total_spent,
    RANK() OVER (ORDER BY SUM(amount) DESC)         AS spending_rank,
    NTILE(100) OVER (ORDER BY SUM(amount) DESC)     AS spending_percentile
FROM all_transactions
GROUP BY user_id
ORDER BY spending_rank;

/*
Insight: NTILE(100) gives each user a spending percentile (1 = top 1%).
Users in the top 10th percentile likely drive 50%+ of platform revenue.
This feeds directly into tiered loyalty reward thresholds.
*/


-- Q12. Cumulative Revenue Over Time (Running Total)
-- Business use: Track GMV milestone achievement; visualize growth trajectory
-- SQL: SUM() OVER (ORDER BY date) — window function

SELECT
    transaction_date,
    ROUND(SUM(amount), 2)                                       AS daily_revenue,
    ROUND(SUM(SUM(amount)) OVER (ORDER BY transaction_date), 2) AS cumulative_revenue
FROM all_transactions
GROUP BY transaction_date
ORDER BY transaction_date;

/*
Insight: Cumulative revenue curve reveals growth rate changes.
A flattening curve signals stagnation; a steep acceleration points to
a successful campaign or product launch period.
*/


-- Q13. Month-over-Month Revenue Growth Rate (LAG Function)
-- Business use: Growth KPI — most commonly asked metric in fintech DA roles
-- SQL: LAG() OVER, DATE_TRUNC, ROUND, CTE

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', transaction_date)   AS month,
        ROUND(SUM(amount), 2)                   AS revenue
    FROM all_transactions
    GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT
    month,
    revenue                                                     AS current_month_revenue,
    LAG(revenue) OVER (ORDER BY month)                          AS previous_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        2
    )                                                           AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;

/*
Insight: MoM growth % is the #1 metric fintech companies track.
Positive MoM = healthy acquisition/engagement. Negative MoM = investigate churn.
NULLIF prevents division-by-zero on the first month row.
*/


-- Q14. Service-wise Revenue Share with Running Contribution (Pareto Analysis)
-- Business use: Identify which 2–3 services drive 80% of platform GMV
-- SQL: SUM() OVER(), chained CTEs, running total, % share

WITH service_revenue AS (
    SELECT
        service,
        ROUND(SUM(amount), 2)   AS total_revenue,
        COUNT(*)                AS transaction_count
    FROM all_transactions
    GROUP BY service
),
pareto AS (
    SELECT *,
        SUM(total_revenue) OVER ()                          AS grand_total,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS running_total
    FROM service_revenue
)
SELECT
    service,
    transaction_count,
    total_revenue,
    ROUND(100.0 * total_revenue / grand_total, 2)           AS revenue_share_pct,
    ROUND(100.0 * running_total / grand_total, 2)           AS cumulative_pct
FROM pareto
ORDER BY total_revenue DESC;

/*
Insight: Loans alone accounts for ~72.8% of GMV — the platform is heavily
concentrated in one service. This is both a strength (high-value product)
and a risk (single-service dependency). Cumulative % pinpoints the 80% threshold.
*/


-- Q15. Reusable User Transaction Summary View + Power User Flag
-- Business use: Centralized user health metric; reusable across reports
-- SQL: CREATE VIEW, CASE WHEN, multiple aggregates

CREATE OR REPLACE VIEW user_transaction_summary AS
SELECT
    t.user_id,
    u.name,
    u.age,
    COUNT(t.transaction_id)                                         AS total_transactions,
    ROUND(SUM(t.amount), 2)                                         AS total_spent,
    ROUND(AVG(t.amount), 2)                                         AS avg_transaction_value,
    MIN(t.transaction_date)                                         AS first_transaction,
    MAX(t.transaction_date)                                         AS last_transaction,
    SUM(CASE WHEN t.payment_status = 'Successful' THEN 1 ELSE 0 END) AS successful_txns,
    ROUND(
        100.0 * SUM(CASE WHEN t.payment_status = 'Successful' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(t.transaction_id), 0), 2
    )                                                               AS success_rate_pct,
    CASE
        WHEN SUM(t.amount) > 30000 THEN '🔴 VIP'
        WHEN SUM(t.amount) > 15000 THEN '🟠 High Value'
        WHEN SUM(t.amount) > 5000  THEN '🟡 Medium Value'
        ELSE                            '🔵 Low Value'
    END                                                             AS customer_tier
FROM all_transactions t
JOIN all_users u ON t.user_id = u.user_id
GROUP BY t.user_id, u.name, u.age;

-- Query the view
SELECT * FROM user_transaction_summary
ORDER BY total_spent DESC;

/*
Insight: This view consolidates 8 user health metrics into one reusable object.
Any analyst or BI tool can query it without rewriting the aggregation logic.
Includes success rate per user — a proxy for user experience quality.
This is production-grade thinking: build once, query everywhere.
*/
