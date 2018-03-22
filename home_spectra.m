function LFPspectra = home_spectra(LFPinput,LFPmeta)
% This function will compute multi-taper spectra from LFP raw data on the
% home files
% 
% INPUTS:
%   - LFPinput, raw LFP data ie. LFP (from LFPhome.mat file)
%   - LFPmeta is the associated metadata file
% OUTPUTS:
%   - LFPspectra -> Actual multi tapered spectra from Chronux toolbox
%     The final spectra are LOG10 and zscores across pain scores
%           LFPspectra.acc
%           LFPspectra.ofc
%           LFPspectra.fq (frequency values)  
% 
% Assumes that all Frequencies are the same from the first value in
% metadata
% 
% prasad shirvalkar md,phd
% updated 3/11/2018

tic
LFP=LFPinput;
ph1=what;
[r1,r2,r3]=fileparts(ph1.path);
addpath(genpath(fullfile(pwd,'toolboxes')));


% Define the parameters for spectral calculation using Chronux toolbox
params.tapers = [300 5]; % Time bandwith product and #tapers
params.pad=1;
params.fpass=([0 100]);
params.Fs= LFPmeta.fs(1);

numrecordings = size(LFP.acc,2);

%calculate the spectra and store them in LFPmeta.spectra
for f=1:numrecordings

[LFPspectra.acc(:,f),LFPspectra.fq(:,f)]= mtspectrumc(LFP.acc(:,f),params);
[LFPspectra.ofc(:,f),fq]= mtspectrumc(LFP.ofc(:,f),params);

end

%Take LOG10 and then zscore across pain scores
LFPspectra.acc= log10(LFPspectra.acc);
LFPspectra.ofc= log10(LFPspectra.ofc);
LFPspectra.zacc= zscore(LFPspectra.acc,0,2);
LFPspectra.zofc= zscore(LFPspectra.ofc,0,2);

painmatch=logical(LFPmeta.painmatch); %include only automatically matched pain scores within 30 mins
LFPspectra.autozacc= zscore(LFPspectra.acc(:,painmatch),0,2);
LFPspectra.autozofc= zscore(LFPspectra.ofc(:,painmatch),0,2);

toc
disp('LFP spectra done')

