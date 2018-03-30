function KS_PreprocessingSegments2_4_timef_p(patientID,filepath)


% Do time frequency analysis with morlet waves.  #4 for UNCLEADED DATA

% close all
% clear all
% clc
%%

patientID = 'EC118';
total = 1;
probe = 0;

filepath = 'E:\ECoG\';

load([filepath patientID '/clinical_elecs_all.mat']);

directoryStringE = [filepath patientID '/ReferencedUC2/'];

%contains variables fselectAnatomy, ChanelInfoTotal, SignalsAllrefV

filesE = dir(strcat(directoryStringE,'*.mat'));
namesE = {filesE.name};
[tmp ind]=sort({filesE.date});

dsFs = 512;
delta = [1 4];
theta = [4 7];
alpha = [8 12];
beta = [13 30];
gammaL = [31 45];
gammaH = [46 70];


for a = 1:length(namesE)
    load([directoryStringE,'/',namesE{ind(a)}]);
    
    if total ==1
        SignalsAllVref = SignalsAllVrefT;
    else if probe == 1
            SignalsAllVref = SignalsAllVrefP;
        end
    end
    
    for ich = 1:size(fselectAnatomy,1)
        %for ich = 1:size(SignalsAllVref,1)
        for iep = 1:size(SignalsAllVref,3)  %do continous waveform transformation for each 30 s block for each brain region
            
            %Figure out which channels (specify region of interest)
            a1 = find(cell2mat(fselectAnatomy(:,5)) == 1); %OFC in this patient
            x = (mean(SignalsAllVref(a1,:,iep),1))';  %does it matter if you do this before/after the cfs
            
            %or do this for each channel
            x = SignalsAllVref(ich,:,iep)';
            
            t = 1:length(x);
            
            %do morlet wave transformation.  Max freq is about 244 or so
            %based on sampling rate of 512 (Nyquist)
            [cfs,f] = cwt(x,dsFs,'amor','NumOctaves',8,'VoicesPerOctave',48);  % will give min Hz about 1 (if want 0.5 need to use 9 octaves.  voices per octave gives the resolution.  this is the max allowed
            cfs2 = cfs;
            f2 = f;
            cfs2(1:86,:) = [];  %eliminate the freqs above 70 hz
            f2(1:86) = [];
            KS_CWTTimeFreqPlot(cfs2,t,f2,'surf',['CWT of Channel' num2str(ich) num2str(iep)],'msec','Hz')  %plots freqs 1:70 Hz
            
            freqMeans = mean(abs(cfs2),2);  %this takes the magnitude -- the hypotenuse of real and imaginary parts
            %plot(f2,freqMeans)
            xlabel('Freq'); ylabel('Magnitude');
            
            %delat range
            powerMatDelta(ich,iep) = mean(mean(abs(cfs2(200:295,:)),2)); %1-4 hz
            %plot(f2(200:295),mean(abs(cfs2(200:295,:)),2))
            %theta range
            powerMatTheta(ich,iep) = mean(mean(abs(cfs2(152:199,:)),2)); %4-7 hz
            %alpha range 8-12 hz
            powerMatAlpha(ich,iep) = mean(mean(abs(cfs2(119:151,:)),2)); %8-12 hz
            %beta range 12-30 hz
            powerMatBeta(ich,iep) = mean(mean(abs(cfs2(59:118,:)),2));
            %gammaL 31-45
            powerMatGammaL(ich,iep) = mean(mean(abs(cfs2(31:58,:)),2));
            %gammaH 46-70
            powerMatGammaH(ich,iep) = mean(mean(abs(cfs2(2:30,:)),2));
            
            %rec_beta = icwt(cfs,f,beta,'amor');
            %power_beta = mean(abs(rec_beta));
            %surf(x,beta,abs(cfs));shading('interp');
            %             powerMatBeta(ich,iep) = power_beta;
            %             clear rec_beta power_beta cfs f t
            
            %display('epoch complete')
        end
        %display('channel complete')
    end
    
    %[SUCCESS,MESSAGE,MESSAGEID] = mkdir(['E:\ECoG\' patientID '\PowerUC\']);
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir([filepath patientID '/PowerUC2/']);
    
    
     save([filepath patientID '/PowerUC2/Pow' num2str(a)],'powerMatBeta',...
        'powerMatAlpha','powerMatTheta','powerMatDelta','powerMatGammaL','powerMatGammaH','fselectAnatomy','-v7.3');
      
end


Margaret = 2;  





