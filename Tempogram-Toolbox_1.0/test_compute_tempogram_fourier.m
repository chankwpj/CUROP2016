%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: test_compute_tempogram_fourier.m
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Description: Illustrates the following steps:
%   1. loads a wav file
%   2. computes a novelty curve
%   3. computes a fourier-based tempogram
%   4. visualizes the tempogram
%   5. rescales to a time-lag axis
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
%   Peter Grosche and Meinard Müller
%   Extracting Predominant Local Pulse Information from Music Recordings 
%   IEEE Transactions on Audio, Speech, and Language Processing, 19(6), 1688-1701, 2011.
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


%% 3., compute fourier-based tempogram
% important parameters:
%   .tempoWindow: trade-off between time- and tempo resolution
%               try chosing a long (e.g., 12 sec) and short (e.g., 3 sec) 
%               window
%   .BPM: tempo range and resolution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = 6;         % window length in sec
parameterTempogram.BPM = 30:1:600;          % tempo values

[tempogram, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);



%% 4., visualize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

visualize_tempogram(tempogram,T,BPM)


%% 5, rescale to time-lag axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Lag_in = 60./BPM;
Lag_out = 0.1:0.001:2;
[tempogram,Lag] = rescaleTempoAxis(tempogram,Lag_in,Lag_out);

parameterVis = [];
parameterVis.yAxisLabel = 'Time-lag (sec)';

visualize_tempogram(tempogram,T,Lag,parameterVis)



