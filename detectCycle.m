function [minStart, max, minEnd] = detectCycle(trace)
%detect the gamma cycle around a spike, return min and max, assuming gamme
%cycle starts at min, and gammaTrace is long enough to contain the entire
%cycle
% gammaTrace is centered at spike
%

traceLength = length(trace);
spikeIndex = round(traceLength/2);
minStart = -1; 
max = -1;
minEnd = -1;
i = spikeIndex;

% handling boundary case: spike at gamma min or max
rightDiff = trace(spikeIndex) - trace(spikeIndex + 1);
leftDiff = trace(spikeIndex) - trace(spikeIndex-1);

if rightDiff < 0 && leftDiff < 0 % spike at gamma min, let's assume this to be minStart
    minStart = spikeIndex;
    %search right for max and minEnd
    while i < traceLength && minEnd == -1
        if trace(i) - trace(i+1) > 0 && max == -1
            max = i;
        end
        if trace(i) - trace(i+1) < 0 && max ~= -1 % max must be found before minEnd
            minEnd = i;
        end
        i = i + 1;
    end
elseif rightDiff > 0 && leftDiff > 0 %spike at gamma max
    max = spikeIndex;
    %search left for minStart
    while i > 1 && minStart == -1
        if trace(i) - trace(i-1) < 0
            minStart = i;
        end
        i = i-1;
    end
    i = spikeIndex;
    %search right for minEnd
    while i < traceLength && minEnd == -1
        if trace(i) - trace(i+1) < 0
            minEnd = i;
        end
        i = i+1;
    end
elseif leftDiff > 0 % spike at rising phase of gamma
    %search left for minStart
    while i > 1 && minStart == -1
        if trace(i) - trace(i-1) < 0
            minStart = i;
        end
        i = i-1;
    end
    % search right for max and minEnd
    i = spikeIndex;
    while i < traceLength && minEnd == -1
        if trace(i) - trace(i+1) > 0 && max == -1
            max = i;
        end
        if trace(i) - trace(i+1) < 0 && max ~= -1 % max must be found before minEnd
            minEnd = i;
        end
        i = i + 1;
    end
elseif rightDiff > 0 % spike at decling phase of gamma   
    %search right for minEnd
    while i < traceLength && minEnd == -1
        if trace(i) - trace(i+1) < 0
            minEnd = i;
        end
        i = i+1;
    end
    % search left for max and minStart
    i = spikeIndex;
    while i > 1 && minStart == -1
        if trace(i) - trace(i-1) > 0 && max == -1
            max = i;
        end
        if trace(i) - trace(i-1) < 0 && max ~= -1 % max must be found before minStart
            minStart = i;
        end
        i = i - 1;
    end
end

end
   
