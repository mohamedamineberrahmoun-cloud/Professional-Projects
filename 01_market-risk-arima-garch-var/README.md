# 📊 Market Risk, Volatility and Market Exposure Modelling: ARIMA-GARCH, VaR, ES, VIX and CAPM Analysis

## 🧭 Project Overview

This project applies financial econometrics techniques to analyse the return dynamics, volatility behaviour and market risk profile of Lockheed Martin Corporation (LMT).

The objective is to model financial returns, estimate conditional volatility, quantify downside risk, and evaluate the robustness of risk measures using statistical backtesting methods. The project combines ARIMA/MA modelling, GARCH-type volatility models, Value-at-Risk (VaR), Expected Shortfall (ES), VIX-based analysis, CAPM regressions and graphical diagnostics commonly used in market risk and financial econometrics.

The analysis is implemented in R and focuses on both statistical modelling and financial interpretation.

## 🎯 Objectives

- Analyse the statistical properties of LMT financial returns and assess whether they exhibit the main stylised facts of financial time series.
- Perform diagnostic tests and transformations to ensure that the return series can be properly modelled.
- Estimate an ARIMA/MA model for the conditional mean of returns.
- Compare several GARCH-type models for conditional volatility, including GARCH, GJR-GARCH, EGARCH and TGARCH specifications.
- Compute dynamic Value-at-Risk and Expected Shortfall measures.
- Backtest VaR estimates using statistical validation tests.
- Backtest Expected Shortfall estimates using appropriate risk validation methods.
- Analyse the relationship between GARCH-based conditional volatility and the VIX index as a proxy for market-implied volatility and market stress.
- Compare the dynamics of the VIX with VaR, Expected Shortfall and conditional volatility.
- Estimate the market exposure of LMT through static and dynamic CAPM analysis.
- Analyse the asymmetric impact of positive and negative shocks on volatility through a News Impact Curve.
- Discuss the strengths, limitations and financial interpretation of the modelling framework.

## 🧪 Methodology

The project follows the following steps:

1. Data collection from financial market sources.
2. Computation of adjusted prices and log-returns.
3. Descriptive statistics and stylised facts analysis.
4. Stationarity, normality and ARCH-effect testing.
5. ARIMA/MA model selection for the conditional mean.
6. Residual diagnostics after mean modelling.
7. Estimation and comparison of GARCH, GJR-GARCH, EGARCH and TGARCH models.
8. Selection of the volatility model using information criteria and residual diagnostics.
9. Estimation of dynamic conditional volatility.
10. Computation of dynamic VaR at 95% and 99% confidence levels.
11. Computation of dynamic Expected Shortfall at 95% and 99% confidence levels.
12. VaR backtesting using Kupiec and Christoffersen tests.
13. Expected Shortfall backtesting using the Acerbi-Szekely approach.
14. Regression analysis between GARCH-based conditional volatility and the VIX index.
15. Comparison between VIX, VaR, ES and conditional volatility dynamics.
16. Static CAPM regression using LMT and S&P 500 excess returns.
17. Dynamic CAPM analysis using a 252-day rolling window.
18. News Impact Curve analysis.
19. Graphical diagnostics and financial interpretation of results.

## 📈 Volatility, VaR and Expected Shortfall Analysis

The core of the project is based on modelling the volatility of LMT returns. After filtering the conditional mean using a time-series model, several GARCH-type specifications are estimated on the residuals.

The volatility modelling framework is used to generate time-varying estimates of risk. By modelling conditional volatility, the analysis translates abstract volatility dynamics into more concrete and interpretable risk measures, such as Value-at-Risk and Expected Shortfall. These measures provide a clearer assessment of potential losses under adverse market conditions and support more robust risk monitoring.

The project evaluates the quality of the risk estimates through statistical backtesting. VaR is assessed using exception-based tests, while Expected Shortfall is evaluated using a dedicated ES backtesting approach.

## 📉 VIX Regression and Risk Measures Analysis

In addition to the ARIMA-GARCH, VaR and Expected Shortfall framework, the project includes a VIX-based analysis. The VIX index is used as a proxy for market-implied volatility and broader market stress.

Rather than only analysing realised volatility, the project compares model-based conditional volatility with a forward-looking market volatility indicator. A regression is performed between the GARCH-based conditional volatility of LMT and the VIX index, with robust inference methods used to improve the reliability of the statistical interpretation.

The VIX analysis focuses on:

- Estimating the relationship between LMT conditional volatility and the VIX.
- Interpreting the sign and magnitude of the regression coefficient.
- Assessing whether market-implied volatility helps explain model-based volatility dynamics.
- Comparing VIX movements with VaR, Expected Shortfall and GARCH-based conditional volatility.
- Understanding how market stress indicators interact with model-based risk estimates.

This section complements the GARCH framework by linking realised return dynamics, conditional volatility, model-based risk measures and forward-looking market-implied volatility.

## 📊 CAPM and Market Exposure Analysis

The project also includes a CAPM-based analysis to estimate the exposure of LMT to broader equity market movements.

A static CAPM regression is performed using LMT excess returns and S&P 500 excess returns. This allows the estimation of the stock’s alpha, beta and explanatory power relative to the market.

In addition, a dynamic CAPM analysis is conducted using a 252-day rolling window. This rolling approach makes it possible to study how LMT’s market beta, alpha and explanatory power evolve over time.

The CAPM section focuses on:

- Estimating LMT’s static market beta.
- Assessing the explanatory power of the market factor.
- Comparing observed returns with CAPM-implied returns.
- Analysing the time variation of beta using rolling regressions.
- Understanding whether LMT’s exposure to the market is stable or regime-dependent.

## ⚡ News Impact Curve

The project includes a News Impact Curve to analyse how positive and negative shocks affect conditional volatility.

This is particularly useful when using asymmetric volatility models such as GJR-GARCH, EGARCH or TGARCH. The objective is to assess whether negative shocks have a stronger impact on volatility than positive shocks of similar magnitude.

The News Impact Curve provides a graphical interpretation of volatility asymmetry and helps connect the statistical model with financial intuition.

## 🛠️ Tools and Libraries

The analysis is conducted in R using packages for financial data collection, time-series modelling, econometric testing, volatility modelling, regression analysis and visualisation.

Main tools include:

- R
- quantmod
- forecast
- tseries
- FinTS
- rugarch
- xts
- zoo
- ggplot2
- lmtest
- sandwich
- moments

Although the analysis could also be implemented in Python, R is particularly well suited for statistical modelling and financial econometrics due to the richness and ergonomics of its specialised packages.

## 🧠 Key Concepts

- Financial returns
- Stylised facts of financial time series
- Stationarity
- Autocorrelation
- ARCH effects
- ARIMA models
- Moving Average models
- GARCH models
- GJR-GARCH
- EGARCH
- TGARCH
- Conditional volatility
- Value-at-Risk
- Expected Shortfall
- Risk backtesting
- Kupiec test
- Christoffersen test
- Acerbi-Szekely ES backtesting
- VIX index
- Market-implied volatility
- Volatility shocks
- CAPM
- Alpha
- Beta
- Rolling regression
- News Impact Curve
- Market risk

## 📁 Repository Structure

```text
01_market-risk-volatility-lmt/
│
├── README.md
├── code/
│   └── market_risk_lmt_analysis.R
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

The project highlights how volatility models can improve the understanding of market risk by capturing time-varying volatility. By modelling conditional volatility, the analysis translates volatility dynamics into more concrete and interpretable risk measures, such as Value-at-Risk and Expected Shortfall, which provide a clearer assessment of potential losses under adverse market conditions.

The VaR and Expected Shortfall backtesting sections evaluate whether the estimated risk measures are consistent with realised market movements. This helps assess the reliability of the model from a risk management perspective.

The VIX regression analysis further enriches the study by examining how market-implied volatility is related to the conditional volatility estimated from the GARCH framework. The comparison between the VIX, VaR, Expected Shortfall and conditional volatility provides additional insight into the interaction between forward-looking market stress indicators and model-based risk estimates.

The CAPM analysis adds a market exposure dimension by estimating both the static and dynamic relationship between LMT and the broader equity market. Finally, the News Impact Curve provides a visual interpretation of how volatility reacts to positive and negative shocks.

## ⚠️ Limitations

The results depend on the selected asset, historical data period, model specification, distributional assumptions and chosen backtesting framework.

The relationship between LMT, the VIX and the broader market may vary across market regimes. Therefore, the results should be interpreted as part of an empirical financial econometrics study rather than as a stable structural relationship.

The analysis is intended for educational and academic purposes only and does not constitute financial or investment advice.
