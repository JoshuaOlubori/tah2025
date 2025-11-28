

### Presentation Deck (10 Slides)

This deck follows a "Diamond" structure: **Context** (Slides 1-2) $\rightarrow$ **Divergence/Deep Dive** (Slides 3-8) $\rightarrow$ **Convergence/Solution** (Slides 9-10).

#### **Slide 1: Title Slide**
* **Main Title:** The Profitability Paradox: Diagnosing AdventureWorks
* **Subtitle:** Uncovering how our biggest revenue engine is destroying value.
* **Footer:** Team Name / Hackathon Date
* **Visual:** A clean, high-resolution logo of AdventureWorks or a generic data analytics background image.

#### **Slide 2: Executive Summary & Context**
* **Headline:** AdventureWorks at a Glance: High Volume, Thin Margins
* **Key Metrics (The "What"):**
    * **Total Revenue:** \$109.85M 
    * **Total Profit:** \$9.37M (8.5\% Margin) 
    * **Revenue Mix:** 73% Reseller (B2B) / 27% Online (D2C) 
* **The Problem Statement:** Despite strong top-line growth, net income is suppressed. Our analysis identifies a disconnect where the primary source of revenue (Resellers) is eroding profitability through aggressive discounting.
* **Visual:** A KPI Dashboard showing Revenue, Profit, and Customer Count.

 The 
#### **Slide 3:Profitability Paradox**
* **Headline:** The Channel Divergence: One Drives Cash, The Other Drives Profit
* **The Data:**
    * **Reseller Channel:** \$32.89M Revenue (2013) $\rightarrow$ **(\$0.94M) Net Loss**.
    * **Online Channel:** \$10.73M Revenue (2013) $\rightarrow$ **\$4.29M Net Profit**.
* **Insight:** There is an inverse relationship between volume and value. The Reseller channel creates cash flow but destroys margin, while the Online channel is highly efficient but lacks scale.
* **Visual:** A dual-axis line chart showing Revenue trends (Reseller going up) vs. Profit Margin trends (Reseller crashing below zero).

```data
Year,Channel,Total Revenue ($),Total Profit ($),Margin (%)
2011,Online,3.86 M,1.54 M,39.91%
2011,Reseller,8.78 M,0.08 M,0.97%
2012,Online,6.39 M,2.38 M,37.28%
2012,Reseller,27.13 M,(1.43 M),-5.29%
2013,Online,10.73 M,4.29 M,40.00%
2013,Reseller,32.89 M,(0.03 M),-0.24%
```

#### **Slide 4: Misaligned Incentives**
* **Headline:** Are We Paying Our Sales Team to Lose Money?
* **Case Study:** Top 5 Salespeople Analysis.
    * **Michael Blythe:** \$9.29M Revenue $\rightarrow$ **(\$281k) Loss**.
    * **Performance:** All top 5 revenue generators produced negative profit margins.
* **Root Cause:** Commission structures appear tied to *Gross Revenue* rather than *Net Profit*, encouraging reps to offer deep discounts to close bulk deals.
* **Visual:** A horizontal bar chart of the Top 5 Sales Reps. Bar length = Revenue (Green). A small red dot or bar next to it = Net Profit (Red/Negative).

```data
Salesperson,Total Revenue,Total Profit,Profit Margin
Michael Blythe,"$9,293,903","($281,662)",-3.03%
Jae Pak,"$8,503,338","($142,034)",-1.67%
Tsvi Reiter,"$7,171,012","($147,095)",-2.05%
Shu Ito,"$6,427,005","($396,323)",-6.17%
Amy Alberts,"$732,759","($24,279)",-3.31%

```

#### **Slide 5: Customer Segmentation (Methodology)**
* **Headline:** Who Are Our Best Customers? (RFM Analysis)
* **Methodology:** We applied **Recency, Frequency, and Monetary (RFM)** scoring using SQL window functions (`NTILE`) to segment 18,484 online customers.
* **The Split:**
    * **Champions & Loyalists:** 39.3% of customers; the high-value core
    * **At-Risk & Lost:** ~21% of the base; requires win-back strategies
* **Visual:** A Treemap or Pie Chart showing the distribution of the 5 segments


```data
Segment,Customer Count,% of Base,Business Implication
Champions,"1,007",5.5%,High-value core; maximize retention.
Loyal Customers,"6,257",33.8%,Stable revenue base; nurture loyalty.
Potential Loyalists,"7,319",39.6%,Largest segment; prime growth target.
At-Risk Customers,"2,907",15.7%,Require win-back; high recovery value.
Lost Customers,994,5.4%,Low-touch or reactivation pilots only.
Total,"18,484",100%,---
```

#### **Slide 6: The "161-Day" Opportunity**
* **Headline:** The Retention Window is Predictable
* **Key Metric:** Average time to 2nd purchase = **161 Days**
* **The Value of Retention:**
    * New Customer AOV: ~\$1,600.
    * Repeat Customer AOV: **\$6,000+ (8-20x higher value)**.
* **Actionable Insight:** We have a specific window (Days 90–120) to intervene before a customer churns. Waiting for organic return is leaving money on the table
* **Visual:** A linear timeline graphic illustrating the "Nurture Zone" (90-120 days) vs. the "Churn Danger Zone" (161+ days).

#### **Slide 7: Product Portfolio Audit**
* **Headline:** Heroes vs. Laggards
* **The Hero:** **Mountain-200 Series**. High revenue, strong margins (15-20%)
* **The Laggard:** **Road-250 Black Series**. Top 10 revenue generator, but operates at a **negative margin**
* **Insight:** The portfolio is unbalanced. Profitable products are subsidizing loss-makers.
* **Visual:** A Scatter Plot. X-Axis: Total Revenue. Y-Axis: Profit Margin. Highlight the Road-250 in the "High Revenue / Negative Margin" quadrant

#### **Slide 8: The Corrosive Impact of Discounting**
* **Headline:** How Deep Discounts Destroy Unit Economics
* **The Mechanics of Loss:**
    * **Road Bikes (0-5% Discount):** +\$62 Profit per unit
    * **Mountain Bikes (>30% Discount):** **-\$846 Loss per unit**
* **Conclusion:** The losses in the Reseller channel and Laggard products are directly tied to unmonitored, aggressive price cuts
* **Visual:** Side-by-side bar charts showing "Profit per Unit" collapsing into negative values as "Discount %" increases

#### **Slide 9: Strategic Recommendations**
* **Headline:** Turning Insights into Action
* **1. Restructure Incentives:** Shift sales commissions from Gross Revenue to Net Profit to stop value destruction.
* **2. Cap Discounts:** Implement a hard 15% discount ceiling on premium items (Mountain/Road Bikes)
* **3. Automate Retention:** Launch a "Day 90" nurture campaign to target the 161-day repeat cycle.
* **4. Rationalize Portfolio:** Immediate audit of Road-250 COGS; discontinue or re-price if margins cannot be recovered.

#### **Slide 10: Conclusion**
* **Headline:** The Path to Sustainable Growth
* **Summary:** AdventureWorks has successfully solved the "Volume" equation. The next phase is solving the "Value" equation.
* **Final Impact:** By aligning channel incentives and focusing on high-value retention, we move from a revenue-driven operation to a profit-optimized business
* **Next Steps:**
    * Implement "Margin-Based" commission pilot in Q1.
    * Deploy SQL triggers for "Laggard" product alerts.
* **Visual:** "Thank You" .