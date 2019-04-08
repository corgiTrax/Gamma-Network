function interpolatedTrace=RemoveSpike(trace, spikePeakIndexes, Interval, bLFP)
%INTERPOLATEDTRACE=RemoveSpike(TRACE, SPIKEPEAKINDEXES, INTERVAL,BLFP) removes
%the points situated in the interval specifid by INTERVAL around the
%indices specified by SPIKEPEAKINDEXES and replaces the removed points by a
%cubic spline interpolation. INTERVAL must be specified as a two point
%vector whose first element must be negative and represent the number of
%point before the indices specified in SPIKEPEAKINDEXES that have to be
%removed. The second element must be positive and represent the number of
%points after the indices that have to removed.
%
%QP: 11-11-2013
%QP: 30-09-2014: modified so that it does not remove the spikes if they are
%to close from the border of the trace as this messes up the interpolation

%Does some checking
if sum(mod(spikePeakIndexes,1))~=0
    error('The values in spikePeakIndexes must be integers')
end

if numel(spikePeakIndexes)~=0
    if min(spikePeakIndexes)<1+Interval(1) || max(spikePeakIndexes)>length(trace)+Interval(2)
        error('The values in spikePeakIndexes exceed the traces dimension or are not appropriate for that interval')
    end
end

if numel(Interval)~=2
    error('Interval must be a two elements vector')
end

if Interval(1)>0 || Interval(2)<0
    error('The first element of interval must be negative and the second must be positive');
end

if bLFP~=0 && bLFP~=1
    error('bLFP must be either 0 or 1')
end

%Removes spikes if they are to close from the edges of the trace
spikePeakIndexes=spikePeakIndexes(spikePeakIndexes>-Interval(1)+1 & spikePeakIndexes<length(trace)-Interval(2)-1);


%shifts the values of spikePeakIndexes if Interval is not symetric
spikePeakIndexes=spikePeakIndexes+round(mean(Interval));

%Computes the values of the indices to be removed by convuluting a window
%around the values of spikePeakIndexes
mySpikeWindow=rectwin(Interval(2)-Interval(1)); 
spikeTrace=zeros(size(trace)); 
spikeTrace(spikePeakIndexes)=1;
convSpikeTrace=conv(spikeTrace,mySpikeWindow,'same');

%Computes the interpolated trace
traceIndex=1:length(trace);
trace=trace(convSpikeTrace==0); cutTraceIndex=traceIndex(convSpikeTrace==0);
if bLFP
    interpolatedTrace=interp1(cutTraceIndex,trace,traceIndex, 'linear')';
else
    interpolatedTrace=interp1(cutTraceIndex,trace,traceIndex, 'pchip')';
end