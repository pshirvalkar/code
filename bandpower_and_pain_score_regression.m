function LFPspectra_out = bandpower_and_pain_score_regression(LFPspectra, LFPmeta,varargin)
% function LFPspectra_out = bandpower_and_pain_score_regression(LFPspectra, LFPmeta,varargin)

%This function will take inputs of LFP spectral signals computed with
%home_spectra.m and process the band-limited power in the following
%Frequency bands: 
% 
% delta = 1-4 Hz
% theta = 4-8 Hz
% alpha = 8-12 Hz
% beta = 12-30 Hz
% Lgamma = 30-60 Hz
% Mgamma = 60-100 Hz 
% 
% 
% INPUTS: 
%       1) LFPspectra can be loaded from LFPspectra.mat in the home directory 
%               This should contain fields .acc .ofc and .fq with spectral
%               data
%           - .zacc, .zofc contain zscored data across ALL sessions
%           (including sleep)
%           -.no0zacc, .no0zofc contain zscored data across all awake
%           sessions only
%            -.autozacc, .autozofc contain zscored data across all
%            automatically matched pain scores only (within 30 mins of
%            recording).
% 
%       2) LFPmeta can be loaded from LFPhome.mat in the home directory
%               This contains pain scores and other metadata
%          LFPmeta.no0pain contains non zero pain scores (awake only)
%        3) Variable inputs= 'z' or 'no0' 'no0z' 'autopain'
%             'z' will use zscored spectra (including pain scores of 0)
%             'no0' will use regular spectra without 0 pain values
%             'no0z' will use zscored spectra without 0 pain scores
%             'autopain' will use zscored spectra on auto matched pain
%                 scores only
% 
% OUTPUTS:
%       LFPspectra_out is the new LFPspectra variable containing calculated
%       power in bands, and Stats of regression
% 
% 
%  prasad shirvalkar md,phd 3/15/2018

%% Define the frequency bands
bands= {'delta','theta','alpha','beta','Lgamma','Mgamma'};
LFPspectra.bands=bands;
fq=LFPspectra.fq(:,1);

delta = (fq>=1 & fq<=4);
theta = (fq>4 & fq<=8);
alpha =(fq>8 & fq<=12);
beta = (fq>12 & fq<=30);
Lgamma =(fq>30 & fq<=70);
Mgamma = (fq>70 & fq<=100);   
close all

if nargin>2
    switch varargin{1}
    
        case 'z'
            PAINSCORES=LFPmeta.pain;
            ACCspectra=LFPspectra.zacc;
            OFCspectra=LFPspectra.zofc;
            spectral_op='mean'; % when calculating bandlimited spectral values, take mean or sum depending on type of data (z scored vs relative)
    
        case 'no0'
            nozero=LFPmeta.pain>0;
            PAINSCORES=LFPmeta.pain(nozero);
            ACCspectra=LFPspectra.zacc(:,nozero);
            OFCspectra=LFPspectra.zofc(:,nozero);
            spectral_op='mean';
            
        case 'no0z'
            PAINSCORES=LFPmeta.no0pain;
            ACCspectra=LFPspectra.no0zacc;
            OFCspectra=LFPspectra.no0zofc;
            spectral_op='mean';
            
        case 'autopain'
            PAINSCORES=LFPmeta.autopain;
            ACCspectra=LFPspectra.autozacc;
            OFCspectra=LFPspectra.autozofc;
            spectral_op='mean';
            
        case 'relative'
     
            PAINSCORES=LFPmeta.autopain;
            LFPmeta.painmatch = logical(LFPmeta.painmatch);
            ACCspectra=LFPspectra.acc(:,LFPmeta.painmatch) ./ sum(LFPspectra.acc(:,LFPmeta.painmatch));
            OFCspectra=LFPspectra.ofc(:,LFPmeta.painmatch) ./ sum(LFPspectra.ofc(:,LFPmeta.painmatch));
            spectral_op='sum';
        otherwise
    disp('Error in 3rd input')
    end
    
else
    
    PAINSCORES=LFPmeta.no0pain;
    ACCspectra=LFPspectra.no0zacc;
    OFCspectra=LFPspectra.no0zofc;
    
end

    
%% Calculate mean power across the session for each pain score/ recording + also calculate regression



for b=1:6 % for each power band
    
    %ACC
eval(['LFPspectra.accbandpower{b} = ' spectral_op '(ACCspectra(' bands{b} ',:));']);
figure(1)
subplot(3,2,b)
hold all
    %regress and plot line
    notnan=~isnan(PAINSCORES);
    Y=PAINSCORES(notnan)';
%     Y=zscore(Y); %use this if you want to zscore the Pain scores
    x1=LFPspectra.accbandpower{b}';
    X=[ones(size(x1)) x1];
    [coeffACC(:,b),BINT,R,RINT,ACCbandSTATS(b,:)] = regress(Y,X);
    x2=linspace(min(LFPspectra.accbandpower{b}),max(LFPspectra.accbandpower{b}),100);
    plot(x2,(coeffACC(2,b).*x2 + coeffACC(1,b)),'r'); 
    text(max(LFPspectra.accbandpower{b}),8,{'R^2 =' num2str(ACCbandSTATS(b,1)),'p = ' num2str(ACCbandSTATS(b,3))}); %R^2 is first value, p is 3rd (mult comparisons, multiple p by 6)
scatter(x1,Y,150,'.');
title(bands{b});ylabel('Pain Score');xlabel('Power')
    
    %OFC
eval(['LFPspectra.ofcbandpower{b} = ' spectral_op '(OFCspectra(' bands{b} ',:));']);
figure(2)
subplot(3,2,b)
hold all
    %regress and plot line
    Y=PAINSCORES';
    %     Y=zscore(Y); %use this if you want to zscore the Pain scores
    x1=LFPspectra.ofcbandpower{b}';
    X=[ones(size(x1)) x1];
    [coeffOFC(:,b),BINT,R,RINT,OFCbandSTATS(b,:)] = regress(Y,X);
    x2=linspace(min(LFPspectra.ofcbandpower{b}),max(LFPspectra.ofcbandpower{b}),100);
    plot(x2,(coeffOFC(2,b).*x2 + coeffOFC(1,b)),'r'); 
    text(max(LFPspectra.ofcbandpower{b}),8,{'R^2 =' num2str(OFCbandSTATS(b,1)),'p = ' num2str(OFCbandSTATS(b,3))}); %R^2 is first value, p is 3rd
scatter(x1,Y,150,'.');
title(bands{b});ylabel('Pain Score');xlabel('Power')

end
LFPspectra.accregress.coeff = coeffACC;
LFPspectra.ofcregress.coeff = coeffOFC;
LFPspectra.accregress.stats = ACCbandSTATS;
LFPspectra.ofcregress.stats = OFCbandSTATS;
LFPspectra_out=LFPspectra;

figure(1)
set(1,'Position',[0 0 751 840])
suptitle('ACC')

figure(2)
suptitle('OFC')
set(2,'Position',[850 0 751 840])

