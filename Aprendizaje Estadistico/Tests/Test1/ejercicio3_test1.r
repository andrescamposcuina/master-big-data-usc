# Cargamos las librerías
library('ISLR')
library('glmnet')

# Cargamos el dataset
auto <- Auto

# Dividimos en conjunto de entranamiento y conjunto de test
conjunto_train <- auto[1:300,]
conjunto_test <- auto[301:392,]

# Ajustamos el modelo de regresión lineal múltiple
z <- lm(mpg ~ cylinders + displacement + horsepower + weight, data = conjunto_train)

# Obtenemos un resumen
summary(z)

# Muestra de train
n <- nrow(conjunto_train)
respuesta_train <- conjunto_train['mpg']
respuesta_train_predicha <- predict(z, data = conjunto_train)
mse_train <-(sum((respuesta_train - respuesta_train_predicha) ^ 2)) / n
mse_train


# Muestra de test
n <- nrow(conjunto_test)
respuesta_test <- conjunto_test['mpg']
respuesta_test_predicha <- predict(z, data = conjunto_test)
mse_test <- (sum((respuesta_test - respuesta_test_predicha) ^ 2)) / n
mse_test

# Lasso
conjunto_train_matrix <- data.matrix(conjunto_train[c("cylinders", "displacement", "horsepower", "weight")])
respuesta_train_matrix <- data.matrix(conjunto_train["mpg"])
lasso <-glmnet(conjunto_train_matrix, respuesta_train_matrix, alpha = 1, lambda = 3)
coef(lasso)

# MSE en el conjunto de test con Lasso
n <- nrow(conjunto_test)
conjunto_test_matrix <- data.matrix(conjunto_test[c("cylinders", "displacement", "horsepower", "weight")])
respuesta_test_matrix <- data.matrix(conjunto_test['mpg'])
respuesta_test_matrix_predicha <- predict(lasso, newx = conjunto_test_matrix)
mse_test <-(sum((respuesta_test_matrix - respuesta_test_matrix_predicha) ^ 2)) / n
mse_test

# Plot del valor de los coeficientes en función de lambda
lasso <- glmnet(conjunto_train_matrix, respuesta_train_matrix, alpha = 1)

lbs_fun <- function(fit, ...) {
  L <- length(fit$lambda)
  x <- log(fit$lambda[L])
  y <- fit$beta[, L]
  labs <- names(y)
  text(x, y, labels = labs, ...)
  legend('topleft',
         legend = labs,
         col = 1:6,
         lty = 1)
}

plot(lasso, xvar = "lambda")
lbs_fun(lasso)
