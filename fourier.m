% Fourier spectrogram of trace

clear
%'QP0017grtA_Spectral.mat' % no spike field for this trial
%'LG0087grtAgrtB_Spectral.mat'
fNames = {'LG0073grtA_Spectral.mat','LG0077grtA_Spectral.mat','LG0082grtE_Spectral.mat','LG0089grtA_Spectral.mat','QP0019grtA_Spectral.mat','QP0020grtA_Spectral','QP0044grtA_Spectral.mat','QP0054grtA_Spectral.mat','QP0061grtA_Spectral'};

for fIndex = 2:2%length(fNames) %TODO
    
    fName = fNames(fIndex);
    load(string(fName));
    disp(fName)
    
    sampleRate = sTraceSerie.global.sampleRate;
    numTraces = length(sTraceSerie.trace);
    lfreq = 1; %Dana chose 33-58 Luc chooses 30-80
    hfreq = 150;
    
    for traceNum = 1:1 %TODO
        fprintf("TraceNum: %d\n",traceNum)
        spikes = sTraceSerie.trace(traceNum).spikePeakIndexes;
        % Note: use original raw traces instead of filtered traces
        data = sTraceSerie.trace(traceNum).trace;

        % Matlab bandpass (bpm) filter with spike retained
        %gamma_bpm_spike = bandpass(data, [lfreq hfreq], sampleRate);

        if ~isempty(sTraceSerie.trace(traceNum).spikePeakIndexes)
            
            data_rmSpike = RemoveSpike(data,sTraceSerie.trace(traceNum).spikePeakIndexes,sampleRate*[-0.001,0.003],0);
            % Matlab bandpass filter with spike removed    
            gamma_bpm_rmSpike = bandpass(data_rmSpike, [lfreq hfreq], sampleRate);   
        
            x = gamma_bpm_rmSpike;
            y = fft(x);     
            f = (0:length(y)-1)*sampleRate/length(y);                        
            n = length(x);                         
            fshift = (-n/2:n/2-1)*(sampleRate/n);
            yshift = fftshift(y);
            plot(fshift,abs(yshift))
            %set(gca, 'YScale', 'log')
        end % end if there are spikes

    end
end % end for each file