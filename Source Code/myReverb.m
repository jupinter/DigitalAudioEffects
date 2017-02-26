function y = myReverb(x, fs, earlyGain, lateGain)
%% 
%   ----Syntax----
%
%   output = myReverb(Input file, Sampling freqeuncy, Early gain, Late
%   gain)
%
%   ----Description----
%
%   This is an algorithmic reverberation based on the Schroeder 4 filter 
%   reverberator (1961). It used four comb filters in parallel sequentially 
%   passed through three all pass filters to simulate early and late 
%   reflections of a room.
%    
%   Schroeder's algorithm can be defined as: y(n)=-g.).(x +z(n-m)+g.y(n-m)
%   Where m is delay length in samples.
%       
%   ----History----
%
%   One of the earliest reverberaters is Schroeder's 4 filter.
%   in the 1960s. The Schroeder algorithm is famed for it's simplicity 
%   yet good simulation of complex echo patterns (Zölzer et al., 2002) 
%   and has become a standard component in many artifical reverberators 
%   used thereafter (Moorer, 1979).
%
%   Moorer later improved on Schroeder's design and creater the Moorer
%   reverberator which used low pass filters on each iteration a impule
%   response tap as well as comb and all pass. Moorer used parallel comb
%   filters with different delay lengths, allpass filters and low pass
%   filters inserted in to the feedback loop to alter reverb time as a
%   function of frequency (Moorer,1979). Snice then, newer and more advanced
%   algorithms have been designed. Dattorro's figure of 8 algorithm consists 
%   of multiple filters configured in series and parallel. Further more,
%   feedback felay networks where introduced by Stautner and Puckette (1982)
%   which are based on delay lines interconnected in a feedback loop by a
%   matrix. The earlier Jot reverberator (1991) avoids resonances 
%   caused by transients by using a digital delay feedback network with a 
%   coefficient matrix (Zölzer et al., 2002).
%      
%   ----References----
%   
%   Moorer, J. A. (1979) About this reverberation business. 
%   Computer Music Journal, 3(2), p. 13. 
%   Available at: http://dx.doi.org/10.2307/3680280.
%
%   Zölzer, U., Zolzer, U., Loscos, A., Arfib, D., Rocchesso, D., Keiler,
%   F. and Evangelista, G. (2002) DAFX - digital audio effects. Chichester, United Kingdom: Wiley, John & Sons.

earlyDelayLen = [0.005, 0.002, 0.001]; %Array that holds early delay time in seconds
leateDelayLen = [0.1, 0.09, 0.08, 0.095]; %Array that holds late time in seconds


%Here allpass filters are used to simulate early reflections of space
%The allpass function is called with the delay line data
%This is processed in series
y = allpass(x, fs, earlyGain, earlyDelayLen(1));
y = allpass(y, fs, earlyGain, earlyDelayLen(2));
y = allpass(y, fs, earlyGain, earlyDelayLen(3));
 
%Here, four comb filters are processed in parallel, simulating the late
%delay reflections
y1 = comb(y, fs, lateGain, leateDelayLen(1));
y2 = comb(y, fs, lateGain, leateDelayLen(2));
y3 = comb(y, fs, lateGain, leateDelayLen(3));
y4 = comb(y, fs, lateGain, leateDelayLen(4));
 
% Mix filtered signals
y = y1+y2+y3+y4; %Sum the parallel processed signals
y = y./max(y); %Normalise the output

%----- Plot Reverb signal -----
figure %New figure for reverb plots
subplot(4,1,1); %Original signal subplot
plot(x, 'k'); %Plot x original signal
title('(REVERB)Original signal'); 
ylabel('Amplitude');
xlabel('Time (s)');
grid on;

subplot(4,1,2); %Altered reverb signal subplot
plot(y, 'k'); %Plot y altered signal
ylabel('Amplitude');
xlabel('Time (s)');
title ('(REVERB)Signal after algorithm'); 
grid on;

% --------------------------- Central time ---------------------------

%Central time is the centre of gravity of the reverb tail
%It is measured in seconds and normalised to the length of the impulse
%response and found by taking the cntroid across the IR

%Calculate interpolated envelope in dB 
[t, e] = dBenvelope(y, 512, fs);
cTime = sum(t.*e)./sum(e); %Calculate the central time by summing the time and envelopes

%Plot central
subplot(4,1,3); 
plot(t, e, 'k'); %Plot time
title('(REVERB)Central time');
ylabel('Level (dB)');
xlabel('Time (s)');
grid on; hold on; 
plot([cTime, cTime], [min(e), max(e)], 'r'); %Plot the envelope


%--------------------------- Reverb time (RT60)---------------------------
%Reverb time is the time it takes for the measured signal to decay by
%60dB in level from its peak value.
%To calculate reverb time you must have the impulse response of the
%reverb.

%This code creates an impulse response
%Create a basic impulse response 
dur = 1; %Duration
b = [1 1]; %Array to hold IR points
N = round(dur*fs); %Find the length
h = zeros(1, fs); %Add extra empty zero data to be correct length
h(1) = b(1); %Apply filters
h(N) = b(2); 

%Using the same reverb algorithm, only now inputing the artifical impulse
%response instead
% Allpass filters
RTSig = allpass(h, fs, earlyGain, earlyDelayLen(1));
RTSig = allpass(RTSig, fs, earlyGain, earlyDelayLen(2));
RTSig = allpass(RTSig, fs, earlyGain, earlyDelayLen(3));
 
% Comb-filters
RTSig1 = comb(RTSig, fs, lateGain, leateDelayLen(1));
RTSig2 = comb(RTSig, fs, lateGain, leateDelayLen(2));
RTSig3 = comb(RTSig, fs, lateGain, leateDelayLen(3));
RTSig4 = comb(RTSig, fs, lateGain, leateDelayLen(4));
 
% Mix filtered signals
RTSig = RTSig1+RTSig2+RTSig3+RTSig4;
RTSig = RTSig./max(RTSig); %Normalise the output signal
 
% Calculate interpolated envelope in dB
[t, e] = dBenvelope(RTSig, 512, fs);

% Find the peak in the envelope
[peakVal, peakIdx] = max(e);

%This checks to see if the signal peak did fall below the RT60
%If peak value falls below 60 dB
if( (peakVal-min(e)) > 60)   
    
    tail = e(peakIdx)-e(peakIdx:end); %Reverb tail - measuring the peak at the end    
    lessThan60 = find(tail>60); %Checking if decayed by 60dB
    rt60Idx = lessThan60(1);      
    % Calculate the RT60
    RT60 = (rt60Idx-peakIdx)/fs %Print RT60

else
    % If it never falls below 60dB use the end of file
    RT60 = (length(x)-peakIdx)/fs;   
   
end

subplot(4,1,4); %Plot the resultant reverb time diagram
plot(t, e, 'k'); 
title ('(REVERB)Reverb time (RT60) of algorithm'); 
ylabel('Level (dB)');
xlabel('Time (s)');
grid on; hold on; 
axis([t(1), t(end), min(e), max(e)]);
plot([t(peakIdx) t(peakIdx)], [min(e) max(e)], 'r');
plot([t(rt60Idx) t(rt60Idx)], [min(e) max(e)], 'r');

end