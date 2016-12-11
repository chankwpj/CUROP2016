%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: test_compute_cyclicTempogram_autocorrelation.m
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/

%
% Description: Illustrates the following steps:
%   1. loads a wav file
%   2. computes a novelty curve
%   3. computes a autocorrelation-based tempogram
%   4. derives a cyclic tempogram
%   5. visualizes the cyclic tempogram
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
% Reference:
%   Peter Grosche, Meinard Müller, and Frank Kurth
%   Cyclic Tempogram - A Mid-level Tempo Representation For Music Signals 
%   Proceedings of IEEE International Conference on Acoustics, Speech, and Signal Processing (ICASSP), Dallas, Texas, USA, 2010.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all



dirWav = 'data_wav/';

filename = 'Debussy_SonataViolinPianoGMinor-02_111_20080519-SMD-ss135-189.wav';
% filename = '110-130bpm_click.wav';
% filename = 'Faure_Op015-01_126_20100612-SMD-0-12.wav';
% filename = 'Poulenc_Valse_114_20100518-SMD-0-15.wav';
% filename = 'Schumann_Op015-03_113_20080115-SMD-0-13.wav';



%% 1., load wav file, automatically converted to Fs = 22050 and mono
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[audio,sideinfo] = wav_to_audio('',dirWav,filename);
Fs = sideinfo.wav.fs;



%% 2., compute novelty curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameterNovelty = [];

[noveltyCurve,featureRate] = audio_to_noveltyCurve(audio, Fs, parameterNovelty);


%% 3., compute autocorrelation-based tempogram (log tempo axis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

octave_divider =  30; %15, 30, 60 ,120

parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 6;                  % window length in sec
parameterTempogram.maxLag = 2;                    % corresponding to 30 bpm
parameterTempogram.minLag = 0.1;                  % corresponding to 600 bpm

[tempogram, T, timeLag] = noveltyCurve_to_tempogram_via_ACF(noveltyCurve,parameterTempogram);






%% 4., derive cyclic tempogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


parameterCyclic = [];
parameterCyclic.octave_divider = octave_divider;

[cyclicTempogram] = tempogram_to_cyclicTempogram(tempogram, 60./timeLag, parameterCyclic);
cyclicTempogram = normalizeFeature(cyclicTempogram,2, 0.0001);


%% 5, visualize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


visualize_cyclicTempogram(cyclicTempogram,T)



