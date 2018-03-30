% Lasso L1 regularization regression

X=cell2mat(LFPspectra.accbandpower'); X=X';
y=LFPmeta.autopain;
n=length(y); 


% Creating testing and training CV sets
c=cvpartition(n,'HoldOut',0.3);
idxTrain = training(c,1);
idxTest=~idxTrain; 


XTrain = X(idxTrain,:);
yTrain = y(idxTrain); 
XTest = X(idxTest,:);
yTest = y(idxTest); 


[B,FitInfo] = lasso(XTrain,yTrain,'Alpha',0.75,'CV',10,'PredictorNames',{'delta','theta','alpha','beta','Lgamma','Mgamma'});
%what is alpha? in elastic net?

idxLambdaMinMSE = FitInfo.IndexMinMSE;
idxLambda1SE = FitInfo.Index1SE;
coef = B(:,idxLambda1SE)
coef0 = FitInfo.Intercept(idxLambda1SE);

idxLambdaMinMSE = FitInfo.IndexMinMSE;
minMSEModelPredictors = FitInfo.PredictorNames(B(:,idxLambdaMinMSE)~=0);


lassoPlot(B,FitInfo,'PlotType','CV');
legend('show') % Show legend



figure
yhat = XTest*coef + coef0;
hold on
scatter(yTest,yhat)
plot(yTest,yTest)
xlabel('Actual Pain Scores')
ylabel('Predicted Pain Scores')
xlim([3 10])
ylim([3 10])
hold off

 