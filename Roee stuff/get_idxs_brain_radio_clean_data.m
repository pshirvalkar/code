 function get_idxs_brain_radio_clean_data(varargin)
if ~isempty(varargin{1})
    datadir = fullfile(varargin{1}{1},'data');
else
    fprintf('choose folder that contains that data .mat file for start end choice \n');
    datadir = uigetdir('choose data dir');
end
[pn,fn,ext] = fileparts(datadir);
load(fullfile(datadir,'dataBR.mat'));
logclean = strcmp(datTab.task,'rest') | strcmp(datTab.task,'ipad')  | strcmp(datTab.task,'walking') ;
totalfiles = sum(logclean);
cntcln = 1; 
for s = 1:size(datTab,1)
    data =  [datTab.lfp{s}'; datTab.ecog{s}'];
    logclean = strcmp(datTab.task{s},'rest') | strcmp(datTab.task{s},'ipad')  | strcmp(datTab.task{s},'walking') ;
    if logclean
        idxclean(s,:) = round(select_clean_data_chunk(data));
        fprintf('file %d out of %d done task - %s time -%s \n',...
            cntcln,totalfiles,...
            datTab.task{s},datTab.time{s});
        cntcln = cntcln + 1;
    else
        idxclean(s,:)  = [NaN NaN];
    end
end
datTab.idxclean = idxclean;
save(fullfile(datadir,'dataBR.mat'),'datTab');

end