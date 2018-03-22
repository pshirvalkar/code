%  Basic montage Analysis to determine best electode pair  
% This will plot a montage data from a combined files using
% combine_montage_data.m


clear
close all
montagepath='/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/CP1/data/processed/montage/';
load([montagepath 'LFPmontage.mat'])





% import the time domain data
numrecordings = size(LFP.acc,2);
groupnum=1:6:numrecordings;


for f=1:6:numrecordings

    for p=1:6
figure(1)
subplot(6,1,p)
plot(LFP.acc(:,f+p-1)+(f/6*0.1)); %set(gca,'PlotBoxAspectRatio',[1 0.12 0.12]);
ylabel('mV')
xlabel('sec')
ylim([0 .5])
text(5,0.1,sprintf(LFPmeta.contacts{f+p-1}(1:4)));
hold all

figure(2)
subplot(6,1,p)
plot(LFP.acc(:,f+p-1)+(f/6*0.2)); %set(gca,'PlotBoxAspectRatio',[1 0.12 0.12]);
ylabel('mV')
xlabel('sec')
ylim([0 1])
text(5,0.1,sprintf(LFPmeta.contacts{f+p-1}(6:end)));
hold all

    end


end


h1=figure(1);set(h1,'Position',[114 42 612 644]);suptitle('ACC');
h2=figure(2);set(h2,'Position',[904 42 612 644]);suptitle('OFC');

%% Spectrogramc ACC and OFC
% The distribution of power values in rightward skewed, many more small
% power vals. So, Zscoring isn't strictly applicable, but people do it. 

params.tapers = [5 7];
params.Fs=Fs;
params.pad=-1;
params.fpass=([0 100]);
for f= 1:size(rawdata,2)
   
    [S{f},t1{f},fq]= mtspecgramc(rawdata{f}.ACC,[2 0.2],params);
    figure (3)
    subplot(3,2,f)
    imagesc(t1{f},fq,(log10(S{f}'))); axis xy; colorbar; 
    caxis ([-10 -4]); text(10,90,sprintf('Contacts %d - %d',ACCleads(f,1),ACCleads(f,2)),'color','w');
    
    [S{f},t1{f},fq]= mtspecgramc(rawdata{f}.OFC,[2 0.2],params);
    figure (4)
    subplot(3,2,f)
    imagesc(t1{f},fq,(log10(S{f}'))); axis xy; colorbar; 
    caxis ([-10 -4]); text(10,90,sprintf('Contacts %d - %d',ACCleads(f,1)+8,ACCleads(f,2)+8),'color','w'    )
end

h3=figure(3);set(h3,'Position',[114 42 550 644]);suptitle(['ACC lead-' {dirname1(99:end)}])
h4=figure(4);set(h4,'Position',[904 42 612 644]);suptitle(['OFC strip-' {dirname1(99:end)}])
%% just plotting
x=3
imagesc(t1{x},fq{x},log10(S{x}')); axis xy; colorbar


%% Spectrum C

 

params.tapers = [5 9];
params.Fs=Fs;
params.pad=-1;
params.fpass=([0 100]);
for f= 1:size(rawdata,2)
    [S{f},fq]= mtspectrumc(rawdata{f}.ACC,params);

    subplot(6,1,f)
    plot(fq,log10(S{f}')); axis xy; ylim([-10 -2]);
end