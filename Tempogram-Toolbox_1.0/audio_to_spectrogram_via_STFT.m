function [f_spec,featureRate,f,t] = audio_to_spectrogram_via_STFT(f_audio,parameter)
%AUDIO_TO_SPECTROGRAM_VIA_STFT Computes a spectrogram using STFT.
%   f_spec = AUDIO_TO_SPECTROGRAM_VIA_STFT(f_audio,parameter) returns the 
%   spectrogram of the audio signal specified by
%   the waveform f_audio in f_spec. 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: audio_to_noveltyCurve
% Date of Revision: 2011-10
% Programmer: Sebastian Ewert, Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Description:
% Computes aspectrogram using a STFT (short-time fourier transform)
%
% Input: f_audio
%       f_audio : wavefrom of audio signal  
%       parameter (optional): parameter struct with fields
%               .StftWindow = hann(4096)
%               .stepsize = round(windowLength/2)
%               .nFFT = windowLength
%               .returnMagSpec = false : return complex of magnitude spectrogram
%               .coefficientRange = [1 floor(max(parameter.nFFT,windowLength)/2)+1]
%               .fs = 22050 : sampling rate of the audio
%
% Output:
%       f_spec: complex spectrogram (only magnitude spectrogram returned in the case
%           parameter.returnMagSpec = true )
%       featureRate : feature rate of the spectrogram (Hz)
%       f : vector of frequecncies (Hz) for the coefficients
%       t : vector of time positions (sec) for the frames
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
%     along with 'Tempogram Toolbox'. If not, see <http://www.gnu.org/licenses/>.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


myhann = @(n)  0.5-0.5*cos(2*pi*((0:n-1)'/(n-1)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    parameter=[];
end
if nargin<1
    error('Please specify input data f_audio');
end
if isfield(parameter,'StftWindow')==0
    parameter.StftWindow = myhann(4096);
end
windowLength = length(parameter.StftWindow);
if isfield(parameter,'stepsize')==0
    parameter.stepsize = round(windowLength/2);
end
if isfield(parameter,'nFFT')==0
    parameter.nFFT = windowLength;
end
if isfield(parameter,'returnMagSpec')==0
    parameter.returnMagSpec = 0;
end
if isfield(parameter,'coefficientRange')==0
    parameter.coefficientRange = [1 floor(max(parameter.nFFT,windowLength)/2)+1];
end
if isfield(parameter,'fs')==0
    parameter.fs = 22050;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some pre calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


stepsize = parameter.stepsize;
featureRate = parameter.fs/(stepsize);
wav_size = length(f_audio);
win = parameter.StftWindow;
first_win = floor(windowLength/2);
num_frames = ceil(wav_size/stepsize);
num_coeffs = parameter.coefficientRange(end)-parameter.coefficientRange(1)+1;
zerosToPad = max(0,parameter.nFFT - windowLength);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spectrogram calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% allocate memory
f_spec = zeros(num_coeffs,num_frames);
if ~parameter.returnMagSpec
    f_spec = complex(f_spec,0);
end

% first window's center is at 0 seconds
frame = (1:windowLength)-first_win;
for n=1:num_frames
    
    % zero centered
    numZeros = sum(frame<1);
    numVals  = sum(frame>0);
        
    if numZeros>0
        x = [zeros(numZeros,1); f_audio(1:(numVals))].*win;
    elseif frame(end) > wav_size
        x = [f_audio(frame(1):wav_size);zeros(windowLength-(wav_size-frame(1)+1),1)].*win;
    else
        x = f_audio(frame).*win;
    end

    if zerosToPad>0
        x = [x;zeros(zerosToPad,1)];
    end

    Xs = fft(x);
    if parameter.returnMagSpec
        f_spec(:,n) = abs(Xs(parameter.coefficientRange(1):parameter.coefficientRange(end))); % magnitude spectrum
    else
        f_spec(:,n) = Xs(parameter.coefficientRange(1):parameter.coefficientRange(end)); % complex spectrum
    end

    frame = frame+stepsize;
end

t = [0:size(f_spec,2)-1] * stepsize/parameter.fs;
f = [0:floor(max(parameter.nFFT,windowLength)/2)]'/...
    (floor(max(parameter.nFFT,windowLength)/2)) * (parameter.fs / 2);
f = f(parameter.coefficientRange(1):parameter.coefficientRange(end));



end
