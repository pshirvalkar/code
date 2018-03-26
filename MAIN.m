
PATIENTID = 'CP1';
%% Process the visit data separately for each session
painscoreimport
ph1=what;
[r1,r2,r3]=fileparts(ph1.path);

addpath(genpath(fullfile(pwd,'toolboxes')));

ProcessVisitData([r1 '/data/raw_data/Session_2018_03_13_Tuesday/'],[r1 '/data/processed/'],PATIENTID)

%% Combine the home visit files into one large Mat file. 
combine_home_data(PATIENTID)
combine_montage_data(PATIENTID)


%%  HOME FILES  Basic Analyses - Generate Power Spectra and divide bands of interest
PATIENTID = 'CP1';
TIME_match = 5;





ph1=what;
[r1,r2,r3]=fileparts(ph1.path);

addpath(genpath(fullfile(pwd,'toolboxes')));
addpath(genpath([r1 '/data/']));
homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];
load([homepath 'LFPhome.mat'])
load painscores.mat
eval(['PS = painScores.' PATIENTID ';']);
LFPmeta = autoPainScore(LFPmeta,PS,TIME_match); %get indices of pain scores that are auto-matched, last val = #min to search for texted pain score to match
LFPspectra = home_spectra(LFP,LFPmeta);


nozero=LFPmeta.pain>0; % exclude sleep trials
LFPmeta.no0pain=LFPmeta.pain(nozero);


save([homepath 'LFPspectra.mat'],'LFPspectra')
save([homepath 'LFPhome.mat'],'LFP','LFPmeta')
disp(['LFPspectra saved for ' PATIENTID])
disp(['LFPhome saved for ' PATIENTID])
    
% %% plot single spectrum and show image. 
% x=21;
% 
% figure 
% plot(LFPspectra.fq(:,x),LFPspectra.acc(:,x))
% xlabel('Frequency (Hz)')
% ylabel('Log 10 Power')
% title('Example spectrogram')
% 
% figure
% imagesc(1,LFPspectra.fq(:,x),LFPspectra.acc(:,x))
% ylabel('Frequency (Hz)')
% set(gca,'Ydir','normal','xticklabel','')


%% REGRESSIONS IN BANDS  of interest vs pain score 
clear

homepath='/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/CP1/data/processed/home/';
addpath(homepath)
load LFPhome.mat
load LFPspectra 
LFPspectra=bandpower_and_pain_score_regression(LFPspectra,LFPmeta,'relative');

% save([homepath 'LFPspectra.mat'],'LFPspectra')

%% Pain score vs spectra: This plots all sessions, vs frequency, organized by Pain score on that session

homepath='/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/CP1/data/processed/home/';
addpath(homepath)

close all
clear
load LFPspectra 
load LFPhome

PAINSCORES=LFPmeta.autopain;
ACCSPECTRA=LFPspectra.autozacc;
OFCSPECTRA=LFPspectra.autozofc;

% % RELATIVE POWER
%             PAINSCORES=LFPmeta.autopain;
%             LFPmeta.painmatch = logical(LFPmeta.painmatch);
%             ACCSPECTRA=LFPspectra.acc(:,LFPmeta.painmatch) ./ sum(LFPspectra.acc(:,LFPmeta.painmatch));
%             OFCSPECTRA=LFPspectra.ofc(:,LFPmeta.painmatch) ./ sum(LFPspectra.ofc(:,LFPmeta.painmatch));
%             

% %non-zscored power 
% imagesc(1:numtrials,LFPspectra.fq(:,1),LFPspectra.acc)
% set(gca,'Ydir','normal')
% title('Spectra ordered by session')
% xlabel('Session'); ylabel('Frequency(Hz)')

numtrials=length(PAINSCORES);
%sort the columns by pain score
[painsort,painsortindex] = sort(PAINSCORES);

imagesc(1:numtrials,LFPspectra.fq(:,1),ACCSPECTRA(:,painsortindex));
colorbar
hold all 
plot(PAINSCORES(painsortindex).*10,'w.','markersize',20) %scatter the pain scores
xlabel('Session') 
ylabel('Frequency or Pain Score x 10')
title('ACC zscored power spectra')
set(gca,'Ydir','normal')
set(gcf,'position',[300 200 500 400])
% caxis([-2 3])

figure
imagesc(1:numtrials,LFPspectra.fq(:,1),OFCSPECTRA(:,painsortindex));
colorbar
hold all 
plot(PAINSCORES(painsortindex).*10,'w.','markersize',20) %scatter the pain scores
xlabel('Session') 
ylabel('Frequency or Pain Score x 10')
title('OFC zscored power spectra')
set(gca,'Ydir','normal')
set(gcf,'position',[800 200 500 400])
% caxis([-2 3])





%% calculate spectrograms and save

params.tapers = [5 7];
params.Fs=422;
params.pad=-1;
params.fpass=([0 100]);
   
    [Sacc,t1acc,fq]= mtspecgramc(LFP.acc,[5 0.5],params);
%     figure (3)
%     subplot(3,2,f)
%     imagesc(t1{f},fq,(log10(S{f}'))); axis xy; colorbar; 
%     caxis ([-10 -4]); text(10,90,sprintf('Contacts %d - %d',ACCleads(f,1),ACCleads(f,2)),'color','w');
    
    [Sofc,t1ofc,fq]= mtspecgramc(LFP.ofc,[5 0.5],params);
%     figure (4)
%     subplot(3,2,f)
%     imagesc(t1{f},fq,(log10(S{f}'))); axis xy; colorbar; 
%     caxis ([-10 -4]); text(10,90,sprintf('Contacts %d - %d',ACCleads(f,1)+8,ACCleads(f,2)+8),'color','w'    )

