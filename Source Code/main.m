%Clear workspace and command window data to ensure variables are correctly
%assigned each time the main.m is ran
clear,clc 

%This file uses the input() function to read in user inputted text to
%control the parameters of the audio effects.

%Read input signal in and assign to variable
signal = input('Enter audio file name (e.g "snare.wav"):');

[x, fs] = audioread(signal); %Extract audio sample data and sampling frequency
Time = length(x)./fs; %Calculate time in seconds for playback

x = x(:,1); %Convert to mono by making x a single row horizontal array

%Enter parameters for flanger and assign them to variables for calling the
%function later
display('Group 1 - Flanger:');
display('Suggested parameters for best results: Delay = 0.03, Rate = 1, Amp = 0.7');
delay = input('Enter delay time (s):');
rate = input ('Enter LFO rate (Hz):');
amp = input('Enter amp level (0 - 0.7):');

%Enter parameters for compression and assign them to variables for calling the
%function later
display('Group 2 - Compressor');
display('Suggested parameters for best results: Ratio = 0.6, Threshold = -1, Knee = 1, Make up gain = 3');
ratio = input('Enter compression ratio:');
threshold = input('Enter compression threshold:');
knee = input('Enter compression knee value:');
dBGain = input('Enter make up gain (dB):');

%Enter parameters for reverb and assign them to variables for calling the
%function later
display('Group 3 - Reverb');
display('Suggested parameters for best results:Early gain = 0.9, late gain = 0.4');
earlyGain = input('Enter early gain value (0-1):');
lateGain = input('Enter late gain value (0-1):');

%Series or parallel processing
select = input('Enter 1 for series processing, 2 for parallel processing (Recommended):');

%In series processing, the signal chain flows linearly from effect one -
%two - three. After each effect the signal is directly processed further.

%If statement that selects series of parallel methods of applying effects
%to the signal
if (select == 1)
   
    %--------------------------- Series ---------------------------
   %Call flanger function and use the variables already set by user input
   y = myFlanger(x,fs,delay,rate,amp); sound(y,fs); %Play processed signal
   
   %Call compressor function and use the variables already set by user input
   y = myCompression(y, fs,ratio,threshold,knee,dBGain); 
   %Permute re-arranges dimensions of an array
   y = permute(y,[2 1]); % Moves the audio data to the right index to allow reverb to work correctly
   pause(Time); %Allow time for the previous sound() to finish
   sound(y,fs); %Play the signal again after being processed a second time
   
   %Call reverb function and use the variables already set by user input     
   y = myReverb(y,fs,earlyGain,lateGain);
   pause(Time); %Allow time for the previous sound() to finish
   
   %Write audio to new .wav file
   audiowrite('outputSeries.wav', y, fs);
   pause(Time); %Allow time for the previous sound() to finish
   display('Final signal');
   sound(y,fs); %Play resultant signal
    
else
    
    %--------------------------- Parallel ---------------------------
    %Call all functions from user param and assign them to three unique output variables
    y1 = myFlanger(x,fs,delay,rate,amp);
    y2 = myCompression(x, fs,ratio,threshold,knee,dBGain);
    y3 = myReverb(x,fs,earlyGain,lateGain);
    
    %Ask user if they want to hear the signals after each process 
    playbackQuestion = input('Enter 1 to hear each signal or 0 to continue');
    if (playbackQuestion == 1)
        
        display('Original'); %Print description of signal to screen
        sound(x,fs); %Play signal
        pause(Time); %Allow time for the previous sound() to finish
       
        display('Flanger');
        sound(y1,fs);%Play signal
        pause(Time); %Allow time for the previous sound() to finish
        
        display('Compressor');%Print description of signal to screen
        sound(y2,fs);%Play signal
        pause(Time); %Allow time for the previous sound() to finish
        
        display('Reverb');%Print description of signal to screen
        sound(y3,fs);%Play signal
        
    end   
    %For some reason y2 array is the wrong way round so this flips it
    %back so that it can be summed without matrix dimension errors
    y2 = permute(y2,[2 1]); % Moves the audio data to the right index
    
    
    %Write audio to new .wav file 
    y1 = y1./max(y1); %normalise first
    y2 = y2./max(y2);
    y3 = y3./max(y3);
    audiowrite('outputFlanger.wav', y1, fs)
    audiowrite('outputCompressor.wav', y2, fs)
    audiowrite('outputReverb.wav', y3, fs)
    
   
    %Sum all three effects
    y = y1+y2+y3;
    
    %Normalise final signal
    y = y./max(y);
    
    pause(Time); %Allow time for the previous sound() to finish
    display('Final signal');
    sound(y,fs); %Play resultant signal
end