%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: demoTempogramToolbox.m
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Description: Illustrates the entire functionality of the tempogram
% toolbox
%
% Audio recordings are obtained from: Saarland Music Data (SMD)
% http://www.mpi-inf.mpg.de/resources/SMD/
%
% License:
%     This file is part of 'Tempogram Toolbox'.
% 
%     'Tempogram Toolbox' is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 2 of the License, or
%     (at your option) any later version.
% 
%     'Tempogram Toolbox' is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with 'Tempogram Toolbox'. If not, see
%     <http://www.gnu.org/licenses/>.
%
% References:
%   Peter Grosche and Meinard Müller
%   Extracting Predominant Local Pulse Information from Music Recordings 
%   IEEE Transactions on Audio, Speech, and Language Processing, 19(6), 1688-1701, 2011.
%
%   Peter Grosche, Meinard Müller, and Frank Kurth
%   Cyclic Tempogram - A Mid-level Tempo Representation For Music Signals 
%   Proceedings of IEEE International Conference on Acoustics, Speech, and Signal Processing (ICASSP), Dallas, Texas, USA, 2010.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



clear
close all

dirWav = 'data_wav/';



%filename = 'Debussy_SonataViolinPianoGMinor-02_111_20080519-SMD-ss135-189.wav';
% filename = '110-130bpm_click.wav';
% filename = 'Faure_Op015-01_126_20100612-SMD-0-12.wav';
% filename = 'Poulenc_Valse_114_20100518-SMD-0-15.wav';
%filename = 'Schumann_Op015-03_113_20080115-SMD-0-13.wav';
filename = 'test.wav';
%filename = 'am_1.wav';
%filename = 'am_2.wav';
%filename = 'pro_1.wav';
%filename = 'pro_2.wav';

%% load wav file, automatically converted to Fs = 22050 and mono
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 1%
[audio,sideinfo] = wav_to_audio('',dirWav,filename);
Fs = sideinfo.wav.fs;

figure; plot((0:length(audio)-1)/Fs,audio);
xlim([0 length(audio)/Fs]);
ylim([-0.5 0.5])
xlabel('Time (sec)')
title('Waveform')


%% compute novelty curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 2%
parameterNovelty = [];

[noveltyCurve,featureRate] = audio_to_noveltyCurve(audio, Fs, parameterNovelty);

parameterVis = [];
parameterVis.featureRate = featureRate;

visualize_noveltyCurve(noveltyCurve,parameterVis)
title('Novelty curve')

%% tempogram_fourier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 3%
parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 8;         % window length in sec
parameterTempogram.BPM = 30:1:600;          % tempo values

[tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
tempogram_fourier = normalizeFeature(tempogram_fourier,2, 0.0001);



visualize_tempogram(tempogram_fourier,T,BPM)
title('Tempogram (Fourier)')


%% PLP curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 4%
parameterPLP = [];
parameterPLP.featureRate = featureRate;
parameterPLP.tempoWindow = parameterTempogram.tempoWindow;

[PLP,featureRate] = tempogram_to_PLPcurve(tempogram_fourier, T, BPM, parameterPLP);
PLP = PLP(1:length(noveltyCurve));  % PLP curve will be longer (zero padding)

parameterVis = [];
parameterVis.featureRate = featureRate;

visualize_noveltyCurve(PLP,parameterVis)
title('PLP curve')


%% tempogram_autocorrelation_timeLagAxis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 5%
parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 8;                  % window length in sec
parameterTempogram.maxLag = 2;                    % corresponding to 30 bpm
parameterTempogram.minLag = 0.1;                  % corresponding to 600 bpm

[tempogram_autocorrelation_timeLag, T, timeLag] = noveltyCurve_to_tempogram_via_ACF(noveltyCurve,parameterTempogram);
tempogram_autocorrelation_timeLag = normalizeFeature(tempogram_autocorrelation_timeLag,2, 0.0001);

parameterVis = [];
parameterVis.yAxisLabel = 'Time-lag (sec)';
visualize_tempogram(tempogram_autocorrelation_timeLag,T,timeLag,parameterVis)
title('Tempogram (Autocorrelation)')

%% tempogram_fourier_timeLagAxis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fig 6%
[tempogram_fourier_timeLag,timeLag] = rescaleTempoAxis(tempogram_fourier,60./BPM,timeLag);
tempogram_fourier_timeLag = normalizeFeature(tempogram_fourier_timeLag,2, 0.0001);

parameterVis = [];
parameterVis.yAxisLabel = 'Time-lag (sec)';
visualize_tempogram(tempogram_fourier_timeLag,T,timeLag,parameterVis)
title('Tempogram (Fourier)')

%% tempogram_autocorrelation_tempoAxis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 7%

[tempogram_autocorrelation,BPM] = rescaleTempoAxis(tempogram_autocorrelation_timeLag,60./timeLag,BPM);
tempogram_autocorrelation = normalizeFeature(tempogram_autocorrelation,2, 0.0001);
visualize_tempogram(tempogram_autocorrelation,T,BPM)
title('Tempogram (Autocorrelation)')


%% cyclicTempogram_fourier, 120 dim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 8%
octave_divider =  120;

parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 5;
parameterTempogram.BPM = 30*2.^(0:1/octave_divider:4); % log tempo axis


parameterCyclic = [];
parameterCyclic.octave_divider = octave_divider;
[tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
[cyclicTempogram_fourier] = tempogram_to_cyclicTempogram(tempogram_fourier, BPM, parameterCyclic);
cyclicTempogram_fourier = normalizeFeature(cyclicTempogram_fourier,2, 0.0001);

visualize_cyclicTempogram(cyclicTempogram_fourier,T)
title('Cyclic tempogram (Fourier) 120')

%% cyclicTempogram_fourier, 15 dim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 9%
octave_divider =  15;

parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 5;
parameterTempogram.BPM = 30*2.^(0:1/octave_divider:4); % log tempo axis


parameterCyclic = [];
parameterCyclic.octave_divider = octave_divider;
[tempogram_fourier, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
[cyclicTempogram_fourier] = tempogram_to_cyclicTempogram(tempogram_fourier, BPM, parameterCyclic);
cyclicTempogram_fourier = normalizeFeature(cyclicTempogram_fourier,2, 0.0001);

visualize_cyclicTempogram(cyclicTempogram_fourier,T)
title('Cyclic tempogram (Fourier) 15 dim')


%% cyclicTempogram_autocorrelation, 120 dim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 10%
octave_divider =  120;

parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 5;                  % window length in sec
parameterTempogram.maxLag = 2;                    % corresponding to 30 bpm
parameterTempogram.minLag = 0.125;                  % corresponding to 480 bpm

[tempogram_autocorrelation_timeLag, T, timeLag] = noveltyCurve_to_tempogram_via_ACF(noveltyCurve,parameterTempogram);

parameterCyclic = [];
parameterCyclic.octave_divider = octave_divider;
[cyclicTempogram_autocorrelation] = tempogram_to_cyclicTempogram(tempogram_autocorrelation_timeLag, 60./timeLag, parameterCyclic);
cyclicTempogram_autocorrelation = normalizeFeature(cyclicTempogram_autocorrelation,2, 0.0001);

visualize_cyclicTempogram(cyclicTempogram_autocorrelation,T)
title('Cyclic tempogram (Autocorrelation) 120 dim')



%% cyclicTempogram_autocorrelation, 15 dim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fig 11%
octave_divider =  15;

parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 5;                  % window length in sec
parameterTempogram.maxLag = 2;                    % corresponding to 30 bpm
parameterTempogram.minLag = 0.125;                  % corresponding to 480 bpm

[tempogram_autocorrelation_timeLag, T, timeLag] = noveltyCurve_to_tempogram_via_ACF(noveltyCurve,parameterTempogram);

parameterCyclic = [];
parameterCyclic.octave_divider = octave_divider;
[cyclicTempogram_autocorrelation] = tempogram_to_cyclicTempogram(tempogram_autocorrelation_timeLag, 60./timeLag, parameterCyclic);
cyclicTempogram_autocorrelation = normalizeFeature(cyclicTempogram_autocorrelation,2, 0.0001);

visualize_cyclicTempogram(cyclicTempogram_autocorrelation,T)
title('Cyclic tempogram (Autocorrelation)  15 dim')


