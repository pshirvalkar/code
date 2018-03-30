function calculate_spectrograms_autopain(LFP,LFPmeta,params)
% function calculate_spectrograms_autopain(LFP,LFPmeta,params)
% 
% This computes spectrograms on the whole dataset and saves the mat file
% 
% INPUTS
% LFP is the raw LFP from LFPhome.mat
% LFPmeta is the metafile from LFPhome.mat
% params is the Chronux params file (with windows added - window, winstep)
% 
% prasad shirvalkar mdphd 3/27/18






tic

   

painind2=find(LFPmeta.painmatch);
[i,j]=sort(LFPmeta.pain(painind2));
painind = painind2(j); %sort all the spectra by pain score


    [Sacc,t1acc,fq]= mtspecgramc(LFP.acc(:,painind),params.windows,params);

    
    [Sofc,t1ofc,fq]= mtspecgramc(LFP.ofc(:,painind),params.windows,params);

toc

homepath='/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/CP1/data/processed/home/';
save([homepath 'CP1specgram.mat'],'Sacc','Sofc','t1acc','fq','params')
disp(['Spectrograms saved as CP1specgram.mat'  ]);
