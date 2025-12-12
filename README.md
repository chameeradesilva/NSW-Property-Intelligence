# 🏡 NSW Real Estate Intelligence Pipeline

### 🚀 The Mission
Real estate data in New South Wales is powerful but fragmented. It exists in massive, messy text files dating back to 1990, with inconsistent formats and disconnected systems. 

**This project creates a "Single Source of Truth" for 30+ years of property trends.** It ingests raw government transaction logs, repairs historical data quality issues, and models the data to answer questions like:
* *How do flood events impact rental yields in specific suburbs?*
* *Which communities are seeing a shift from owner-occupiers to investors?*

### 🛠️ The Architecture
I built this pipeline to mimic a modern production environment, separating **Extraction** (getting the data) from **Transformation** (making sense of it).

```
[Jupyter Notebook] → [S3] → [AWS Glue Crawler] → [Athena] → [dbt Cloud] → [Analytics]
```

**1. Extract & Load (Jupyter Notebook + Python + Polars)**
* **Notebook:** `Bulk_property_sales_information.ipynb` runs multiple self-contained scripts:
  * **Download Cell:** Fetches bulk property sales data from NSW Government (1990-2025)
  * **Script 1:** Parses and preprocesses ARCHIVED data (1990-2000) using `Polars`
  * **Script 2:** Processes CURRENT ANNUAL data (2001-2024) with schema normalization
  * **Script 3:** Handles CURRENT WEEKLY data (2025) for real-time updates
* **Challenge:** The source data (bulk .dat files) suffers from "Schema Drift"—the format changed drastically in 2001.
* **Output:** Partitioned Parquet files (optimized for cloud data lakes) saved locally

**2. Upload to AWS S3**
* **Notebook:** Includes a built-in S3 uploader that pushes processed Parquet files to S3
* **Credentials:** Uses Colab Secrets to securely access AWS credentials
* **Destination:** `s3://au-real-estate/processed/nsw_bulk_property_sales/`

**3. Data Cataloging (AWS Glue Crawler)**
* **Purpose:** Automatically crawls S3 partitions and creates/updates the AWS Glue Data Catalog
* **Result:** Makes data discoverable and queryable via AWS Athena
* **Partitioning:** Organized by `year=YYYY/` for efficient querying

**4. Query Layer (AWS Athena)**
* **Purpose:** SQL interface to query Parquet files directly from S3
* **Use Case:** Explore raw data, run ad-hoc analytics, validate data quality

**5. Transform (dbt Cloud + SQL)**
* **Staging Layer:** Cleans raw data and handles type casting.
* **Mart Layer:**
    * `fct_sales`: A unified timeline of 30 years of sales.
    * `agg_market_trends`: Aggregated metrics (Median Price, Rental Yield) ready for BI dashboards.
* **Data Quality:** Automated testing (via dbt) ensures no missing prices or invalid dates enter the final report.
* **dbt Cloud:** Orchestrates transformations with version control, documentation, and lineage tracking

### 📂 Repository Structure
* `Bulk_property_sales_information.ipynb`: Main Jupyter notebook containing all extraction, preprocessing, and S3 upload scripts.
* `transform/`: The complete dbt Cloud project (Models, Tests, Seeds).

### ⚡ Quick Start Workflow

**Prerequisites:**
* Google Colab (free)
* AWS Account with S3, Athena, and Glue access
* dbt Cloud account
* Colab Secrets configured with AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)

**Step 1: Extract & Preprocess (Google Colab)**
1. Open `Bulk_property_sales_information.ipynb` in Google Colab
2. Run the download cell to fetch NSW government property sales data
3. Run Scripts 1-3 to parse and preprocess data (creates Parquet files in `/output`)
4. Run the S3 uploader cell to push processed data to AWS S3

**Step 2: Catalog Data (AWS Glue)**
1. Go to AWS Glue Console → Crawlers
2. Create a new crawler pointing to: `s3://au-real-estate/processed/nsw_bulk_property_sales/`
3. Configure output database: `nsw_real_estate`
4. Run the crawler to create/update the Glue Data Catalog

**Step 3: Validate & Explore (AWS Athena)**
Query in Athena Console:
```sql
SELECT COUNT(*) FROM nsw_real_estate.sales_data;
SELECT DISTINCT year FROM nsw_real_estate.sales_data ORDER BY year;
```

**Step 4: Transform (dbt Cloud)**
1. Connect dbt Cloud to your GitHub repository
2. Configure dbt Cloud to connect to Athena as the data source
3. Deploy: dbt Cloud will automatically run transformations on schedule
4. Monitor lineage and test results in dbt Cloud UI

**Step 5: Monitor & Report**
* Access transformed data in Athena for BI tool integration (Looker, Tableau, etc.)
* View dbt documentation and lineage at: `https://cloud.getdbt.com/[your-account]/`

### 🔑 Environment Setup

**Colab Secrets Configuration:**
Add these secrets in Colab (Secrets → Add new secret):
* `AWS_ACCESS_KEY_ID`: Your AWS access key
* `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key

**dbt Cloud Setup:**
1. Create a dbt Cloud account at https://cloud.getdbt.com
2. Connect your GitHub repository containing the `transform/` folder
3. Configure Athena as your data source:
   - Database: `nsw_real_estate`
   - AWS Region: `us-east-1` (or your region)
   - S3 Output Location: `s3://your-bucket/athena-results/`

### 📊 Data Flow Summary
```
Raw NSW Government Data (1990-2025)
    ↓
Colab Notebook (Polars Processing)
    ↓
Partitioned Parquet Files (local)
    ↓
AWS S3 (s3://au-real-estate/processed/)
    ↓
AWS Glue Crawler (Data Cataloging)
    ↓
AWS Athena (SQL Queries)
    ↓
dbt Cloud Transformations
    ↓
Analytics-Ready Marts (fct_sales, agg_market_trends)
    ↓
BI Tools (Looker, Tableau, Power BI)
```

### 🧪 Data Quality
* **dbt Tests:** Automated validation of primary keys, relationships, and data types
* **Row Counts:** Tracked across each transformation stage
* **Date Validation:** Ensures all contract/settlement dates are valid ISO format
* **Price Validation:** Flags anomalies and missing values

### 📚 Documentation
* dbt Models: Documented in `transform/models/` with descriptions and tests
* dbt Cloud UI: Interactive lineage, data dictionary, and test results
* Code Comments: Detailed in parser scripts for data extraction logic
