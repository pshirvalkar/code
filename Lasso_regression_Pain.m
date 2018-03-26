% Lasso L1? regularization regression

X=cell2mat(LFPspectra.accbandpower');
y=LFPmeta.autopain;

[B,FitInfo] = lasso(a,y,'CV',10,'PredictorNames',{'delta','theta','alpha','beta','Lgamma','Mgamma'});

idxLambdaMinMSE = FitInfo.IndexMinMSE;
minMSEModelPredictors = FitInfo.PredictorNames(B(:,idxLambdaMinMSE)~=0);


lassoPlot(B,FitInfo,'PlotType','CV');
legend('show') % Show legend

