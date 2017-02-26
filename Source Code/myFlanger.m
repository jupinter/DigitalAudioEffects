function y = myFlanger(x,fs, delay, rate, amp)
%%
%   ----Syntax----
%
%   output = myFlanger(Input signal, Sampling frequency, Flanger delay, LFO
%   Oscillation rate, amplitude)
%
%   ----Description----
%
%   Creates a single FIR delay with the delay time oscillating from either 
%   0-3ms or 0-15ms at 0.1-5Hz with a LFO to create a warping effect.
%   Flanging efects can also be implemented with a IIR filter however it
%   would require normalisation as IIR filters can introduce a large
%   increase in gain dB  (Zölzer et al., 2002).
%  
%   Suggested parameters for optimal effect
%
%   amp = 0.7
%   delay = 0.03
%   rate = 1 
%
%   ----History----
%
%   Line delay is regarded as the earliest delay technique, where it was used
%   by radio stations to send their signal out miles away and feed
%   back in the returning signal which would then have x amount of
%   milliescond delay.
%
%   For musical applications, analogue tape was the kickstarter. In the
%   1950s magnetic tape delay began to be used for musical purposes. First
%   a 'slapback' effect emerged, commonly heard on early rock and roll
%   recordings (Taylor, 2011).
%    
%   One of the first musical electronic devices to use digital signal processing
%   for delay was the Boss DD-2 in 1983 (Bybee, 2015) This was a digital delay effect
%   pedal capable longer delays than tape and would evolve to surpass
%   analogue delay in other areas such as modulation effects and
%   versatility (What is delay? A Mini guide to this effect, 2013).
%
%   Delay modulation allowed for various effects such as flanger, chorus, 
%   echo and vibrato. 
%
%   ----References----
%
%   Bybee, J. (2015) Echoes in time: The history of BOSS delay pedals - BOSS U.S. 
%   Available at: http://www.bossus.com/blog/2015/11/11/echoes-in-time-the-history-of-boss-delay-pedals/ 
%   [Accessed 10 January 2017].
%
%   Taylor, P. (2011) History of delay. Available at: 
%   http://www.effectrode.com/echorec-3/history-of-delay/ 
%   [Accessed 6 January 2017].
%   
%   Zölzer, U., Zolzer, U., Loscos, A., Arfib, D., Rocchesso, D., Keiler,
%   F. and Evangelista, G. (2002) DAFX - digital audio effects. Chichester, United Kingdom: Wiley, John & Sons.
%
%   ----Bibliography----
%
%   What is delay? A Mini guide to this effect (2013) 
%   Available at: http://www.dawsons.co.uk/blog/what-is-delay 
%   [Accessed 3 January 2017].

%--------------------------- Flanger ---------------------------

%Find the length of the input signal and store it in an index
index = 1:length(x); 

% Create a sinusoidal wave that oscillates when multipled with the LFO rate
sinLFO = (sin(2*pi*index*(rate/fs)))'; %A sinewave is commonly sin(2*pi*frequency*time)
                                       %(rate/fs) dictates the oscillations
                                       
%convert delay (ms) to max delay in samples
max_samp_delay = round(delay*fs); %Rounds the delay (ms) to fs (44100) digits

% create empty vector the size of the input for the output to fill (allocating memory)
y = zeros(length(x),1); %zeros() generates 0s for padding arrays with empty data

% Corrects the array to avoid referencing negative samples (which would
% cause incorrect playback)
y(1:max_samp_delay) = x(1:max_samp_delay); %Sets y the same delay as x

% For each sample generate delay and feed it back in with oscillation
for i = (max_samp_delay+1):length(x),
    
    cur_sin = abs(sinLFO(i)); %Calculate absolute value of oscillated signal
    
    % Generate delay from 1-max_samp_delay and ensure it is a whole number 
    cur_delay = ceil(cur_sin*max_samp_delay); %ceil is a function for
                                              %rounding to a positive number
    
    % Feed delayed signal back into original signal
    y(i) = (amp*x(i)) + amp*(x(i-cur_delay)); %Original signal + Delayed signal
end

%--------------------------- Plot signals ---------------------------
figure %New figure just for the flanger effect
subplot(2,1,1); %Subplot for original signal
plot(x, 'c'); %Display the original input signal
title('(FLANGE)Original signal'); 
ylabel('Amplitude');
xlabel('Time (s)');
grid on;

subplot(2,1,2); %Subplot for resultant signal (positioned below previous plot)
plot(y, 'r'); %Display the output signal
title('(FLANGE)Signal after flanger'); 
ylabel('Amplitude');
xlabel('Time (s)');
grid on;
end