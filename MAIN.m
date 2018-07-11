
clear
 
PATIENTID = 'CP2Lt';


if numel(PATIENTID)>3 %for referencing pain scores, times etc, use only PatientID #
    ptID3=PATIENTID(1:3);
else
    ptID3=PATIENTID;
end


homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];
load([homepath PATIENTID 'LFPhome.mat'])
load([homepath PATIENTID 'LFPspectra.mat'])
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
load([homepath PATIENTID 'LFPhome.mat'])

% Highpass > 1 Hz and correct DC offset
        params.sr=LFPmeta.fs(1); params.lowcutoff=1; %Sampling rate 422 Hz, and highpass above 1 hz
        LFP.acc=preproc_dc_offset_high_pass(LFP.acc,params); 
        LFP.ofc=preproc_dc_offset_high_pass(LFP.ofc,params); %highpass > 1 Hz and correct dc offset

% zscore the raw LFP and save separately
        LFP.zacc = zscore(LFP.acc);
        LFP.zofc = zscore(LFP.ofc); 
        
      
save([homepath PATIENTID 'LFPhome.mat'],'LFP','LFPmeta')
disp([PATIENTID 'LFPhome.mat saved again'])
        
%% Split the recordings by unique electrode contacts and save this index.
homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];
load([homepath PATIENTID 'LFPhome.mat'])

LFPmeta = contact_sort(LFPmeta); 


save([homepath PATIENTID 'LFPhome.mat'],'LFP','LFPmeta')
disp([PATIENTID 'LFPhome.mat saved '])

%%  HOME FILES  Basic Analyses - Generate Power Spectra and divide bands of interest 
TIME_match = 10; %for pain scores auto matching base on time from recording (mins)
Time_to_compute = []; %duration of LFP recording to use (seconds)
  
tic

% Load the relevant .mat files
ph1=what;
[r1,r2,r3]=fileparts(ph1.path);
addpath(genpath(fullfile(pwd,'toolboxes')));
addpath(genpath([r1 '/data/']));
homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];
load([homepath PATIENTID 'LFPhome.mat'])
load painscores.mat
eval(['PS = painScores.' ptID3 ';']);
eval(['MS = moodScores.' ptID3 ';']);

% Compute the spectrum
LFPmeta = autoPainScore(LFPmeta,PS,MS,TIME_match); %get indices of pain scores that are auto-matched, last val = #min to search for texted pain score to match
LFPspectra = home_spectra(LFP,LFPmeta,Time_to_compute); %to use z scored LFP add 'z' at end


save([homepath PATIENTID 'LFPspectra.mat'],'LFPspectra')
save([homepath PATIENTID 'LFPhome.mat'],'LFP','LFPmeta')
disp(['LFPspectra saved for ' PATIENTID])
disp(['LFPhome saved for ' PATIENTID])

%% REGRESSIONS IN BANDS  of interest vs pain score  +PLOTS /separately for each electrode pair per brain region
homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];
load([homepath PATIENTID 'LFPspectra.mat']);


LFPspectra = bandpower_and_pain_score_regression(LFPspectra,LFPmeta,'autopain');
    

% Pain score vs spectra: This plots all sessions, vs frequency, organized by Pain score on that session
figure
plot_session_spectra_vs_painscores(LFPspectra,LFPmeta,'autopain')



save([homepath PATIENTID 'LFPspectra.mat'],'LFPspectra')
disp(['LFPspectra saved for ' PATIENTID])

%% Decoding of Pain Score based on classifier
make_feature_vector_decode
[trainedClsfr,valAccuracy,valScores]=CP1_SVM(wekatable)




%%  Mean Spectra for different pain score values
%find unique pain scores, index them, compute averaged mtspectra with
%error bars for each unique pain score, then plot
close all
homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];addpath(homepath)
load([PATIENTID 'LFPhome.mat']);



[normSacc,normSofc,Saccerr,Sofcerr,painvals,f] = mean_PSD_per_pain_value(LFP,LFPmeta);

subplot 121
plot(f,(normSacc))
% legend(painvals)
title('ACC avg spectra for each pain value')
subplot 122
plot(f,(normSofc))
legend(painvals)
title('OFC avg spectra for each pain value')



%% calculate spectrograms  only for auto pain scores and save
params.tapers = [10 19];
params.Fs=422;
params.pad=1;
params.fpass=([0 100]);
params.windows = [2 .5]; %window, winstep

calculate_spectrograms_autopain(LFP,LFPmeta,params,PATIENTID)

load([PATIENTID 'specgram.mat'])
plot_session_spectrograms_with_painscores












