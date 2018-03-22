%
% This script will import pain scores from XLS files, and organize them
% automatically based on dates and times. 
% 
% 
% The XLS Files are created using EXPORT from www.textit.in
% 
% 1. The latest texting data should be in file 'All_Text_data.xlsx', in the
% Dropbox Folder / Study Visits/ -> This will organize data for all
% patients.
% 2. Save the mat file with one cell array where painScores.CP1, CP2 etc are the outputs. 
%               output{:,1} are the times, and output{:,2} are the pain scores. 
% 
% 2.1 When running Process Visit Data for each session, it will search for
% pain score times within 1 hour  of the recording (30 mins pre and post)
% in getVisitDetails
% 
% prasad shirvalkar mdphd 3/21/18 745pm
% =======================================

%% Save the raw TEXTIT.IN exports as All_Text_data.xlsx and load it here
function painscoreimport

pn=which('All_Text_data.xlsx');
[paintimes,raw,~]=xlsread(pn);  

dateANDtime = datevec(datetime(paintimes(:,1),'ConvertFrom','excel','Format','yyyy-MM-dd'));
times=datevec(datetime(paintimes(:,1),'ConvertFrom','excel','Format','hh:mm:ss'));
painnums=paintimes(:,7); %these are pain scores
dir_incoming=strcmp(raw(:,6),'Incoming');  %take only incoming text msgs (not outgoing)

dateANDtime=dateANDtime(dir_incoming,:); 
times=times(dir_incoming,:);
raw=raw(dir_incoming,:);
painnums=painnums(dir_incoming);

dateANDtime(:,4:6)=times(:,4:6);

[patientnames,~,indraw]=unique(raw(:,4));
unq_pt_ind=strncmp(patientnames,'CP',2) & cellfun(@length,patientnames)==3; %length of 3 chars, including letters 'CP'
 

% Create structures where the painScore.CP1, etc are built with times and painScores
 for p = find(unq_pt_ind)'
     
     hold_dt = datetime(dateANDtime(p==indraw,:)); % all the date/times for that patient
     holdpainscore = painnums(p==indraw,7); %all pain scores for pt.
     [maybenum,status1] = cellfun(@str2num,holdpainscore,'UniformOutput',0); %DO NOT NEED THIS LINE
     num_ind=cellfun(@logical,status1);
     i=1;
     for n = 1:length(num_ind)
         
      if maybenum{n} <=10 & length(maybenum{n})==1
        eval(['painScores.' patientnames{p} '{1}(i)=hold_dt(n);']); %write the date and time
        eval(['painScores.' patientnames{p} '{2}(i)=maybenum{n};']); %write the pain score values
        i=i+1;
       
      end
     end
     
     
 end
 
     
save('/Users/prasad/Desktop/ChangLab DATA/DBS CP matlab analysis/painscores.mat','painScores');

disp('painscores.mat saved')



%% Alternative is to import from Checklist_all_visits which can be done manually. 
