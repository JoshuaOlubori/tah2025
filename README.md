# Analytics Hackathon 2025 — AdventureWorks Business Analysis

**Challenge:** Analyze the AdventureWorks dataset to identify five high-quality, business-relevant insights across channel performance, customer behavior, and product optimization.

**Submission:** Compressed PDF Report on Google Drive  
🔗 [Access Full Report (PDF)](https://drive.google.com/xxxxxxxxxxxxxxxxx)

---

## 📊 Project Overview

This submission presents a data-driven analysis of AdventureWorks' sales performance, customer segmentation, and product profitability. The analysis uncovers a critical **profitability paradox**: the Reseller channel drives 73% of revenue but operates at a loss, while the Online channel delivers superior margins. Key recommendations address pricing discipline, incentive realignment, and targeted retention strategies.

---

## 📁 Project Structure

### [`01_Data_Engineering/`](./Analytics_Hackathon_2025/01_Data_Engineering/)

**Database schema and ETL setup**

- `create_analytics_schema.sql` — SQL script to create analytical schema and views for AdventureWorks data
- Contains foundational tables and computed metrics used across all analyses

### [`02_Analysis_Scripts/`](./Analytics_Hackathon_2025/02_Analysis_Scripts/)

**Analytical queries organized by theme**

#### [`Theme1_Channel_Performance/`](./Analytics_Hackathon_2025/02_Analysis_Scripts/Theme1_Channel_Performance/)

- **Objective:** Analyze Online vs. Reseller channel profitability, operational metrics, and salesforce effectiveness
- **Key Finding:** Reseller channel contributes 73% of revenue but frequently operates at negative margins due to aggressive discounting
- **Queries & Views:** Channel revenue, profitability, salesforce metrics, geographic distribution

#### [`Theme2_Customer_Segmentation/`](./Analytics_Hackathon_2025/02_Analysis_Scripts/Theme2_Customer_Segmentation/)

- **Objective:** Identify customer segments using RFM analysis and understand repeat purchase behavior
- **Key Finding:** 5.5% of customers (Champions) drive a disproportionate share of revenue; average repeat purchase cycle is 161 days
- **Queries & Views:** RFM scoring, customer lifetime value, repeat purchase metrics, geographic concentration

#### [`Theme3_Product_Optimization/`](./Analytics_Hackathon_2025/02_Analysis_Scripts/Theme3_Product_Optimization/)

- **Objective:** Evaluate product profitability, bundling opportunities, and discount sensitivity
- **Key Finding:** Deep discounts (>30%) on Mountain Bikes invert margins to losses of ~$846 per unit; hero products (Mountain-200) subsidize laggards (Road-250)
- **Queries & Views:** Product rankings, market basket analysis, discount impact, channel-specific performance

### [`consolidated_scripts/`](./Analytics_Hackathon_2025/consolidated_scripts/)

**Complete SQL analysis in two formats**

- `all_queries.sql` — All exploratory and analytical queries in one file
- `all_views.sql` — All SQL Server views created for dashboarding and reporting

### [`report/`](./Analytics_Hackathon_2025/report/)

**Presentation-ready PDF report and LaTeX source**

#### Report Contents

- **Introduction** — Business context, KPIs, channel overview
- **Chapter 1: Channel Performance Analysis** — Profitability paradox, operational metrics, geographic performance
- **Chapter 2: Customer Segmentation Analysis** — RFM framework, segment distribution, repeat purchase behavior
- **Chapter 3: Product Optimization** — Hero vs. laggard products, market basket opportunities, discount sensitivity
- **Chapter 4: Conclusion & Recommendations** — Five high-impact recommendations for restoring profitability

#### Technical Details

- **Format:** LaTeX (compiled to PDF)
- **Structure:**
  - `AdventureWorks.tex` — Master document
  - `AdventureWorksThesis.cls` — Custom document class
  - `Chapters/` — Individual chapter files
  - `Matter/` — Front matter, appendices, bibliograpy
  - `Configurations/` — Typography, colors, headers, code highlighting
  - `Figures/` — Charts and visualizations

### [`data/`](./Analytics_Hackathon_2025/data/)

**Output data and supplementary files**

#### Subdirectories

- `additional_customer_data/` — Customer segmentation outputs (AOV, acquisition trends, RFM distribution)
- `additional_product_data/` — Product analysis outputs (discount impact, category revenue, top/bottom products)
- `views_output/` — CSV exports from all SQL Server views for reference

---

## 📈 Interactive Dashboard

**Power BI Report**  
🔗 [View Interactive Dashboard](https://app.powerbi.com/xxxxxxxxxxxxxxxxx)

![Power BI Dashboard Preview](./placeholder-powerbi-screenshot.png)  
_Placeholder: Replace with actual screenshot of key Power BI report page showing channel comparison, customer segmentation, and product performance_

---

## 🎯 Key Insights & Recommendations

### Insight 1: The Profitability Paradox

**Finding:** Reseller channel generates $80.5M (73%) of revenue but operates at negative margins; Online generates $29.4M but maintains ~40% margins.  
**Recommendation:** Restructure Reseller incentives to reward net profit rather than gross revenue; implement dynamic discount caps (15% ceiling).

### Insight 2: Concentrated Customer Value

**Finding:** 5.5% of online customers (Champions) and 33.8% (Loyal) account for the majority of revenue; 161-day repeat purchase cycle identified.  
**Recommendation:** Launch "Champion" VIP program and deploy automated nurture campaigns between days 90–120 post-purchase.

### Insight 3: Discount-Driven Unprofitability

**Finding:** Mountain Bikes at >30% discount incur losses of ~$846 per unit; Road Bikes at 0–5% discount yield $62 profit per unit.  
**Recommendation:** Enforce company-wide discount policy with 15% floor for high-value categories and mandatory approval gates.

### Insight 4: Imbalanced Product Portfolio

**Finding:** Hero products (Mountain-200 series, 15–20% margins) subsidize laggards (Road-250 Black, negative margins despite top-10 revenue).  
**Recommendation:** Conduct urgent profitability audit of top 20 SKUs; consider price adjustments or discontinuation for loss-making products.

### Insight 5: Market Basket & Bundling Opportunities

**Finding:** Strong co-purchase patterns (Water Bottle + Cage = 1,692 pairs; Helmet + Patch Kit = 132 pairs) reveal bundling potential.  
**Recommendation:** Create official bundles ("Reseller Build Kits," "Online Adventure Bundles") to improve AOV without eroding unit margins.

---

## 📊 Deliverables Checklist

| Deliverable              | Location                       | Status                                           |
| ------------------------ | ------------------------------ | ------------------------------------------------ |
| **SQL Scripts**          | `consolidated_scripts/`        | ✅ All queries and views                         |
| **Documentation Report** | `report/` (PDF + LaTeX source) | ✅ Comprehensive analysis                        |
| **Dashboard**            | Power BI (link above)          | 🔗 [Interactive Report](#-interactive-dashboard) |
| **Presentation Slides**  | `report/` (embedded in PDF)    | ✅ Summary slides in conclusion                  |

---

## 🛠️ Tools & Technologies Used

| Tool                            | Purpose                                            |
| ------------------------------- | -------------------------------------------------- |
| **SQL Server**                  | Data exploration, schema design, view creation     |
| **Power BI**                    | Interactive dashboards, slicers, KPI cards         |
| **Python** (Pandas, Matplotlib) | Statistical analysis, supplementary visualizations |
| **Excel**                       | Data cleaning, quick calculations                  |
| **LaTeX**                       | Professional PDF report generation                 |
| **Git**                         | Version control and collaboration                  |

---

## 📖 How to Use This Repository

### For Reviewers

1. **Quick Summary:** Start with this README and the [PDF Report](#-interactive-dashboard)
2. **Detailed Analysis:** Review individual chapter files in `report/Chapters/`
3. **Raw Data & Queries:** Explore `consolidated_scripts/` for SQL logic and `data/views_output/` for sample outputs
4. **Dashboard:** Open the [Power BI interactive report](#-interactive-dashboard) for real-time exploration

### For Developers / Future Enhancements

1. **Restore Schema:** Run `01_Data_Engineering/create_analytics_schema.sql` against AdventureWorks database
2. **Run Analysis Scripts:** Execute queries in `02_Analysis_Scripts/` by theme
3. **Compile LaTeX Report:** Use `report/AdventureWorks.tex` with pdfLaTeX or XeLaTeX
4. **Update Power BI:** Refresh data source connection to your SQL Server instance

---

## 📞 Key Metrics (Summary)

| Metric                        | Value    |
| ----------------------------- | -------- |
| Total Revenue                 | $109.85M |
| Total Profit                  | $9.37M   |
| Overall Profit Margin         | 8.5%     |
| Total Customers               | 19.1K    |
| Reseller Revenue (% of Total) | 73.3%    |
| Online Revenue (% of Total)   | 26.7%    |
| Online Profit Margin          | ~40%     |
| Reseller Profit Margin        | Negative |
| Repeat Customer Rate          | 60%+     |
| Average Repeat Purchase Cycle | 161 days |

---

## 📝 Documentation & Methodology

Each chapter follows a consistent structure:

1. **Objectives** — Clear business questions addressed
2. **Methodology** — SQL and analytical approach
3. **Key Findings** — Evidence-backed insights with supporting tables/charts
4. **Business Implications** — Actionable recommendations with expected impact
5. **Limitations** — Honest discussion of data constraints and assumptions

---

## 🚀 Next Steps & Future Work

- [ ] Implement recommended discount policy and track impact
- [ ] A/B test "Champion" VIP program on select customer cohorts
- [ ] Conduct detailed COGS audit for Road-250 series
- [ ] Build automated weekly monitoring dashboard for margin trends
- [ ] Expand geographic analysis to forecast international expansion potential

---

## 📄 Submission Details

**Hackathon:** The Analytics Hackathon 2025  
**Challenge:** Business Intelligence & Data Analysis  
**Team/Participant:** AdventureWorks Analytics  
**Submission Date:** November 2025  
**Evaluation Criteria:**

- Insight Quality (25 points)
- SQL & Analysis Proficiency (25 points)
- Visualization & Storytelling (20 points)
- Documentation (15 points)
- Presentation (15 points)

---

## 📎 Quick Links

- 📊 [Interactive Power BI Dashboard](https://app.powerbi.com/xxxxxxxxxxxxxxxxx)
- 📄 [Full Report PDF (Google Drive)](https://drive.google.com/xxxxxxxxxxxxxxxxx)
- 💾 [SQL Scripts](./Analytics_Hackathon_2025/consolidated_scripts/)
- 📖 [Detailed Analysis by Theme](./Analytics_Hackathon_2025/02_Analysis_Scripts/)
- 📈 [Data Exports & Views](./Analytics_Hackathon_2025/data/views_output/)

---

**Last Updated:** November 28, 2025  
**Report Version:** 1.0.0
