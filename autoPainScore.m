function LFPmeta=autoPainScore(LFPmeta,painScores,timedur)

% autPainScore will flag 1 if pain score is automatically detected within
% 30 mins of recording. 
%
% 
% INPUTS -  LFPmeta is loaded, and input giving metadata
%           
%           painScores which is created by painscoreimport.m (use
%           painScores.CP1 CP2 etc.)
% 
%           timedur specified the amount of time to look fwd and back
% 
% 
% prasad shirvalkar mdphd 3/21/18 745 pm
% This should be incorporated into getvisitdetails so that autopainscore is
% flagged




for x= 1:length(LFPmeta.time)
   holdtime=LFPmeta.time(x,:);
    
%             automatically find the pain score corresponding to the file
%             if there is a recorded score +/- given mins
                hold_duration=duration(0,timedur,0);
                timediff=abs(painScores{1} - holdtime);
                painscoreMatch=timediff<hold_duration;
                
                if sum(painscoreMatch)>0
                    holdpain=painScores{2}(painscoreMatch);
                    LFPmeta.autopain(x) = max(holdpain); %if more than 1 score take the higher one
                    LFPmeta.painmatch(x)=1;
                else
                    LFPmeta.autopain(x)=nan;
                    LFPmeta.painmatch(x)=0;
                end
                     
                

                
end


LFPmeta.autopain=LFPmeta.autopain(~isnan(LFPmeta.autopain));

end
