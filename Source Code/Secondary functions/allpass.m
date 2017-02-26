function y = allpass(x, fs, gain, delayLen)
%%
% Syntax
% output = allpass(input signal, sampling frequency, gaine, delay lenght)
%

%Calculate delay length in samples
delayLen = round(delayLen*fs); % note, gain should be less than 1. 

% create coefficient filters that will shape the signal
b = [gain, zeros(1, delayLen-1), 1];
a = [1,    zeros(1, delayLen-1), gain];

% filter the input signal 
y = filter(b,a,x);
end
