%
% This script will import pain scores from XLS files, and organize them
% automatically based on dates and times. 
% 
% 
% The XLS Files are created by manual editing after TEXTIT download, and must be chosen
% separately for each patient. 
% 
% 1. The latest texting data should be in file 'Checklist_all_visits', in the
% Dropbox Folder / Study Visits/ CP1, CP2 etc-> This will organize data for all patients.
% 
% 2. Save the mat file with one cell array where painScores.CP1, CP2 etc are the outputs. 
%               output{:,1} are the times, and output{:,2} are the pain scores. 
% 
% 
% prasad shirvalkar mdphd 4/23/18 
% =======================================

%% Save the raw TEXTIT.IN exports as Texting Data organized in the Checklist_all_visits_CP1.xlsx (or CP2) and load it here
function [painScores,moodScores] = painscoreimport

ALL_pts = {'CP1','CP2'};

basepn=('/Users/pshirvalkar/Dropbox/SUBNETS Dropbox/Chronic Pain - Activa PC+S study/Study Visits/');
fn1=([basepn 'CP1/Checklist_all_visits_CP1.xlsx']);
fn2=([basepn 'CP2/Checklist_all_visits_CP2.xlsx']);
[paintimes,~,~]=xlsread(fn1,'Texting Data_PAIN'); 
[paintimes2,~,~]=xlsread(fn2,'Texting Data_PAIN'); 
[moodtimes,~,~]=xlsread(fn1,'Texting Data_MOOD'); 
[moodtimes2,~,~]=xlsread(fn2,'Texting Data_MOOD');


% for CP1
dateANDtime = datevec(datetime(paintimes(:,1),'ConvertFrom','excel','Format','yyyy-MM-dd'));
times=datevec(datetime(paintimes(:,2),'ConvertFrom','excel','Format','hh:mm:ss'));
painnums=paintimes(:,3); %these are pain scores
dateANDtime(:,4:6)=times(:,4:6);
    %FOR MOOD
    mdateANDtime = datevec(datetime(moodtimes(:,1),'ConvertFrom','excel','Format','yyyy-MM-dd'));
    mtimes=datevec(datetime(moodtimes(:,2),'ConvertFrom','excel','Format','hh:mm:ss'));
    moodnums=moodtimes(:,3); %these are mood scores (0 worst, 10 best)
    mdateANDtime(:,4:6)=mtimes(:,4:6);

    
    
    
% for CP2
dateANDtime2 = datevec(datetime(paintimes2(:,1),'ConvertFrom','excel','Format','yyyy-MM-dd'));
times2=datevec(datetime(paintimes2(:,2),'ConvertFrom','excel','Format','hh:mm:ss'));
painnums2=paintimes2(:,3); %these are pain scores
dateANDtime2(:,4:6)=times2(:,4:6);
    %FOR MOOD
    mdateANDtime2 = datevec(datetime(moodtimes2(:,1),'ConvertFrom','excel','Format','yyyy-MM-dd'));
    mtimes2=datevec(datetime(moodtimes2(:,2),'ConvertFrom','excel','Format','hh:mm:ss'));
    moodnums2=moodtimes2(:,3); %these are mood scores (0 worst, 10 best)
    mdateANDtime2(:,4:6)=mtimes2(:,4:6);


painScores.CP1{:,1} = datetime(dateANDtime);
painScores.CP2{:,1} = datetime(dateANDtime2);

painScores.CP1{:,2} = painnums;
painScores.CP2{:,2} = painnums2;

moodScores.CP1{:,1} = datetime(mdateANDtime);
moodScores.CP2{:,1} = datetime(mdateANDtime2);

moodScores.CP1{:,2} = moodnums;
moodScores.CP2{:,2} = moodnums2;


        
save('/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/painscores.mat','painScores','moodScores');

disp('painscores.mat saved')

