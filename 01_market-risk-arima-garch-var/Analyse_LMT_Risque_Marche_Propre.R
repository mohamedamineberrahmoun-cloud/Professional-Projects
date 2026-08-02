
# ============================================================================
# 1. PACKAGES ET PARAMÈTRES
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

Date_debut = "2000-01-01"
Date_fin = "2026-05-01"
Nombre_jours_annuel = 252


# ============================================================================
# 2. IMPORTATION ET PRÉPARATION DES DONNÉES
# ============================================================================

getSymbols("LMT", src = "yahoo", from = Date_debut, to = Date_fin)
getSymbols("^GSPC", src = "yahoo", from = Date_debut, to = Date_fin)
getSymbols("DTB3", src = "FRED", from = Date_debut, to = Date_fin)

Prix_LMT = Ad(LMT)
Prix_SP500 = Ad(GSPC)

Rendements_LMT = na.omit(diff(log(Prix_LMT)))
Rendements_SP500 = na.omit(diff(log(Prix_SP500)))

Dates = as.Date(index(Rendements_LMT))
Rendements = as.numeric(Rendements_LMT)

# Conversion du taux annuel en taux journalier
Taux_sans_risque = (1 + DTB3 / 100)^(1 / Nombre_jours_annuel) - 1


# ============================================================================
# 3. ANALYSE DESCRIPTIVE DES RENDEMENTS
# ============================================================================

cat("\n================ ANALYSE DESCRIPTIVE ================\n")

print(summary(Rendements_LMT))
cat("Skewness :", round(skewness(Rendements), 4), "\n")
cat("Kurtosis :", round(kurtosis(Rendements), 4), "\n")

print(jarque.bera.test(Rendements))
print(t.test(Rendements, mu = 0))

plot(Dates,Rendements,type = "l",col = "grey50",main = "Rendements journaliers de LMT",
  xlab = "Date",
  ylab = "Rendement logarithmique")


# ============================================================================
# 4. STATIONNARITÉ ET EFFETS ARCH
# ============================================================================

cat("\n================ STATIONNARITÉ ET EFFETS ARCH ================\n")

print(adf.test(Rendements))
print(kpss.test(Rendements))
print(ArchTest(Rendements, lags = 10))

ggtsdisplay(Rendements, plot.type = "partial", lag.max = 40)

hist(Rendements_LMT* 100,breaks = 100,main = "Histogramme des rendements de LMT",xlab = "Rendement journalier (%)",col = "grey")
# ============================================================================
# 5. MODÉLISATION DE LA MOYENNE : ARMA
# ============================================================================

cat("\n================ COMPARAISON DES MODÈLES ARMA ================\n")

Comparaison_ARMA = data.frame()

for (p in 0:2) {
  for (q in 0:2) {

    Modele_temporaire = Arima(
      Rendements,
      order = c(p, 0, q),
      include.mean = TRUE,
      method = "ML"
    )

    Residus_temporaires = na.omit(residuals(Modele_temporaire))

    Test_Ljung = Box.test(
      Residus_temporaires,
      lag = 20,
      type = "Ljung-Box",
      fitdf = p + q
    )

    Test_ARCH = ArchTest(Residus_temporaires, lags = 10)
    Test_JB = jarque.bera.test(Residus_temporaires)

    Comparaison_ARMA = rbind(
      Comparaison_ARMA,
      data.frame(
        Modele = paste0("ARMA(", p, ",", q, ")"),
        AIC = AIC(Modele_temporaire),
        BIC = BIC(Modele_temporaire),
        Ljung_Box = Test_Ljung$p.value,
        ARCH_LM = Test_ARCH$p.value,
        Jarque_Bera = Test_JB$p.value
      )
    )
  }
}

Comparaison_ARMA = Comparaison_ARMA[order(Comparaison_ARMA$AIC), ]
print(Comparaison_ARMA, row.names = FALSE)


# ---- Modèle de moyenne retenu : ARMA(0,2) -------------------

Modele_ARMA = Arima(Rendements,order = c(0, 0, 2),include.mean = TRUE,method = "ML")

cat("\n================ MODÈLE ARMA(0,2) RETENU ================\n")
print(summary(Modele_ARMA))
print(coeftest(Modele_ARMA))

checkresiduals(Modele_ARMA, lag = 20)

Residus_ARMA = na.omit(residuals(Modele_ARMA))
Residus_GARCH = Residus_ARMA * 100

print(ArchTest(Residus_ARMA, lags = 10))
print(Box.test(Residus_ARMA^2, lag = 20, type = "Ljung-Box"))
print(jarque.bera.test(Residus_ARMA))

ggtsdisplay(Residus_ARMA^2, plot.type = "partial", lag.max = 40)

Valeurs_ajustees_ARMA = as.numeric(fitted(Modele_ARMA))

plot(Dates,Rendements,type = "l",col = "grey70",main = "Rendements observés et ajustés - ARMA(0,2)",
  xlab = "Date",
  ylab = "Rendement")

lines(Dates, Valeurs_ajustees_ARMA, col = "red", lwd = 2)

legend("topright",c("Rendements observés", "Valeurs ajustées"),col = c("grey70", "red"),
  lty = 1,
  bty = "n")


# ============================================================================
# 6. COMPARAISON DES MODÈLES DE VOLATILITÉ
# ============================================================================

cat("\n================ COMPARAISON DES MODÈLES GARCH ================\n")

Modeles_GARCH = c("sGARCH", "gjrGARCH", "eGARCH", "fGARCH")
Distributions = c("norm", "std")
Comparaison_GARCH = data.frame()

for (Nom_modele in Modeles_GARCH) {
  for (Distribution in Distributions) {

    if (Nom_modele == "fGARCH") {

      Specification = ugarchspec(variance.model = list(  model = "fGARCH",  submodel = "TGARCH",  garchOrder = c(1, 1)),
        mean.model = list(armaOrder = c(0, 0), include.mean = FALSE), distribution.model = Distribution)
      
      Nom_affiche = "TGARCH"

    } else {

      Specification = ugarchspec(variance.model = list( model = Nom_modele,garchOrder = c(1, 1)),
        mean.model = list(armaOrder = c(0, 0),include.mean = FALSE),distribution.model = Distribution)

      Nom_affiche = Nom_modele
    }

    Ajustement = ugarchfit(spec = Specification,data = Residus_GARCH,solver = "hybrid")
    
    Residus_standardises=na.omit(as.numeric(residuals(Ajustement, standardize = TRUE)))
    
      Test_Ljung = Box.test( Residus_standardises,lag = 20, type = "Ljung-Box")

      Test_Ljung_carres = Box.test( Residus_standardises^2, lag = 20, type = "Ljung-Box" )

      Test_ARCH = ArchTest(Residus_standardises, lags = 10)

      Comparaison_GARCH = rbind(
        Comparaison_GARCH,
        data.frame(
          Modele = Nom_affiche,
          Distribution = Distribution,
          AIC = infocriteria(Ajustement)[1],
          BIC = infocriteria(Ajustement)[2],
          Ljung_Box = Test_Ljung$p.value,
          Ljung_Box_Carres = Test_Ljung_carres$p.value,
          ARCH_LM = Test_ARCH$p.value,
          Convergence = convergence(Ajustement)
        )
      )
  }
}

Comparaison_GARCH = Comparaison_GARCH[order(Comparaison_GARCH$AIC), ]
print(Comparaison_GARCH, row.names = FALSE)


# ============================================================================
# 7. MODÈLE FINAL : TGARCH(1,1) - STUDENT
# ============================================================================

Specification_TGARCH = ugarchspec(variance.model = list( model = "fGARCH",  submodel = "TGARCH",  garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0),include.mean = FALSE),distribution.model = "std")

Modele_TGARCH = ugarchfit(spec = Specification_TGARCH,data = Residus_GARCH,solver = "hybrid")

cat("\n================ MODÈLE TGARCH-STUDENT RETENU ================\n")
show(Modele_TGARCH)

cat("Convergence :", convergence(Modele_TGARCH), "\n")
cat("Conditionnement numérique :", Modele_TGARCH@fit$condH, "\n")

Residus_standardises = na.omit(
  as.numeric(residuals(Modele_TGARCH, standardize = TRUE))
)

ggtsdisplay(Residus_standardises, plot.type = "partial", lag.max = 40)
ggtsdisplay(Residus_standardises^2, plot.type = "partial", lag.max = 40)


# ============================================================================
# 8. VOLATILITÉ CONDITIONNELLE ET PRÉVISION
# ============================================================================

Volatilite = as.numeric(sigma(Modele_TGARCH)) / 100
Dates_volatilite = tail(Dates, length(Volatilite))

plot(Dates_volatilite,Volatilite,type = "l",col = "blue",main = "Volatilité conditionnelle - TGARCH(1,1) Student",
  xlab = "Date",
  ylab = "Volatilité journalière")


# ---- Rendements, moyenne conditionnelle et bandes de volatilité

Nombre_observations = min(length(Rendements),length(Valeurs_ajustees_ARMA),length(Volatilite))

Rendements_alignes = tail(Rendements, Nombre_observations)
Moyenne_alignee = tail(Valeurs_ajustees_ARMA, Nombre_observations)
Volatilite_alignee = tail(Volatilite, Nombre_observations)
Dates_alignees = tail(Dates, Nombre_observations)

plot(Dates_alignees,Rendements_alignes,type = "l",col = "grey70",main = "Rendements et bandes de volatilité ARMA-TGARCH",
  xlab = "Date",
  ylab = "Rendement")

lines(Dates_alignees, Moyenne_alignee, col = "red", lwd = 2)
lines(Dates_alignees, Moyenne_alignee + 2 * Volatilite_alignee, col = "blue", lty = 2)
lines(Dates_alignees, Moyenne_alignee - 2 * Volatilite_alignee, col = "blue", lty = 2)

legend(
  "topright",
  c("Rendements", "Moyenne ARMA", "Bandes TGARCH"),
  col = c("grey70", "red", "blue"),
  lty = c(1, 1, 2),
  bty = "n"
)


# ---- Persistance et volatilité de long terme ----------------

Persistance = as.numeric(persistence(Modele_TGARCH))

Demi_vie = log(0.5) / log(Persistance)

Variance_long_terme = as.numeric(uncvariance(Modele_TGARCH))
Volatilite_LT_journaliere = sqrt(Variance_long_terme)
Volatilite_LT_annuelle = sqrt(Variance_long_terme * Nombre_jours_annuel)

cat("\n================ DYNAMIQUE DE VOLATILITÉ ================\n")
cat("Persistance :", round(Persistance, 4), "\n")
cat("Demi-vie des chocs :", round(Demi_vie, 1), "jours\n")
cat("Volatilité journalière de long terme :", round(Volatilite_LT_journaliere, 4), "%\n")
cat("Volatilité annualisée de long terme :", round(Volatilite_LT_annuelle, 4), "%\n")

# ---- Prévision de la volatilité sur 252 jours ---------------

Prevision_volatilite = ugarchforecast( Modele_TGARCH, n.ahead = Nombre_jours_annuel)

Volatilite_prevue = as.numeric(sigma(Prevision_volatilite)) / 100
Volatilite_historique = tail(Volatilite, 500)
Nombre_historique = length(Volatilite_historique)

plot( 1:Nombre_historique, Volatilite_historique, type = "l", col = "blue",
  xlim = c(1, Nombre_historique + Nombre_jours_annuel),
  ylim = range(c(Volatilite_historique, Volatilite_prevue), na.rm = TRUE),
  main = "Prévision de la volatilité - TGARCH(1,1) Student",
  xlab = "Observation",
  ylab = "Volatilité journalière"
)

lines(
  (Nombre_historique + 1):(Nombre_historique + Nombre_jours_annuel),
  Volatilite_prevue,
  col = "red",
  lwd = 2
)

abline(v = Nombre_historique, lty = 2)

legend(
  "topright",
  c("Volatilité historique", "Volatilité prévue"),
  col = c("blue", "red"),
  lty = 1,
  bty = "n"
)


# ============================================================================
# 9. NEWS IMPACT CURVE
# ============================================================================

Parametres = coef(Modele_TGARCH)
Omega = Parametres["omega"]
Alpha = Parametres["alpha1"]
Beta = Parametres["beta1"]
Eta = Parametres["eta11"]

Volatilite_long_terme = sqrt(uncvariance(Modele_TGARCH))
Chocs = seq(-5, 5, length.out = 500)

Volatilite_induite =Omega +Beta * Volatilite_long_terme +Alpha * Volatilite_long_terme * (abs(Chocs) - Eta * Chocs)

plot(Chocs,Volatilite_induite,type = "l",lwd = 2,
  main = "News Impact Curve - TGARCH(1,1) Student",
  xlab = "Choc standardisé passé",
  ylab = "Volatilité conditionnelle induite (%)"
)

abline(v = 0, lty = 2)


# ============================================================================
# 10. VALUE AT RISK ET EXPECTED SHORTFALL
# ============================================================================

Shape = coef(Modele_TGARCH)["shape"]

Quantile_95 = qdist("std",p = 0.05,mu = 0,sigma = 1,shape = Shape)

Quantile_99 = qdist("std",p = 0.01,mu = 0,sigma = 1,shape = Shape)

Rendements_pct = Rendements * 100
Moyenne_ARMA_pct = as.numeric(fitted(Modele_ARMA)) * 100
Volatilite_TGARCH_pct = as.numeric(sigma(Modele_TGARCH))

Nombre_VaR = min(length(Rendements_pct),length(Moyenne_ARMA_pct),length(Volatilite_TGARCH_pct))

Rendements_pct = tail(Rendements_pct, Nombre_VaR)
Moyenne_ARMA_pct = tail(Moyenne_ARMA_pct, Nombre_VaR)
Volatilite_TGARCH_pct = tail(Volatilite_TGARCH_pct, Nombre_VaR)
Dates_VaR = tail(Dates, Nombre_VaR)

Seuil_VaR_95 = Moyenne_ARMA_pct + Volatilite_TGARCH_pct * Quantile_95
Seuil_VaR_99 = Moyenne_ARMA_pct + Volatilite_TGARCH_pct * Quantile_99

Violations_95 = Rendements_pct < Seuil_VaR_95
Violations_99 = Rendements_pct < Seuil_VaR_99

plot(Dates_VaR,Rendements_pct,type = "l",col = "grey",main = "Rendements et Value at Risk",
  xlab = "Date",
  ylab = "Rendement (%)")

lines(Dates_VaR, Seuil_VaR_95, col = "orange", lwd = 2)
lines(Dates_VaR, Seuil_VaR_99, col = "red", lwd = 2)
points(Dates_VaR[Violations_95], Rendements_pct[Violations_95], col = "orange", pch = 19, cex = 0.5)
points(Dates_VaR[Violations_99], Rendements_pct[Violations_99], col = "red", pch = 19, cex = 0.5)

legend("bottomleft",c("Rendements", "VaR 95 %", "VaR 99 %"),col = c("grey", "orange", "red"),
  lty = 1,
  bty = "n"
)

cat("\n================ VIOLATIONS DE LA VaR ================\n")
cat("VaR 95 % :", sum(Violations_95), "violations sur", Nombre_VaR,
    "- fréquence :", round(mean(Violations_95) * 100, 3), "%\n")
cat("VaR 99 % :", sum(Violations_99), "violations sur", Nombre_VaR,
    "- fréquence :", round(mean(Violations_99) * 100, 3), "%\n")


# ---- Expected Shortfall Student standardisée ----------------

Densite_95 = ddist("std",y = Quantile_95,mu = 0,sigma = 1,shape = Shape)

Densite_99 = ddist("std",y = Quantile_99,mu = 0,sigma = 1,shape = Shape)

ES_standardisee_95 =-Densite_95 / 0.05 *(Shape - 2 + Quantile_95^2) / (Shape - 1)

ES_standardisee_99 =-Densite_99 / 0.01 *(Shape - 2 + Quantile_99^2) / (Shape - 1)

ES_95 = Moyenne_ARMA_pct + Volatilite_TGARCH_pct * ES_standardisee_95
ES_99 = Moyenne_ARMA_pct + Volatilite_TGARCH_pct * ES_standardisee_99

plot(Dates_VaR,Rendements_pct,type = "l",col = "grey",main = "VaR et Expected Shortfall à 99 %",
  xlab = "Date",
  ylab = "Rendement (%)")

lines(Dates_VaR, Seuil_VaR_99, col = "orange", lwd = 2)
lines(Dates_VaR, ES_99, col = "red", lwd = 2)

legend("bottomleft",c("Rendements", "VaR 99 %", "ES 99 %"),col = c("grey", "orange", "red"),
  lty = 1,
  bty = "n")


# ============================================================================
# 11. BACKTESTING DE LA VaR ET DE L'EXPECTED SHORTFALL
# ============================================================================

# Les fonctions ci-dessous utilisent directement les log-vraisemblances afin
# d'éviter les erreurs numériques rencontrées par VaRTest sur un long historique.

Test_Kupiec = function(Violations, Alpha) {

  N = length(Violations)
  X = sum(Violations)
  Frequence = X / N

  Frequence = min(max(Frequence, .Machine$double.eps), 1 - .Machine$double.eps)

  LogL_H0 = (N - X) * log(1 - Alpha) + X * log(Alpha)
  LogL_H1 = (N - X) * log(1 - Frequence) + X * log(Frequence)

  LR = -2 * (LogL_H0 - LogL_H1)
  P_value = 1 - pchisq(LR, df = 1)

  data.frame(
    Observations = N,
    Violations = X,
    Frequence = X / N,
    LR_Kupiec = LR,
    P_value = P_value,
    Decision = ifelse(P_value > 0.05, "VaR acceptée", "VaR rejetée")
  )
}

Test_Christoffersen = function(Violations, Alpha) {

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

  LogL_independance =
    (N00 + N10) * log(1 - Pi) +
    (N01 + N11) * log(Pi)

  LogL_markov =
    N00 * log(1 - Pi01) +
    N01 * log(Pi01) +
    N10 * log(1 - Pi11) +
    N11 * log(Pi11)

  LR_independance = -2 * (LogL_independance - LogL_markov)
  P_independance = 1 - pchisq(LR_independance, df = 1)

  Resultat_Kupiec = Test_Kupiec(Violations, Alpha)
  LR_conditionnel = Resultat_Kupiec$LR_Kupiec + LR_independance
  P_conditionnel = 1 - pchisq(LR_conditionnel, df = 2)

  data.frame(
    LR_Independance = LR_independance,
    P_Independance = P_independance,
    LR_Conditionnel = LR_conditionnel,
    P_Conditionnel = P_conditionnel,
    Decision = ifelse(
      P_conditionnel > 0.05,
      "VaR acceptée",
      "VaR rejetée"
    )
  )
}

cat("\n================ TEST DE KUPIEC ================\n")
print(Test_Kupiec(Violations_95, 0.05))
print(Test_Kupiec(Violations_99, 0.01))

cat("\n================ TEST DE CHRISTOFFERSEN ================\n")
print(Test_Christoffersen(Violations_95, 0.05))
print(Test_Christoffersen(Violations_99, 0.01))

set.seed(123)

Test_ES_95 = ESTest(alpha = 0.05,actual = Rendements_pct,ES = ES_95,VaR = Seuil_VaR_95,boot = TRUE,n.boot = 1000)

Test_ES_99 = ESTest(alpha = 0.01,actual = Rendements_pct,ES = ES_99,VaR = Seuil_VaR_99,boot = TRUE, n.boot = 1000)

cat("\n================ TEST DE L'EXPECTED SHORTFALL ================\n")
print(Test_ES_95)
print(Test_ES_99)


# ============================================================================
# 12. CAPM STATIQUE ET DYNAMIQUE
# ============================================================================

# Alignement journalier du taux sans risque avec les jours de cotation
Donnees_CAPM = merge(Rendements_LMT, Rendements_SP500)
Donnees_CAPM = merge(Donnees_CAPM, Taux_sans_risque, join = "left")
Donnees_CAPM[, 3] = na.locf(Donnees_CAPM[, 3], na.rm = FALSE)
Donnees_CAPM = na.omit(Donnees_CAPM)

colnames(Donnees_CAPM) = c("LMT", "Marche", "Rf")

Donnees_CAPM$Exces_LMT = Donnees_CAPM$LMT - Donnees_CAPM$Rf
Donnees_CAPM$Exces_Marche = Donnees_CAPM$Marche - Donnees_CAPM$Rf

CAPM = lm(Exces_LMT ~ Exces_Marche,data = as.data.frame(Donnees_CAPM))

cat("\n================ CAPM STATIQUE ================\n")
print(summary(CAPM))

Alpha_CAPM = coef(CAPM)[1]
Beta_CAPM = coef(CAPM)[2]
R2_CAPM = summary(CAPM)$r.squared

cat("Alpha :", round(Alpha_CAPM, 6),
    "| Beta :", round(Beta_CAPM, 4),
    "| R² :", round(R2_CAPM * 100, 2), "%\n")

plot(as.numeric(Donnees_CAPM$Exces_Marche),as.numeric(Donnees_CAPM$Exces_LMT),pch = 16,cex = 0.5,col = "grey60",
  main = "CAPM - LMT et S&P 500",
  xlab = "Excès de rendement du marché",
  ylab = "Excès de rendement de LMT"
)

abline(CAPM, col = "red", lwd = 2)


# ---- CAPM dynamique sur une fenêtre de 252 jours ------------

CAPM_rolling = rollapply(
  Donnees_CAPM[, c("Exces_LMT", "Exces_Marche")],
  width = Nombre_jours_annuel,
  FUN = function(X) {

    X = as.data.frame(X)
    Modele = lm(X[, 1] ~ X[, 2])

    c(
      Alpha = unname(coef(Modele)[1]),
      Beta = unname(coef(Modele)[2]),
      R2 = summary(Modele)$r.squared
    )
  },
  by.column = FALSE,
  align = "right"
)

cat("\n================ CAPM DYNAMIQUE ================\n")
cat("Beta moyen :", round(mean(CAPM_rolling$Beta, na.rm = TRUE), 4), "\n")
cat("Beta minimum :", round(min(CAPM_rolling$Beta, na.rm = TRUE), 4), "\n")
cat("Beta maximum :", round(max(CAPM_rolling$Beta, na.rm = TRUE), 4), "\n")

plot(CAPM_rolling$Beta,type = "l",main = "Bêta dynamique - fenêtre de 252 jours",
  xlab = "Date",
  ylab = "Bêta")

abline(h = 1, col = "red", lty = 2)
abline(h = Beta_CAPM, col = "grey", lty = 3)

plot(CAPM_rolling$Alpha,type = "l",main = "Alpha dynamique - fenêtre de 252 jours",
  xlab = "Date",
  ylab = "Alpha")

abline(h = 0, col = "red", lty = 2)

plot(CAPM_rolling$R2,type = "l",main = "R² dynamique - fenêtre de 252 jours",
  xlab = "Date",
  ylab = "R²")


# ============================================================================
# 13. COMPARAISON DE LA VOLATILITÉ DE LMT AU VIX
# ============================================================================

getSymbols("^VIX",src = "yahoo",from = min(Dates_volatilite),to = max(Dates_volatilite))

VIX_journalier = Cl(VIX)

# Le VIX et la volatilité de LMT sont exprimés en pourcentage annualisé

Volatilite_LMT_annuelle = xts(Volatilite * sqrt(Nombre_jours_annuel) * 100,order.by = Dates_volatilite)

Donnees_VIX = na.omit(merge(Volatilite_LMT_annuelle, VIX_journalier))

colnames(Donnees_VIX) = c("Volatilite_LMT", "VIX")

plot(index(Donnees_VIX),as.numeric(Donnees_VIX$Volatilite_LMT),type = "l",col = "blue",
  main = "Volatilité estimée de LMT et VIX",
  xlab = "Date",
  ylab = "Volatilité annualisée (%)")

lines(index(Donnees_VIX),as.numeric(Donnees_VIX$VIX),col = "red")

legend("topright",c("Volatilité LMT", "VIX"),col = c("blue", "red"),lty = 1,bty = "n")

Donnees_regression_VIX = data.frame(Volatilite_LMT = as.numeric(Donnees_VIX$Volatilite_LMT),VIX = as.numeric(Donnees_VIX$VIX))

Modele_VIX = lm(Volatilite_LMT ~ VIX,data = Donnees_regression_VIX)

cat("\n================ RÉGRESSION DE LA VOLATILITÉ SUR LE VIX ================\n")
print(summary(Modele_VIX))

Correlation_VIX = cor(Donnees_regression_VIX$Volatilite_LMT,Donnees_regression_VIX$VIX)

cat("Corrélation entre la volatilité de LMT et le VIX :",round(Correlation_VIX, 4), "\n")

plot(Donnees_regression_VIX$VIX,Donnees_regression_VIX$Volatilite_LMT,
  main = "Relation entre le VIX et la volatilité de LMT",
  xlab = "VIX (%)",
  ylab = "Volatilité annualisée de LMT (%)"
)

abline(Modele_VIX, col = "red", lwd = 2)

