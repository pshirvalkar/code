% ACUTE PAIN MAIN FILE 
% This file will process all Acute Pain Activity related data, for
% Experiments conducted in clinic, including QST, pain activities, walking
% etc. 
% 
% Because data will be different for each session, each session should have
% a params file with the events of interest demarcated. 
% 
% 
% 
% 
% 
% 


%% Define the Patient ID
clear
 
PATIENTID = 'CP1';

if numel(PATIENTID)>3 %for referencing pain scores, times etc, use only PatientID #
    ptID3=PATIENTID(1:3);
else
    ptID3=PATIENTID;
end
%%




% import the time domain data
numsessions = size(filelist1,1) ;

for f=1:numsessions
    raw1=importdata(filelist1{f});
    rawdata{f}.ACC= raw1(:,1); %columns 1 (ACC) and 3 (OFC) are time domain data 
    rawdata{f}.OFC= raw1(:,3); 
    
   tvals=linspace(0,60,length(rawdata{f}.ACC));
   
   figure(1) 
   subplot(numsessions,1,f) 
   plot(tvals,rawdata{f}.ACC)
   ylim([-.1 .1])
   
    
   
   figure(2) 
   subplot(numsessions,1,f) 
   plot(tvals,rawdata{f}.OFC)
   ylim([-.5 .5])
   
end




%%
x=7;% which file to process
figure
time=linspace(0,length(rawdata{x}.ACC)/Fs,length(rawdata{x}.ACC));
plot(time,rawdata{x}.ACC)
hold
plot(time,(rawdata{x}.OFC-1))



%% 
clear S1 S2
winstep= [4 1]; %window len (s), window step (s)
params.tapers = [20 19]; %Time x BW,  #slepian tapers
params.Fs=Fs;
params.pad=-1;
params.fpass=([0 100]);

numsessions= size(rawdata,2);
for f= 1:numsessions
    
   
    [Sa,t1,fq1]= mtspecgramc(rawdata{f}.ACC,winstep,params);
    [So,t2,fq2]= mtspecgramc(rawdata{f}.OFC,winstep,params);
    
    S1(f,:,:)=Sa';
    S2(f,:,:)=So';
end

Sacc = log10(S1); 
Sofc = log10(S2); 

Zacc = zscore(Sacc,0,1);
Zofc = zscore(Sofc,0,1);

if ~isinteger(numsessions/2)
    numplots=numsessions+1;
else
    numplots=numsessions;
end


for x=1:numsessions
   
    figure (2)
    subplot(numplots/2,2,x)
    imagesc(t1,fq1,squeeze(Sacc(x,:,:))); axis xy; colorbar;
    caxis([-10 -4])
    
figure (3)
    subplot(numplots/2,2,x)
    imagesc(t1,fq1,squeeze(Zacc(x,:,:))); axis xy; colorbar;

    figure (4)
    subplot(numplots/2,2,x)
    imagesc(t1,fq1,squeeze(Sofc(x,:,:))); axis xy; colorbar;
    caxis([-10 -4])
    

figure (5)
  
    subplot(numplots/2,2,x)
    imagesc(t1,fq1,squeeze(Zofc(x,:,:))); axis xy; colorbar;
% caxis([-8 -1])


end

%% Spectrum C
clear M* S*
for x= 1:numsessions

params.tapers = [10 19];
params.Fs=Fs;
params.pad=-1;
params.fpass=([0 100]);
% for f= 1:size(rawdata,2)
    [Sacc{x},fq]= mtspectrumc(rawdata{x}.ACC,params);
    [Sofc{x},fq]= mtspectrumc(rawdata{x}.OFC,params);

    S10acc{x}=log10(Sacc{x});
    S10ofc{x}=log10(Sofc{x});
    Macc(:,x)=S10acc{x};
    Mofc(:,x)=S10ofc{x};
    
%     subplot(6,1,f)
% 
% figure (3)
% % subplot(numsessions,2,x)
%     plot(fq,(S10acc{x}')); axis xy; ylim([-10 -2]); title('ACC')
%     hold all
%     
% figure (4)
% % subplot(numsessions,2,x)
%     plot(fq,(S10ofc{x}')); axis xy; ylim([-10 -2]); title('OFC')
%     hold all
    
% end
end

Zacc=zscore(Macc);
Zofc=zscore(Mofc);

figure(3)
plot(fq,Zacc)
figure(4)
plot(fq,Zofc)


%% Power bands

bands= {'delta','theta','alpha','beta','Lgamma','Mgamma'}
delta = (fq>=2 & fq<=4);
theta = (fq>=4 & fq<=12);
alpha =(fq>=12 & fq<=20);
beta = (fq>=20 & fq<=30);
Lgamma =(fq>=30 & fq<=60);
Mgamma = (fq>=60 & fq<=100);   

% ACC mean power in bands
Pacc(1) = mean(S10acc{x}(delta));
Pacc(2) = mean(S10acc{x}(theta));
Pacc(3) = mean(S10acc{x}(alpha));
Pacc(4) = mean(S10acc{x}(beta));
Pacc(5) = mean(S10acc{x}(Lgamma));
Pacc(6) = mean(S10acc{x}(Mgamma));

% OFC mean power in bands
Pofc(1) = mean(S10ofc{x}(delta));   
Pofc(2) = mean(S10ofc{x}(theta));
Pofc(3) = mean(S10ofc{x}(alpha));
Pofc(4) = mean(S10ofc{x}(beta));
Pofc(5) = mean(S10ofc{x}(Lgamma));
Pofc(6) = mean(S10ofc{x}(Mgamma));

figure
subplot(211); bar(Pacc);set(gca,'xTickLabels',bands);
subplot(212);bar(Pofc);set(gca,'xTicklabels',bands);