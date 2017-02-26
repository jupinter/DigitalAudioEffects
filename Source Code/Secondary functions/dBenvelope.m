function [t, env] = dBenvelope(x, frameLen, fs)
%%
%   Returns an interpolated dB amplitude envelope of x
%
%   Syntax
%   time, envelope = dBenevelope(input signal, frame length, sampling
%   frequency)


% set up the x axis...
ts = 1/fs;
dur = length(x)/fs;
t = 0 :ts:dur-ts;

% init frame positions...
frStart = 1;
frEnd   = frameLen;

% number of frames...
numFrames = floor(length(x)/frameLen);

% loop over each frame to compute env...
for i = 1:numFrames

    % Compute peak envelope...
   frameCtrs(i) = t(frStart+round(frEnd-frStart));
   ampXpeak(i) = 20*log10(max(abs(x(frStart:frEnd)))); %Peak Amplitude

   % update frame position...
   frStart = frStart+frameLen;
   frEnd = frEnd+frameLen;
end

% interpolate the envelope...
frameCtrs = frameCtrs;
ampXpeak = ampXpeak;
env = interp1(frameCtrs, ampXpeak, t);

env = env(~isnan(env));
t   = t(~isnan(env));