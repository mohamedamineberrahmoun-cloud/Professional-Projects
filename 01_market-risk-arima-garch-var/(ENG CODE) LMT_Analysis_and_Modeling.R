
# ============================================================================
# 1. PACKAGES AND PARAMETERS
# ============================================================================

library(quantmod)
library(tseries)
library(forecast)
library(FinTS)
library(moments)
library(rugarch)
library(xts)
library(zoo)
library(lmtest)

graphics.off()

Start_date = "2000-01-01"
End_date = "2026-05-01"
Annual_trading_days = 252


# ============================================================================
# 2. DATA IMPORT AND PREPARATION
# ============================================================================

getSymbols("LMT", src = "yahoo", from = Start_date, to = End_date)
getSymbols("^GSPC", src = "yahoo", from = Start_date, to = End_date)
getSymbols("DGS3MO", src = "FRED", from = Start_date, to = End_date)

LMT_prices = Ad(LMT)
SP500_prices = Ad(GSPC)

LMT_returns = na.omit(diff(log(LMT_prices)))
SP500_returns = na.omit(diff(log(SP500_prices)))

Dates = as.Date(index(LMT_returns))
Returns = as.numeric(LMT_returns)

# Convert the annual rate into a daily rate
Risk_free_rate = log(1 + DGS3MO / 100) / 252


# ============================================================================
# 3. DESCRIPTIVE ANALYSIS OF RETURNS
# ============================================================================

cat("\n================ DESCRIPTIVE ANALYSIS ================\n")

print(summary(LMT_returns))
cat("Skewness :", round(skewness(Returns), 4), "\n")
cat("Kurtosis :", round(kurtosis(Returns), 4), "\n")

print(jarque.bera.test(Returns))
print(t.test(Returns, mu = 0))

plot(Dates,Returns,type = "l",col = "grey50",main = "LMT daily returns",
  xlab = "Date",
  ylab = "Log return")


# ============================================================================
# 4. STATIONARITY AND ARCH EFFECTS
# ============================================================================

cat("\n================ STATIONARITY AND ARCH EFFECTS ================\n")

print(adf.test(Returns))
print(kpss.test(Returns))
print(ArchTest(Returns, lags = 10))

ggtsdisplay(Returns, plot.type = "partial", lag.max = 40)

hist(LMT_returns* 100,breaks = 100,main = "Histogram of LMT returns",xlab = "Daily return (%)",col = "grey")
# ============================================================================
# 5. MEAN MODELING: ARMA
# ============================================================================

cat("\n================ ARMA MODEL COMPARISON ================\n")

ARMA_comparison = data.frame()

for (p in 0:2) {
  for (q in 0:2) {

    Temporary_model = Arima(
      Returns,
      order = c(p, 0, q),
      include.mean = TRUE,
      method = "ML"
    )

    Temporary_residuals = na.omit(residuals(Temporary_model))

    Ljung_test = Box.test(
      Temporary_residuals,
      lag = 20,
      type = "Ljung-Box",
      fitdf = p + q
    )

    ARCH_test = ArchTest(Temporary_residuals, lags = 10)
    JB_test = jarque.bera.test(Temporary_residuals)

    ARMA_comparison = rbind(
      ARMA_comparison,
      data.frame(
        Model = paste0("ARMA(", p, ",", q, ")"),
        AIC = AIC(Temporary_model),
        BIC = BIC(Temporary_model),
        Ljung_Box = Ljung_test$p.value,
        ARCH_LM = ARCH_test$p.value,
        Jarque_Bera = JB_test$p.value
      )
    )
  }
}

ARMA_comparison = ARMA_comparison[order(ARMA_comparison$AIC), ]
print(ARMA_comparison, row.names = FALSE)


# ---- Selected mean model: ARMA(0,2) -------------------

ARMA_model = Arima(Returns,order = c(0, 0, 2),include.mean = TRUE,method = "ML")

cat("\n================ SELECTED ARMA(0,2) MODEL ================\n")
print(summary(ARMA_model))
print(coeftest(ARMA_model))

checkresiduals(ARMA_model, lag = 20)

ARMA_residuals = na.omit(residuals(ARMA_model))
GARCH_residuals = ARMA_residuals * 100

print(ArchTest(ARMA_residuals, lags = 10))
print(Box.test(ARMA_residuals^2, lag = 20, type = "Ljung-Box"))
print(jarque.bera.test(ARMA_residuals))

ggtsdisplay(ARMA_residuals^2, plot.type = "partial", lag.max = 40)

ARMA_fitted_values = as.numeric(fitted(ARMA_model))

plot(Dates,Returns,type = "l",col = "grey70",main = "Observed and fitted returns - ARMA(0,2)",
  xlab = "Date",
  ylab = "Return")

lines(Dates, ARMA_fitted_values, col = "red", lwd = 2)

legend("topright",c("Observed returns", "Fitted values"),col = c("grey70", "red"),
  lty = 1,
  bty = "n")


# ============================================================================
# 6. VOLATILITY MODEL COMPARISON
# ============================================================================

cat("\n================ GARCH MODEL COMPARISON ================\n")

GARCH_models = c("sGARCH", "gjrGARCH", "eGARCH", "fGARCH")
Distributions = c("norm", "std")
GARCH_comparison = data.frame()

for (Model_name in GARCH_models) {
  for (Distribution in Distributions) {

    if (Model_name == "fGARCH") {

      Specification = ugarchspec(variance.model = list(  model = "fGARCH",  submodel = "TGARCH",  garchOrder = c(1, 1)),
        mean.model = list(armaOrder = c(0, 0), include.mean = FALSE), distribution.model = Distribution)
      
      Display_name = "TGARCH"

    } else {

      Specification = ugarchspec(variance.model = list( model = Model_name,garchOrder = c(1, 1)),
        mean.model = list(armaOrder = c(0, 0),include.mean = FALSE),distribution.model = Distribution)

      Display_name = Model_name
    }

    Fit = ugarchfit(spec = Specification,data = GARCH_residuals,solver = "hybrid")
    
    Standardized_residuals = na.omit(as.numeric(residuals(Fit, standardize = TRUE)))
    
      Ljung_test = Box.test( Standardized_residuals,lag = 20, type = "Ljung-Box")

      Squared_Ljung_test = Box.test( Standardized_residuals^2, lag = 20, type = "Ljung-Box" )

      ARCH_test = ArchTest(Standardized_residuals, lags = 10)

      GARCH_comparison = rbind(
        GARCH_comparison,
        data.frame(
          Model = Display_name,
          Distribution = Distribution,
          AIC = infocriteria(Fit)[1],
          BIC = infocriteria(Fit)[2],
          Ljung_Box = Ljung_test$p.value,
          Squared_Ljung_Box = Squared_Ljung_test$p.value,
          ARCH_LM = ARCH_test$p.value,
          Convergence = convergence(Fit)
        )
      )
  }
}

GARCH_comparison = GARCH_comparison[order(GARCH_comparison$AIC), ]
print(GARCH_comparison, row.names = FALSE)


# ============================================================================
# 7. FINAL MODEL: TGARCH(1,1) - STUDENT-T
# ============================================================================

TGARCH_specification = ugarchspec(variance.model = list( model = "fGARCH",  submodel = "TGARCH",  garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0),include.mean = FALSE),distribution.model = "std")

TGARCH_model = ugarchfit(spec = TGARCH_specification,data = GARCH_residuals,solver = "hybrid")

cat("\n================ SELECTED TGARCH-STUDENT-T MODEL ================\n")
show(TGARCH_model)

cat("Convergence:", convergence(TGARCH_model), "\n")
cat("Numerical conditioning:", TGARCH_model@fit$condH, "\n")

Standardized_residuals = na.omit(
  as.numeric(residuals(TGARCH_model, standardize = TRUE))
)

ggtsdisplay(Standardized_residuals, plot.type = "partial", lag.max = 40)
ggtsdisplay(Standardized_residuals^2, plot.type = "partial", lag.max = 40)


# ============================================================================
# 8. CONDITIONAL VOLATILITY AND FORECASTING
# ============================================================================

Volatility = as.numeric(sigma(TGARCH_model)) / 100
Volatility_dates = tail(Dates, length(Volatility))

plot(Volatility_dates,Volatility,type = "l",col = "blue",main = "Conditional volatility - TGARCH(1,1) Student-t",
  xlab = "Date",
  ylab = "Daily volatility")


# ---- Returns, conditional mean, and volatility bands

Number_of_observations = min(length(Returns),length(ARMA_fitted_values),length(Volatility))

Aligned_returns = tail(Returns, Number_of_observations)
Aligned_mean = tail(ARMA_fitted_values, Number_of_observations)
Aligned_volatility = tail(Volatility, Number_of_observations)
Aligned_dates = tail(Dates, Number_of_observations)

plot(Aligned_dates,Aligned_returns,type = "l",col = "grey70",main = "Returns and ARMA-TGARCH volatility bands",
  xlab = "Date",
  ylab = "Return")

lines(Aligned_dates, Aligned_mean, col = "red", lwd = 2)
lines(Aligned_dates, Aligned_mean + 2 * Aligned_volatility, col = "blue", lty = 2)
lines(Aligned_dates, Aligned_mean - 2 * Aligned_volatility, col = "blue", lty = 2)

legend(
  "topright",
  c("Returns", "ARMA mean", "TGARCH bands"),
  col = c("grey70", "red", "blue"),
  lty = c(1, 1, 2),
  bty = "n"
)


# ---- Persistence and long-run volatility ----------------

Persistence = as.numeric(persistence(TGARCH_model))

Half_life = log(0.5) / log(Persistence)

Long_run_variance = as.numeric(uncvariance(TGARCH_model))
Daily_long_run_volatility = sqrt(Long_run_variance)
Annual_long_run_volatility = sqrt(Long_run_variance * Annual_trading_days)

cat("\n================ VOLATILITY DYNAMICS ================\n")
cat("Persistence:", round(Persistence, 4), "\n")
cat("Shock half-life :", round(Half_life, 1), "days\n")
cat("Long-run daily volatility :", round(Daily_long_run_volatility, 4), "%\n")
cat("Long-run annualized volatility :", round(Annual_long_run_volatility, 4), "%\n")

# ---- 252-day volatility forecast ---------------

Volatility_forecast = ugarchforecast( TGARCH_model, n.ahead = Annual_trading_days)

Forecast_volatility = as.numeric(sigma(Volatility_forecast)) / 100
Historical_volatility = tail(Volatility, 500)
Historical_length = length(Historical_volatility)

plot( 1:Historical_length, Historical_volatility, type = "l", col = "blue",
  xlim = c(1, Historical_length + Annual_trading_days),
  ylim = range(c(Historical_volatility, Forecast_volatility), na.rm = TRUE),
  main = "Volatility forecast - TGARCH(1,1) Student-t",
  xlab = "Observation",
  ylab = "Daily volatility"
)

lines(
  (Historical_length + 1):(Historical_length + Annual_trading_days),
  Forecast_volatility,
  col = "red",
  lwd = 2
)

abline(v = Historical_length, lty = 2)

legend(
  "topright",
  c("Historical volatility", "Forecast volatility"),
  col = c("blue", "red"),
  lty = 1,
  bty = "n"
)


# ============================================================================
# 9. NEWS IMPACT CURVE
# ============================================================================

Parameters = coef(TGARCH_model)
Omega = Parameters["omega"]
Alpha = Parameters["alpha1"]
Beta = Parameters["beta1"]
Eta = Parameters["eta11"]

Long_run_volatility = sqrt(uncvariance(TGARCH_model))
Shocks = seq(-5, 5, length.out = 500)

Induced_volatility = Omega + Beta * Long_run_volatility + Alpha * Long_run_volatility * (abs(Shocks) - Eta * Shocks)

plot(Shocks,Induced_volatility,type = "l",lwd = 2,
  main = "News Impact Curve - TGARCH(1,1) Student",
  xlab = "Past standardized shock",
  ylab = "Induced conditional volatility (%)"
)

abline(v = 0, lty = 2)


# ============================================================================
# 10. VALUE AT RISK AND EXPECTED SHORTFALL
# ============================================================================

Shape = coef(TGARCH_model)["shape"]

Quantile_95 = qdist("std",p = 0.05,mu = 0,sigma = 1,shape = Shape)

Quantile_99 = qdist("std",p = 0.01,mu = 0,sigma = 1,shape = Shape)

Returns_pct = Returns * 100
ARMA_mean_pct = as.numeric(fitted(ARMA_model)) * 100
TGARCH_volatility_pct = as.numeric(sigma(TGARCH_model))

VaR_sample_size = min(length(Returns_pct),length(ARMA_mean_pct),length(TGARCH_volatility_pct))

Returns_pct = tail(Returns_pct, VaR_sample_size)
ARMA_mean_pct = tail(ARMA_mean_pct, VaR_sample_size)
TGARCH_volatility_pct = tail(TGARCH_volatility_pct, VaR_sample_size)
VaR_dates = tail(Dates, VaR_sample_size)

VaR_95_threshold = ARMA_mean_pct + TGARCH_volatility_pct * Quantile_95
VaR_99_threshold = ARMA_mean_pct + TGARCH_volatility_pct * Quantile_99

Violations_95 = Returns_pct < VaR_95_threshold
Violations_99 = Returns_pct < VaR_99_threshold

plot(VaR_dates,Returns_pct,type = "l",col = "grey",main = "Returns and Value at Risk",
  xlab = "Date",
  ylab = "Return (%)")

lines(VaR_dates, VaR_95_threshold, col = "orange", lwd = 2)
lines(VaR_dates, VaR_99_threshold, col = "red", lwd = 2)
points(VaR_dates[Violations_95], Returns_pct[Violations_95], col = "orange", pch = 19, cex = 0.5)
points(VaR_dates[Violations_99], Returns_pct[Violations_99], col = "red", pch = 19, cex = 0.5)

legend("bottomleft",c("Returns", "VaR 95 %", "VaR 99 %"),col = c("grey", "orange", "red"),
  lty = 1,
  bty = "n"
)

cat("\n================ VaR VIOLATIONS ================\n")
cat("VaR 95%:", sum(Violations_95), "violations out of", VaR_sample_size,
    "- frequency:", round(mean(Violations_95) * 100, 3), "%\n")
cat("VaR 99%:", sum(Violations_99), "violations out of", VaR_sample_size,
    "- frequency:", round(mean(Violations_99) * 100, 3), "%\n")


# ---- Standardized Student-t Expected Shortfall ----------------

Density_95 = ddist("std",y = Quantile_95,mu = 0,sigma = 1,shape = Shape)

Density_99 = ddist("std",y = Quantile_99,mu = 0,sigma = 1,shape = Shape)

Standardized_ES_95 = -Density_95 / 0.05 *(Shape - 2 + Quantile_95^2) / (Shape - 1)

Standardized_ES_99 = -Density_99 / 0.01 *(Shape - 2 + Quantile_99^2) / (Shape - 1)

ES_95 = ARMA_mean_pct + TGARCH_volatility_pct * Standardized_ES_95
ES_99 = ARMA_mean_pct + TGARCH_volatility_pct * Standardized_ES_99

plot(VaR_dates,Returns_pct,type = "l",col = "grey",main = "99% VaR and Expected Shortfall",
  xlab = "Date",
  ylab = "Return (%)")

lines(VaR_dates, VaR_99_threshold, col = "orange", lwd = 2)
lines(VaR_dates, ES_99, col = "red", lwd = 2)

legend("bottomleft",c("Returns", "VaR 99 %", "ES 99 %"),col = c("grey", "orange", "red"),
  lty = 1,
  bty = "n")


# ============================================================================
# 11. BACKTESTING VaR AND EXPECTED SHORTFALL
# ============================================================================

# The functions below directly use log-likelihoods in order
# to avoid the numerical errors encountered with VaRTest over a long sample.

Kupiec_test = function(Violations, Alpha) {

  N = length(Violations)
  X = sum(Violations)
  Frequency = X / N

  Frequency = min(max(Frequency, .Machine$double.eps), 1 - .Machine$double.eps)

  LogL_H0 = (N - X) * log(1 - Alpha) + X * log(Alpha)
  LogL_H1 = (N - X) * log(1 - Frequency) + X * log(Frequency)

  LR = -2 * (LogL_H0 - LogL_H1)
  P_value = 1 - pchisq(LR, df = 1)

  data.frame(
    Observations = N,
    Violations = X,
    Frequency = X / N,
    LR_Kupiec = LR,
    P_value = P_value,
    Decision = ifelse(P_value > 0.05, "VaR accepted", "VaR rejected")
  )
}

Christoffersen_test = function(Violations, Alpha) {

  I = as.integer(Violations)

  N00 = sum(head(I, -1) == 0 & tail(I, -1) == 0)
  N01 = sum(head(I, -1) == 0 & tail(I, -1) == 1)
  N10 = sum(head(I, -1) == 1 & tail(I, -1) == 0)
  N11 = sum(head(I, -1) == 1 & tail(I, -1) == 1)

  Pi = (N01 + N11) / (N00 + N01 + N10 + N11)
  Pi01 = N01 / (N00 + N01)
  Pi11 = N11 / (N10 + N11)

  Pi = min(max(Pi, .Machine$double.eps), 1 - .Machine$double.eps)
  Pi01 = min(max(Pi01, .Machine$double.eps), 1 - .Machine$double.eps)
  Pi11 = min(max(Pi11, .Machine$double.eps), 1 - .Machine$double.eps)

  LogL_independence =
    (N00 + N10) * log(1 - Pi) +
    (N01 + N11) * log(Pi)

  LogL_markov =
    N00 * log(1 - Pi01) +
    N01 * log(Pi01) +
    N10 * log(1 - Pi11) +
    N11 * log(Pi11)

  LR_independence = -2 * (LogL_independence - LogL_markov)
  P_independence = 1 - pchisq(LR_independence, df = 1)

  Kupiec_result = Kupiec_test(Violations, Alpha)
  LR_conditional = Kupiec_result$LR_Kupiec + LR_independence
  P_conditional = 1 - pchisq(LR_conditional, df = 2)

  data.frame(
    LR_Independence = LR_independence,
    P_Independence = P_independence,
    LR_Conditional = LR_conditional,
    P_Conditional = P_conditional,
    Decision = ifelse(
      P_conditional > 0.05,
      "VaR accepted",
      "VaR rejected"
    )
  )
}

cat("\n================ KUPIEC TEST ================\n")
print(Kupiec_test(Violations_95, 0.05))
print(Kupiec_test(Violations_99, 0.01))

cat("\n================ CHRISTOFFERSEN TEST ================\n")
print(Christoffersen_test(Violations_95, 0.05))
print(Christoffersen_test(Violations_99, 0.01))

set.seed(123)

ES_test_95 = ESTest(alpha = 0.05,actual = Returns_pct,ES = ES_95,VaR = VaR_95_threshold,boot = TRUE,n.boot = 1000)

ES_test_99 = ESTest(alpha = 0.01,actual = Returns_pct,ES = ES_99,VaR = VaR_99_threshold,boot = TRUE, n.boot = 1000)

cat("\n================ EXPECTED SHORTFALL TEST ================\n")
print(ES_test_95)
print(ES_test_99)


# ============================================================================
# 12. STATIC AND DYNAMIC CAPM
# ============================================================================

# Align the daily risk-free rate with trading days
CAPM_data = merge(LMT_returns, SP500_returns)
CAPM_data = merge(CAPM_data, Risk_free_rate, join = "left")
CAPM_data[, 3] = na.locf(CAPM_data[, 3], na.rm = FALSE)
CAPM_data = na.omit(CAPM_data)

colnames(CAPM_data) = c("LMT", "Market", "Rf")

CAPM_data$LMT_excess = CAPM_data$LMT - CAPM_data$Rf
CAPM_data$Market_excess = CAPM_data$Market - CAPM_data$Rf

CAPM = lm(LMT_excess ~ Market_excess,data = as.data.frame(CAPM_data))

cat("\n================ STATIC CAPM ================\n")
print(summary(CAPM))

CAPM_alpha = coef(CAPM)[1]
CAPM_beta = coef(CAPM)[2]
CAPM_R2 = summary(CAPM)$r.squared

cat("Alpha:", round(CAPM_alpha, 6),
    "| Beta:", round(CAPM_beta, 4),
    "| R-squared:", round(CAPM_R2 * 100, 2), "%\n")

plot(as.numeric(CAPM_data$Market_excess),as.numeric(CAPM_data$LMT_excess),pch = 16,cex = 0.5,col = "grey60",
  main = "CAPM - LMT and S&P 500",
  xlab = "Market excess return",
  ylab = "LMT excess return"
)

abline(CAPM, col = "red", lwd = 2)


# ---- Dynamic CAPM over a 252-day rolling window ------------

Rolling_CAPM = rollapply(
  CAPM_data[, c("LMT_excess", "Market_excess")],
  width = Annual_trading_days,
  FUN = function(X) {

    X = as.data.frame(X)
    Model = lm(X[, 1] ~ X[, 2])

    c(
      Alpha = unname(coef(Model)[1]),
      Beta = unname(coef(Model)[2]),
      R2 = summary(Model)$r.squared
    )
  },
  by.column = FALSE,
  align = "right"
)

cat("\n================ DYNAMIC CAPM ================\n")
cat("Average beta:", round(mean(Rolling_CAPM$Beta, na.rm = TRUE), 4), "\n")
cat("Minimum beta:", round(min(Rolling_CAPM$Beta, na.rm = TRUE), 4), "\n")
cat("Maximum beta:", round(max(Rolling_CAPM$Beta, na.rm = TRUE), 4), "\n")

plot(Rolling_CAPM$Beta,type = "l",main = "Dynamic beta - 252-day rolling window",
  xlab = "Date",
  ylab = "Beta")

abline(h = 1, col = "red", lty = 2)
abline(h = CAPM_beta, col = "grey", lty = 3)

plot(Rolling_CAPM$Alpha,type = "l",main = "Dynamic alpha - 252-day rolling window",
  xlab = "Date",
  ylab = "Alpha")

abline(h = 0, col = "red", lty = 2)

plot(Rolling_CAPM$R2,type = "l",main = "Dynamic R-squared - 252-day rolling window",
  xlab = "Date",
  ylab = "R²")


# ============================================================================
# 13. COMPARISON OF LMT VOLATILITY WITH THE VIX
# ============================================================================

getSymbols("^VIX",src = "yahoo",from = min(Volatility_dates),to = max(Volatility_dates))

Daily_VIX = Cl(VIX)

# The VIX and LMT volatility are expressed as annualized percentages

Annualized_LMT_volatility = xts(Volatility * sqrt(Annual_trading_days) * 100,order.by = Volatility_dates)

VIX_data = na.omit(merge(Annualized_LMT_volatility, Daily_VIX))

colnames(VIX_data) = c("LMT_volatility", "VIX")

plot(index(VIX_data),as.numeric(VIX_data$LMT_volatility),type = "l",col = "blue",
  main = "Estimated LMT volatility and VIX",
  xlab = "Date",
  ylab = "Annualized volatility (%)")

lines(index(VIX_data),as.numeric(VIX_data$VIX),col = "red")

legend("topright",c("LMT volatility", "VIX"),col = c("blue", "red"),lty = 1,bty = "n")

VIX_regression_data = data.frame(LMT_volatility = as.numeric(VIX_data$LMT_volatility),VIX = as.numeric(VIX_data$VIX))

VIX_model = lm(LMT_volatility ~ VIX,data = VIX_regression_data)

cat("\n================ REGRESSION OF VOLATILITY ON THE VIX ================\n")
print(summary(VIX_model))

VIX_correlation = cor(VIX_regression_data$LMT_volatility,VIX_regression_data$VIX)

cat("Correlation between LMT volatility and the VIX:",round(VIX_correlation, 4), "\n")

plot(VIX_regression_data$VIX,VIX_regression_data$LMT_volatility,
  main = "Relationship between the VIX and LMT volatility",
  xlab = "VIX (%)",
  ylab = "Annualized LMT volatility (%)"
)

abline(VIX_model, col = "red", lwd = 2)




