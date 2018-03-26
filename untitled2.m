params.tapers = [30 60]; % Time bandwith product and #tapers
params.pad=0;
params.fpass=([0 100]);
params.Fs= LFPmeta.fs(1);

x=25;

[n1,f1]= mtspectrumc(LFP.acc(:,x),params);
[n2,f2]= mtspectrumc(LFP.ofc(:,x),params);


plot(f1,log10(n1))
