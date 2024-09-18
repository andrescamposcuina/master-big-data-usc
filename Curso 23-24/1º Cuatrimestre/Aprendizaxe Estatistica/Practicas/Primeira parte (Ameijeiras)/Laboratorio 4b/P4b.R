# Datos de prostata

# install.packages("Brq")
library(Brq)
data(Prostate)

dim(Prostate)
head(Prostate)

# Regresión lineal para explicar la variable lpsa en función 
# del resto de marcadores clínicos 
# Y=beta_0+beta_1 X_1 + ... + beta_8 X_8 + epsilon

# Estimación de mínimos cuadrados 

lm(lpsa~ ., data=Prostate)

# Estimación Ridge
# Minimizar RSS+lambda*sum (beta^2)

library(MASS)
rr <- lm.ridge(lpsa ~ ., lambda = 0,data=Prostate)
rr$coef # Se estandariza las variables
coef(rr) # En escala original, coincide con lm

# Si lambda != 0
lam <- seq(0, 10, by = 0.01)
rr <- lm.ridge(lpsa ~ ., lambda = lam,data=Prostate)

# Matriz donde las filas recogen los parámetros estimados
# para cada valor de lambda
coef(rr)

# Alternativa: librería glmnet
#install.packages("glmnet")
library(glmnet)

y <- Prostate$lpsa
x <- Prostate[,-9]
# Regresión cuasi-ridge: alpha=0
rr_glmnet <- glmnet(x, y, alpha = 0, lambda = 0)
coef(rr_glmnet)
rr_glmnet2 <- glmnet(x, y, alpha = 0, lambda = lam)

# No tenemos los mismos coeficientes, porque no es 
# exactamente Ridge
coef(rr_glmnet2)[,10]
rr_glmnet2$lambda[10]
# Alternativa si queremos buscar un lambda en concreto
coef(rr_glmnet2,s=9.91)

rownames(coef(rr))[992]
coef(rr)[992,]

# Pero el resultado de penalizar es similar
plot(rr_glmnet2, xvar = "lambda")



# Estimación LASSO
# Minimizar RSS+lambda*sum (abs(beta))

# Regresión cuasi-LASSO: alpha=1
# Si 0<alpha<1 combina ambas penalizaciones 

# Si lambda=0 ambas devuelven el mismo resultado
lasso <- glmnet(x, y, alpha = 1, lambda = 0)
coef(lasso)
coef(rr_glmnet)

lasso2 <- glmnet(x, y, alpha = 1, lambda = lam)
coef(lasso2)[,950]
lasso2$lambda[950]
plot(lasso2, xvar = "lambda")


# Selección del parámetro de penalización

# Regressión Ridge
# Validación cruzada de k-iteraciones (por defecto k=10)
cvout <- cv.glmnet(as.matrix(x), y, alpha = 0, lambda = lam)
# Lambda estimado
cvout$lambda.min
# Coeficientes para ese lambda
coef(cvout, s = "lambda.min")

# Regressión LASSO
cvout2 <- cv.glmnet(as.matrix(x), y, alpha = 1, lambda = lam)
cvout2$lambda.min
coef(cvout2, s = "lambda.min")
# El lambda más grande para el cual el error cuadrático medio (ECM)
# es como mucho el ECM+Error Típico (del ECM)
cvout2$lambda.1se
coef(cvout2, s = "lambda.1se")

# Predicción (cuando lambda=0.5) de las primeras 5 observaciones
predict(lasso2, newx = as.matrix( x[1:5,]), type = "response", s = 0.5)
