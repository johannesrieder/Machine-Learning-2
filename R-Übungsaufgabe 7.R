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

y <- data.matrix(data$medv)
x <- data %>% select(crim, zn, indus, chas, nox, rm, age, dis, rad, tax, ptratio, b, lstat) %>% data.matrix()

newx.test <- model.matrix(~.-test$medv, 
                          data=test)[,2:14]
newx.train <- model.matrix(~.-train$medv, 
                           data=train)[,2:14]
#------------------------------------
# Aufgabe 2: Lineare Regression
#------------------------------------
# Lineare Regression mit Output-Variable Purchase und den anderen Variablen als Input-Variablen
linreg.fit <- lm(formula = medv ~ . , 
                 data = train)

# Vorhersage von medv der Testdaten auf Basis der linearen Regression
linreg.pred <- predict(object  = linreg.fit,
                       newdata = test,
                       type    = "response")

# Mittlere quadratische Abweichung für train-Datenpunkte
linreg.train.mqa <- mean((train$medv - predict(linreg.fit,newdata=train))^2)

# Mittlere quadratische Abweichung für test-Datenpunkte
linreg.test.mqa <- mean((test$medv - predict(linreg.fit,newdata=test))^2)

#------------------------------------
# Aufgabe 3: Bias-Variance
#------------------------------------

# Approved by James Jamal Steck's Geodreieck
# MQA (Varianz) hoch, Bias hoch, Modell nicht gut gefitted, da zu wenig Datenpunkte 
# --> Underfitting

#------------------------------------
# Aufgabe 4: Ridge Regression
#------------------------------------

ridreg.lambdas <- 10^seq( from = 5, to = -3, length = 100)
ridreg.cv <- cv.glmnet(x = x, 
                       y = y,
                       alpha = 0, 
                       lambda = ridreg.lambdas)

ridreg.lambda <- ridreg.cv$lambda.min

ridreg.fit <- ridreg.cv$glmnet.fit

ridreg <- glmnet(x, y, alpha = 0, lambda = ridreg.lambda)

ridreg.pred <- predict(ridreg, s = ridreg.lambda, newx = newx.test)

# Mittlere quadratische Abweichung für train-Datenpunkte
ridreg.train.mqa <- mean((train$medv - predict(ridreg.fit,newx=newx.train))^2)

# Mittlere quadratische Abweichung für test-Datenpunkte
ridreg.test.mqa <- mean((test$medv - predict(ridreg.fit,newx=newx.test))^2)

#------------------------------------
# Aufgabe 5: Lasso Regression
#------------------------------------

lasreg.lambdas <- 10^seq( from = 5, to = -3, length = 100)
lasreg.cv <- cv.glmnet(x = x, 
                       y = y, 
                       alpha = 1, 
                       lambda = lasreg.lambdas)

lasreg.lambda <- lasreg.cv$lambda.min

lasreg.fit <- lasreg.cv$glmnet.fit

lasreg <- glmnet(x, y, alpha = 0, lambda = lasreg.lambda)

lasreg.pred <- predict(lasreg, s = lasreg.lambda, newx = newx.test)

# Mittlere quadratische Abweichung für train-Datenpunkte
lasreg.train.mqa <- mean((train$medv - predict(lasreg.fit,newx=newx.train))^2)

# Mittlere quadratische Abweichung für test-Datenpunkte
lasreg.test.mqa <- mean((test$medv - predict(lasreg.fit,newx=newx.test))^2)

#------------------------------------
# Aufgabe 6: Vergleich der Ergebnisse
#------------------------------------

#    ...Platz für Ihren Code und Begründung...