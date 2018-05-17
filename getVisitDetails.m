function outdat = getVisitDetails(protTable,painScores,moodScores)
%% This function open a gui that allows experimenter to report experimental conditions 
%  For Activa PC + S 

% input: 
%    1- protTable is table of found files in visit from function ProcessVisitData.m
%    2- painScores is a mat file of pain score data that has been loaded from
%     painscoreimport.m/ column 1=date and times, 2=pain NRS
% output: a completed protocol with med + stim + task details in table
% format 

%%% 

for r = 1:size(protTable)
    outdata{r,1} = protTable.Fn{r};
    outdata{r,2} = char(protTable.Date(r)); %date and time of recording
    outdata{r,3} = char(protTable.Dur(r));
    outdata{r,4} = protTable.Fs{r};
    outdata{r,5} = char(protTable.contacts(r));
    outdata{r,6} = protTable.Task{r};
    outdata{r,7} = logical(0);
    outdata{r,8} = char(0);
    outdata{r,9} = double(0); %Pain Score 
    outdata{r,10} = double(0); %Mood Score 
    outdata{r,11} = double(0);
    
    %CONSIDER ADDING ANOTHER COLUMN/ FIELD - 1 = autodetected pain score
    
%             automatically find the pain score (and Mood score) corresponding to the file
%             if there is a recorded score +/- 30 mins
                half_hour=duration(0,30,0);
                timediff=abs(painScores{1} - outdata{r,2});
                    moodtimediff=abs(moodScores{1} - outdata{r,2});
                painscoreMatch=timediff<half_hour;
                moodscoreMatch=moodtimediff<half_hour;
                
                if sum(painscoreMatch)>0
                    holdpain=painScores{2}(painscoreMatch);
                outdata{r,9} = max(holdpain); %if more than 1 score get max pain score
                outdata{r,6} = 'home';
                end
                     
                if sum(moodscoreMatch)>0
                    holdmood=moodScores{2}(moodscoreMatch);
                outdata{r,10} = max(holdmood); %if more than 1 score get max pain score
                end
                
                    
                
                
end



hfig = figure();
hfig.Position = [100 100 1100 500];
t = uitable('Parent', hfig);
t.Position = [0 0 1100 450];
t.ColumnWidth = {200 150 60 40 100 120 30 80 80 120};
t.Data = outdata;%protCell; 
t.ColumnName = {'fn','date','duration','Fs','contacts','task','med','Med Name','PainScore','MoodScore','TimeFromMed (min)'}; 
t.ColumnEditable = [false false false false false true true true true true true];
t.ColumnFormat = {[] []  [] [] [] {'Pain Activity','Pre-Post Med','home','QST','error'},...
                           [],...
                           [],[]};


input('done editing table?[1] ');
outdat = t.Data; 
close(hfig); 
end