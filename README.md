<div align="center">

# 📱 PhonePe Transaction Analytics

### End-to-end analysis of digital payment behavior across UPI, recharges, loans, insurance & money transfers

[![Python](https://img.shields.io/badge/Python-3.10-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![Pandas](https://img.shields.io/badge/Pandas-Data%20Wrangling-150458?style=flat&logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![SQL](https://img.shields.io/badge/SQL-Querying-4479A1?style=flat&logo=postgresql&logoColor=white)](#)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)](#)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?style=flat&logo=jupyter&logoColor=white)](#)

</div>

---

## 📌 Overview

This project analyzes **~300,000 PhonePe transaction records** to uncover patterns in how users across India transact, recharge, borrow, insure, and transfer money on the platform. It combines **Python (EDA & cleaning)**, **SQL (business querying)**, and **Power BI (interactive dashboarding)** to deliver a complete, recruiter-ready data analytics workflow — from raw CSVs to actionable insight.

The analysis covers five core services on the PhonePe ecosystem:

| Service | Dataset |
|---|---|
| 💸 Peer-to-peer & merchant transactions | `all_transactions.csv` |
| 👤 User activity & demographics | `all_users.csv` |
| 🛡️ Insurance purchases | `insurance.csv` |
| 🏦 Loan disbursals | `loans.csv` |
| 🔁 Money transfers | `money_transfer.csv` |
| 📲 Recharge & bill payments | `recharge_bills.csv` |

---

## 🎯 What This Project Answers

- What does the **success vs. failure breakdown** of transactions look like (Successful / Failed / Wrong PIN / Server Error), and where are failures concentrated?
- Which **services** (recharges, transfers, loans, insurance) drive the most volume and value?
- How does **user engagement** vary — active users, repeat behavior, and adoption trends?
- What do **UPI transaction patterns** reveal about peak usage, transaction size, and frequency?
- How can these insights be communicated through an **executive-ready Power BI dashboard**?

---

## 🛠️ Tech Stack

| Layer | Tools Used |
|---|---|
| **Data Cleaning & EDA** | Python, Pandas, NumPy |
| **Querying & Analysis** | SQL |
| **Visualization** | Power BI (DAX, interactive dashboard) |
| **Notebook Environment** | Jupyter Notebook |
| **Version Control** | Git & GitHub |

---

## 📂 Repository Structure

```
phonepe-transaction-analytics/
├── phonepe-transaction-analytics.ipynb   # Data cleaning, EDA & analysis in Python
├── phonepe_transactions.sql              # SQL queries for business-question answering
├── phonepe_powerbi.pdf                   # Exported view of the Power BI dashboard
├── all_transactions.csv                  # Core transaction-level dataset
├── all_users.csv                         # User-level dataset
├── insurance.csv                         # Insurance transactions
├── loans.csv                             # Loan transactions
├── money_transfer.csv                    # Money transfer records
├── recharge_bills.csv                    # Recharge & bill payment records
└── README.md
```

---

## 🔍 Project Workflow

1. **Data Cleaning & Preparation** — Handled missing values, standardized transaction status categories, and structured raw CSVs for analysis using Pandas in the Jupyter notebook.
2. **Exploratory Data Analysis** — Explored transaction status distribution, service-wise volume trends, and user behavior patterns across the dataset.
3. **SQL Analysis** — Wrote structured queries (`phonepe_transactions.sql`) to answer business questions around transaction success rates, top services, and user activity.
4. **Power BI Dashboard** — Built an interactive dashboard (exported as `phonepe_powerbi.pdf`) to visualize KPIs, trends, and breakdowns for non-technical stakeholders.

---

## 📊 Dashboard Preview

A snapshot of the Power BI dashboard is available in [`phonepe_powerbi.pdf`](./phonepe_powerbi.pdf), covering transaction status breakdowns, service-wise distribution, and user trends.

---

## 🚀 How to Run

```bash
# Clone the repository
git clone https://github.com/Yashchaudhary872/phonepe-transaction-analytics.git
cd phonepe-transaction-analytics

# Install dependencies
pip install pandas numpy jupyter

# Launch the notebook
jupyter notebook phonepe-transaction-analytics.ipynb
```

To explore the SQL analysis, load the CSVs into your preferred SQL environment (MySQL/PostgreSQL/SQLite) and run the queries in `phonepe_transactions.sql`. The Power BI dashboard can be viewed directly via the included PDF export.

---

## 👤 Author

**Yash Chaudhary**
B.Tech IT Student | Aspiring Data Analyst

[![GitHub](https://img.shields.io/badge/GitHub-Yashchaudhary872-181717?style=flat&logo=github)](https://github.com/Yashchaudhary872)
[![Email](https://img.shields.io/badge/Email-chaudharyyash872%40gmail.com-D14836?style=flat&logo=gmail&logoColor=white)](mailto:chaudharyyash872@gmail.com)

---

<div align="center">
⭐ If you found this project useful or interesting, consider giving it a star!
</div>
