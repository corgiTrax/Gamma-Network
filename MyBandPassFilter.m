function [ s_filt,tv] = MyBandPassFilter(s,mySeconds,lfreq,hfreq)
%Butterworth zero phase bandpass filter taken from
% https://www.mathworks.com/matlabcentral/answers/349832-how-to-apply-bandpass-filter
% Used for somatic potentials clipped at -35 mV

% D=test33;
% s=D;
Fs = 20000*mySeconds;                                                % Sampling Frequency (Hz)
Fn = Fs/2;                                              % Nyquist Frequency (Hz)
Wp = mySeconds*[lfreq hfreq]/Fn;                                    % Passband Frequencies (Normalised)
Ws = mySeconds*[lfreq-3 hfreq+2]/Fn;                                    % Stopband Frequencies (Normalised)
Rp = 4;                                                % Passband Ripple (dB)
Rs = 50;                                                % Stopband Ripple (dB)
[n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);                         % Filter Order
[z,p,k] = cheby2(n,Rs,Ws);                              % Filter Design
[sosbp,gbp] = zp2sos(z,p,k);                            % Convert To Second-Order-Section For Stability
%figure(1)
freqz(sosbp, 2^16, Fs);                                 % Filter Bode Plot
tv = linspace(0, 1, length(s))/Fs;                      % Time Vector (s)
s_filt = filtfilt(sosbp,gbp, s);                        % Filter Signal
%figure(2);
%plot(tv, s_filt);
%grid

end

