## Inference

## Goal: to estimate an unknown parameter

## Example: we want to estimate the population mean, using a dataset

## In the following examples, we know the popultation mean, but remember that in practice that is not the case!

# We impose a population mean equal to 2 and we generate a sample of size 200

dat=rnorm(200, mean=2, sd=1)

## Point estimation: a single value that estimates the parameter

# If we want to estimate the population mean with a single value, we can use the sample mean

mean(dat)

# We can see that this value is "close" to the true mean

## Most of the classic results on inference are based on the Central Limit Theorem. That result says that if n is large, the distribution of the sample mean is approximately normal

# The mean of the distribution of the sample mean is equal to the population mean [\bar{X} is unbiased]

# The standard deviation of the distribution of the sample mean is equal to the standard deviation of the population divided by the squared root of n

## We are goint to see that in practice
# In the following example, we generate (independent) data from the same distribution (identically distributed)

# We are going to generate 10000 samples of size n=200 from a normal distribution and compute its mean in a loop
meandat=numeric()
n=200
for(i in 1:10000){
  # In this case, we know that the population mean is 2 and the population standard deviation is 1
  dat=rnorm(n, mean=2, sd=1)
  # We compute the sample mean for each sample
  meandat[i]=mean(dat)
}

hist(meandat,freq=F)
# The sample mean is approximately normal with mean 2 and standard deviation 1/\sqrt{n}

# To see that we plot the normal density function for values of x between 1.6 and 2.4
seqx=seq(1.6,2.4,by=0.01)
seqy=dnorm(seqx,mean=2,sd=1/sqrt(n))

lines(seqx,seqy,col=2)
# We can see that the histogram is well approximated by the gaussian density
# You can try to modify the sample size (n), you will observe that the standard deviation (dispersion or distance from the mean) will be modified. It will be larger if n is smaller

# The same is true, even if data does not follow a normal distribution
dat2=rexp(200,1)
hist(dat2,freq=F)
# In this case, data only takes positive value, the distribution is assymetric, ... Thus, it does not follow a normal distribution
# But the sample mean follows a normal distribution!

# We are going to see that result
# We are going to generate 10000 samples of size n=200 from an exponential distribution and compute its mean in a loop
meandat2=numeric()
n=200
for(i in 1:10000){
  # In this case, we know that the population mean is 1 and the population standard deviation is 1 (the mean and the standard deviation are equal to 1/rate)
  dat2=rexp(n, rate=1)
  # We compute the sample mean for each sample
  meandat2[i]=mean(dat2)
}
hist(meandat2,freq=F)

# The sample mean is approximately normal with mean 1 and standard deviation 1/\sqrt{n}
seqx=seq(0.6,1.4,by=0.01)
seqy=dnorm(seqx,mean=1,sd=1/sqrt(n))
lines(seqx,seqy,col=2)












## Confidence interval
# It is an interval depending only on the sample!
# It says with a confidence level, where the true parameter is
dat=rnorm(200, mean=2, sd=1)
tt=t.test(dat,conf.level = 0.95)
# We are 95% sure that the true parameter is within the following limits:
tt$conf.int

# We are going to see that result

# We are going to generate 10000 samples of size n=200 from a normal distribution and compute its confidence interval for the population mean in a loop
cidat=numeric()
n=200
for(i in 1:10000){
  # In this case, we know that the population mean is 2
  dat=rnorm(n, mean=2, sd=1)
  # We compute the 95% confidence interval for each sample
  tt=t.test(dat,conf.level = 0.95)
  cit=tt$conf.int
  # We check if the population mean (2) is within the confidence limits
  cidat[i]=(cit[1]<2)&(cit[2]>2)
  # cidat[i] is true if and only if 2 is inside the CI
}

# We can see that aproximately 95% of the times, 2 was within the confidence interval
table(cidat)
# The number of trues (1) is close to 0.95*10000=9500














## Hypothesis test
# hypothesis test is a decision-making process that examines the data, and on the basis of expectation under H0, leads to a decision as to whether or not to reject H0

# We can see if we could reject the null hypothesis that the true (population) mean is equal to 10

# Null hypothesis H0: mu=10
# Alternative hypothesis H1: mu!=10

# We need to impose the significance level alpha=0.05

# We collect the sample
dat=rnorm(200, mean=2, sd=1)

# We compute the p-value
tt=t.test(dat,mu=10,alternative = "two.sided")
tt$p.value
# Since the p-value is lower that 0.05, we reject the null hypothesis
# (we have statistical evidences to reject that the population mean is equal to 10 for a signinficance level of the 5%)

# What does it mean to have a significance level alpha=0.05?
# It means that we expect an incorrect rejection of a true null hypothesis 5% of the times


# We are going to see that result

# We are going to generate 10000 samples of size n=200 from a normal distribution and test if the population mean is equal to 2 in a loop
pvdat=numeric()
n=200
for(i in 1:10000){
  # In this case, we know that the population mean is 2
  dat=rnorm(n, mean=2, sd=1)
  # We compute the p-value (when testing H0: mu=2) for each sample
  # Remember that in this case, we know that we are under the null (mu=2)
  tt=t.test(dat,mu=2)
  pvt=tt$p.value
  # We check if the p-value is lower that 5% (i.e. if we reject the null hypothesis)
  pvdat[i]=pvt<0.05
}

# We can see that aproximately 5% of the times, the p-value was below 0.05, i.e., that 5% of the times we rejected the null hypothesis
table(pvdat)
# The number of trues (1) is close to 0.05*10000=500

