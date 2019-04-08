% response (delay) historgram
% one neuron, different stimulus (0-360), plot gamma delay (first spike
% after onset, all spikes).

clear
%'QP0017grtA_Spectral.mat' % no spike field for this trial
%'LG0087grtAgrtB_Spectral.mat'
fNames = {'LG0073grtA_Spectral.mat','LG0077grtA_Spectral.mat','LG0082grtE_Spectral.mat','LG0089grtA_Spectral.mat','QP0019grtA_Spectral.mat','QP0020grtA_Spectral','QP0044grtA_Spectral.mat','QP0054grtA_Spectral.mat','QP0061grtA_Spectral'};

spikeStartDiffAll = [];
spikeMaxDiffAll = []; % to calculate where each spike is in its phase
spikeEndDiffAll = [];
stim_orient = [];
spikeCountAll = [];

for fIndex = 9:9%length(fNames) %TODO
    
    fName = fNames(fIndex);
    load(string(fName));
    disp(fName)
    
    sampleRate = sTraceSerie.global.sampleRate;
    numTraces = length(sTraceSerie.trace);
    lfreq = 35; %Dana chose 33-58 Luc chooses 30-80
    hfreq = 55;
    oneSide = 1000; % search how far (index) left-right for gamma cycle min max
    
    for traceNum = 1:numTraces %TODO
        fprintf("TraceNum: %d\n",traceNum)
        spikes = sTraceSerie.trace(traceNum).spikePeakIndexes;
        % Note: use original raw traces instead of filtered traces
        data = sTraceSerie.trace(traceNum).trace

        % Matlab bandpass (bpm) filter with spike retained
        gamma_bpm_spike = bandpass(data, [lfreq hfreq], sampleRate);

        spikeCount = 0;
        
        if ~isempty(sTraceSerie.trace(traceNum).spikePeakIndexes)
                       
            for spike = 1:length(spikes) %TODO
                % can only look at spike after onset
                spikeIndex = sTraceSerie.trace(traceNum).spikePeakIndexes(spike);
                 if spikeIndex < 40000 % || spikeIndex > 42000 % 100ms window
                    continue
                 end
                
                l = spikeIndex - oneSide;
                r = spikeIndex + oneSide;
                if l < 0 || r > length(data) % if spike too close to edge, pass
                    continue
                end
                data_rmSpike = RemoveSpike(data,sTraceSerie.trace(traceNum).spikePeakIndexes,sampleRate*[-0.001,0.003],0);

                % Matlab bandpass filter with spike removed    
                gamma_bpm_rmSpike = bandpass(data_rmSpike, [lfreq hfreq], sampleRate);

                segment = gamma_bpm_rmSpike(l:r); %TODO use gamma_bpm_rmSpike|gamma_bpm_lfp
                [minStartP, maxP, minEndP] = detectCycle(segment);
                                
                cycleLen = (minEndP - minStartP) / 360; % in degrees
                spikeStartDiff = (oneSide+1 - minStartP) / cycleLen;
                spikeMaxDiff = (oneSide+1 - maxP); 
                spikeEndDiff = (oneSide+1 - minEndP);
                % TODO, need to normalize this to be phase
                spikeStartDiffAll = [spikeStartDiffAll, spikeStartDiff];
                spikeMaxDiffAll = [spikeMaxDiffAll, spikeMaxDiff];
                spikeEndDiffAll = [spikeEndDiffAll, spikeEndDiff];
                
                %This needs to be here since some traces do not have
                %spikes; some traces have a spike but it is too close to
                %edge
                stim_orient = [stim_orient,sTraceSerie.global.stimStruct.StimMatrix(traceNum)];
                spikeCount = spikeCount + 1;
                
                if spikeCount == 1
                    break%TODO; only look at the first spike
                end
            end % end for each spike
        else
            disp('No spike in this trace')
        end %end if for if there are spikes
        spikeCountAll = [spikeCountAll, spikeCount];
    end
end % end for each file

%polar plot first spike gamma delay(min-spike) and stimulus angle

[orientSorted, orientOrder] = sort(stimOrient);
delay = spikeStartDiffAll(orientOrder);
orientSorted = degtorad(orientSorted);


delayWBound = delay;

countBound = 0;
for i = 2:length(orientSorted)
    if orientSorted(i) ~= orientSorted(i-1)
        delayWBound = [delayWBound(1:i+countBound-1) 0 delayWBound(i+countBound:end)];
        countBound = countBound + 1;
    end
end

bar(delayWBound)

saveFileName = strcat('barPlot_firstDelayAfterStimOnset/',string(fName),'.png')
saveas(gcf,saveFileName)



