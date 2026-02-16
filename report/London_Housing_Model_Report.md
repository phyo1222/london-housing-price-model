# London Housing Price Modelling Report

-------------------------
## Executive Summary
-------------------------
This project develops a regression-based pricing model to analyse the determinants of residential property prices in Greater London. The objective is to quantify the relative contribution of structural characteristics and location in explaining transaction price variation.

A baseline model including property type and transaction year explains approximately 15% of price variation (R² = 0.15). After introducing district fixed effects, explanatory power increases to 50% (R² = 0.50), with RMSE improving by approximately 23%.

These results indicate that location is the dominant driver of price dispersion in the London housing market. However, roughly half of the variation remains unexplained, suggesting the presence of omitted structural, spatial, and macroeconomic factors.


-------------------------
## Data Description
-------------------------
The dataset contains London residential property transactions including:
- Sale price  
- Property type  
- District (location)  
- Transaction year  

### Data Preparation
1. Removed invalid or missing observations.
2. Log-transformed sale price to address right-skewness.
3. Split data into training and test sets.
4. Applied train-only outlier trimming using percentile thresholds.
5. Created a frozen modelling dataset prior to estimation.

All preprocessing was conducted within the training pipeline to prevent data leakage.


-------------------------
## Model Specification
-------------------------
### Baseline Model
log(Price) = β0 + β1(PropertyType) + β2(Year) + ε

### Extended Model (With District Fixed Effects)
log(Price) = β0 + β1(PropertyType) + β2(Year) + γ(District) + ε

Property type and year are treated as categorical variables. District fixed effects capture spatial heterogeneity across boroughs.


-------------------------
## Model Performance
-------------------------
Baseline Model:
- R² = 0.15

Extended Model:
- R² = 0.50
- RMSE reduced by approximately 23%

Structural characteristics alone provide limited predictive power. Introducing district fixed effects substantially improves explanatory strength, confirming that spatial heterogeneity dominates pricing dynamics in London’s housing market.


-------------------------
## Coefficient Interpretation
-------------------------
Key findings from the extended model include:
- Detached and semi-detached properties command significant price premiums relative to flats (reference category), holding district constant.
- Year effects capture cyclical housing market movements.
- District coefficients vary substantially, reflecting strong cross-borough price dispersion.

Because the dependent variable is log-transformed, coefficients can be interpreted approximately as percentage differences relative to the base category.ariable is log-transformed, coefficients can be interpreted approximately as percentage differences relative to the base category.


-------------------------
## Diagnostic Testing
-------------------------
- Log transformation reduces heteroskedasticity.
- Heteroskedasticity-robust (HC1) standard errors were applied.
- No evidence of severe multicollinearity among structural predictors.
- Residual distribution approximates normality.

The use of robust standard errors ensures valid inference under non-constant variance.


-------------------------
## Residual Analysis by District
-------------------------
Aggregating residuals at the district level reveals systematic over- and under-prediction patterns in certain areas.

This suggests:
- Omitted neighbourhood characteristics
- Spatial clustering effects
- Within-district heterogeneity not captured by categorical fixed effects

These findings motivate potential extensions using spatial econometric techniques.


-------------------------
## Economic Interpretation
-------------------------
The results suggest that:
1. The London housing market is segmented into micro-markets.
2. Structural variables alone are weak predictors of price.
3. Spatial heterogeneity explains a substantial share of variation.
4. District-level effects absorb significant price premiums.

The remaining unexplained variation likely reflects omitted variables such as:
- Floor area
- Energy performance ratings
- Proximity to transport hubs
- School quality
- Interest rate conditions
- Spatial autocorrelation effects


-------------------------
## Limitations
-------------------------
- Random train-test split may mix different market regimes.
- Fixed effects capture location but not spatial spillovers.
- Potential omitted variable bias.
- Possible endogeneity between district selection and property characteristics.
- No dynamic time modelling.


-------------------------
## Conclusion
-------------------------
Incorporating district fixed effects significantly improves predictive performance in London housing price modelling.

The analysis confirms that location is the primary driver of cross-sectional price variation while also highlighting substantial unexplained heterogeneity. Future extensions should incorporate richer structural and spatial variables to enhance explanatory completeness and predictive accuracy.