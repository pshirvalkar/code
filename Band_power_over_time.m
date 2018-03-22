%Plot all the raw LFP data together in one plot for ACC and OFC 


for x=1:size(LFPspectra.acc,2)
   figure (1)
   x1=linspace(0,60,size(LFP.acc,1));
   plot(x1,LFP.acc(:,x)+(x*0.1))
      hold all
      
   figure (2) 
    plot(x1,LFP.ofc(:,x)+(x*0.3))
   hold all

    
    
end
figure(1)
% set(gca,'yticklabel','')
xlabel('Time (s)')
title('ACC all raw LFPs')

figure(2)
% set(gca,'yticklabel','')
xlabel('Time (s)')
title('OFC all raw LFPs')


%FIRDA detect in OFC?

%% Plot band power vs session in actual calendar time to see if  this changes over time 
% for x=2
%     clf
%     subplot 211
%     scatter(LFPmeta.time,LFPspectra.accbandpower{x})
%     hold all
%     
%     subplot 212
%     scatter(LFPmeta.time,LFPspectra.ofcbandpower{x})
%     hold all
%     
% end

x=1

subplot(311) 
plot(LFPmeta.time,LFPspectra.accbandpower{x},'b.','markersize',20);
ylabel('Band Power')


subplot(312) 
t=timeofday(LFPmeta.time);
plot(t,LFPspectra.accbandpower{x},'b.','markersize',20);
ylabel('Band power')
xlabel('Time of Day')


subplot(313) 
[n,wd]=weekday(LFPmeta.time);
[a,b]=weekday([2:7,1]); %day of week list Sun to Sat for ticks
plot(n,LFPspectra.accbandpower{x},'b.','markersize',20);
set(gca,'xticklabel',b);
ylabel('Band Power')