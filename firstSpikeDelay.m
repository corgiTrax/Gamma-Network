% Get 1st spike's delay after onset (with 100ms delay)

clear
% hyperparameters
% Delta wave -(0.1 – 4 Hz)
% Theta wave – (4 – 8 Hz)
% Alpha wave – (8 – 15 Hz)
% Mu wave – (7.5 – 12.5 Hz)
% SMR wave – (12.5 – 15.5 Hz)
% Beta wave – (16 – 31 Hz
% Gamma wave –  (32 – 70 Hz)
% Fast gamma – (70 to 130)
% For gamma, Dana chose 33-58 Luc chose 30-80
lfreq = 35; 
hfreq = 55;
% search how far (index) left-right for gamma cycle min max
oneSide = round(20000/lfreq) + 100;
% use cellBody oscillation or LFP to extract gamma?
dataSource = "cellBody";%"cellBody";
% phaseStart: bottom or top
phaseStart = "bottom";
% use zeroCrossing as start or not
zeroCross = false;
% exclude spikes that are at phases greater than this value; 
%if 1 then it means don't exclude anything; if 0.5 then exclude the latter half
phaseLimit = 1;
% whether to convert phase to a numeric value by taking log
phaseExpTrans = false;
transConst = -3; %alpha in Ballard and Jehee's paper; only works if phaseExpTrans = true

% look at data during stim on or off
stimOn = true;
% time range
timeStart = 42000; % stimulus onset is 2s, 100ms to reach to V1
timeEnd = 102000; %5.1s, what Luc chose

% First couple of spike or all spikes?
allSpike = true;
spikeLimit = 1; % only works if allSpike == false

%TODO: matlab bandpass filter or butterworh bandpass filter?

% which cell
cellID = 9;

% These trials have no spikes: 'QP0017grtA_Spectral.mat', 'LG0087grtAgrtB_Spectral.mat'
fNamesPYR = {'LG0073grtA_Spectral.mat','LG0077grtA_Spectral.mat','LG0082grtE_Spectral.mat','LG0089grtA_Spectral.mat','QP0019grtA_Spectral.mat','QP0020grtA_Spectral','QP0044grtA_Spectral.mat','QP0054grtA_Spectral.mat','QP0061grtA_Spectral'};
fNamesPV = {'LG0044grtB_Spectral','LG0060modAmodBodd_Spectral','LG0061modA_Spectral','LG0080modAmodBodd_Spectral','QP0007grtA_Spectral','QP0049modB_Spectral','QP0058modAOdd_Spectral','QP0065grtBOdd_Spectral','QP0068grtAOdd_Spectral'};

spikeStartDiffAll = [];
spikeMidDiffAll = []; % to calculate where each spike is in its phase
spikeEndDiffAll = [];
stim_orient = [];
spikeCountAll = [];
freqs = []; % frequency at spike

figure('Visible','off');

for fIndex = cellID:cellID%length(fNames) %TODO
    
    fName = fNamesPYR(fIndex);
    load(string(fName));
    disp(fName)
    
    sampleRate = sTraceSerie.global.sampleRate;
    numTraces = length(sTraceSerie.trace);
    
    for traceNum = 1:numTraces
        fprintf("TraceNum: %d\n",traceNum)
        spikes = sTraceSerie.trace(traceNum).spikePeakIndexes;
        % Note: use original raw traces instead of filtered traces

        if dataSource == "cellBody" %TODO: not using these -- we are removing spikes
            data = sTraceSerie.trace(traceNum).trace;
            % Matlab bandpass (bpm) filter with spike retained
            %gamma_bpm_spike = bandpass(data, [lfreq hfreq], sampleRate);
            %[gamma_bpm_spike, ~] = MyBandPassFilter(data, 7, lfreq, hfreq);
        elseif dataSource == "LFP"
            data = sTraceSerie.trace(traceNum).LFPTrace;
            %gamma_bpm_lfp = bandpass(data, [lfreq hfreq], sampleRate);
            %[gamma_bpm_lfp, ~] = MyBandPassFilter(data, 7, lfreq, hfreq);
        end
        
        spikeCount = 0;
        
        if ~isempty(sTraceSerie.trace(traceNum).spikePeakIndexes)
            
            if dataSource == "cellBody"
                data_rmSpike = RemoveSpike(data,sTraceSerie.trace(traceNum).spikePeakIndexes,sampleRate*[-0.0001,0.003],0);
                % Matlab bandpass filter with spike removed    
                %gamma_bpm_rmSpike = bandpass(data_rmSpike, [lfreq hfreq], sampleRate); 
                [gamma_bpm_rmSpike, ~] = MyBandPassFilter(data_rmSpike, 7, lfreq, hfreq);
            elseif dataSource == "LFP"
                interval=sTraceSerie.LFPStat.correctionInterval;
                data_rmSpike = RemoveSpike(data,sTraceSerie.trace(traceNum).spikePeakIndexes,sampleRate*interval,0);
                % Matlab bandpass filter with spike removed    
                gamma_bpm_lfp_rmSpike = bandpass(data_rmSpike, [lfreq hfreq], sampleRate);
            end
            
            for spike = 1:length(spikes)
                % can only look at spike after onset
                spikeIndex = sTraceSerie.trace(traceNum).spikePeakIndexes(spike);
                if stimOn
                    if spikeIndex < timeStart || spikeIndex > timeEnd % spikeIndex > timeStart && spikeIndex < timeEnd
                        continue
                    end
                else
                    if spikeIndex > timeStart && spikeIndex < timeEnd
                        continue
                    end
                end
                l = spikeIndex - oneSide;
                r = spikeIndex + oneSide;
                % if spike too close to edge, pass
                if l < 0 || r > length(data) 
                    continue
                end
                
                if dataSource == "cellBody"
                    segment = gamma_bpm_rmSpike(l:r); %TODO use gamma_bpm_spike
                elseif dataSource == "LFP"
                    segment = gamma_bpm_lfp_rmSpike(l:r);
                end
                
                if phaseStart == "bottom"
                    [startP, midP, endP] = detectCycleMinStart(segment);
                elseif phaseStart == "top"
                    [startP, midP, endP] = detectCycleMaxStart(segment);
                end
                
                cycleLen = (endP - startP); % / 360 in degrees
                freqs = [freqs, 20000 / cycleLen];
                spikeStartDiff = (oneSide+1 - startP) / cycleLen;
                
                if zeroCross
                    zeroCross = (midP + startP) / 2;
                    spikeStartDiff = (oneSide+1 - zeroCross) / cycleLen;
                    if spikeStartDiff < 0
                        spikeStartDiff = spikeStartDiff + 1; %TODO it should belong to the previous cycle;TODO:this is not exactly right 
                    end
                end

                %  TODO:only use spike that are in the first quater of gamma
                %  phase?
                if spikeStartDiff >= 0 && spikeStartDiff <= phaseLimit
                    spikeMidDiff = (oneSide+1 - midP); 
                    spikeEndDiff = (oneSide+1 - endP);
                        
                    if phaseExpTrans == true
                        spikeStartDiff = exp(transConst * spikeStartDiff);
                        if spikeStartDiff < 0
                            spikeStartDiff = 0;
                        end
                    end
                    
                    spikeStartDiffAll = [spikeStartDiffAll, spikeStartDiff];
                    spikeMidDiffAll = [spikeMidDiffAll, spikeMidDiff];
                    spikeEndDiffAll = [spikeEndDiffAll, spikeEndDiff];

                    stim_orient = [stim_orient,sTraceSerie.global.stimStruct.StimMatrix(traceNum)];
                    spikeCount = spikeCount + 1;
                end
                
                if allSpike == false % do not include spikes
                    if spikeCount == spikeLimit
                        break % only look at the first several spike
                    end
                end

                % plot
%                 figure
%                 plot(gamma_bpm_rmSpike(l:r))
%                 hold
%                 line([oneSide,oneSide],ylim)
%                 legend("spike osci", "no spike osci", "spike")

            end % end for each spike
        else
            disp('No spike in this trace')
        end %end if for if there are spikes
        spikeCountAll = [spikeCountAll, spikeCount];
    end
end % end for each file




