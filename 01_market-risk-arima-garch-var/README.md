# 📊 Market Risk and Volatility Modelling: ARIMA-GARCH, VaR and Expected Shortfall Backtesting

## 🧭 Project Overview

This project applies financial econometrics techniques to model the return dynamics and volatility of a financial asset. The objective is to estimate time-series models, analyse volatility clustering, forecast conditional volatility, and evaluate market risk using Value-at-Risk (VaR), Expected Shortfall (ES), statistical backtesting methods, and a regression-based analysis involving the VIX index.

The project combines ARIMA modelling for return dynamics, GARCH-type volatility models, risk validation tools, and a comparison with market-implied volatility indicators commonly used in market risk analysis.

## 🎯 Objectives

- Analyse the statistical properties of financial returns and assess whether they exhibit the main stylised facts of financial time series.
- Perform the necessary diagnostic tests and transformations to ensure that the series can be properly modelled.
- Estimate ARIMA models for the conditional mean.
- Estimate GARCH-type models for conditional volatility.
- Compute Value-at-Risk and Expected Shortfall measures.
- Backtest VaR estimates using statistical validation tests.
- Backtest Expected Shortfall estimates using appropriate risk validation methods.
- Conduct a regression analysis using the VIX index to study the relationship between asset returns and market-implied volatility.
- Compare the movements of the VIX with VaR, Expected Shortfall and GARCH-based conditional volatility.
- Discuss the strengths and limitations of the modelling approach.

## 🧪 Methodology

The project follows the following steps:

1. Data collection and preparation.
2. Return computation and descriptive statistics.
3. Stationarity and diagnostic testing.
4. ARIMA model estimation.
5. GARCH volatility modelling.
6. Value-at-Risk estimation.
7. Expected Shortfall estimation.
8. VaR and ES backtesting.
9. VIX regression analysis.
10. Comparison between VIX, VaR, ES and conditional volatility dynamics.
11. Interpretation of results.

## 📈 VIX Regression and Risk Measures Analysis

In addition to the ARIMA-GARCH, VaR and Expected Shortfall framework, the project includes a regression-based analysis using the VIX index as a proxy for market-implied volatility and market stress.

The objective of this section is to examine the relationship between the selected asset returns and changes in the VIX. This allows the analysis to assess whether the asset exhibits sensitivity to volatility shocks and broader market uncertainty.

The VIX regression analysis focuses on:

- Estimating the relationship between asset returns and VIX variations.
- Interpreting the sign and magnitude of the regression coefficient.
- Assessing whether changes in market-implied volatility help explain asset return behaviour.
- Analysing the statistical significance of the relationship.
- Discussing the role of volatility shocks in market risk modelling.

The project also compares the dynamics of the VIX with the estimated risk measures and conditional volatility. This comparison helps assess whether periods of higher market-implied volatility are associated with higher Value-at-Risk, higher Expected Shortfall, and increased GARCH-based conditional volatility.

This additional analysis complements the GARCH framework by linking realised return dynamics, model-based risk estimates, conditional volatility, and a forward-looking market volatility indicator.

## 🛠️ Tools and Libraries

The analysis is conducted in R using packages for financial time series analysis, econometric modelling, statistical testing, volatility modelling, and risk measurement.

Main tools include:

- R
- Time-series analysis packages
- GARCH modelling packages
- Statistical testing tools
- Risk measurement and backtesting tools
- Regression analysis tools
- Data visualisation packages

Although the analysis could also be implemented in Python, R is particularly well suited for statistical modelling and financial econometrics due to the richness and ergonomics of its specialised packages.

## 🧠 Key Concepts

- Financial returns
- Stylised facts of financial time series
- Stationarity
- ARIMA models
- Volatility clustering
- ARCH effects
- GARCH models
- Conditional volatility
- Value-at-Risk
- Expected Shortfall
- Risk backtesting
- VIX index
- Market-implied volatility
- Volatility shocks
- Regression analysis
- Market risk

## 📁 Repository Structure

```text
01_market-risk-arima-garch-var-es/
│
├── README.md
├── code/
│   └── arima_garch_var_es_analysis.R
│
├── data/
│   └── README.md
│
├── outputs/
│   ├── figures/
│   └── tables/
│
└── report/
    └── project_slides.pdf
```

## ✅ Results

The project highlights how volatility models can improve the understanding of market risk by capturing time-varying volatility. The VaR and ES backtesting sections allow the model’s risk estimates to be evaluated against realised market movements.

The VIX regression analysis further enriches the study by examining how market-implied volatility and volatility shocks are related to the behaviour of the selected asset. The comparison between the VIX, VaR, Expected Shortfall and conditional volatility provides additional insight into the interaction between forward-looking market stress indicators and model-based risk estimates.

## ⚠️ Limitations

The results depend on the selected asset, historical data period, model specification, distributional assumptions, and the chosen backtesting framework. The relationship between the VIX and the selected asset may also vary across market regimes and should therefore be interpreted with caution.

The analysis is intended for educational and academic purposes only and does not constitute financial or investment advice.
