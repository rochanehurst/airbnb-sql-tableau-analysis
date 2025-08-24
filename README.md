# Airbnb Data Analysis (SQL + Tableau)

## Project Overview
This project explores U.S. Airbnb listings through **data cleaning, SQL analysis, and Tableau visualizations**.  
Starting with raw, messy data (~500k rows), I built an **end-to-end pipeline** to clean, analyze, and present insights on **market distribution, pricing, host behavior, and guest satisfaction**.

---

## Tools & Technologies
- **SQL (MySQL)** → data cleaning & analysis  
- **Tableau Public** → dashboards & storytelling visualizations  
- **Excel/CSV** → exporting queries for visualization  

---

## Data Cleaning Highlights
Raw Airbnb data required extensive preprocessing before analysis:
- Removed duplicates with `ROW_NUMBER()` and CTEs.  
- Standardized text fields (trim, lowercase → proper case in Tableau).  
- Cleaned inconsistent city/state names using **fuzzy matching** (`SOUNDEX`) and CASE statements.  
- Converted fields:
  - `price` → numeric `price_num`  
  - `bathrooms` → `bathrooms_num` (decimal)  
  - `host_since` → DATE  
- Standardized ZIP codes to 5 digits.  
- Dropped unnecessary columns (`market`, `host_verifications`, staging fields).  
- Final dataset reduced to **U.S.-only, clean, analysis-ready records**.  

---

## SQL Analysis
I wrote queries to answer key business questions:

- **Listings distribution**
  - Top cities and states by number of listings  
- **Property insights**
  - Distribution of property types  
  - Average price by room type (entire home, private, shared)  
- **Host dynamics**
  - Growth of hosts over time (YoY + cumulative)  
  - Share of multi-property vs single-property hosts  
  - Top 10 hosts by number of listings  
- **Pricing & reviews**
  - Average price by city/state (threshold ≥10 listings)  
  - Review score averages across states  
  - Relationship between price ranges and review ratings  
  - Pricing trends by older vs newer hosts  

---

## Tableau Dashboards
Built **3 dashboards** to visualize results:

### Market Overview
- Listings per city/state (map)  
- Top 20 cities by average Airbnb price  
- Distribution of listings by market size  

### Host Insights
- Top 10 hosts by number of listings  
- Donut chart: single vs. multi-property hosts  
- Host growth timeline with YoY growth  

### Properties & Reviews
- Average price by accommodation type  
- Distribution of property types  
- Average review scores by state  
- Price range vs. average review score  

---

## Key Insights
- **Concentration**: New York and Los Angeles dominate with ~19k listings each.  
- **Property distribution**: Apartments & houses make up **80%+** of listings.  
- **Hosts**: ~63% are single-property hosts, while ~37% are multi-property operators.  
- **Pricing**: Entire homes are ~2.5× more expensive than private rooms.  
- **Reviews**: Scores are consistently high (92–96), regardless of price.  
- **Growth**: Host count surged 2010–2015, then stabilized.  

---

## Repository Structure
- `SQL_Cleaning.sql` → cleaning script  
- `SQL_Analysis.sql` → analysis queries  
- `/Dashboards` → Tableau workbook + screenshots  

---

## 🔗 Tableau Dashboards
- [Market Overview](https://public.tableau.com/app/profile/rochane.hurst/viz/AirbnbAnalysis-MarketOverview/MarketDistribution?publish=yes)  
- [Host Insights](https://public.tableau.com/app/profile/rochane.hurst/viz/AirbnbAnalysis-HostInsights/HostsDynamics)  
- [Properties & Reviews](https://public.tableau.com/app/profile/rochane.hurst/viz/AirbnbAnalysis-PropertiesandReviews/PropertyTypesandReviews)  


