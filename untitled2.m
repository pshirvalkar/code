% Coherence using mscohere determines cohernece in multiple bands
% simulataneously.  
% PRS
 

Fs=422;

[Cxy,F]=mscohere(LFP.acc,LFP.ofc,2^(nextpow2(Fs)),...
    2^(nextpow2(Fs/2)),...
    2^(nextpow2(Fs)),...
    Fs);

idxplot = F > 0 & F < 100; 
hplot = plot(F(idxplot),Cxy(idxplot,:));
xlabel('Freq (Hz)');
ylabel('coherence'); 