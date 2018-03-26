tt=painScores.CP2{1}; %pain times 
pp=painScores.CP2{2}; %pain score 
 
dt = diff(tt);

d_hour=duration(1,0,0);
l_delete=dt<d_hour;


l_delete2(1)=logical(1); l_delete2(2:length(l_delete)+1)=l_delete;

tt(l_delete2)=[];
pp(l_delete2)=[];


