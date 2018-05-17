thresh =5; %zscore threshold
lfp_hold=LFP.right.acc;
clf 

l1=lile(lfp_hold,422);




hold all
plot(l1) %original linelength



lz=zscore(l1(~isnan(l1)));
plot(abs(lz)) %zscored LL


xz1=lz>thresh;
xz=find(xz1);
yy=repmat(15,size(xz));
plot(xz,yy,'*') %segments to remove
 
plot(lfp_hold*10) %raw LFP
% 
% for x=1:length(xz)
%     lfp_clean1
%     
%     
% end
