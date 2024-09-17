## Example 1: improving sales

#setwd("C:/Users/Jose/Downloads")
Advertising <- read.csv("Advertising.csv")
#attach(Advertising)

# Observe a phenomenon
plot(Advertising$Radio,Advertising$Sales)

# Construct a model for that phenomenon
modelo=lm(Sales~Radio,data=Advertising)
abline(modelo)

# Make predictions
nuevo=data.frame(Radio=25)
predict(modelo,newdata=nuevo)

# install.packages("rgl")
library(rgl)
plot3d(Advertising[, c("Radio", "Newspaper", "Sales")])

modelo2=lm(Sales~Radio+Newspaper,data=Advertising)
plot3d(modelo2)

nuevo2=data.frame(Radio=25,Newspaper=30)
predict(modelo2,newdata=nuevo2)


## Example 2: Fuel consumption

# install.packages("ISLR")
library(ISLR)
data(Auto)
plot(Auto$horsepower, Auto$mpg)
modelo3=lm(mpg~horsepower,data=Auto)
abline(modelo3)

# Polynomial of degree 3
modelo4=lm(mpg~poly(horsepower,3),data=Auto)
abline(modelo4)

hpgrid=seq(40,240,len=1000)
mpggrid=predict(modelo4,newdata=data.frame(horsepower=hpgrid))

lines(hpgrid,mpggrid,col=2)


## Example 3: Default 

library(ISLR)
data(Default)
plot(Default$balance, Default$default)

## Example 4: petal measures of iris specimens
data(iris)
plot(iris[, 3:4], col = iris$Species)
legend("bottomright", levels(iris$Species), col = 1:3, pch = 1)
