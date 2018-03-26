function [LFP,LFPmeta]=combine_montage_data(patientID)

%This function will run through all the MONTAGE data and combined the mat
%files into a large mat file that can be used to analyze all data
%simulataneously. 
% 
% 
% INPUTS:   patientID to process (ie.) 'CP1'
% 
% OUTPUTS:
%           LFP and LFPmeta described below:
% 
% 
% THIS FUNCTION ASSUMES 
%   Home folder of: '/Users/prasad/Desktop/ChangLab DATA/DBS CP matlab analysis/ ... patientID.../data/processed/montage/'
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

montagepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' patientID '/data/processed/montage/'];
montagesubpath=strsplit(genpath(montagepath),':');

homeind=1;



%search for mat files in the subfolders and combine them. 
for h=2:length(montagesubpath)-1 %last folder is empty/ ignore {1} root dir
    
    
    W=what(montagesubpath{h});
    
    if ~isempty(W.mat) %if a mat file exists
        fn = cell2mat(strcat(W.path,'/',W.mat));
        load(fn,'montageLFP','xmlmTab'); 

        
%         find nonempty cells
emptyTabrows = cellfun(@isempty,table2array(xmlmTab)); 
datarows1=find(emptyTabrows(:,1)<1); 

        for x=datarows1(1):datarows1(end) %index this to add them together. 
  
            LFP.acc(1:length(montageLFP(x).ACC),homeind)= montageLFP(x).ACC;
            LFP.ofc(1:length(montageLFP(x).OFC),homeind)= montageLFP(x).OFC;
            LFPmeta.time(homeind,:) = xmlmTab.Date{x};
            LFPmeta.contacts{homeind} = xmlmTab.Contacts{x};
            LFPmeta.fs(homeind) = str2double(xmlmTab.Fs{x});
            
            homeind = homeind+1;
   
        end
        
        clear xmlm* montageLFP
    end
    
end

LFPmeta.time = datetime(LFPmeta.time);

LFPout = [montagepath 'LFPmontage.mat'];
save(LFPout,'LFP','LFPmeta');
disp('Mat file "LFPmontage" saved - Done Combining')
