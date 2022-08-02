from sklearn import metrics
from sklearn import svm
from sklearn import preprocessing
from sklearn import cross_validation
from sklearn import grid_search


parameters = {'C':[ 0.05,0.1,0.5],'class_weight':[{-1:0.1},{-1:0.07},{-1:0.05},{-1:0.035},{-1:0.01}],'penalty':['l1'],'dual':[False]}

X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, y, test_size=0.3, random_state=1)
scaler = preprocessing.StandardScaler()
X_train = scaler.fit_transform(X_train)
svc_precision = svm.LinearSVC()
svc_recall = svm.LinearSVC()
clf_precision = grid_search.GridSearchCV(svc_precision, parameters,scoring='precision')
clf_recall = grid_search.GridSearchCV(svc_recall, parameters,scoring='recall')
clf_precision.fit(X_train, y_train.ravel())
clf_recall.fit(X_train, y_train.ravel())

d = np.array([clf_precision.grid_scores_[i][1] for i in xrange(15)])
d2 = np.array([clf_recall.grid_scores_[i][1] for i in xrange(15)])
plt.plot(d*d2,'r',marker='o')
idx_conf = np.argmax(d*d2)

params,k,kk = clf_precision.grid_scores_[idx_conf]
print params


clf = svm.LinearSVC(**params)
clf.fit(X_train,y_train.ravel())

X_test = scaler.transform(X_test) 
yhat=clf_precision.predict(X_test)

def draw_confusion(y_test,yhat,labels):
    cm = metrics.confusion_matrix(y_test, yhat)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.matshow(cm)
    plt.title('Confusion matrix',size=20)
    ax.set_xticklabels([''] + labels, size=20)
    ax.set_yticklabels([''] + labels, size=20)
    plt.ylabel('Predicted',size=20)
    plt.xlabel('True',size=20)
    for i in xrange(2):
        for j in xrange(2):
            ax.text(i, j, cm[i,j], va='center', ha='center',color='white',size=20)
    fig.set_size_inches(7,7)
    plt.show()

draw_confusion(y_test,yhat,['approved', 'denied'])
print metrics.classification_report(y_test,yhat)
