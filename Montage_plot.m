%  Basic montage Analysis to determine best electode pair  
% This will plot a montage data from a combined files using
% combine_montage_data.m
% 
% First plot the Raw LFP 
% Then plot the power spectrum below, to compare across electrodes
% 
% 
% prasad shirvalkar mdphd
% may 2018


clear
close all

PATIENTID = 'CP1';


montagepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/montage/'];
load([montagepath PATIENTID 'LFPmontage.mat'])

 
% % Filter out frequencies to bandstop
% d = designfilt('bandstopiir','FilterOrder',2, ...
%                'HalfPowerFrequency1',81,'HalfPowerFrequency2',83, ...
%                'DesignMethod','butter','SampleRate',422);
            
         
LFP.acc=LFP.acc(1000:end,:);
LFP.ofc=LFP.ofc(1000:end,:);

mtime=linspace(0,60,size(LFP.acc,1)); 
       
% import the time domain data
numrecordings = size(LFP.acc,2);
groupnum=1:6:numrecordings;


for f=1:6:numrecordings

    % Find spectrum.
       Fs=LFPmeta.fs(f);
       [ACCspec(:,f:f+5),fq] = pwelch(LFP.acc(:,f:f+5),Fs,Fs/2,1:100,Fs,'psd');
       [OFCspec(:,f:f+5),~] = pwelch(LFP.ofc(:,f:f+5),Fs,Fs/2,1:100,Fs,'psd');
       
    for p=1:6
figure(f)
subplot(2,1,1)
plot(mtime,LFP.acc(:,f+p-1)+(p*0.1));
ylabel('mV')
xlabel('sec'); title('Raw LFP')
% ylim([-.2 .2])
hold all

figure(f+1)
subplot(2,1,1)
plot(mtime, LFP.ofc(:,f+p-1)+(p*0.2));
ylabel('mV')
xlabel('sec');title('Raw LFP') 
% ylim([-.5 .5])
hold all


% get contact pair numbers

Csplit=strsplit(LFPmeta.contacts{p},'/');
ACCcontact{p}=Csplit{1};
OFCcontact{p}=Csplit{2};



       figure(f)
       subplot(2,1,2)
       plot(fq,log10(ACCspec(:,f+p-1)),'linewidth',2)
       xlabel('Freq (Hz)'); ylabel('log 10 mV^2/Hz'); title('Power Spectrum');hold all
       
       figure(f+1)
       subplot(2,1,2)
       plot(fq,log10(OFCspec(:,f+p-1)),'linewidth',2)
       xlabel('Freq (Hz)'); ylabel('log 10 mV^2/Hz'); title('Power Spectrum');hold all
    end

    
    
 
h1=figure(f);set(h1,'Position',[114 42 612 644]);suptitle(['ACC-' datestr(LFPmeta.time(f))]);
legend(ACCcontact);

h2=figure(f+1);set(h2,'Position',[904 42 612 644]);suptitle(['OFC-' datestr(LFPmeta.time(f))]);
legend(OFCcontact);

end



