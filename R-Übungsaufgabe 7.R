#<<<---------- Bemerkung Korrektur --------------->>>
# -------------
# Ergebnis:
# -------------
# Aufgabe 1: /2
# Aufgabe 2: /2
# Aufgabe 3: /4
# Aufgabe 4: /4
# Aufgabe 5: /4
# Aufgabe 6: /4
# -------------
# Summe: /20
#--------------
#<<<---------------------------------------------->>>

#
# Template für die Bearbeitung der Übungsaufgaben 7
#        -- Analyse des BostonHousing-Datensatz -- 
#

#-----------------
# Bitte ausfüllen:
#-----------------
# Gruppenname: Obi-Wan
# Gruppenteilnehmer: Lisa Trovato-Monastra, Johannes Rieder, Jannik Steck, Marius Bauer

#-------------------------
# notwendinge Bibliotheken
#-------------------------
library(mlbench) #Datensatz
library(glmnet)  #Ridge/Lasso-Regression
library(dplyr)

#------------------------------------
# Aufgabe 1: Trainings- und Testdaten
#------------------------------------
data("BostonHousing")
data <- BostonHousing

set.seed(50)
# Einteilung des Caravan-Datensatzes in 80% Trainings- und 20% Testdaten
rows.train <- sample(length(data$medv), 0.8 * length(data$medv))
train         <- as.data.frame(data[rows.train,])
test          <- as.data.frame(data[-rows.train,])

#------------------------------------
# Aufgabe 2: Lineare Regression
#------------------------------------
# Lineare Regression mit Output-Variable Purchase und den anderen Variablen als Input-Variablen
linreg.fit <- lm(formula = medv ~ . , 
                 data = train)
linreg.fit

plot(linreg.fit)

# Vorhersage von medv der Testdaten auf Basis der linearen Regression
linreg.pred <- predict(object  = linreg.fit,
                       newdata = test,
                       type    = "response")

# Mittlere quadratische Abweichung für train-Datenpunkte
linreg.train.mqa <- mean(
  (data$medv - predict(object=linreg.fit, newdata=train))^2)

# Mittlere quadratische Abweichung für test-Datenpunkte
linreg.test.mqa <- mean(
  (data$medv - predict(object=linreg.fit, newdata=test))^2)

#------------------------------------
# Aufgabe 3: Bias-Variance
#------------------------------------

# Approved by James Jamal Steck's Geodreieck
# MQA (Varianz) hoch, Bias hoch, Modell nicht gut gefitted, da zu wenig Datenpunkte 
# --> Underfitting

#------------------------------------
# Aufgabe 4: Ridge Regression
#------------------------------------

y <- data$medv
x <- data %>% select(crim, zn, indus, chas, nox, rm, age, dis, rad, tax, ptratio, b, lstat) %>% data.matrix()

lambda <- 10^seq( from = 5, to = -3, length = 100)

rreg.fit <- glmnet(x = x, 
                   y = y,
                   alpha = 0, 
                   lambda = lambda)

plot(rreg.fit)
rreg.fit
#------------------------------------
# Aufgabe 5: Lasso Regression
#------------------------------------

y <- data$medv
x <- data %>% select(crim, zn, indus, chas, nox, rm, age, dis, rad, tax, ptratio, b, lstat) %>% data.matrix()

lambda <- 10^seq( from = 5, to = -3, length = 100)

lasreg.fit <- glmnet(x = x, 
                     y = y,
                     alpha = 1, 
                     lambda = lambda)

plot(lasreg.fit)
lasreg.fit
#------------------------------------
# Aufgabe 6: Vergleich der Ergebnisse
#------------------------------------

#    ...Platz für Ihren Code und Begründung...