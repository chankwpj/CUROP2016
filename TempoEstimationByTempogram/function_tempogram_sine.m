function [ FourierXautocorrelation, T,BPM ] = function_tempogram_sine( filename, windowSec, plot  )
%FUNCTION_TEMPOGRAM_SINE Summary of this function goes here
%   Detailed explanation goes here
dirWav = '';
AlgorithmPath = strcat('C:/Users/genius/Desktop/Evaluation/MIRE_2015/OnsetDectector/OnsetDetector.py');



%% load wav file, automatically converted to Fs = 44100 and mono
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 1%
parameter.destSamplerate = 44100;
[audio,sideinfo] = wav_to_audio('',dirWav,filename, parameter); %no acutall covertion but adding sid info
Fs = sideinfo.wav.fs;
%[audio, temp] = audioread(strcat(dirWav, filename));
audiowrite('temp.wav',audio,Fs);
[status, onsetTime] = MIREX_Machine('temp.wav', AlgorithmPath );
sine_signal = warped_sine_amp(onsetTime, audio, Fs);
audio = sine_signal;
%index = find(audio < 0);
%audio(index) = 0;
%plot(audio)


%% compute novelty curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 2%
parameterNovelty = [];
[noveltyCurve,featureRate] = audio_to_noveltyCurve(audio, Fs, parameterNovelty);
 
parameterVis = [];
parameterVis.featureRate = featureRate;

%visualize_noveltyCurve(noveltyCurve,parameterVis)
%title('Novelty curve')

%% tempogram_fourier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = windowSec;         % window length in sec
parameterTempogram.BPM = 30:1:600;          % tempo values

[tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
tempogram_fourier = normalizeFeature(tempogram_fourier,2, 0.0001);



%visualize_tempogram(tempogram_fourier,T,BPM)
%title('Tempogram (Fourier)')

%% tempogram_autocorrelation_timeLagAxis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = windowSec;                  % window length in sec
parameterTempogram.maxLag = 2;                    % corresponding to 30 bpm
parameterTempogram.minLag = 0.1;                  % corresponding to 600 bpm

[tempogram_autocorrelation_timeLag, T, timeLag] = noveltyCurve_to_tempogram_via_ACF(noveltyCurve,parameterTempogram);
tempogram_autocorrelation_timeLag = normalizeFeature(tempogram_autocorrelation_timeLag,2, 0.0001);

parameterVis = [];
parameterVis.yAxisLabel = 'Time-lag (sec)';
%visualize_tempogram(tempogram_autocorrelation_timeLag,T,timeLag,parameterVis)
%title('Tempogram (Autocorrelation)')

%% tempogram_fourier_timeLagAxis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[tempogram_fourier_timeLag,timeLag] = rescaleTempoAxis(tempogram_fourier,60./BPM,timeLag);
tempogram_fourier_timeLag = normalizeFeature(tempogram_fourier_timeLag,2, 0.0001);

parameterVis = [];
parameterVis.yAxisLabel = 'Time-lag (sec)';
%visualize_tempogram(tempogram_fourier_timeLag,T,timeLag,parameterVis)
%title('Tempogram (Fourier)')

%% tempogram_autocorrelation_tempoAxis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[tempogram_autocorrelation,BPM] = rescaleTempoAxis(tempogram_autocorrelation_timeLag,60./timeLag,BPM);
tempogram_autocorrelation = normalizeFeature(tempogram_autocorrelation,2, 0.0001);
%visualize_tempogram(tempogram_autocorrelation,T,BPM)
%title('Tempogram (Autocorrelation)')


%% Fourier x autocorrelation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FourierXautocorrelation = tempogram_fourier.*tempogram_autocorrelation;
if (plot == 1)
    visualize_tempogram(FourierXautocorrelation,T,BPM);
    title(strcat(filename, '-', 'Sine'))
end
%% Draw max
%{
maxs = drawMax(FourierXautocorrelation);
%value 0 == min BPM therefore, add min BPM to all the values;
[indexx, indexy] = find(maxs >= 1);
indexx = indexx + min(BPM);
figure; plot(indexy, indexx, 'red')
ylim([min(BPM) max(BPM)])
max(max(maxs))
%}
end

