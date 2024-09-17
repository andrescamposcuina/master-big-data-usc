# Información de 10000 clientes de una entidad bancaria
# install.packages("ISLR")
library(ISLR)
data(Default)
head(Default)

# Objetivo: predecir Y (cuando un cliente incurrirá en impago 
# de crédito de la tarjeta)
# Explicativa (X): saldo medio mensual del cliente

default01 <- numeric()
default01[Default$default=="No"]=0
default01[Default$default=="Yes"]=1

# Si aplicamos regresión lineal clásica tenemos un problema
reglin <- lm(default01 ~ Default$balance)
plot(Default$balance,default01,
 main="Ajuste logístico",xlab="Saldo",ylab="Impago",ylim=c(-0.1,1))
abline(reglin)


# Ajuste de un modelo de regresión logística
reglog1 <- glm(default ~ balance, data = Default, family = "binomial")
summary(reglog1)

# Coeficientes
reglog1$coefficients

# Odds (de alguien con saldo medio cero)
odds=exp(reglog1$coefficients[1])
odds
# Probabilidad de que no incurra en impago
odds/(1+odds)

# Por cada unidad monetaria, la odds de impago 
# se multiplica por exp(beta1)
odds1=exp(reglog1$coefficients[2])
saldo=1000
odds1000=odds*odds1^saldo
odds1000/(1+odds1000)


# La frontera entre clasificar como default o no, estará en el valor
# de x que satisface
# beta_0 + beta_1 X = 0
front = -reglog1$coefficients[1]/reglog1$coefficients[2]
fron
oddsfront = odds*odds1^front
oddsfront/(1+oddsfront)

# Representación

plot(Default$balance,default01,
 main="Ajuste logístico",xlab="Saldo",ylab="Impago")
seqx=seq(-10,2800,len=10000)
seqy=predict(reglog1,list(balance=seqx),type="response")
lines(seqx,seqy,col=2,lwd=2)


# Clasificación (predicción)

# Probabilidad de default acorde a sus saldo medio
probdef <- predict(reglog1, type = "response")

# Clasifico en persona que puede cometer default
# si esa prob es mayor que 0.5
clasif1 <- probdef>0.5

# Comparamos realidad con clasificación (Matriz de confusión)
table(Default$default,clasif1)

# Podría ser más "precavido" y catalogar como que sea
# riesgo de default si el modelo predice una probabilidad
# mayor del 20%
clasif2 <- probdef>0.2
table(Default$default,clasif2)

