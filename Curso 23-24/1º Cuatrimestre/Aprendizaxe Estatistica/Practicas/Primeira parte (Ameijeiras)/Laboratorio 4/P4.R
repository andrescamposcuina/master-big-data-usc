### Multicollinearity
# It is a problem that you can run into when you’re fitting a 
# regression model and two or more predictor variables are moderately 
# or highly correlated (meaning that one can be linearly predicted 
# from the others)


# Sample size
n <- 1000

# Theoretical model Y=f(X)+eps, f(x)=beta0+beta1*x1+beta2*x2
beta0<-0 
beta1<-1
beta2<-1

# Standard deviation of the error term
sigma<-1

# Number of samples
B<-1000 

# correlation values
rhos=c(0.1,0.5,0.9)

# Estimated coefficients
cc<-array(dim=c(B,3,length(rhos))) 

# Estimated correlation
corv<-matrix(nrow=B, ncol=3)

for(j in 1:length(rhos)){

rho=rhos[j] # Correlation

for (i in 1:B){ 
eps<-rnorm(n,0,sigma) # The error follows a normal distribution of mean 0
x1<-rnorm(n)   # The x1 values follow a normal
xs<-rnorm(n)   # The x star values follow a normal
x2<-rho*x1+sqrt(1-rho^2)*xs # The x1 and x2 values are correlated 
y<-beta0+beta1*x1+beta2*x2+eps # y=f(x)+eps
z<-lm(y~x1+x2)  # Linear model 
cc[i,,j]<-coef(z) # Row i contains the estimated coefficients

corv[i,j] <- cor(x1,x2) # i element contains the estimated correlation
}
}

# The expected value is beta0, beta1, beta2
apply(cc,c(2,3),mean)
# The variance of beta0, beta1, beta2 change
apply(cc,c(2,3),var)

# The sample correlation is close to the theoretical one
colMeans(corv)

# For beta0
j=1
plot(density(cc[,j,1])) # rho=0.1 (black)
lines(density(cc[,j,2]),col=2) # rho=0.5 (red)
lines(density(cc[,j,3]),col=3) # rho=0.9 (green)

# For beta1
j=2
plot(density(cc[,j,1])) # rho=0.1 (black)
lines(density(cc[,j,2]),col=2) # rho=0.5 (red)
lines(density(cc[,j,3]),col=3) # rho=0.9 (green)

# For beta2
j=3
plot(density(cc[,j,1])) # rho=0.1 (black)
lines(density(cc[,j,2]),col=2) # rho=0.5 (red)
lines(density(cc[,j,3]),col=3) # rho=0.9 (green)

# The variance of multiple regression coefficients is inflated 
# by the presence of correlated variables

##########################################################

### More features than observations 
# Classical approaches such as least squares linear regression 
# are not appropriate when the number of features p is as large as, 
# or larger than, the number of observations n

# Theoretical model Y=f(X)+eps, f(x)=beta0+beta1x
beta0<-0
beta1<-1

# Standard deviation of the error term
sigma<-1


par(mfrow=c(1,2)) 
for(n in c(50,2)){
eps<-rnorm(n,0,sigma) # The error follows a normal distribution of mean 0
x<-runif(n)   # The x values follow a uniform
y<-beta0+beta1*x+eps # y=f(x)+eps
z<-lm(y~x)  # Linear model
plot(x,y)
abline(z)
}









# Sample size
n <- 100

# Large dimension
ps <- c(90,40,10)

# Number of samples
B<-1000 


# Estimated coefficients (beta1 and beta2)
cc<-array(dim=c(B,2,length(ps))) 

for(j in 1:length(ps)){
p=ps[j]
for (i in 1:B){ 
eps<-rnorm(n,0,sigma) # The error follows a normal distribution of mean 0
xmat<-matrix(runif(n*p),nrow=n,ncol=p) # The x_j values follow a uniform
y<-rowSums(xmat)+eps # y=f(x)+eps, f(x)=x1+...+xp
df<-data.frame(y,xmat)

z<-lm(y ~ .,data=df)  # Linear model 
cc[i,,j]<-coef(z)[2:3] # Row i contains the estimated coefficients beta1 and beta2
}
}
 

# For beta1
j=1
plot(density(cc[,j,1]),ylim=c(0,1.1)) # p=90 (black)
lines(density(cc[,j,2]),col=2) # p=40 (red)
lines(density(cc[,j,3]),col=3) # p=10 (green)

# For beta2
j=2
plot(density(cc[,j,1]),ylim=c(0,1.1)) # p=90 (black)
lines(density(cc[,j,2]),col=2) # p=40 (red)
lines(density(cc[,j,3]),col=3) # p=10 (green)


