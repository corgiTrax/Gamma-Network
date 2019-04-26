function [maxStart, min, maxEnd] = detectCycleMaxStart(trace)
%detect the gamma cycle around a spike, return min and max, assuming gamme
%cycle starts at max, and gammaTrace is long enough to contain the entire
%cycle
% gammaTrace is centered at spike
%

traceLength = length(trace);
spikeIndex = round(traceLength/2);
maxStart = -1; 
min = -1;
maxEnd = -1;
i = spikeIndex;

% handling boundary case: spike at gamma min or max
rightDiff = trace(spikeIndex) - trace(spikeIndex + 1);
leftDiff = trace(spikeIndex) - trace(spikeIndex-1);

if rightDiff > 0 && leftDiff > 0 % spike at gamma max, let's assume this to be maxStart
    maxStart = spikeIndex;
    %search right for min and maxEnd
    while i < traceLength && maxEnd == -1
        if trace(i) - trace(i+1) < 0 && min == -1
            min = i;
        end
        if trace(i) - trace(i+1) > 0 && min ~= -1 % min must be found before maxEnd
            maxEnd = i;
        end
        i = i + 1;
    end
    
elseif rightDiff < 0 && leftDiff < 0 %spike at gamma min
    min = spikeIndex;
    %search left for maxStart
    while i > 1 && maxStart == -1
        if trace(i) - trace(i-1) > 0
            maxStart = i;
        end
        i = i-1;
    end
    i = spikeIndex;
    %search right for maxEnd
    while i < traceLength && maxEnd == -1
        if trace(i) - trace(i+1) > 0
            maxEnd = i;
        end
        i = i+1;
    end
elseif leftDiff < 0 % spike at decling phase of gamma
    %search left for maxStart
    while i > 1 && maxStart == -1
        if trace(i) - trace(i-1) > 0
            maxStart = i;
        end
        i = i-1;
    end
    % search right for min and maxEnd
    i = spikeIndex;
    while i < traceLength && maxEnd == -1
        if trace(i) - trace(i+1) < 0 && min == -1
            min = i;
        end
        if trace(i) - trace(i+1) > 0 && min ~= -1 % max must be found before minEnd
            maxEnd = i;
        end
        i = i + 1;
    end
elseif rightDiff < 0 % spike at rising phase of gamma
    %search right for maxEnd
    while i < traceLength && maxEnd == -1
        if trace(i) - trace(i+1) > 0
            maxEnd = i;
        end
        i = i+1;
    end
    % search left for min and maxStart
    i = spikeIndex;
    while i > 1 && maxStart == -1
        if trace(i) - trace(i-1) < 0 && min == -1
            min = i;
        end
        if trace(i) - trace(i-1) > 0 && min ~= -1 % min must be found before maxStart
            maxStart = i;
        end
        i = i - 1;
    end
end

end
   
