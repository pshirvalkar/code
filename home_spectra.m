function LFPspectra = home_spectra(LFPinput,LFPmeta,varargin)
% This function will compute multi-taper spectra from LFP raw data on the
% home files
% 
% INPUTS:
%   - LFPinput, raw LFP data ie. LFP (from LFPhome.mat file)
%   - LFPmeta is the associated metadata file
%   -optional input, # of seconds of data to use from start:number (if
%   blank, will use all data)
%
% OUTPUTS:
%   - LFPspectra -> Actual multi tapered spectra from Chronux toolbox
%     The final spectra are LOG10 and variably zscored across pain scores
%           LFPspectra.(z)acc
%           LFPspectra.(z)ofc
%                    *.no0zacc and ofc (without zero pain values)
%                    *.autozacc/ofc - with automated pain score import
%           LFPspectra.fq (frequency values)  
% 
% Assumes that all Frequencies are the same from the first value in
% metadata
% 
% prasad shirvalkar md,phd
% updated 3/11/2018

tic
LFP=LFPinput;
addpath(genpath(fullfile(pwd,'toolboxes')));

if ~isempty(varargin)
    
    fin_ind = LFPmeta.fs(1)*varargin{1};
else
    fin_ind=size(LFP.acc,1);
    
    
end

 

% Define the parameters for spectral calculation using Chronux toolbox
params.tapers = [30 60]; % Time bandwith product and #tapers
params.pad=0;
params.fpass=([0 100]);
params.Fs= LFPmeta.fs(1);

numrecordings = size(LFP.acc,2);

%calculate the spectra and store them in LFPmeta.spectra
for f=1:numrecordings

[LFPspectra.acc(:,f),LFPspectra.fq(:,f)]= mtspectrumc(LFP.acc(1:fin_ind,f),params);
[LFPspectra.ofc(:,f),~]= mtspectrumc(LFP.ofc(1:fin_ind,f),params);

end

%Take LOG10 and then zscore across pain scores
LFPspectra.acc= log10(LFPspectra.acc);
LFPspectra.ofc= log10(LFPspectra.ofc);
LFPspectra.zacc= zscore(LFPspectra.acc,0,2);
LFPspectra.zofc= zscore(LFPspectra.ofc,0,2);

no0 = LFPmeta.pain>0;
LFPspectra.no0zacc= zscore(LFPspectra.acc(:,no0),0,2);
LFPspectra.no0zofc= zscore(LFPspectra.ofc(:,no0),0,2);

painmatch=logical(LFPmeta.painmatch); %include only automatically matched pain scores within 30 mins
LFPspectra.autozacc= zscore(LFPspectra.acc(:,painmatch),0,2);
LFPspectra.autozofc= zscore(LFPspectra.ofc(:,painmatch),0,2);

toc
disp('LFP spectra done')

