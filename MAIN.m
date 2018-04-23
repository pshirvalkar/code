

 
PATIENTID = 'CP2Lt';
%% Process the visit data separately for each session
painscoreimport
ph1=what;
[r1,r2,r3]=fileparts(ph1.path);

addpath(genpath(fullfile(pwd,'toolboxes')));
activeinputfolder=uigetdir([r1 '/' PATIENTID '/data/rawdata/']); %here choose the folder to process
ProcessVisitData([activeinputfolder '/'], [r1 '/' PATIENTID '/data/processed/'],PATIENTID)

%% Combine the home visit files into one large Mat file. 
combine_home_data(PATIENTID)
combine_montage_data(PATIENTID) 

%% Data cleaning and Preprocessing

homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];
load([homepath 'LFPhome.mat'])

% Highpass > 1 Hz and correct DC offset
        params.sr=LFPmeta.fs(1); params.lowcutoff=1; %Sampling rate 422 Hz, and highpass above 1 hz
        LFP.acc=preproc_dc_offset_high_pass(LFP.acc,params); 
        LFP.ofc=preproc_dc_offset_high_pass(LFP.ofc,params); %highpass > 1 Hz and correct dc offset

% zscore the raw LFP and save separately
        LFP.zacc = zscore(LFP.acc);
        LFP.zofc = zscore(LFP.ofc); 
        
        
        
save([homepath 'LFPhome.mat'],'LFP','LFPmeta')


%%  HOME FILES  Basic Analyses - Generate Power Spectra and divide bands of interest
PATIENTID = 'CP1';
TIME_match = 10;
Time_to_compute = 15;
  
tic
%  All_Time_to_compute = [1,2,5,10,15,30,45,59] %how many seconds of data to use?
%  exportToPPTX('open','Sessionduration_vs_painscore.pptx');
% for x=1:8
%     Time_to_compute = All_Time_to_compute(x); %how many seconds of data to use?
  
close all

%  exportToPPTX

% Load the relevant .mat files
ph1=what;
[r1,r2,r3]=fileparts(ph1.path);
addpath(genpath(fullfile(pwd,'toolboxes')));
addpath(genpath([r1 '/data/']));
homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];
load([homepath 'LFPhome.mat'])
load painscores.mat
eval(['PS = painScores.' PATIENTID ';']);

% Compute the spectrum
LFPmeta = autoPainScore(LFPmeta,PS,TIME_match); %get indices of pain scores that are auto-matched, last val = #min to search for texted pain score to match
LFPspectra = home_spectra(LFP,LFPmeta,Time_to_compute); %to use z scored LFP add 'z' at end


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


homepath='/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/CP1/data/processed/home/';
addpath(homepath)
load LFPhome.mat
load LFPspectra 
LFPspectra = bandpower_and_pain_score_regression(LFPspectra,LFPmeta,'autopain');

%              figHandles = get(groot, 'Children');
%             exportToPPTX('addslide');
%             exportToPPTX('addtext',['Session duration - ' num2str(Time_to_compute) ' sec']);
%             exportToPPTX('addslide'); exportToPPTX('addpicture',figHandles(1));    
%             exportToPPTX('addslide'); exportToPPTX('addpicture',figHandles(2));
% 
% close all

% save([homepath 'LFPspectra.mat'],'LFPspectra')

%% Pain score vs spectra: This plots all sessions, vs frequency, organized by Pain score on that session

close all

% 
% load LFPspectra 
% load LFPhome

plot_session_spectra_vs_painscores(LFPspectra,LFPmeta,'autopain')

% 
%             figHandles = get(groot, 'Children');
%             exportToPPTX('addslide'); exportToPPTX('addpicture',figHandles(1));    
%             exportToPPTX('addslide'); exportToPPTX('addpicture',figHandles(2));
% close all
% time_loop{x}=LFPspectra;
% end
%             exportToPPTX('saveandclose','Sessionduration_vs_painscore.pptx');

%% calculate spectrograms  only for auto pain scores and save
params.tapers = [30 50];
params.Fs=422;
params.pad=0;
params.fpass=([0 100]);
params.windows = [5 1]; %window, winstep

calculate_spectrograms_autopain(LFP,LFPmeta,params)

load CP1specgram.mat
plot_session_spectrograms_with_painscores












