clear
%'QP0017grtA_Spectral.mat' % no spike field for this trial
%'LG0087grtAgrtB_Spectral.mat'
fNames = {'LG0073grtA_Spectral.mat','LG0077grtA_Spectral.mat','LG0082grtE_Spectral.mat','LG0089grtA_Spectral.mat','QP0019grtA_Spectral.mat','QP0020grtA_Spectral','QP0044grtA_Spectral.mat','QP0054grtA_Spectral.mat','QP0061grtA_Spectral'};

spikeStartDiffAll = [];
spikeMaxDiffAll = []; % to calculate where each spike is in its phase
spikeEndDiffAll = [];
stim_orient = [];
spikeCountAll = [];

for fIndex = 2:2%length(fNames) %TODO
    
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
        % Note: use original raw traces vs filtered traces
        data = sTraceSerie.trace(traceNum).trace;
        %data = sTraceSerie.trace(traceNum).filteredTrace;
        % data_lfp = sTraceSerie.trace(traceNum).LFPTrace;

        %data_capSpike = data;
        %data_capSpike(data_capSpike > -37) = -37; % Raw trace only: a value set by Dana, this removed spike as well
        %data_capSpike(data_capSpike - 10; % filteredTrace only

        % Matlab bandpass (bpm) filter with spike retained
        gamma_bpm_spike = bandpass(data, [lfreq hfreq], sampleRate);
        % Dana used this filter (bpd)
        % [gamma_bpd_spike, ~] = MyBandPassFilter(data, 7, lfreq, hfreq); %7: 7seconds

        % get gamma from LFPs
        % gamma_bpm_lfp = bandpass(data_lfp, [lfreq hfreq], sampleRate);
        % Dana used this filter (bpd)
        % [gamma_bpd_lfp, ~] = MyBandPassFilter(data_lfp, 7, lfreq, hfreq); %7: 7seconds

        %gamma_bpm_capSpike = bandpass(data_capSpike, [lfreq hfreq], sampleRate);
        % [gamma_bpd_capSpike, ~] = MyBandPassFilter(data_capSpike, 7, lfreq, hfreq); %7: 7seconds
        
        spikeCount = 0;
        
        if ~isempty(sTraceSerie.trace(traceNum).spikePeakIndexes)
                       
            for spike = 1:length(spikes) %TODO
                % can only look at spike after onset
                spikeIndex = sTraceSerie.trace(traceNum).spikePeakIndexes(spike);
                 if spikeIndex < 40000 || spikeIndex > 42000 % 100ms window
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
                % [gamma_bpd_rmSpike,~] = MyBandPassFilter(data_rmSpike, 7, lfreq, hfreq);

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
                
                %if spikeCount == 1
                %    break%TODO; only look at the first spike
                %end
                
                %plot data
                % figure
                % plot(data(l:r))
                % hold
                % plot(data_capSpike(l:r))
                % plot(data_rmSpike(l:r));
                % legend("raw", "capSpike", "rmSpike")

                % plot extracted gamma 
%                  figure
%                  plot(gamma_bpm_lfp(l:r))
%                  hold
                % plot(gamma_bpd_spike(l:r))
                % plot(gamma_bpm_capSpike(l:r))
                % plot(gamma_bpd_capSpike(l:r))
                %plot(gamma_bpm_rmSpike(l:r))
                % plot(gamma_bpd_rmSpike(l:r))
                %legend("bpm spike", "bpd Spike", "bpm capSpike", "bpd capSpike", "bpm rmSpike", "bpd rmSpike","spike")
%                  line([oneSide,oneSide],ylim,'Color','red')
%                  line([minStartP,minStartP],ylim, 'Color','blue')
%                  line([maxP,maxP],ylim, 'Color','blue')
%                  line([minEndP,minEndP],ylim, 'Color','blue')
%                legend("bpm spike", "spike")

                % figure
                % plot(gamma_bpm_lfp(l:r))
                % hold
                % plot(gamma_bpd_lfp(l:r))
                % line([oneSide,oneSide],ylim)
                % legend("bpm lfp", "bpd lfp", "spike")
                % 
                % figure
                % plot(gamma_bpm_lfp(l:r))
                % hold
                % plot(gamma_bpm_rmSpike(l:r))
                % ylim([-1 1])
                % line([oneSide,oneSide],ylim)
                % legend("bpm lfp", "bpm rmSpike", "spike")

            end % end for each spike
        else
            disp('No spike in this trace')
        end %end if for if there are spikes
        spikeCountAll = [spikeCountAll, spikeCount];
        
    end %end for each each trace
        % save to a different file
        % sTraceSerie.trace(traceNum).gammaTrace = gamma;
        % outFile = strcat('gamma',fName);
        % save(outFile)
        %clear
end % end for each file

% disp("spikeStartDiff:")
% mean(spikeStartDiffAll)
% std(spikeStartDiffAll)
% disp("spikeMaxDiff:")
% mean(spikeMaxDiffAll)
% std(spikeMaxDiffAll)
% disp("spikeEndDiff:")
% mean(spikeEndDiffAll)
% std(spikeEndDiffAll)

