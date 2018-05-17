function [LFP,LFPmeta]=combine_home_data(patientID)

%This function will run through all the home visit data and combined the mat
%files into a large mat file that can be used to analyze all data
%simulataneously. Pain scores etc and in structure format
%  
% INPUTS:   patientID is the ID of patient to process (ie.) 'CP1'
% 
% OUTPUTS:
%           LFP and LFPmeta described below:
% 
% 
% THIS FUNCTION ASSUMES 
%   Home folder of: '/Users/prasad/Desktop/ChangLab DATA/DBS CP matlab analysis/... patient ID... /data/processed/home/'
%   and Saves combined Mat file: LFPhome to the above directory.
% 
% 
%   LFP data is organized into a structure with fields: 
%             LFP.acc and LFP.ofc, with time series data 
%               organized in columns, where each column is a separate recording
%             LFPmeta containing metadata including 
%                 LFPmeta.time  - timestamps
%                 LFPpain - pain scores 
%                 LFPmeta.fs - sampling rate
%                 LFP.contacts - electrode contact pairs ACC//OFC  
% 
%            
%
%  prasad shirvalkar mdphd 3/8/2018

homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' patientID '/data/processed/home/'];
homesubpath=strsplit(genpath(homepath),':');

homeind=1;


%search for mat files in the subfolders and combine them. 
for h=2:length(homesubpath)-1
% Ignore the first entry to homesubpath, which is root directory, and last folder is empty

    W=what(homesubpath{h});
    
    if ~isempty(W.mat) %if a mat file exists
        fn = cell2mat(strcat(W.path,'/',W.mat));
        load(fn,'taskLFP','taskTab'); 

        for x=1:length(taskLFP) %index this to add them together. IF there 
%               is a shorter recording, pad it with zeros so that it fits in 
%               the matrix
            
numsamp = length(taskLFP(x).ACC);

            LFP.acc(1:numsamp,homeind)= taskLFP(x).ACC;
            LFP.ofc(1:numsamp,homeind)= taskLFP(x).OFC;
            LFPmeta.time(homeind,:) = taskTab.Time{x};
            LFPmeta.pain(homeind) = taskTab.Painscore(x);
            LFPmeta.fs(homeind) = str2double(taskTab.Fs{x});
            LFPmeta.contacts{homeind}=taskTab.Contacts{x};
         
   
           a=strcmp(taskTab.Properties.VariableNames,'Moodscore');
           if sum(a)>0 %if mood scores exist
            LFPmeta.mood(homeind) = taskTab.Moodscore(x);
           end
              homeind = homeind+1;
        end
        
        clear task*
    end
    
end

LFPmeta.time = datetime(LFPmeta.time);

LFPout = [homepath patientID 'LFPhome.mat'];
save(LFPout,'LFP','LFPmeta');
disp(['Mat file "' patientID 'LFPhome" saved - Done Combining'])
