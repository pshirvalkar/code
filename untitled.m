 data = LFP.m1;
 Fs=800;
      
        [fftOut,f] = pwelch(data,Fs,Fs/2,1:200,Fs,'psd');
        %[fftOut,f] = pwelch(data,512,256,1024,params.sr); % from nicki
        plot(f,log10(fftOut),'linewidth',2); 
        hold all
       