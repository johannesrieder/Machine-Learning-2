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

set.seed(42)
# Einteilung des BostonHousing-Datensatzes in 80% Trainings- und 20% Testdaten
rows.train <- sample(length(data$medv), 0.8 * length(data$medv))
train         <- as.data.frame(data[rows.train,])
test          <- as.data.frame(data[-rows.train,])

y <- data.matrix(data$medv)
x <- data %>% select(crim, zn, indus, chas, nox, rm, age, dis, rad, tax, ptratio, b, lstat) %>% data.matrix()

grid <- 10^seq(from = 5, to = -3, length = 100)

newx.test <- model.matrix(~.-test$medv, 
                          data=test)[,2:14]
newx.train <- model.matrix(~.-train$medv, 
                           data=train)[,2:14]

#------------------------------------
# Aufgabe 2: Lineare Regression
#------------------------------------
# Lineare Regression mit Output-Variable medv und den anderen Variablen als Input-Variablen
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

# Die MQAs der Trainings- und Testdaten sind sehr hoch, was auf ein Under-
# fitting hinweist. Underfitting ist in diesem Fall 
# auf gering verfügbare Trainingsdaten zurückzuführen. Wäre das Modell 
# hingegen overfitted, würde die MQA bei den Trainingsdaten deutlich geringer 
# ausfallen als die MQA der Testdaten. 
#
# 

#------------------------------------
# Aufgabe 4: Ridge Regression
#------------------------------------

# Ridge Regression mit alpha = 0
ridreg.cv <- cv.glmnet(x = x, 
                       y = y,
                       alpha = 0, 
                       lambda = grid)

ridreg.lambda <- ridreg.cv$lambda.min

ridreg <- glmnet(x, y, alpha = 0, lambda = ridreg.lambda)

# Prediction für die Testdaten
pred <- predict(ridreg, s = ridreg.lambda, newx = newx.test)

# Mittlere quadratische Abweichung für train-Datenpunkte
ridreg.train.mqa <- mean((train$medv - predict(ridreg, newx=newx.train))^2)

# Mittlere quadratische Abweichung für test-Datenpunkte
ridreg.test.mqa <- mean((test$medv - predict(ridreg, newx=newx.test))^2)


#------------------------------------
# Aufgabe 5: Lasso Regression
#------------------------------------

# Lasso Regression mit alpha = 1
lasreg.cv <- cv.glmnet(x = x, 
                       y = y,
                       alpha = 1, 
                       lambda = grid)

lasreg.lambda <- lasreg.cv$lambda.min

lasreg <- glmnet(x, y, alpha = 1, lambda = lasreg.lambda)

# Die Parameter "indus" und "age" werden auf 0 gesetzt.
coef(lasreg)

# Prediction für die Testdaten
pred <- predict(lasreg, s = lasreg.lambda, newx = newx.test)

# Mittlere quadratische Abweichung für train-Datenpunkte
lasreg.train.mqa <- mean((train$medv - predict(lasreg, newx=newx.train))^2)

# Mittlere quadratische Abweichung für test-Datenpunkte
lasreg.test.mqa <- mean((test$medv - predict(lasreg, newx=newx.test))^2)


#------------------------------------
# Aufgabe 6: Vergleich der Ergebnisse
#------------------------------------

print("Lineare Regression:")
print(paste("Train-Fehler: ", linreg.train.mqa))
print(paste("Test-Fehler: ", linreg.test.mqa))
print("-------------------------------------")
print("Ridge Regression:")
print(paste("Train-Fehler: ", ridreg.train.mqa))
print(paste("Test-Fehler: ", ridreg.test.mqa))
print("-------------------------------------")
print("Lasso Regression:")
print(paste("Train-Fehler: ", lasreg.train.mqa))
print(paste("Test-Fehler: ", lasreg.test.mqa))
print("-------------------------------------")

#
# Vergleicht man die Modelle anhand der berechneten MQAs, wird ersichtlich, 
# dass die lineare Regression die geringste MQA aufweisen kann und somit am
# besten geeignet ist. Die Modelle der Ridge-Regression und Lasso-Regression
# liefern höhere MQAs.
# Die Lasso-Regression selektiert Variablen ohne/kaum Einfluss und entfernt
# diese aus dem Modell. Hingegen werden bei der Ridge-Regression zu große 
# Koeffizienten verringert, um damit die Vorhersagegenauigkeit der Zielvariable
# zu verbessern. Da nicht alle Variablen betrachtet werden, wird ein Overfitting
# der Modelle vermieden, weswegen eine höhere MQA entsteht. Das Modell ist 
# unserer Ansicht nach underfitted, wodurch die Vorteile der Regularisierung
# gegen Overfitting nicht greifen.
#
