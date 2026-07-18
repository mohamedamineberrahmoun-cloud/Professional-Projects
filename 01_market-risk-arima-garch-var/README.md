# 📊 Market Risk and Volatility Modelling of Lockheed Martin (LMT)

## 🧭 Project Overview

This project applies financial econometrics techniques to analyse the return dynamics, volatility behaviour and market risk profile of Lockheed Martin Corporation (LMT).

The objective is to model financial returns, estimate conditional volatility, quantify downside risk, and evaluate risk measures using statistical backtesting methods. The project combines ARIMA/MA modelling, GARCH-type volatility models, Value-at-Risk (VaR), Expected Shortfall (ES), VIX-based analysis, CAPM regressions and graphical diagnostics commonly used in market risk and financial econometrics.

The analysis is implemented in R and focuses on both statistical modelling and financial interpretation.

## 🎯 Objectives

- Analyse the statistical properties and stylised facts of LMT financial returns.
- Model the conditional mean of returns using an ARIMA/MA framework.
- Estimate and compare GARCH, GJR-GARCH, EGARCH and TGARCH volatility models.
- Compute dynamic Value-at-Risk and Expected Shortfall measures.
- Backtest VaR and ES using statistical validation methods.
- Analyse the relationship between GARCH-based conditional volatility and the VIX index.
- Compare the dynamics of VIX, VaR, Expected Shortfall and conditional volatility.
- Estimate LMT’s market exposure through static and dynamic CAPM analysis.
- Analyse volatility asymmetry through a News Impact Curve.
- Discuss the strengths, limitations and financial interpretation of the modelling framework.

## 🧪 Methodology

The project follows a complete financial econometrics pipeline:

1. Data collection and log-return computation.
2. Descriptive statistics and stylised facts analysis.
3. Stationarity, normality and ARCH-effect testing.
4. ARIMA/MA modelling of the conditional mean.
5. Residual diagnostics after mean modelling.
6. Estimation and comparison of GARCH-type volatility models.
7. Dynamic VaR and Expected Shortfall estimation.
8. VaR and ES backtesting.
9. VIX regression and comparison with model-based risk measures.
10. Static and rolling CAPM analysis.
11. News Impact Curve analysis.
12. Graphical diagnostics and financial interpretation.

## 📈 Volatility, VaR and Expected Shortfall Analysis

The core of the project is based on modelling the time-varying volatility of LMT returns. After filtering the conditional mean, several GARCH-type specifications are estimated and compared using information criteria and residual diagnostics.

The selected volatility model is used to compute dynamic VaR and Expected Shortfall at 95% and 99% confidence levels. By modelling conditional volatility, the analysis translates volatility dynamics into more concrete and interpretable risk measures, which provide a clearer assessment of potential losses under adverse market conditions.

VaR is evaluated using Kupiec and Christoffersen tests, while Expected Shortfall is assessed using the Acerbi-Szekely backtesting approach.

## 📉 VIX Regression and Risk Measures Analysis

The project includes a VIX-based analysis to connect model-based volatility with market-implied volatility and broader market stress.

A regression is performed between LMT’s GARCH-based conditional volatility and the VIX index. This helps assess whether broader market stress is reflected in the conditional volatility estimated from LMT returns.

The analysis also compares the dynamics of the VIX with VaR, Expected Shortfall and conditional volatility to better understand the interaction between forward-looking market stress indicators and model-based risk estimates.

## 📊 CAPM and Market Exposure Analysis

The project also includes a CAPM-based analysis to estimate the exposure of LMT to broader equity market movements.

A static CAPM regression is performed using LMT excess returns and S&P 500 excess returns. This allows the estimation of the stock’s alpha, beta and explanatory power relative to the market.

A rolling 252-day CAPM analysis is also conducted to study how LMT’s market beta and explanatory power evolve over time.

## ⚡ News Impact Curve

The project includes a News Impact Curve to analyse how positive and negative shocks affect conditional volatility.

This is particularly useful for interpreting asymmetric volatility models such as GJR-GARCH, EGARCH and TGARCH. The objective is to assess whether negative shocks have a stronger impact on volatility than positive shocks of similar magnitude.

## 🛠️ Tools

The analysis is conducted in R using specialised packages for financial data collection, time-series modelling, econometric testing, volatility modelling, regression analysis and visualisation.

Main packages include:

- `quantmod`, `xts`, `zoo`
- `forecast`, `tseries`, `FinTS`
- `rugarch`
- `ggplot2`
- `lmtest`, `sandwich`, `moments`

## 🧠 Key Concepts

- Financial returns and stylised facts
- Stationarity, autocorrelation and ARCH effects
- ARIMA / MA models
- GARCH, GJR-GARCH, EGARCH and TGARCH models
- Conditional volatility
- Value-at-Risk and Expected Shortfall
- Kupiec and Christoffersen tests
- Acerbi-Szekely ES backtesting
- VIX and market-implied volatility
- CAPM, alpha, beta and rolling regressions
- News Impact Curve
- Market risk

## 📁 Repository Structure

this repositery will be kept simple since the manipulations are quite usual in  but in the near future a more complete approach to explaining the statistical test regarding the validation of the expected shortfall and the Var exptmation will be added to this repository to provide somme clarity in a non pure mathematical way to suite various reading profiles

```text
01_market-risk-volatility-lmt/
│
├── README.md
├── code/
│   └── market_risk_lmt_analysis.R
└── report/
    └── project_slides.pdf
```

## ✅ Main Results

The analysis shows that LMT returns exhibit key stylised facts of financial time series, including non-normality, leptokurtosis and volatility clustering.

Among the tested volatility models, the TGARCH(1,1) model with Student distribution provides the best fit according to information criteria and residual diagnostics. The model captures persistent and asymmetric volatility dynamics, with negative shocks having a stronger impact on future volatility than positive shocks.

The dynamic VaR and Expected Shortfall measures provide interpretable downside risk estimates. The backtesting results indicate that the risk measures are statistically consistent with realised market movements.

The VIX analysis shows a strong positive relationship between market-implied volatility and LMT’s conditional volatility. The CAPM section highlights LMT’s defensive profile relative to the broader equity market, while the rolling beta analysis shows that market exposure varies over time.

Overall, the project shows that LMT is a defensive asset but remains sensitive to market stress, geopolitical events and volatility shocks.

## ⚠️ Limitations

The results depend on the selected asset, historical period, model specification, distributional assumptions and backtesting framework.

The relationship between LMT, the VIX and the broader market may vary across market regimes. Therefore, the results should be interpreted as part of an empirical financial econometrics study rather than as a stable structural relationship.

This project is intended for educational and academic purposes only and does not constitute financial or investment advice.
