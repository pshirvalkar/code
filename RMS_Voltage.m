%% plot RMS voltage of signals over time 


accRMS = rms(LFP.acc); 
ofcRMS = rms(LFP.ofc);
close all

[b,itime]=sort(LFPmeta.time);

subplot 211
scatter(LFPmeta.time,accRMS,100,'b.')
hold all
mmACC= movmean(accRMS,5);
plot(LFPmeta.time(itime),mmACC(itime))
title('ACC')
ylabel('RMS voltage - mV')

subplot 212
scatter(LFPmeta.time,ofcRMS,100,'k.')
hold all
mmOFC= movmean(ofcRMS,5);
plot(LFPmeta.time(itime),mmOFC(itime))
title('OFC')
ylabel('RMS voltage - mV')


%% electrode impedance plot

load ElectrodeImpedance.mat
figure

subplot 211

plot(Eimpedance.date,Eimpedance.vals(1:6,:))
legend(Eimpedance.contacts(1:6,:))
title('ACC Electrode Impedances')
ylabel('Impedance (Ohms)')

subplot 212
plot(Eimpedance.date,Eimpedance.vals(7:12,:))
legend(Eimpedance.contacts(7:12,:))
title('OFC Electrode Impedances')
ylabel('Impedance (Ohms)')  