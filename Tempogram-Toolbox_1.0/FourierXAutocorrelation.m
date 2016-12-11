function FourierXAutocorrelation (filename, r, c, p)

AlgorithmPath = strcat('C:/Users/genius/Desktop/Evaluation/MIRE_2015/OnsetDectector/OnsetDetector.py');

dirWav = 'data_wav/';
filename = filename;

%% load wav file, automatically converted to Fs = 44100 and mono
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 1%
parameter.destSamplerate = 44100;
[audio,sideinfo] = wav_to_audio('',dirWav,filename, parameter);
Fs = sideinfo.wav.fs;


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
parameterTempogram.tempoWindow = 8;         % window length in sec 8
parameterTempogram.BPM = 30:1:600;          % tempo values

[tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
tempogram_fourier = normalizeFeature(tempogram_fourier,2, 0.0001);



%visualize_tempogram(tempogram_fourier,T,BPM)
%title('Tempogram (Fourier)')

%% tempogram_autocorrelation_timeLagAxis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 8;                  % window length in sec 8
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
visualize_tempogram(FourierXautocorrelation,T,BPM);
title(filename)


%% Draw max     
%{
hold on
subplot(r, c, p);
max = drawMax(FourierXautocorrelation);
%visualize_tempogram(max,T,BPM);
[indexx, indexy] = find(max >= 1);
size(max)
if filename(1) == 'p'
    plot(indexy, indexx, 'red','LineWidth',2); %red for pro
else
    plot(indexy, indexx, 'blue','LineWidth',2); %blue for pro
end
ylim([30 600])
xlim([0 1300])
title(filename);
hold off
%}
end