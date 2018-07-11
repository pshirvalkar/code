function LFPmeta=autoPainScore(LFPmeta,painScores,moodScores,timedur)

% autPainScore will flag 1 if pain score is automatically detected within
% 30 mins of recording.  
% This will also look for mood score times, and match those as well.
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
% prasad shirvalkar mdphd 5/7/2018
% This should be incorporated into getvisitdetails so that autopainscore is
% flagged

if isfield(LFPmeta,'paintime')
LFPmeta = rmfield(LFPmeta,'paintime');
end
if isfield(LFPmeta,'autopain')
LFPmeta = rmfield(LFPmeta,'autopain');
end
if isfield(LFPmeta,'autopaintime')
LFPmeta = rmfield(LFPmeta,'autopaintime');
end
if isfield(LFPmeta,'moodtime')
LFPmeta = rmfield(LFPmeta,'moodtime');
end
if isfield(LFPmeta,'automood')
LFPmeta = rmfield(LFPmeta,'automood');
end
if isfield(LFPmeta,'automoodtime')
LFPmeta = rmfield(LFPmeta,'automoodtime');
end


for x= 1:length(LFPmeta.time)
   holdtime=LFPmeta.time(x,:);
    
%             automatically find the pain score corresponding to the file
%             if there is a recorded score +/- given mins
                hold_duration=duration(0,timedur,0);
                timediff=abs(painScores{1} - holdtime);
                painscoreMatch=timediff<hold_duration;
                
                if sum(painscoreMatch)>0 & ~isnan(painScores{2}(painscoreMatch))
                         holdpain=painScores{2}(painscoreMatch);
                         [i1,j1]= max(holdpain); %if more than 1 score take the higher one
                         
                    LFPmeta.autopain(x) = i1;
                    LFPmeta.painmatch(x)=1;
                         holdpaintime = painScores{1}(painscoreMatch);
                    LFPmeta.autopaintime(x,:)= holdpaintime(j1);
                   
                else
                    LFPmeta.autopain(x)=nan;
                    LFPmeta.painmatch(x)=0;
                    LFPmeta.autopaintime(x,:)= NaT;
                end
                
                
%                 FOR MOOD
%                     automatically find the MOOD score corresponding to the file
%             if there is a recorded score +/- given mins
           
                mtimediff=abs(moodScores{1} - holdtime);
                moodscoreMatch=mtimediff<hold_duration;
                
                if sum(moodscoreMatch)>0
                         holdmood=moodScores{2}(moodscoreMatch);
                         [i1,j1]= max(holdmood); %if more than 1 score take the higher one
                    LFPmeta.automood(x) = i1;
                    LFPmeta.moodmatch(x)=1;
                         holdmoodtime = moodScores{1}(moodscoreMatch);
                    LFPmeta.automoodtime(x,:)= holdmoodtime(j1);
                else
                    LFPmeta.automood(x)=nan;
                    LFPmeta.moodmatch(x)=0;
                    LFPmeta.automoodtime(x,:)= NaT;
                end
     
% Find the pain time that was manually entered, always within 8 hours max
% (usually 1-2)
               if LFPmeta.pain(x)>0
                p=painScores{2};
                ind_pain_scores=(LFPmeta.pain(x) == p);
                ind_pain_times=abs(painScores{1}-LFPmeta.time(x))<(duration(8,0,0));
                t2 = painScores{1}(ind_pain_scores & ind_pain_times);
                LFPmeta.paintime(x)= t2(1);
            
               else
                   LFPmeta.paintime(x)=LFPmeta.time(x);
               end
               
end



LFPmeta.autopain=LFPmeta.autopain(~isnan(LFPmeta.autopain));
LFPmeta.automood=LFPmeta.automood(~isnan(LFPmeta.automood));

LFPmeta.autopaintime=LFPmeta.autopaintime(~isnat(LFPmeta.autopaintime));
LFPmeta.automoodtime=LFPmeta.automoodtime(~isnat(LFPmeta.automoodtime));
nozero=LFPmeta.pain>0; % exclude sleep trials
LFPmeta.no0pain=LFPmeta.pain(nozero);
disp([num2str(length(LFPmeta.autopain)) ' Pain and Mood Scores Auto-matched'])
end
