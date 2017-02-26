function  y = myCompression(x, fs, ratio, threshold, knee, dBGain)
%%
%   ----Syntax----
%   
%   output = compression(Input file, Sampling frequency, compression
%   threshold, knee, make up gain)
%
%   ----Description----
%   
%   This is a feed-forward compressor function based on the Reiss and McPherson
%   algorithm which contains knee, attack, release and make up gain
%   functionality.
%      
%   ----History----
% 
%   Compression is a type of dymanic processing that is based on amplitude
%   and level detection that automates the gain based on the level of the
%   input signal (Zölzer et al., 2002). Compression is a non-linear form of
%   processing because it uses the input signal for processing, reducing
%   high signal levels and leaving quieter parts untreated (Reiss et al., 2014).
% 
%   Compression has many usages, from almost every part of studio recording
%   to live broadcasting and performances. Compresison is used commonly in
%   recording to compress the dynamic range of a sound source. Changing the
%   dynamic range of audio can create a desirable sound signature for
%   modern recording. In live applications, compressors are used to ensure
%   that a sound source is kept at an appropriate level whilst reducing any
%   unwanted peaks in level that could cause feedback or clipping.
%
%   One of the most iconic industry used compressors is the LA1176 by
%   Univeral Audio and the Teletronix LA-2A. Both compressors are no longer
%   in production in their original state, but they can be emulated with
%   audio plugins from Universal Audio.
%
%  ----References----
%
%   Reiss, J. D. and McPherson, A. (2014) Audio effects theory, 
%   implementation, and applications. Boca Raton, FL, United States: CRC Press.
%
%   Zölzer, U., Zolzer, U., Loscos, A., Arfib, D., Rocchesso, D., Keiler,
%   F. and Evangelista, G. (2002) DAFX - digital audio effects. Chichester, United Kingdom: Wiley, John & Sons.

%Define time parameters
ts = 1/fs; %Time of one sample
dur = length(x)/fs; %Find the duration of the signal by multiplying length by sample freq
time = 0 :ts:dur-ts; %Create time as an array  

%--------------------------- Plot signal before compression ---------------------------

%RMS Calculated by taking the root mean squared (RMS) for each frame of audio
%Peak amplitude calculated by taking the mac and min value for each frame
%of audio

%Create frame parameters for analysis
frameLen = 268;
frStart = 1;
frEnd = frameLen;
 
% Add extra zeros for correct matrix dimensions
numFrames = floor(length(x)/frameLen);
y=x;

%For every frame
for i = 1:numFrames
   %Calculate Gain and apply it to a frame
   frameCtrsC(i) = time(frStart+round(frEnd-frStart)); %Time of signal from start to end
   ampXrms(i) = sqrt(mean(y(frStart:frEnd).^2)); %Calculate RMS amplitude
   ampXpeak(i) = max(x(frStart:frEnd)); %Calculat peak amplitude
   
   %Update frame position with new data
   frStart = frStart+frameLen;
   frEnd = frEnd+frameLen;
end

%Plot RMS amp
figure %New figure box just for compression plots
subplot(5,1,1); %Assign to a subplot
plot(time, x); hold on; grid on;
plot(frameCtrsC, ampXrms, 'r', 'LineWidth', 2 ) %Plot RMS line over the signal
ylabel('Gain (dB)')
xlabel('Time (s)')
title('(COMPRESSION)RMS Amplitude envelope')
%Plot peak amp
subplot(5,1,2);%Assign to a subplot
plot(time, x); hold on; grid on;
plot(frameCtrsC, ampXpeak, 'r', 'LineWidth', 2 ) %Plot peak line over the signal
ylabel('Gain (dB)')
xlabel('Time (s)')
title('(COMPRESSION)Peak Amplitude envelope')

%--------------------------- Compression ---------------------------

%Knee is specified in width and defines the slope of the input output curve
%between unity and ratio

%Compute knee coefficients
%This technique is called quadratic-spline interpolation which calculates
%coefficients based on polynomial equations.
%knee width is represented as two sample points x1 = T-k/2
%                                               x2 = T+k/2
%Then it interpolates between the two points using this quadratic equation:
%a1 + b1x + c1x^2

c0 = -((ratio - 1.0) * (threshold * threshold - knee * threshold + knee * knee / 4.0)) / (2.0 * knee * ratio);
c1 = ((ratio - 1) * threshold + (ratio + 1) * knee / 2.0) / (knee * ratio);
c2 = (1 - ratio) / (2.0 * knee * ratio);

%Preallocate size of processed signal in memory
y = zeros(1, length(x));

%For every sample of the orginal audio data
for n=1:length(x)
    
    % Calculate uncompressed portion of signal that will not be effected
    % If orginal siganl is equal to or below the threshold then do not
    % effect the signal.
    if (x(n) <= threshold - (knee*0.5))
        y(n) = x(n);
    % Calculate compressed part
    elseif (x(n) > threshold + (knee*0.5)) %if  signal is above threshold
        %Reduce gain by the gain reduction threshold ratio 
        y(n) = threshold + (x(n)-threshold)/ratio; 
    %Compute knee smoothing
    else
        y(n) = x(n) * x(n) *c2 + x(n) * c1 + c0; % multiply signal by knee coefficients
    end
    
end

%--------------------------- Transfer function plot ---------------------------

%Transfer function allows monitoring of the gain and gain reduction
%Subplot for the transfer function plot
subplot(5,1,3);
plot(x, y, 'k'); hold on; %Plot origianl signal and processed signal
plot([threshold, threshold],[min(x), max(x)], 'k--');%threshold - min max
plot([min(x), max(x)],[threshold, threshold], 'k--');%Min max - threshold
title('(COMPRESSION)Transfer function');

% --------------------------- Make up gain ---------------------------

%Apply make up gain
y = y.* (10.^(dBGain/20)); %User define param for dBGain using dB conversion forumla:
                           % A = 10*log10(P2/P1)

% --------------------------- Plot signal after compression and gain ---------------------------

%RMS Calculated by taking the root mean squared (RMS) for each frame of audio
%Peak amplitude calculated by taking the mac and min value for each frame
%of audio

%Create frame parameters for analysis (Named _AfterC to avoid conflict with
%previously used variables for plotting signal)
frameLen_AfterC = 268;
frStart_AfterC = 1;
frEnd_AfterC = frameLen_AfterC;
 
% Add extra zeros for correct matrix dimensions
numFrames_AfterC = floor(length(y)/frameLen_AfterC);

%For every frame
for i = 1:numFrames_AfterC
   %Calculate Gain and apply it to a frame
   frameCtrs_AfterC(i) = time(frStart_AfterC+round(frEnd_AfterC-frStart_AfterC)); %Time of signal from start to end
   ampYrms_AfterC(i) = sqrt(mean(y(frStart_AfterC:frEnd_AfterC).^2)); %Calculate RMS amplitude
   ampYpeak_AfterC(i) = max(y(frStart_AfterC:frEnd_AfterC)); %Calculate peak amplitude
   
   %Update frame position with new data
   frEnd_AfterC = frEnd_AfterC+frameLen_AfterC;
   
end

%Plot RMS amp
subplot(5,1,4); %Assign to a subplot
plot(time, y); hold on; grid on;
plot(frameCtrs_AfterC, ampYrms_AfterC, 'g', 'LineWidth', 2 ) %Plot RMS line over the signal
ylabel('Gain (dB)')
xlabel('Time (s)')
title('(COMPRESSION)RMS Amplitude envelope after compression')
%Plot Peak amp
subplot(5,1,5);
plot(time, y); hold on; grid on;
plot(frameCtrs_AfterC, ampYpeak_AfterC, 'g', 'LineWidth', 2 ) %Plot peak line over the signal
ylabel('Gain (dB)')
xlabel('Time (s)')
title('(COMPRESSION)Peak Amplitude envelope after compression')

end