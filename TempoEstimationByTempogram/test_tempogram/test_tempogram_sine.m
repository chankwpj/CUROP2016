clear
close all

AlgorithmPath = strcat('C:/Users/genius/Desktop/SourceCode/MIREX_2015/OnsetDectector/OnsetDetector.py');

dirWav = '';
filename = 'C:/Users/genius/Desktop/SourceCode/Audio/In_the_hall_of_mountain_king.wav'; % king of mantain
%filename = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/Mozart_Fantasy.wav'; % Mozart_Fantasy


%% load wav file, automatically converted to Fs = 44100 and mono
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 1%
parameter.destSamplerate = 44100;
[audio,sideinfo] = wav_to_audio('',dirWav,filename, parameter); %no acutall covertion but adding sid info
Fs = sideinfo.wav.fs;
%[audio, temp] = audioread(strcat(dirWav, filename));
audiowrite('temp1.wav',audio,Fs);


%% compute sine based signal curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 2%
%parameterNovelty = [];
%[noveltyCurve,featureRate] = audio_to_noveltyCurve(audio, Fs, parameterNovelty);

[status, onsetTime] = MIREX_Machine('temp1.wav', AlgorithmPath );

sine_signal = warped_sine(onsetTime, audio, Fs);
sine_signal = sine_signal.';


parameterVis = [];
featureRate = 200.0004;%default output from method audio_to_noveltyCurve()
parameterVis.featureRate = featureRate ; 

%visualize_noveltyCurve(sine_signal,parameterVis)
%title('Signal curve')



%% tempogram_fourier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 8;         % window length in sec
parameterTempogram.BPM = 30:1:600;          % tempo values

[tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(sine_signal,parameterTempogram);
tempogram_fourier = normalizeFeature(tempogram_fourier,2, 0.0001);


visualize_tempogram(tempogram_fourier,T,BPM)
title('Tempogram (Fourier)')

