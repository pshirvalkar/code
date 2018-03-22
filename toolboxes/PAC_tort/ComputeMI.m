function MI= ComputeMI(idxArray,amp,cnts,nbin)

idxuse = squeeze(idxArray);
% computation
tosum = amp.*idxuse;
sums = sum(tosum,1);
MeanAmp = sums./cnts;
MI =(log(nbin)-(-sum( (MeanAmp/sum(MeanAmp)).*log((MeanAmp/sum(MeanAmp))) )  ))/log(nbin);


end