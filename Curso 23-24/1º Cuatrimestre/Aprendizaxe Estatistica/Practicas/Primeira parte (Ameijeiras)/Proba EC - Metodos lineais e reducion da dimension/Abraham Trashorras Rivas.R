# Abraham Trashorras RIvas
install.packages("ISLR")
library("ISLR")
data("Hitters")
Hitters2 <- Hitters[,-c(14,15,20)]
Hitters2 <- na.omit(Hitters2)
Hitters2

Hitters2_train <- Hitters2[1:200,]
Hitters2_test <- Hitters2[201:263,]


summary(Hitters2)
help(Hitters)

# Objetivo -> Predecir salary en base a las covariables

# Primero hacemos lm
hlm <- lm(Salary~ ., data=Hitters2_train)
hpredict <- predict(hlm,newdata=Hitters2_test)
# Residuos
hrestest <- Hitters2_test$Salary-hpredict
# Suma de Residuos al Cuadrado
sum(hrestest^2)
# MSE
mean(hrestest^2)

# Ridge, usando el paquete glmnet
install.packages("glmnet")
library(glmnet)
y <- Hitters2_train$Salary
x <- Hitters2_train[,1:16]
lam <- seq(0, 10, by = 0.01)
# Calculamos lambda para el cual el MSE sea menor
cvout <- cv.glmnet(as.matrix(x), y, alpha = 0, lambda = lam)
# Lambda estimado
cvout$lambda.min # Nos da lambda=2.15
# Coeficientes para ese lambda
coef(cvout, s = "lambda.min")

# Calculamos Ridge
ridge <- glmnet(x, y, alpha = 0, lambda = cvout$lambda.min)
ridgepredict <- predict(ridge, newx = as.matrix(Hitters2_test[,1:16]), type = "response", s = 0.5)
# Residuos
ridgerestest <- Hitters2_test$Salary-ridgepredict
# Suma de Residuos al Cuadrado
sum(ridgerestest^2)
# MSE
mean(ridgerestest^2)


# Lasso, tambien usando glmnet
#Aprovechamos las variables de Ridge
cvout2 <- cv.glmnet(as.matrix(x), y, alpha = 1, lambda = lam)
cvout2$lambda.min # Nos da lambda=0.87
coef(cvout2, s = "lambda.min")

# Calculamos Lasso
lasso <- glmnet(x, y, alpha = 1, lambda = cvout2$lambda.min)
lassopredict <- predict(lasso, newx = as.matrix(Hitters2_test[,1:16]), type = "response", s = 0.5)
# Residuos
lassoestest <- Hitters2_test$Salary-lassopredict
# Suma de Residuos al Cuadrado
sum(lassoestest^2)
# MSE
mean(lassoestest^2)

