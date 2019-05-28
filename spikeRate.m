% Get spike rate after stimulus onset
clear
% No pike:
%'QP0017grtA_Spectral.mat','LG0087grtAgrtB_Spectral.mat'
fNames = {'LG0073grtA_Spectral.mat','LG0077grtA_Spectral.mat','LG0082grtE_Spectral.mat','LG0089grtA_Spectral.mat','QP0019grtA_Spectral.mat','QP0020grtA_Spectral','QP0044grtA_Spectral.mat','QP0054grtA_Spectral.mat','QP0061grtA_Spectral'};
%No spike: LG0059grtB_Spectral
%'LG0067grtB_Spectral','LG0069modA_Spectral','LG0070grtA_Spectral','QP0021grtA_Spectral','QP0023grtB_Spectral','QP0025grtA_Spectral'
%'QP0027grtA_Spectral','QP0034grtC_Spectral','QP0036grtA_Spectral','QP0042grtC_Spectral','QP0053grtA_Spectral'
%'QP0056grtA_Spectral','QP0057grtA_Spectral'
fNamesPV = {'LG0044grtB_Spectral','LG0060modAmodBodd_Spectral','LG0061modA_Spectral','LG0080modAmodBodd_Spectral','QP0007grtA_Spectral','QP0049modB_Spectral','QP0058modAOdd_Spectral','QP0065grtBOdd_Spectral','QP0068grtAOdd_Spectral'};
% No spike: PV_VC+10Data
fNamesPV2 = {'QP0068grtB_Spectral'};
stimOrient = [];
spikeCountAll = [];
cellIndex = [];

total_trace = 0;

for fIndex = 1:9%length(fNames) %TODO
    
    fName = fNamesPV(fIndex);
    load(string(fName));
    disp(fName)
    
    sampleRate = sTraceSerie.global.sampleRate;
    numTraces = length(sTraceSerie.trace);
    
    for traceNum = 1:numTraces %TODO
        total_trace = total_trace + 1;
        fprintf("TraceNum: %d\n",traceNum)
        spikes = sTraceSerie.trace(traceNum).spikePeakIndexes;
        spikeCount = 0;
        
        if ~isempty(sTraceSerie.trace(traceNum).spikePeakIndexes)
                       
            for spike = 1:length(spikes) %TODO
                % can only look at spike after onset
                spikeIndex = sTraceSerie.trace(traceNum).spikePeakIndexes(spike);
                 if spikeIndex < 42000  || spikeIndex >  102000 % 2.1s-5.1s window
                    continue
                 end
                
                stimOrient = [stimOrient,sTraceSerie.global.stimStruct.StimMatrix(traceNum)];
                cellIndex = [cellIndex, fIndex];
                spikeCount = spikeCount + 1;
                
            end % end for each spike
        else
            disp('No spike in this trace')
        end %end if for if there are spikes
        spikeCountAll = [spikeCountAll, spikeCount];
    end
end % end for each file


% polar plot rate (# of spikes after stimulus onset) for each trial each
% trace
% orient_all = sTraceSerie.global.stimStruct.StimMatrix;
% [orient_sorted, orient_order] = sort(orient_all);
% rate = spikeCountAll(orient_order);
% orient_sorted = degtorad(orient_sorted);
% polarscatter(orient_sorted, rate)
% hold
% unique_ori = [orient_sorted(1)];
% avg_rate = [];
% temp_rate = [rate(1)];
% 
% for i = 2:length(orient_sorted)
%    if orient_sorted(i) ~= orient_sorted(i-1)
%        avg_rate = [avg_rate, mean(temp_rate)];
%        unique_ori = [unique_ori, orient_sorted(i)];
%        temp_rate = [];
%    end
%    temp_rate = [temp_rate, rate(i)];
%    if i == length(orient_sorted)
%        avg_rate = [avg_rate, mean(temp_rate)];
%    end
% end
% polarplot(unique_ori, avg_rate)
% saveFileName = strcat('spikeRateAfterStimOnset/',string(fName),'.png')
% saveas(gcf,saveFileName)