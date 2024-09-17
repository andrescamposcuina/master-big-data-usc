%reset -f 
import pandas as pd
import numpy as np
loans = pd.read_csv('https://spark-public.s3.amazonaws.com/dataanalysis/loansData.csv')
print 'Original data shape:' + str(loans.shape)
cl = loans

#Remove %
cl['Interest.Rate'] = cl['Interest.Rate'].str.replace('%','').astype(float)
cl['Debt.To.Income.Ratio'] = cl['Debt.To.Income.Ratio'].str.replace('%','').astype(float)

#C Replace states
states=cl['State'].unique()
dic_states = dict(zip(states,range(len(states))))
cl['State'] = cl['State'].map(lambda x: dic_states[x])

#D Remove the word months
cl['Loan.Length'] = cl['Loan.Length'].str.replace('months','').astype(int)

#E Loan purpose
purpose=cl['Loan.Purpose'].unique()
print '\nPurpose is split in the following fields: \n'+ str(purpose)
# If we do not want to split, we can use numerical attributes
#dic_purpose = dict(zip(purpose,range(len(purpose))))
#cl['Loan.Purpose'] = cl['Loan.Purpose'].map(lambda x: dic_purpose[x])
for event_kind in purpose:
    col_name = 'purpose.'+event_kind.lower()  # Lower case
    cl[col_name] = cl['Home.Ownership'].apply(lambda e: np.where(event_kind in e,1.,0.))
cl = cl.drop('Loan.Purpose',1)

#F HOME OWNERSHIP
home=cl['Home.Ownership'].unique()
print '\nHome is split in the following fields: \n'+ str(home)
# If we do not want to split, we can use numerical attributes
#dic_home = dict(zip(home,range(len(home))))
#cl['Home.Ownership'] = cl['Home.Ownership'].map(lambda x: dic_home[x])
#Unrolling 
for event_kind in home:
    col_name = 'home.'+event_kind.lower()  # Lower case
    cl[col_name] = cl['Home.Ownership'].apply(lambda e: np.where(event_kind in e,1.,0.))
cl = cl.drop('Home.Ownership',1)

#G FICO MIN and MAX split
k = cl['FICO.Range'].str.split('-').tolist()
min_data = [int(x) for x,y in k]
cl['FICO.min'] = min_data
max_data = [int(y) for x,y in k]
cl['FICO.max'] = max_data

#Drop FICO.range
cl = cl.drop("FICO.Range",1)

#Employment length
cl['Employment.Length']=cl['Employment.Length'].str.replace(' years','')
cl['Employment.Length']=cl['Employment.Length'].str.replace(' year','')
cl['Employment.Length']=cl['Employment.Length'].str.replace('< 1','1')
cl['Employment.Length']=cl['Employment.Length'].str.rstrip('+')
cl['Employment.Length']=cl['Employment.Length'].replace('n/a',np.NaN)
cl['Employment.Length']=cl['Employment.Length'].astype(float)
employ = cl['Employment.Length'].unique()

#Fill missing values
cl = cl.fillna(cl.mean())

#Full funding problem definition:
import matplotlib.pyplot as plt
plt.figure()
full=np.array(cl['Amount.Requested'].tolist())-np.array(cl['Amount.Funded.By.Investors'].tolist())
a= plt.hist(full,bins=20)
plt.title('Histogram of loan differences')
y = np.where(full>1000.,1,-1) #Predict failing to fulfill above 1000 dollars

#Drop  'Amount.Funded.By.Investors' and 'State'
cl = cl.drop('Amount.Funded.By.Investors',1)
cl = cl.drop('State',1)

X = cl.values
print '\nAttributes:\n' + str(cl.columns.tolist())
print '\n'
cl.head()