# 🏡 NSW Real Estate Intelligence Pipeline

### 🚀 The Mission
Real estate data in New South Wales is powerful but fragmented. It exists in massive, messy text files dating back to 1990, with inconsistent formats and disconnected systems. 

**This project creates a "Single Source of Truth" for 30+ years of property trends.** It ingests raw government transaction logs, repairs historical data quality issues, and models the data to answer questions like:
* *How do flood events impact rental yields in specific suburbs?*
* *Which communities are seeing a shift from owner-occupiers to investors?*

### 🛠️ The Architecture
I built this pipeline to mimic a modern production environment, separating **Extraction** (getting the data) from **Transformation** (making sense of it).

**1. Extract & Load (Python + Polars)**
* **Challenge:** The source data (bulk .dat files) suffers from "Schema Drift"—the format changed drastically in 2001.
* **Solution:** Custom Python parsers using `Polars` for high-performance processing. These scripts normalize column structures and output partitioned Parquet files (optimized for Cloud/Data Lakes).

**2. Transform (dbt + SQL)**
* **Staging Layer:** Cleans raw data and handles type casting.
* **Mart Layer:**
    * `fct_sales`: A unified timeline of 30 years of sales.
    * `agg_market_trends`: Aggregated metrics (Median Price, Rental Yield) ready for BI dashboards.
* **Data Quality:** Automated testing (via dbt) ensures no missing prices or invalid dates enter the final report.

### 📂 Repository Structure
* `extract_load/`: Python scripts for parsing raw .dat/zip files.
* `transform/`: The complete dbt project (Models, Tests, Seeds).

### ⚡ Quick Start
**Prerequisites:** Python 3.9+, dbt-core.

**1. Python Setup**
```bash
pip install -r requirements.txt
python extract_load/process_current.py
