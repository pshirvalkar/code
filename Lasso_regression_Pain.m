% Lasso L1 regularization regression

X=cell2mat([Espectra.acc(2).bandpower';Espectra.ofc(2).bandpower']); X=X';
y=(Espectra.acc(2).painscores);
n=length(y); 



% Creating testing and training CV sets
c=cvpartition(n,'Kfold',5);
idxTrain = training(c,1);
idxTest=~idxTrain; 


XTrain = X(idxTrain,:);
yTrain = y(idxTrain); 
XTest = X(idxTest,:);
yTest = y(idxTest); 


[B,FitInfo] = lasso(X,y,'Alpha',0.8,'CV',c,'MCreps',5,'PredictorNames',{'ACCdelta','ACCtheta','ACCalpha','ACCbeta','ACCLgamma','ACCMgamma','OFCdelta','OFCtheta','OFCalpha','OFCbeta','OFCLgamma','OFCMgamma'});
% alpha = Scalar value in the interval (0,1] representing the weight of lasso (L1) versus ridge (L2) optimization. Alpha = 1 represents lasso regression, Alpha close to 0 approaches ridge regression, and other values represent elastic net optimization

idxLambdaMinMSE = FitInfo.IndexMinMSE
idxLambda1SE = FitInfo.Index1SE
coef = B(:,idxLambda1SE)
coef0 = FitInfo.Intercept(idxLambda1SE)

idxLambdaMinMSE = FitInfo.IndexMinMSE
minMSEModelPredictors = FitInfo.PredictorNames(B(:,idxLambdaMinMSE)~=0)


lassoPlot(B,FitInfo,'PlotType','CV');
legend('show') % Show legend



figure (2)
clf
yhat = XTest*coef + coef0;
hold on
scatter(yTest,yhat)
plot(yTest,yTest)
xlabel('Actual Pain Scores')
ylabel('Predicted Pain Scores')
% xlim([3 10])
% ylim([3 10])
hold off

 