function calculate_spectrograms_autopain(LFP,LFPmeta,params,PATIENTID)
% function calculate_spectrograms_autopain(LFP,LFPmeta,params)
% 
% This computes spectrograms on the whole dataset and saves the mat file
% 
% INPUTS
% LFP is the raw LFP from LFPhome.mat
% LFPmeta is the metafile from LFPhome.mat
% params is the Chronux params file (with windows added - window, winstep)
% 
% prasad shirvalkar mdphd 4/23/18






tic

   

painind2=find(LFPmeta.painmatch);
[i,j]=sort(LFPmeta.pain(painind2));
painind = painind2(j); %sort all the spectra by pain score


    [Sacc,t1acc,fq]= mtspecgramc(LFP.acc(:,painind),params.windows,params);

    
    [Sofc,t1ofc,fq]= mtspecgramc(LFP.ofc(:,painind),params.windows,params);

toc

homepath=['/Users/pshirvalkar/Desktop/ChangLab DATA/DBS CP matlab analysis/' PATIENTID '/data/processed/home/'];
save([homepath PATIENTID 'specgram.mat'],'Sacc','Sofc','t1acc','fq','params')
disp(['Spectrograms saved as ' PATIENTID 'specgram.mat'  ]);
