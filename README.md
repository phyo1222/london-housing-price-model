# London Housing Prices Model

-------------------------
## Overview
-------------------------
This project analyses residential property transactions in Greater London (2023–2025) to quantify the impact of structural and spatial characteristics on housing prices.

The core objective is to measure the incremental explanatory power gained by incorporating district-level fixed effects into a log-linear regression framework.


-------------------------
## Data
-------------------------
- Source: UK Land Registry Price Paid Data
- Years: 2023, 2024, 2025
- Filtered applied:
  - Greater London only
  - Standard residential transactions (PPD Category A)

Cleaned modelling dataset:
data_clean/london_model_data.csv

### Data Access
Raw transaction data is sourced from the UK Land Registry Price Paid dataset.
Due to file size constraints, raw data files are not stored in this repository.
They can be downloaded from:
https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads


-------------------------
## Methodology
-------------------------
### 1. Data Preparation
- Combined yearly datasets
- Filtered to Greater London
- Removed non-standard transactions
- Created:
  - `log_price`
  - `year`, `month`
  - Factor variables for property characteristics

### 2. Train-Test Split
- 80/20 random split
- Factor levels aligned between train and test

### 3. Outlier Handling
- 1st and 99th percentile thresholds calculated on **training set only**
- Outliers removed from training data
- Full test set retained to ensure realistic evaluation

### 4. Models
**Baseline Model:**
log_price ~ property_type + new_build + tenure + year + month
**Location Model:**
log_price ~ property_type + new_build + tenure + year + month + district


-------------------------
## Results
-------------------------
| Model      | RMSE (log) | Test R² |
|------------|------------|---------|
| Baseline   | ~0.49      | ~0.15   |
| Location   | ~0.38      | ~0.50   |

Adding district-level effects reduced prediction error by approximately 23% and increased out-of-sample explanatory power substantially.

The final model explains roughly 50% of variation in housing prices, confirming that location is a dominant driver of London property values.


-------------------------
## Diagnostics
-------------------------
Diagnostics are saved in:
outputs/plots/

Includes:
- Residual distribution
- Residuals vs fitted plot
- QQ plot

Residuals are approximately symmetric but show mild right-tail behaviour, indicating underprediction in high-value segments.


-------------------------
## District Mispricing
-------------------------
District-level average residuals were computed to identify relative over- and under-valuation patterns.

Results available in:
outputs/tables/district_mispricing.csv

Positive mean residuals indicate observed prices exceed model expectations; negative values indicate the opposite.


-------------------------
## Limitations
-------------------------
- Random split rather than time-based validation
- No property size or interior condition variables
- No macroeconomic controls
- Evidence of mild heteroskedasticity at higher price levels


-------------------------
## Project Structure
-------------------------
data_raw/    Raw Land Registry data
data_clean/  Processed modelling dataset
scripts/     Data preparation and modelling scripts
models/      Saved regression models
outputs/     Generated plots and tables
report/      Final written report


-------------------------
## How to Reproduce
-------------------------
1. Run `01_data_preparation.R`
2. Run `02_modelling.R`

All outputs (tables, plots, and models) are generated automatically.
