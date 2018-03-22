function organize_brain_radio_data(varargin)
%  This calls the folder organizer function: ProcessVisitData.m

if ~isempty(varargin{1}) %get the root directory with new recording files
    rootdir = varargin{1}{1};
    if ~any(exist(fullfile(rootdir,'Protocol-details.json'),'file'))
        fprintf('choose visit dir with brain radio text files (must be in one dir)\n');
        ProcessVisitData(rootdir);
    else
        fprintf('json file exist, choose visit dir \n');
    end
else
    %% organize brain radio files
    fprintf('choose visit dir for data saving \n');
    rootdir = uigetdir('choose visit dir to save data .mat');
    
    if ~any(exist(fullfile(rootdir,'Protocol-details.json'),'file'))
        fprintf('choose visit dir with brain radio text files (must be in one dir)\n');
        addBrainRadioVisit(rootdir);
    else
        fprintf('json file exist, choose visit dir \n');
    end
end
%% create data and figures folder
mkdir(fullfile(rootdir,'data'));
mkdir(fullfile(rootdir,'figures'));
datdir = fullfile(rootdir,'data');
figdir = fullfile(rootdir,'figures');
%% create table of data
sessiondirs = findFilesBVQX(rootdir,'s_*',...
    struct('dirs',1,'depth',1));
jsonfn = fullfile(rootdir,'Protocol-details.json');
visitjson = loadjson(jsonfn,'SimplifyCell',1); % this is how to read the data back in.
cnt = 1;
for s = 1:length(sessiondirs)
    filesfound = findFilesBVQX(sessiondirs{s},'*.txt');
    if length(filesfound) == 1 % could be raw file 
        [pn,fn,ext] = fileparts(filesfound{1});
        fileuse = fullfile(pn,[fn ext]);
        clear pn fn ext 
    elseif length(filesfound) == 2 % only choose the non raw file 
        [pn{1},fn{1},ext] = fileparts(filesfound{1});
        [pn{2},fn{2},ext] = fileparts(filesfound{2});
        fnuse = fn{~cellfun(@(x) any(strfind(x,'_raw')),fn)};
        pnuse = pn{1};
        fileuse = fullfile(pnuse,[fnuse ext]);
        clear pn fn ext 
    elseif length(filesfound) >= 3 & ~strcmp(visitjson(s).task,'montage')
        error('too many files in session')
    end
    
    % only loop on files if its a montage 
    if strcmp(visitjson(s).task,'montage')
        ffn = filesfound; 
        fnuse = ffn(~cellfun(@(x) any(strfind(x,'_raw')),ffn)); % get rid of raw files 
        ffn = fnuse; 
    else
        ffn{1} = fileuse; 
    end
    
    for ff = 1:length(ffn)
        fileuse = ffn{ff};
        [pn,fn,ext] = fileparts(fileuse);
        
        if any(strfind(fn,'raw')) % if its a raw file, get xml data from non raw xml
            xmlfnm = [fn(1:end-4) '.xml'];
        else
            xmlfnm = [fn '.xml'];
        end
        
        
        
        xmlstruc = xml2struct(fullfile(pn,xmlfnm));
        if isfield(xmlstruc,'RecordingItem')
            xmlstrucparsed = parseXMLstruc(xmlstruc);
        else
            xmlstrucparsed = parseXMLstruc2(xmlstruc);
        end
        xmldata = xmlstrucparsed.RecordingItem;
        
        data = importdata(fileuse);
        datout(cnt).patient   = fn(1:6);
        datout(cnt).sessionum = visitjson(s).num;
        datout(cnt).time      = visitjson(s).time;
        datout(cnt).duration  = visitjson(s).dur;
        datout(cnt).task      = visitjson(s).task;
        datout(cnt).med       = visitjson(s).med;
        datout(cnt).stim      = visitjson(s).stim;
        datout(cnt).sr        = getsampleratefromxml(xmlstrucparsed);
        datout(cnt).ecog      = data(:,3);
        datout(cnt).ecog_elec = sprintf('+%s-%s',...
            xmlstrucparsed.RecordingItem.SenseChannelConfig.Channel3.PlusInput,...
            xmlstrucparsed.RecordingItem.SenseChannelConfig.Channel3.MinusInput);
        datout(cnt).lfp       = data(:,1);
        datout(cnt).lfp_elec  = sprintf('+%s-%s',...
            xmlstrucparsed.RecordingItem.SenseChannelConfig.Channel1.PlusInput,...
            xmlstrucparsed.RecordingItem.SenseChannelConfig.Channel1.MinusInput);
        cnt = cnt +1;
        clear pn fn ext  
    end
    clear ffn 
end
datTab = struct2table(datout);
fnmsave = fullfile(datdir,'dataBR.mat');
save(fnmsave,'datTab');
end