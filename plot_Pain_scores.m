
%Basic scatter plot and histogram re: Date, day and time 
%painscores.mat holds all automated data. use the individual mat files for
%true verified pain scores. 

addpath(genpath('/Users/prasad/Desktop/ChangLab DATA/DBS CP matlab analysis/CP1/data/processed'));

clear
close all
load LFPhome

pp=LFPmeta.autopain;
tt=LFPmeta.time(logical(LFPmeta.painmatch),:);

figure
subplot 311
plot(tt,pp,'b.','markersize',40);
ylabel('Pain Score')
xlabel('Date')

subplot 312
t=timeofday(tt);
plot(t,pp,'b.','markersize',40);
ylabel('Pain Score')
xlabel('Time of Day')


subplot 313
[n,wd]=weekday(tt);
[a,b]=weekday([2:7,1]); %day of week list Sun to Sat for ticks
plot(n,pp,'b.','markersize',40);
set(gca,'xticklabel',b);
ylabel('Pain Score')
xlabel('Day')

figure
histogram(LFPmeta.autopain,10,'normalization','probability')
title('Histogram of Numerical Pain Rating Scores')
ylabel('probability')
xlabel('Pain Score')