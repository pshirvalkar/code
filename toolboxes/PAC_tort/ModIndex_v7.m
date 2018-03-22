% Programmed by Adriano Tort, CBD, BU, 2008
% 
% Phase-amplitude cross-frequency coupling measure:
%
% [MI,MeanAmp]=ModIndex_v2(Phase, Amp, position)
%
% Inputs:
% Phase = phase time series (1 signal)
% Amp = amplitude time series (multiple signals, all Amp signals)
% position = phase bins (left boundary)
%
% Outputs:
% MI = modulation index (see Tort et al PNAS 2008, 2009 and J Neurophysiol 2010)
% MeanAmp = amplitude distribution over phase bins (non-normalized)
 
function [MI,MeanAmp]=ModIndex_v7(Phase, Amp, position)

nbin=length(position);  % we are breaking 0-360o in 18 bins, ie, each bin has 20o
winsize = 2*pi/nbin;
 
% now we compute the mean amplitude in each phase:

%% modified
% tic

Q_Phase=ceil(Phase/(2*pi)*nbin+ceil(nbin/2)); %quantized Phase
map=[Q_Phase', Amp'];
map = sortrows(map,1);%sort base on quantized phase (col 1)

idx=[1;find(diff(map(:,1))~= 0)+1; size(Amp, 2)];

MeanAmp = zeros(nbin, size(Amp,1));

for j=1:nbin
    MeanAmp(j,:)=mean(map(idx(j):idx(j+1), 2:end), 1);
end

% toc

%modified
% MI=(log(nbin)-(-sum((MeanAmp/sum(MeanAmp)).*log((MeanAmp/sum(MeanAmp))))))/log(nbin);


% sum_MeanAmp=MeanAmp/sum(MeanAmp);
% MI=(log(nbin)-(-sum((sum_MeanAmp).*log((sum_MeanAmp)))))/log(nbin);

% sum_MeanAmp=MeanAmp/sum(MeanAmp,1);
p_MeanAmp=bsxfun(@rdivide,MeanAmp, sum(MeanAmp,1));
% MI=(log(nbin)-(-sum((sum_MeanAmp).*log((sum_MeanAmp)))))/log(nbin);
MI=(log(nbin)-(-sum((p_MeanAmp).*log((p_MeanAmp)),1)))/log(nbin);

% toc


%% original
% tic
% MeanAmp=zeros(1,nbin); 
% for j=1:nbin   
% I = find(Phase <  position(j)+winsize & Phase >=  position(j));
% MeanAmp(j)=mean(Amp(I)); 
% end
% toc
 
% so note that the center of each bin (for plotting purposes) is
% position+winsize/2
 
% at this point you might want to plot the result to see if there's any
% amplitude modulation
 
% bar(10:20:720,[MeanAmp,MeanAmp])
% xlim([0 720])

% and next you quantify the amount of amp modulation by means of a
% normalized entropy index:



%original
% MI=(log(nbin)-(-sum((MeanAmp/sum(MeanAmp)).*log((MeanAmp/sum(MeanAmp))))))/log(nbin);
% toc
end
