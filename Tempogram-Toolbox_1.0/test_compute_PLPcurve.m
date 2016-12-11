%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: test_compute_PLPcurve.m
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/

%
% Description: Illustrates the following steps:
%   1. loads a wav file
%   2. computes a novelty curve
%   3. computes a fourier-based tempogram
%   4. derives a PLP curve
%   5. visualizes novelty and PLP curves
%   6. sonifies novelty and PLP peaks
%   7. computes a PLP curve of a restricted tempo range
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
%     'Tempogram Toolbox' is distributed in the hope that it will be
%     useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with 'Tempogram Toolbox'. If not, see
%     <http://www.gnu.org/licenses/>.
%
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
visualize_tempogram(tempogram,T,BPM)
title('Tempogram (Fourier)')


%% 4., compute PLP curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameterPLP = [];
parameterPLP.featureRate = featureRate;
parameterPLP.tempoWindow = parameterTempogram.tempoWindow;

[PLP,featureRate] = tempogram_to_PLPcurve(tempogram, T, BPM, parameterPLP);
PLP = PLP(1:length(noveltyCurve));  % PLP curve will be longer (zero padding)



%% 5, visualize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameterVis = [];
parameterVis.featureRate = featureRate;

visualize_noveltyCurve(noveltyCurve,parameterVis)
title('Novelty curve')

visualize_noveltyCurve(PLP,parameterVis)
title('PLP curve')


%% 6, sonify
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameterSoni = [];
parameterSoni.Fs = Fs;
parameterSoni.featureRate = featureRate;

sonification = sonify_noveltyCurve(noveltyCurve,audio,parameterSoni);

wavwrite(sonification,Fs,'sonification_novelty.wav')


parameterSoni = [];
parameterSoni.Fs = Fs;
parameterSoni.featureRate = featureRate;

sonification = sonify_noveltyCurve(PLP,audio,parameterSoni);

wavwrite(sonification,Fs,'sonification_PLP.wav')


%% 7, compute a PLP curve of a restricted tempo range
% Here, we restrict the range of tempo parameters to [70,110] BPM
% and compute a restricted PLP curve. 
% 
% Instead of computing a restricted tempogram, we could also set
% parameterPLP.PLPrange = [70,110] and use the original tempogram with the 
% tempo set [30,600]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


parameterTempogram.tempoWindow = 6;         % window length in sec
parameterTempogram.BPM = 70:1:110;          % tempo values

[tempogram, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);
visualize_tempogram(tempogram,T,BPM)
title('Tempogram (Fourier) restricted')

parameterPLP.tempoWindow = parameterTempogram.tempoWindow;

[PLP_restricted] = tempogram_to_PLPcurve(tempogram, T, BPM, parameterPLP);
PLP_restricted = PLP_restricted(1:length(noveltyCurve));  % PLP curve will be longer (zero padding)

visualize_noveltyCurve(PLP_restricted,parameterVis)
title('PLP curve (restricted)')

sonification = sonify_noveltyCurve(PLP_restricted,audio,parameterSoni);

wavwrite(sonification,Fs,'sonification_PLP-BPMrestricted.wav')


