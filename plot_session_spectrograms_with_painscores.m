
painind2=find(LFPmeta.painmatch);
[i,j]=sort(LFPmeta.pain(painind2));
painind = painind2(j); %sort all the spectra by pain score



% Plot the individual spectrograms with pain scores to see variance in
% session
painsorted=LFPmeta.pain(painind);
zSacc=zscore(log10(Sacc),2);
zSofc=zscore(log10(Sofc),2);
accLFP=LFP.acc(:,painind).*100;
ofcLFP=LFP.ofc(:,painind).*100;
lfp_time = linspace(0,60,size(LFP.acc,1));


for x=1:31
    
    figure (100+x)
%     subplot(6,6,x)
 imagesc(t1acc,fq,zSacc(:,:,x)'); 
%     caxis ([-2 2]); 
    title(['ACC - ' num2str(painsorted(x))]);
    set(gca,'Ydir','normal')

    %plot overlying RAW LFP SIGNAL
hold all
plot(lfp_time,accLFP(:,x)+50,'w')

    
     figure (200+x)
%     subplot(6,6,x)
 imagesc(t1acc,fq,zSofc(:,:,x)');   
%     caxis ([-2 2]); 
    title(['OFC - ' num2str(painsorted(x))]);
    set(gca,'Ydir','normal')

    
        %plot overlying RAW LFP SIGNAL
hold all
plot(lfp_time,ofcLFP(:,x)+50,'w')
  


figure(100+x)
set(gcf,'position',[0+x 200 700 700])

figure(200+x)
set(gcf,'position',[800+x 200 700 700])
    
end


