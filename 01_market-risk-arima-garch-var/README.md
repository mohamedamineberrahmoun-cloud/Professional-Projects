# 📊 Market Risk and Volatility Modelling of Lockheed Martin (LMT)

## 🧭 Project Overview

This project applies financial econometrics techniques to analyse the return dynamics, volatility behaviour and market risk profile of Lockheed Martin Corporation (LMT).

The objective is to model financial returns, estimate conditional volatility, quantify downside risk and evaluate risk measures using statistical backtesting methods. The project combines ARMA modelling, GARCH-type volatility models, Value-at-Risk (VaR), Expected Shortfall (ES), VIX-based analysis, CAPM regressions and graphical diagnostics commonly used in market risk and financial econometrics.

The analysis is implemented in R and focuses on both statistical modelling and financial interpretation. Some sections of the code, particularly those related to visualisation, have been deliberately simplified to improve readability and make the analytical workflow easier to follow.

Initially, the Beamer presentation and the R code will be available in French. Complete English versions will be added within 5 to 10 days.

## 🎯 Objectives

- Analyse the statistical properties and stylised facts of LMT financial returns.
- Model the conditional mean of returns using an ARMA framework.
- Estimate and compare GARCH, GJR-GARCH, EGARCH and TGARCH volatility models.
- Compute dynamic Value-at-Risk and Expected Shortfall measures.
- Backtest VaR and ES using statistical validation methods.
- Analyse the relationship between GARCH-based conditional volatility and the VIX index.
- Estimate LMT’s market exposure through static and rolling CAPM regressions.
- Analyse volatility asymmetry using a News Impact Curve.
- Discuss the strengths, limitations and financial interpretation of the modelling framework.

## 🧪 Methodology

The project follows a complete financial econometrics pipeline:

1. Data collection and logarithmic-return computation.
2. Descriptive statistics and stylised-facts analysis.
3. Stationarity, normality and ARCH-effect testing.
4. ARMA modelling of the conditional mean.
5. Residual diagnostics after conditional mean modelling.
6. Estimation and comparison of GARCH-type volatility models.
7. Conditional volatility analysis and volatility forecasting.
8. News Impact Curve analysis.
9. Dynamic Value-at-Risk and Expected Shortfall estimation.
10. VaR and ES backtesting.
11. Static and rolling CAPM analysis.
12. VIX regression and comparison with model-based conditional volatility.
13. Graphical diagnostics and financial interpretation.

## ⚡ News Impact Curve

The project includes a News Impact Curve to analyse how positive and negative shocks affect conditional volatility.

This analysis is particularly useful for interpreting asymmetric volatility models such as GJR-GARCH, EGARCH and TGARCH. The objective is to assess whether negative shocks have a stronger impact on volatility than positive shocks of a comparable magnitude.    

## 📈 Volatility, VaR and Expected Shortfall Analysis

The core of the project is based on modelling the time-varying volatility of LMT returns. After filtering the conditional mean, several GARCH-type specifications are estimated and compared using information criteria and residual diagnostics.

The selected volatility model is used to compute dynamic VaR and Expected Shortfall estimates at the 95% and 99% confidence levels. By modelling conditional volatility, the analysis translates volatility dynamics into more concrete and interpretable risk measures, providing a clearer assessment of potential losses under adverse market conditions.

VaR is evaluated using the Kupiec and Christoffersen tests, while Expected Shortfall is assessed using the McNeil–Frey backtesting procedure.

## 📊 CAPM and Market Exposure Analysis

The project also includes a CAPM-based analysis to estimate LMT’s exposure to broader equity-market movements.

A static CAPM regression is performed using LMT excess returns and S&P 500 excess returns. This allows the estimation of the stock’s alpha, beta and explanatory power relative to the market.

A rolling 252-trading-day CAPM analysis is also conducted to study how LMT’s market beta and explanatory power evolve over time.

## 📉 VIX Regression and Conditional Volatility Analysis

The project includes a VIX-based analysis to connect model-based volatility with market-implied volatility and broader market stress.

A regression is performed between LMT’s GARCH-based conditional volatility and the VIX index. This helps assess whether periods of broader market stress are associated with higher conditional volatility estimated from LMT returns.

The analysis therefore provides a comparison between a forward-looking market-implied volatility indicator and a model-based estimate derived from historical LMT returns.


## 🛠️ Tools

The analysis is conducted in R using specialised packages for financial data collection, time-series modelling, econometric testing, volatility modelling, regression analysis and visualisation.

The main packages include:

- `quantmod`, `xts`, `zoo`
- `forecast`, `tseries`, `FinTS`
- `rugarch`
- `lmtest`, `moments`
- `ggplot2`, `scales`

## 🧠 Key Concepts

- Financial returns and stylised facts
- Stationarity, autocorrelation and ARCH effects
- ARMA and MA models
- GARCH, GJR-GARCH, EGARCH and TGARCH models
- Student’s t-distributed innovations
- Conditional volatility
- Volatility persistence
- News Impact Curve
- Value-at-Risk and Expected Shortfall
- Kupiec and Christoffersen tests
- McNeil–Frey Expected Shortfall backtesting
- VIX and market-implied volatility
- CAPM, alpha, beta and rolling regressions
- Market risk

## 📁 Repository Structure

This repository is deliberately kept simple, as the main modelling procedures are relatively standard in financial econometrics.

A future update will include a more detailed explanation of the statistical tests used to validate Value-at-Risk and Expected Shortfall estimates. The objective will be to present these methods in an intuitive and accessible way, without relying on unnecessarily complex mathematical developments, so that the project can be understood by readers with different technical backgrounds.

```text
├── 01_market-risk-arima-garch-var/
│   ├── LMT_Analysis_and_Modelling_EN.R
│   ├── LMT_Results_Presentation_EN.pdf
│   ├── Analyse_et_Modelisation_LMT_FR.R
│   ├── Presentation_Resultats_LMT_FR.pdf
│   └── README.md
```

✅ Main Results

The analysis shows that LMT returns exhibit several stylised facts commonly observed in financial time series, including non-normality, excess kurtosis and volatility clustering.

Among the tested volatility models, the TGARCH(1,1) model with Student’s t-distributed innovations provides the best overall fit according to the information criteria and residual diagnostics considered in the analysis.

The model captures persistent and asymmetric volatility dynamics. The estimated asymmetry indicates that negative shocks have a stronger impact on future volatility than positive shocks of a comparable magnitude.

The dynamic VaR and Expected Shortfall estimates provide interpretable measures of downside risk. The Kupiec and Christoffersen tests do not reject the adequacy of the selected VaR estimates at conventional significance levels. The McNeil–Frey backtesting results also provide no statistical evidence against the adequacy of the corresponding Expected Shortfall estimates.

The VIX analysis reveals a strong positive association between market-implied volatility and LMT’s estimated conditional volatility.

The CAPM analysis suggests that LMT has historically exhibited a relatively defensive profile compared with the broader equity market. However, the rolling beta analysis shows that its market exposure varies over time.

Overall, the results suggest that LMT has a relatively defensive market profile while remaining sensitive to broader market stress and volatility shocks.

⚠️ Limitations

The results depend on the selected asset, historical period, model specification, distributional assumptions and backtesting framework.

The relationship between LMT, the VIX and the broader market may vary across market regimes. The VIX regression should therefore be interpreted as an empirical association rather than as evidence of a causal relationship.

Historical and geopolitical events may help interpret certain volatility peaks, but these events are not explicitly included as explanatory variables in the model.

The results should therefore be interpreted as part of an empirical financial econometrics study rather than as evidence of stable structural relationships.

This project is intended for educational and academic purposes only and does not constitute financial or investment advice.
