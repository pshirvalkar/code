clear wekaout accS ofcS

for x=1:99
    
    idx_fq = LFPspectra.fq(:,1)>x & LFPspectra.fq(:,1)<x+1;
    accS(:,x)= mean(LFPspectra.autozacc(idx_fq,:));
    ofcS(:,x)= mean(LFPspectra.autozofc(idx_fq,:));
end

wekaout(:,1:size(accS,2))=accS;
wekaout(:,end+1:size(ofcS,2)*2)=ofcS;




wekaout(:,end+1)=(LFPmeta.autopain)>7';


arffwrite('CP1_allfqs',wekaout)