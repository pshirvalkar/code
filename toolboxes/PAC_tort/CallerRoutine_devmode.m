%% Evaluation code for PAC 
%  Main changes: 
%  1. use logical indexing 
%  2. transpose some vectors so that largest dimension first (allows faster
%  comptuation
%  3. use index counting + reshape to make parfor more efficient 
%% 
%% set params: 
PhaseFreqVector      = 2:2:50;
AmpFreqVector        = 100:5:200;
PhaseFreq_BandWidth  = 4;
AmpFreq_BandWidth    = 10;
useparfor            = 0; % if true, user parfor, requires parallel computing toolbox 

%% Define the Amplitude- and Phase- Frequencies
load ExtractHGHFOOpenField.mat
lfp = lfpHFO;
data_length = length(lfp);
srate = 1000;
dt = 1/srate;
t = (1:data_length)*dt;

%% For comodulation calculation (only has to be calculated once)
nbin = 18;
position=zeros(1,nbin); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbin;
for j=1:nbin
    position(j) = -pi+(j-1)*winsize;
end
%% Do filtering and Hilbert transform on CPU

'CPU filtering'

Comodulogram=single(zeros(length(PhaseFreqVector),length(AmpFreqVector)));
AmpFreqTransformed = zeros(length(AmpFreqVector), data_length);
PhaseFreqTransformed = zeros(length(PhaseFreqVector), data_length);

for ii=1:length(AmpFreqVector)
    Af1 = AmpFreqVector(ii);
    Af2=Af1+AmpFreq_BandWidth;
    AmpFreq=eegfilt(lfp,srate,Af1,Af2); % just filtering
    AmpFreqTransformed(ii, :) = abs(hilbert(AmpFreq)); % getting the amplitude envelope
end

for jj=1:length(PhaseFreqVector)
    Pf1 = PhaseFreqVector(jj);
    Pf2 = Pf1 + PhaseFreq_BandWidth;
    PhaseFreq=eegfilt(lfp,srate,Pf1,Pf2); % this is just filtering
    PhaseFreqTransformed(jj, :) = angle(hilbert(PhaseFreq)); % this is getting the phase time series
end
toc

%% Do comodulation calculation
veruse = 1;
if veruse == 1
    
    'Comodulation loop'
    
    %% version 1
    start = tic;
    nbin = length(position);  % we are breaking 0-360o in 18 bins, ie, each bin has 20o
    winsize = 2*pi/nbin;
    lognbin = log(nbin);
    pairuse = [];cnt = 1;
    for jj=1:length(AmpFreqVector)
        for ii=1:length(PhaseFreqVector)
            puse1(cnt) = ii;
            puse2(cnt) = jj;
            cnt = cnt + 1;
        end
    end
    
    Comodulogram = zeros(size(pairuse,1),1,'single');
    for p = 1:size(puse1,2)
        Comodulogram(p) = ModIndex_v3(PhaseFreqTransformed(puse1(p), :), AmpFreqTransformed(puse2(p), :)', position,nbin,winsize,lognbin);
    end
   Coreshaped = reshape(Comodulogram,length(PhaseFreqVector),length(AmpFreqVector));

%    Comodulogram=single(zeros(length(PhaseFreqVector),length(AmpFreqVector)));
%     counter1=0;
%     for ii=1:length(PhaseFreqVector)
%         counter1=counter1+1;
%         
%         Pf1 = PhaseFreqVector(ii);
%         Pf2 = Pf1+PhaseFreq_BandWidth;
%         
%         counter2=0;
%         for jj=1:length(AmpFreqVector)
%             counter2=counter2+1;
%             
%             Af1 = AmpFreqVector(jj);
%             Af2 = Af1+AmpFreq_BandWidth;
%             [MI,MeanAmp]=ModIndex_v2(PhaseFreqTransformed(ii, :), AmpFreqTransformed(jj, :), position);
%             Comodulogram(counter1,counter2)=MI;
%         end
%     end
    fprintf('version 1 done in %f secs \n',toc(start));
    
    figure;
    contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Coreshaped',30,'lines','none')
    set(gca,'fontsize',14)
    ylabel('Amplitude Frequency (Hz)')
    xlabel('Phase Frequency (Hz)')
    title('version 1');
    colorbar
    
else
    %% version 2
    %% pre compute the mean for each phase and amplitude
    Comodulogram = single(zeros(length(PhaseFreqVector),length(AmpFreqVector)));
    nbin=length(position);  % we are breaking 0-360o in 18 bins, ie, each bin has 20o
    winsize = 2*pi/nbin;
    idxArray = logical(zeros(length(AmpFreqTransformed),length(PhaseFreqVector),nbin,'single'));
    % convert to single
    AmpFreqTransformed = single(AmpFreqTransformed);
    PhaseFreqTransformed = single(PhaseFreqTransformed);
    % create idxs for for phase / bin combination in advance
    startidx = tic;
    for ii=1:length(PhaseFreqVector)
        Phase   = PhaseFreqTransformed(ii, :);
        for j=1:nbin
            idxArray(:,ii,j) = Phase <  position(j)+winsize & Phase >=  position(j);  % logical idx 30% faster than find
        end
    end
    ampArray = zeros(length(AmpFreqTransformed),nbin,length(AmpFreqVector),'single');
    for jj=1:length(AmpFreqVector)
        Amp     = AmpFreqTransformed(jj, :);
        Amprep = repmat(Amp,nbin,1)';
        ampArray(:,:,jj) = Amprep;
    end
    
    % do average for all bins at once
    cntsAll = squeeze(sum(idxArray,1));
    pairuse = [];cnt = 1; 
    for jj=1:length(AmpFreqVector)
        for ii=1:length(PhaseFreqVector)
            pairuse(cnt,1) = ii;
            pairuse(cnt,2) = jj;
            cnt = cnt + 1; 
        end
    end
    
    Comodulogram = zeros(size(pairuse,1),1,'single');
    fprintf('indexing took %f secs \n',toc(startidx));
    
    % computation loop
    % attempt at vectorizing these loops...
    
    start2 = tic;
    
    for p = 1:size(pairuse,1)
        Comodulogram(p) = ComputeMI(idxArray(:,pairuse(p,1),:),ampArray(:,:,pairuse(p,2)),cntsAll(pairuse(p,1),:),nbin);
    end

   Coreshaped = reshape(Comodulogram,length(PhaseFreqVector),length(AmpFreqVector));
    % sums = sum(ampArray.*idxArray,3);
    % cnts = sum(idxArray,3);
    % MeanAmp = sums./cnts;
    %
    %
    %
    %
    % % do average for all bins at once
    % for jj=1:length(AmpFreqVector)
    %     Amp     = AmpFreqTransformed(jj, :);
    %     Amprep = repmat(Amp,nbin,1);
    %     for ii=1:length(PhaseFreqVector)
    %         idxUse = squeeze(idxArray(ii,:,:));
    %         sums = sum(Amprep.*idxUse,2);
    %         cnts = sum(idxUse,2);
    %         MeanAmp = sums./cnts;
    %         MI =(log(nbin)-(-sum( (MeanAmp/sum(MeanAmp)).*log((MeanAmp/sum(MeanAmp))) )  ))/log(nbin);
    %         Comodulogram(ii,jj)=MI;
    %     end
    % end
    fprintf('version 2 done in %f secs \n',toc(start2));
    %% Graph comodulogram
    
    figure;
    contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Coreshaped',30,'lines','none')
    set(gca,'fontsize',14)
    ylabel('Amplitude Frequency (Hz)')
    xlabel('Phase Frequency (Hz)')
    title('version 2');
    colorbar
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Use the routine below to look at specific pairs of frequency range:

Pf1 = 6
Pf2 = 12
Af1 = 60
Af2 = 100

[MI,MeanAmp] = ModIndex_v1(lfp,srate,Pf1,Pf2,Af1,Af2)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Or use the routine below to make a comodulogram using ModIndex_v1; this takes longer than
%% the method outlined above using ModIndex_v2 because in this routine multiple filtering of the same
%% frequency range is employed (the Amp frequencies are filtered multiple times, one
%% for each phase frequency). This routine might be the only choice though
%% for computers with low memory, because it does not create the matrices
%% AmpFreqTransformed and PhaseFreqTransformed as the routine above

tic

PhaseFreqVector=2:2:50;
AmpFreqVector=10:5:200;

PhaseFreq_BandWidth=4;
AmpFreq_BandWidth=10;

Comodulogram=zeros(length(PhaseFreqVector),length(AmpFreqVector));

counter1=0;
for Pf1=PhaseFreqVector
    counter1=counter1+1;
    Pf1 % just to check the progress
    Pf2=Pf1+PhaseFreq_BandWidth;
    
    counter2=0;
    for Af1=AmpFreqVector
        counter2=counter2+1;
        Af2=Af1+AmpFreq_BandWidth;
        
        [MI,MeanAmp]=ModIndex_v1(lfp,srate,Pf1,Pf2,Af1,Af2);
        
        Comodulogram(counter1,counter2)=MI;
        
        
    end
    
end

toc

%%

clf
contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Comodulogram',30,'lines','none')
set(gca,'fontsize',14)
ylabel('Amplitude Frequency (Hz)')
xlabel('Phase Frequency (Hz)')
colorbar




