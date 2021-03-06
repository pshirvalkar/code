%% Cross spectra between ACC and OFC
% This will calculate
% 1. autocorrelation of ACC spectra from 1 sesion, compared to every other
% session from session with lowest pain score to highest. 
% 2. Autocorr for OFC as in 1. 
% 3. Cross Spectrum of simultaneously recorded ACC-OFC data.
% 
% 
% prasad shirvalkar mdphd


PAINSCORES=LFPmeta.autopain;
ACCSPECTRA=LFPspectra.autozacc;
OFCSPECTRA=LFPspectra.autozofc;


numtrials=length(PAINSCORES);
%sort the columns by pain score
[painsort,painsortindex] = sort(PAINSCORES);
% painsortindex=(1:100); %(to order by actual date)

c1= corr(ACCSPECTRA(:,painsortindex));
c2= corr(OFCSPECTRA(:,painsortindex));
c12=corr(ACCSPECTRA(:,painsortindex),OFCSPECTRA(:,painsortindex));

figure 
imagesc(c1);
title('ACC Cross-session Spectral correlation')
caxis([-.5 .5])
set(gca,'ydir','normal')
colorbar

figure
imagesc(c2);
title('OFC Cross-session Spectral correlation')
caxis([-.5 .5])
set(gca,'ydir','normal')
colorbar

figure
plot(LFPmeta.autopain(painsortindex),'r.','markersize',30)
ylabel('Pain Score 1-10')
xlabel('Session #')


figure
imagesc(c12);
caxis([-.5 .5])
title('ACC-OFC between region, Cross Session Spectral correlation')
colorbar
set(gca,'ydir','normal')

%% Calculate coherency  between OFC/ACC and LFP in all bands (skip this if done/saved already)
tic

params.Fs=422; 
params.tapers=[30 60];
params.pad=0;
params.fpass=[0 100];

[C,phi,S12,S1,S2,f]=coherencyc(LFP.acc,LFP.ofc,params);
toc

mC=mean(C);
LFPmeta.painmatch=logical(LFPmeta.painmatch);
LFPspectra.ALLcoherence=C;
LFPspectra.ALLcoherencefq=f;


close all
    yy=LFPmeta.pain(LFPmeta.pain>0);
    xx1=mC(LFPmeta.pain>0)';
    [coefC1,BINT1,R1,RINT1,cSTATS1] = regressplot(yy',xx1,6);
   
title('Coherence between ACC and OFC across all bands (1-100 Hz) vs Pain Score')
xlabel('Coherence')
ylabel('Pain Score')


%% PLOT within band coherence values

C=LFPspectra.ALLcoherence(:,logical(LFPmeta.painmatch));


% Band Limited Coherence
delta = (f>=2 & f<=4);
theta = (f>4 & f<=8);
alpha =(f>8 & f<=12);
beta = (f>12 & f<=30);
Lgamma =(f>30 & f<=70);
Hgamma = (f>70 & f<=100);   
bands= {'delta','theta','alpha','beta','Lgamma','Hgamma'};
bandlims={[2 4],[4 8],[8 12],[12 30],[30 70],[70 100]};


for b=1:6 % for each power band
    
    %ACC- OFC coherence
eval(['LFPspectra.coherence{b} = mean(C(' bands{b} ',:));']);
figure(2)
subplot(3,2,b)
hold all
% regress and plot line
x1=LFPspectra.coherence{b}';
Y=(LFPmeta.autopain');
%     Y=zscore(Y); %use this if you want to zscore the Pain scores
    [coefC(:,b),~,~,~,cSTATS(b,:)] = regressplot(Y,x1,6);
    title(bands{b});ylabel('Pain Score');xlabel('Coherence')
   
end

% ppt_export([PATIENTID 'general.pptx'])

LFPspectra.coherenceregress.stats=cSTATS;
LFPspectra.coherenceregress.coeff=coefC;


save([homepath PATIENTID 'LFPspectra.mat'],'LFPspectra')
save([homepath PATIENTID 'LFPhome.mat'],'LFP','LFPmeta')
disp(['LFPspectra saved for ' PATIENTID])
disp(['LFPhome saved for ' PATIENTID])



% 
% figure(1)
% imagesc(1:77,f,zscore(S1,0,2)); 
% figure(2)
% imagesc(1:77,f,zscore(S2,0,2)); 
% figure(3)
% imagesc(1:77,f,zscore(C,0,2)); 


%% HILBERT correlations between ACC and OFC


bands= {'delta','theta','alpha','beta','Lgamma','Hgamma'};
bandlims={[2 4],[4 8],[8 12],[12 30],[30 70],[70 100]};


tic
CC=cell(6,1);

indnum=find(LFPmeta.painmatch);
for bb=1:6

lo=bandlims{bb}(1);
hi=bandlims{bb}(2);


CC{bb}=zeros(length(indnum),1);


    for x=1:length(indnum)
        a=LFP.acc(:,indnum(x));
        b=LFP.ofc(:,indnum(x));
        

        a2=eegfilt(a',422,lo,hi);
        b2=eegfilt(b',422,lo,hi);
        ha=hilbert(a2);hb=hilbert(b2);
       
%         if (bb==1 && x ==21)
%        figure(11)
%        subplot 211
%        plot(a2); hold all; plot(abs(ha));
%        subplot 212
%        plot(b2); hold all; plot(abs(hb));
%         end
        
        
        a123=corrcoef(abs(ha),abs(hb)); %get the correlation coefficient
        CC{bb}(x)=a123(1,2);
    end
 
    
figure (10)
subplot (3,2,bb)
 title([num2str(lo) '-' num2str(hi) ' Hz'])
  Y=LFPmeta.autopain'; x1=CC{bb};
  regressplot(Y,x1,6);
 xlim([-.5 1])
 ylabel('Pain Score'); xlabel('Analytic Amplitude Correlation')
 title(bands{bb})
 
end

toc

LFPspectra.hilbertcorr=CC;

  save([homepath PATIENTID 'LFPspectra.mat'],'LFPspectra')
disp(['LFPspectra saved for ' PATIENTID])


