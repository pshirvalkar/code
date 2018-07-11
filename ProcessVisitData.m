function ProcessVisitData(varargin)
%% Function Process Visit Data 
% This function takes a new Recording folder with LFP data from a single
% recording session/visit and organizes it. 

% FIRST RUN PAINSCOREIMPORT.m
% 
% What it does: 
% 1) Adds the files into subfolders based on type of recording:
%        -Montage 
%        -Home Recordings (with Pain Score) 
%        -During Painful activity
%        -Pre and Post Medication
%        -QST sessions
%        
% 2) creates a Task json in the parent folder (this is easier to read
% than XML for quick reference)
% 3) Creates session jsons that must be populated as well. 
%
% INPUTS:
%     Input Directory (Recording session folder to add)
%     Output directory (where to put processed files)
%     Patient ID - eg. 'CP1', 'CP2' etc.
% 
%Prasad Shirvalkar, mdphd, updated 3/2018
%
%Adapted from Roee Gilron's scripts- 2017 - (aka. Roee's addBrainaRadioVisit)
clc
ph1=what;
[r1,r2,r3]=fileparts(ph1.path);
if nargin == 3
    dirorganize = varargin{1};
    processfolder = varargin{2};
    ptID = varargin{3};
    name_len=length(ptID)+11;
else
    disp('Choose Recording Session Folder to add')
    dirorganize = uigetdir([r1 '/data/']);
    processfolder = fullfile(r1,'data','processed/');
    disp('enter patient ID (CP1, CP2) as third input)')

end
   disp(['Organized data will be output to ...' r1(end-3:end) '/data/processed/'])

%% find files from the current folder, extract Time Series and Find montage status
fftxt=findFilesBVQX(dirorganize,'*_MR_*.txt'); %find all recording files in that folder
%% get timeseries and find text files
for f = 1:length(fftxt)
    [pn,fn,ext] = fileparts(fftxt{f});
        xmlfnm = [fn '.xml'];
    
    %Import and organize the xml file with metadata
    xmlstruc = xml2struct(fullfile(pn,xmlfnm));
    if isfield(xmlstruc,'RecordingItem')
        xmlstrucparsed = parseXMLstruc(xmlstruc);
    else
       sprintf(['invalid XML file? - ' fn])
    end
   
    xmldata = xmlstrucparsed.RecordingItem;
        [Y, M, D, H, MN, S] = datevec(xmldata.RecordingDuration,'HH:MM:SS'); %calculate recording duration
        recDurSec = (H*3600)+(MN*60)+S; 
        
    % dat is a structure holding pathname, filename, recording duration and
    % montage status for processing Montage Files, this is sorted and
    % becomes dattablSort
    dat(f).pn = pn;
    dat(f).fn = fn;
    dat(f).ff = fftxt{f}; 
    dat(f).time = datetime(datevec(xmldata.INSTimeStamp,'mm/dd/yyyy HH:MM:SS PM'));
    dat(f).RecDurSecs = recDurSec; 
    dat(f).ismontage = strcmp(xmldata.RecordingType,'Montage');
    dat(f).Fs=xmldata.SenseChannelConfig.TDSampleRate(1:3);
    dat(f).contacts=[xmldata.SenseChannelConfig.Channel1.PlusInput xmldata.SenseChannelConfig.Channel1.MinusInput ...
        '/' xmldata.SenseChannelConfig.Channel3.PlusInput xmldata.SenseChannelConfig.Channel3.MinusInput];
end

if length(dat)>1  %to format the table into cells if only one entry
    datTable = struct2table(dat); %take the structure and make it a table to useelse
else
    datTable = struct2table(dat,'AsArray',true); %take the structure and make it a table to useend
end

%% create groupings
dattablSort = sortrows(datTable, 'time');
exts = {'.txt','.xml'};
f = 1;
grpcnt = 1; %this allows multiple files from each type to be separated

logexc = cellfun(@any, strfind( dattablSort.fn,'raw')); %exclude Raw files (now out of date)
dattablSort = dattablSort(~logexc,:); 

while f <= size(dattablSort,1)
   
    %xmlhold is a structure holding all XML data related to the TXT file.
    %ONLY the first montage file (of 6) will have an XML file associated
    %with it.
    xmlhold(grpcnt).num = grpcnt; 
    xmlhold(grpcnt).Fn = dattablSort.fn{f};
    xmlhold(grpcnt).Date = string(dattablSort.time(f));
    xmlhold(grpcnt).Dur = string(seconds(dattablSort.RecDurSecs(f))) ;
    xmlhold(grpcnt).Fs = dattablSort.Fs(f);
    xmlhold(grpcnt).contacts = dattablSort.contacts(f);
    xmlhold(grpcnt).Task = '';
    xmlhold(grpcnt).Med = '';
    xmlhold(grpcnt).MedName = '';
    xmlhold(grpcnt).PainScore= '';
    xmlhold(grpcnt).TimeFromMed= '';
    
    
%% Put all montage files into separate folder. 
    if dattablSort.ismontage(f)
        
        montageonly =1; %reports if folder only contains only montage files
        xmlhold(grpcnt).Task = 'montage'; 
        montagedirmove=[processfolder 'montage/' dattablSort.fn{f}(1:(length(ptID)+11))];
        warning('off','MATLAB:MKDIR:DirectoryExists'); %turn off this dumb warning
        mkdir(montagedirmove);
        idxm = f;
        
        %copy all txt and xml files into montage subfolder
        for i = idxm:idxm+5 %There are 6 contact pairs by default = 6 montage files
            for s = 1:2
                src = fullfile(dattablSort.pn{i},[dattablSort.fn{i} exts{s}]);
                des = fullfile(montagedirmove,[dattablSort.fn{i} exts{s}]);
                    copyfile(src,des); 
                    
            end
%             build the montage XML output
             [pn,fn,ext] = fileparts(fftxt{i});
             xmlfnm = [fn '.xml'];        
             xmlmontage(i).Fn = dattablSort.fn{i};
             xmlmontage(i).Date = char(dattablSort.time(i));
             xmlmontage(i).Dur = char(seconds(dattablSort.RecDurSecs(i))) ;
             xmlmontage(i).Fs = dattablSort.Fs{i};
             xmlmontage(i).Contacts = dattablSort.contacts{i}; %try without curly braces (i) if breaks here
             
%              load each file for saving into mat below
           raw1=importdata([montagedirmove '/' dattablSort.fn{i} '.txt']);
           montageLFP(i).ACC= raw1(:,1); %columns 1 (ACC) and 3 (OFC) are time domain data
           montageLFP(i).OFC= raw1(:,3);
        end
        f = idxm+6;
        
        
        % create MONTAGE JSON FILE 
        savejson('',xmlmontage,fullfile(montagedirmove, 'Montage-details.json'));

        % save MAT file HERE
        xmlmTab = struct2table(xmlmontage);
        save([montagedirmove '/montage-' xmlmontage(idxm).Fn(1:name_len)],'montageLFP','xmlmTab');
        clear raw1 montageLFP
    else % if not montage,  move to next section 
        f = f+1;
    end  %end montage vs other sorter  
    grpcnt = grpcnt + 1;
end

xmltasknames={xmlhold.Task};
xmlindM=strcmp(xmltasknames,'montage'); %check which files are montage related (montage will only have first file)
%% What to do with NON-MONTAGE FILES  (everything else)

if size(xmlhold,2)>1 || (xmlindM==0)%if there are more than just montage files..
%     Find which xml index is from montage and exclude that one for Task ID

montageonly = 0;
if length(xmlhold)>1  %to format the table into cells if only one entry
xmlTable = struct2table(xmlhold(~xmlindM));
else
xmlTable = struct2table(xmlhold(~xmlindM),'AsArray',true);
end

% Load Painscores from text messaging file and patient ID from input 3 above (created by painscoreimport.m)
load painscores.mat
if strncmp(ptID,'CP2',3)
    ptID2='CP2';
else
    ptID2=ptID;
end

eval(['pt_pain = painScores.' ptID2]);
eval(['pt_mood = moodScores.' ptID2]);


%% Assign Tasks, Pain scores etc to Task files (GETVISITDETAILS here, which opens user input table)
% Open excelfile for Pain Score reference if needed.
% system(['open -a "Microsoft Excel" All_Text_data.xlsx'])

        %xmltable input => compTab output
        compTable = getVisitDetails(xmlTable,pt_pain,pt_mood); % user input visit conditions - med, task status, pain Score etc into a pop-up UI TABLE
        compTab = cell2table(compTable);
        compTab.Properties.VariableNames = {'fn','Time','Dur','Fs','Contacts','Task','Med','MedName','Painscore','Moodscore','TimeFromMed','StimSide','StimContacts','StimPW','StimFreq','StimAmp','StimDur','Notes'};
       
        diffTasks= unique(compTab.Task);
        
        for u=1:size(diffTasks,1) %For each unique task
            taskind = strcmp(compTab.Task,diffTasks(u));
            taskTab=compTab(taskind,:);
        % Copy each file into the Task Folder assigned to it in the prior step
            for d = 1:size(taskTab)
            
            taskdir=[processfolder taskTab.Task{d} '/' taskTab.fn{d}(1:name_len)];
%only first length(ptID+11) [14(for CP1) or 16(for CP2Lt)] characters signify unique folder named
            mkdir(taskdir);
            copyfile([dirorganize taskTab.fn{d} '.txt'],taskdir); 
            copyfile([dirorganize taskTab.fn{d} '.xml'],taskdir);
              raw1=importdata([dirorganize taskTab.fn{d} '.txt']);
           taskLFP(d).ACC= raw1(:,1); %columns 1 (ACC) and 3 (OFC) are time domain data
           taskLFP(d).OFC= raw1(:,3);
            end
            
            
            %% create Task json 
       
        savejson('',table2struct(taskTab),fullfile(taskdir, 'Task-metadata.json'));
        
%         save Task Mat file 
        save([taskdir '/task-' taskTab.fn{1}(1:name_len)],'taskLFP','taskTab');
        clear raw1 taskLFP
        end
       
     
end
%% move misc and LOG files into separate folder:
        endings = {'*LOG.txt','*RT.txt','*RT.xml'};
        extradir = fullfile(processfolder,'logs-misc');
        mkdir(extradir);

        for e = 1:length(endings)
            ff = findFilesBVQX(dirorganize,sprintf(endings{e}),...
                struct('depth',1));
            for d = 1:length(ff)
                [pn,fn,ext] = fileparts(ff{d});
                copyfile(ff{d},fullfile(extradir,[fn ext]));
            end
        end
        
%%
  
rawfolder = strfind(dirorganize,'data');
disp([dirorganize(rawfolder(end)+4:end)  ' has been organized'])

if montageonly>0
    
    disp('Folder only contains Montage Files')
end

end