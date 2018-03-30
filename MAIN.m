
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
TIME_match = 10;
Time_to_compute = 10; %how many seconds of data to use?




ph1=what;
[r1,r2,r3]=fileparts(ph1.path);

addpath(genpath(fullfile(pwd,'toolboxes')));
addpath(genpath([r1 '/data/']));
homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];
load([homepath 'LFPhome.mat'])
load painscores.mat
eval(['PS = painScores.' PATIENTID ';']);
LFPmeta = autoPainScore(LFPmeta,PS,TIME_match); %get indices of pain scores that are auto-matched, last val = #min to search for texted pain score to match
LFPspectra = home_spectra(LFP,LFPmeta,Time_to_compute);


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
LFPspectra=bandpower_and_pain_score_regression(LFPspectra,LFPmeta,'autopain');

% save([homepath 'LFPspectra.mat'],'LFPspectra')

%% Pain score vs spectra: This plots all sessions, vs frequency, organized by Pain score on that session

homepath='/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/CP1/data/processed/home/';
addpath(homepath)

close all
clear
load LFPspectra 
load LFPhome

plot_session_spectra_vs_painscores(LFPspectra,LFPmeta,'autopain')


%% calculate spectrograms  only for auto pain scores and save
params.tapers = [30 50];
params.Fs=422;
params.pad=0;
params.fpass=([0 100]);
params.windows = [5 1]; %window, winstep

calculate_spectrograms_autopain(LFP,LFPmeta,params)

load CP1specgram.mat
plot_session_spectrograms_with_painscores











