# Advertising data
Advertising=read.csv("C:\\Users\\Jose\\Downloads\\Advertising.csv")

# Punctual estimation of coefficients
mod <- lm(Advertising$Sales ~ Advertising$TV)
mod$coefficients

# Representation
plot(Advertising$TV, Advertising$Sales)
abline(mod, col = 2)

# Confidence intervals
confint(mod)

# Alternative
summary(mod)$coefficients[,2]

# Lower limits
qt <- 2
qt <- qt(0.975,length(Advertising$Sales)-2)
mod$coefficients+qt*summary(mod)$coefficients[,2]
# Upper limits
mod$coefficients+qt*summary(mod)$coefficients[,2]

# Testing H0: beta_1=0 vs H1: beta_1!=0 
summary(mod)$coefficients

# Alternative 
# t-statistic
ts <- mod$coefficients/summary(mod)$coefficients[,2]
ts
# p-value
2*pt(-abs(ts),length(Advertising$Sales)-2)

# Residual Standard Error
summary(mod)$sigma
# The RSE is an estimate of the standard deviation of epsilon
# It is the average amount that the response 
# will deviate from the true regression line
# actual sales in each market deviate from the true regression 
# line by approximately 3260 units, on average.
# As we can see it depends on the units of Y

# R^2 statistic
summary(mod)$r.squared 
# Formula R^2=(TSS-RSS)/TSS = 1-RSS/TSS
# TSS= sum((y_i-mean(y))^2) total sum of squares
TSS <- sum((Advertising$Sales-mean(Advertising$Sales))^2)
RSS <- sum(mod$residuals^2)
1-RSS/TSS


##############################################################

# Multiple linear regression
mod2 <- lm(Sales ~ TV + Radio + Newspaper, data=Advertising)
# Punctual estimation of coefficients
mod2$coefficients
# Alternative
Xmat <- cbind(rep(1,length(Advertising$TV)), Advertising$TV, Advertising$Radio, Advertising$Newspaper)
solve(t(Xmat)%*%Xmat)%*%t(Xmat)%*%Advertising$Sales

# Confidence intervals coefficients
confint(mod2)

# Test H0: there is no relation between Y and all the regressors
summary(mod2)
# F-statistic: 570.3 on 3 and 196 DF,  p-value: < 2.2e-16

# Testing H0: beta_1=0 vs H1: beta_1!=0 
summary(mod2)

# Residual Standard Error
summary(mod2)$sigma
sqrt(sum(mod2$residuals^2)/(length((Advertising$Sales))-3-1))

# R^2 statistic

# TSS remains equal
TSS <- sum((Advertising$Sales-mean(Advertising$Sales))^2)
# Since we are adding one parameter RSS should be lower or equal
RSS <- sum(mod2$residuals^2)
# Thus, R^2 will always increase
R2 <- 1-RSS/TSS; R2
summary(mod2)$r.squared

# Alternative that penalizes the number of covariates: 
# Adjusted R^2 statistic
n <- length(Advertising$Sales)
p <- 3
1 - (1 - R2) * ((n - 1)/(n-p-1))
summary(mod2)$adj.r.squared

## Make predictions

# Prediction interval

# Given that $100,000 is spent on TV advertising and 
# $20,000 is spent on radio advertising in a particular city
nuevo=data.frame(TV=100,Radio=20,Newspaper=0)
# the 95% prediction interval is
predict(mod2, newdata=nuevo, interval='prediction')
# uncertainty surrounding the sales for a particular city

# Confidence interval
# The mean response for those values of the predictors will be 
# in the 95% condicence interval
predict(mod2, newdata=nuevo, interval='confidence')
# uncertainty surrounding the average sales 
# over a large number of cities.



##############################################################

# We are goint to see that \hat \beta_0 and \hat \beta_1 are
# unbiased, and with the variance indicated in Slide 19  
# distributed as a Student t (almost Gaussian) 

# Sample size
n <- 500

# Theoretical model Y=f(X)+eps, f(x)=beta0+beta1x
beta0<-3 
beta1<-5

# Standard deviation of the error term
sigma<-1

# Number of samples
B<-1000 

# Estimated coefficients
cc<-matrix(nr=B,nc=2) 

# Estandard error
er<-matrix(nr=B,nc=2)

for (i in 1:B){ 
eps<-rnorm(n,0,sigma) # The error follows a normal distribution of mean 0
x<-runif(n)   # The x values follow a uniform
y<-beta0+beta1*x+eps # y=f(x)+eps
z<-lm(y~x)  # Linear model 
cc[i,]<-coef(z) # Row i contains the estimated coefficients

# Standard error (beta0)
er[i,1]<-sigma^2*(1/n+mean(x)^2/sum((x-mean(x))^2))

# Standard error (beta1)
er[i,2]<-sigma^2/sum((x-mean(x))^2)
}

# The expected value is beta0 and beta1
colMeans(cc)
c(beta0,beta1)

# The distribution of (\hat \beta_j - \beta_j) / SE( \hat \beta_j ) is a student t
hist((cc[,1]-beta0)/sqrt(er[,1]),freq=F)
seqx<- seq(-4,4,len=1000)
seqy <- dt(seqx,n-2)
lines(seqx,seqy, col=2)

hist((cc[,2]-beta1)/sqrt(er[,2]),freq=F)
seqx<- seq(-4,4,len=1000)
seqy <- dt(seqx,n-2)
lines(seqx,seqy, col=2)