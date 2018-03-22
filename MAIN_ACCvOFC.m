%% Cross spectra
c1= corr(LFPspectra.zacc(:,painsortindex));
c2= corr(LFPspectra.zofc(:,painsortindex));
c12=corr(LFPspectra.zacc(:,painsortindex),LFPspectra.zofc(:,painsortindex));

figure 
imagesc(c1);
title('ACC Cross-session Spectral correlation')
caxis([-.5 .5])
colorbar

figure
imagesc(c2);
title('OFC Cross-session Spectral correlation')
caxis([-.5 .5])
colorbar

figure
plot(LFPmeta.pain(painsortindex),'r.','markersize',30)
ylabel('Pain Score 1-10')
xlabel('Session #')

figure
imagesc(c12);
caxis([-.5 .5])
title('ACC-OFC between region, Cross Session Spectral correlation')
colorbar

%% Evaluate coherency  between ACC and LFP 
tic

params.Fs=422; 
params.tapers=[300 5];
params.pad=0;
params.fpass=[0 100];

[C,phi,S12,S1,S2,f]=coherencyc(LFP.acc,LFP.ofc,params);
toc

mC=mean(C);

close all
nozero=LFPmeta.pain>-1;
scatter(mC,LFPmeta.pain,150,'k.');
title('Coherence between ACC and OFC across all bands (1-100 Hz) vs Pain Score')
xlabel('Coherence')
ylabel('Pain Score')


% Band Limited Coherence
delta = (f>=1 & f<=4);
theta = (f>4 & f<=8);
alpha =(f>8 & f<=12);
beta = (f>12 & f<=30);
Lgamma =(f>30 & f<=60);
Mgamma = (f>60 & f<=100);   
bands= {'delta','theta','alpha','beta','Lgamma','Mgamma'};
bandlims={[1 4],[4 8],[8 12],[12 30],[30 60],[60 100]};



   %FILTER FOR PAIN SCORES
    nozero = (LFPmeta.pain>0); %insert this in Y and x1 to exclude pain scores of 0
    allscores =  logical(ones(size(LFPmeta.pain))); %#ok<LOGL>
    

    PainInd = nozero; %SET THIS FILTER to APPLY TO PAIN SCORES or only nonzero ones
    
    
% Calculate within band coherence between ACC-OFC
for b=1:6 % for each power band
    
    %ACC- OFC coherence
eval(['LFPspectra.coherence{b} = mean(C(' bands{b} ',:));']);
figure(2)
subplot(3,2,b)
hold all
%     %regress and plot line
    Y=LFPmeta.pain(PainInd)';
% %     Y=zscore(Y); %use this if you want to zscore the Pain scores
    x1=LFPspectra.coherence{b}(PainInd)';
    X=[ones(size(x1)) x1];
    [coeffC(:,b),BINT,R,RINT,cSTATS(b,:)] = regress(Y,X);
    x2=linspace(min(LFPspectra.coherence{b}),max(LFPspectra.coherence{b}),100);
    plot(x2,(coeffC(2,b).*x2 + coeffC(1,b)),'r'); 
    text(max(LFPspectra.coherence{b}),6,{'R^2 =' num2str(cSTATS(b,1)),'p = ' num2str(cSTATS(b,3))}); %R^2 is first value, p is 3rd
scatter(x1,Y,150,'.');
title(bands{b});ylabel('Pain Score');xlabel('Coherence')
    

end







% 
% figure(1)
% imagesc(1:77,f,zscore(S1,0,2)); 
% figure(2)
% imagesc(1:77,f,zscore(S2,0,2)); 
% figure(3)
% imagesc(1:77,f,zscore(C,0,2)); 


%% HILBERT correlations between ACC and OFC
tic


for bb=1:6

lo=bandlims{bb}(1);
hi=bandlims{bb}(2);

clear CC 

indnum=find(PainInd);
    for x=1:length(indnum)
        a=LFP.acc(:,indnum(x));
        b=LFP.ofc(:,indnum(x));
        

        a2=eegfilt(a',422,lo,hi);
        b2=eegfilt(b',422,lo,hi);
        ha=hilbert(a2);hb=hilbert(b2);
       
        if (bb==1 && x ==21)
       figure(11)
       subplot 211
       plot(a2); hold all; plot(abs(ha));
       subplot 212
       plot(b2); hold all; plot(abs(hb));
        end
        
        
        a123=corrcoef(abs(ha),abs(hb)); %get the correlation coefficient
        CC(x)=a123(1,2);
    end
 
    
figure (10)
subplot (3,2,bb)
 title([num2str(lo) '-' num2str(hi) ' Hz'])
 plot(CC,LFPmeta.pain(PainInd),'b.','markersize',10)
 xlim([-.5 1])
 ylabel('Pain Score')
 xlabel('Analytic Amplitude Correlation')
 
end

toc

