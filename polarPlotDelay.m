%polar plot first spike gamma delay(min-spike) and stimulus angle

% 
% [orient_sorted, orient_order] = sort(stim_orient);
% delay = spikeStartDiffAll(orient_order);
% orient_sorted = degtorad(orient_sorted);
% polarscatter(orient_sorted, delay)
% 
% unique_ori = [orient_sorted(1)];
% avg_delay = [];
% temp_delay = [delay(1)];
% 
% for i = 2:length(orient_sorted)
%    if orient_sorted(i) ~= orient_sorted(i-1)
%        avg_delay = [avg_delay, mean(temp_delay)];
%        unique_ori = [unique_ori, orient_sorted(i)];
%        temp_delay = [];
%    end
%    temp_delay = [temp_delay, delay(i)];
%    if i == length(orient_sorted)
%        avg_delay = [avg_delay, mean(temp_delay)];
%    end
% end
% 
% polarplot(unique_ori, avg_delay)

%saveFileName = strcat('avgDelayAfterStimOnset/',string(fName),'.png')
%saveas(gcf,saveFileName)

% polar plot rate (# of spikes after stimulus onset) for each trial each
% trace
orient_all = sTraceSerie.global.stimStruct.StimMatrix;

[orient_sorted, orient_order] = sort(orient_all);

rate = spikeCountAll(orient_order);

orient_sorted = degtorad(orient_sorted);

polarscatter(orient_sorted, rate)

unique_ori = [orient_sorted(1)];
avg_rate = [];
temp_rate = [rate(1)];

for i = 2:length(orient_sorted)
   if orient_sorted(i) ~= orient_sorted(i-1)
       avg_rate = [avg_rate, mean(temp_rate)];
       unique_ori = [unique_ori, orient_sorted(i)];
       temp_rate = [];
   end
   temp_rate = [temp_rate, rate(i)];
   if i == length(orient_sorted)
       avg_rate = [avg_rate, mean(temp_rate)];
   end
end
%polarplot(unique_ori, avg_rate)
% saveFileName = strcat('spikeRateAfterStimOnset/',string(fName),'.png')
% saveas(gcf,saveFileName)
