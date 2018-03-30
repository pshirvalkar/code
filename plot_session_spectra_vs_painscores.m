function plot_session_spectra_vs_painscores(LFPspectra,LFPmeta,process_mode)

% This function will plot two spectral figures of Freq vs Session, with
% overlying pain score data.
% 
% function plot_session_spectra_vs_painscores(LFPspectra,LFPmeta,process_mode)
% 
% 
% INPUTS:
%     LFPspectra  =  containing spectral data
%     LFPmeta = containing pain scores
%     process_mode =      'z', 'no0', 'no0z','autopain', 'relative' 
%       - corresponding to: z-scored, no0 pain scores, no 0 pain and zscored,
%       automatically matched pain scores (with z score), and relative
%       power
% 
% No OUTPUTS
% 
% 
% 
% 
% prasad shirvalkar mdphd 3/27/2018



    switch process_mode
       
    
        case 'z'
            PAINSCORES=LFPmeta.pain;
            ACCspectra=LFPspectra.zacc;
            OFCspectra=LFPspectra.zofc;
            
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
        otherwise
    disp('Error in 3rd input')
    end
    





numtrials=length(PAINSCORES);
%sort the columns by pain score
[~,painsortindex] = sort(PAINSCORES);

imagesc(1:numtrials,LFPspectra.fq(:,1),ACCspectra(:,painsortindex));
colorbar
hold all 
plot(PAINSCORES(painsortindex).*10,'w.','markersize',20) %scatter the pain scores
xlabel('Session') 
ylabel('Frequency or Pain Score x 10')
title('ACC zscored power spectra')
set(gca,'Ydir','normal')
set(gcf,'position',[300 200 500 400])
% caxis([-2 3])

figure
imagesc(1:numtrials,LFPspectra.fq(:,1),OFCspectra(:,painsortindex));
colorbar
hold all 
plot(PAINSCORES(painsortindex).*10,'w.','markersize',20) %scatter the pain scores
xlabel('Session') 
ylabel('Frequency or Pain Score x 10')
title('OFC zscored power spectra')
set(gca,'Ydir','normal')
set(gcf,'position',[800 200 500 400])
% caxis([-2 3])
