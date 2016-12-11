function [tempogram, T, BPM] = noveltyCurve_to_tempogram_via_DFT(novelty,parameter)
%NOVELTYCURVE_TO_TEMPOGRAM_VIA_DFT Computes a tempogram using STFT.
%   [tempogram] = noveltyCurve_to_tempogram_via_DFT(novelty) returns the 
%   complex valued fourier tempogram tempogram for a novelty curve novelty.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: noveltyCurve_to_tempogram_via_DFT
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Description:
% Computes a complex valued fourier tempogram for a given novelty curve 
% indicating note onset candidates in the form of peaks.
% This implementation provides parameters for chosing fourier
% coefficients in a frequency range corresponding to musically meaningful
% tempo values in bpm.
%
% To use the fast implementation as mex file, compute_fourierCoefficients.c
% needs to be compiled by calling "mex compute_fourierCoefficients.c".
%
% Input:
%       novelty : a novelty curve indicating note onset positions 
%       parameter (optional): parameter struct with fields
%               .featureRate : feature rate of the novelty curve (Hz).
%                       This needs to be set to allow for setting other
%                       parameters in seconds!
%               .tempoWindow: Analysis window length in seconds
%               .stepsize: window stepsize in frames (of novelty curve)
%               .BPM: vector containing BPM values to compute
%               .useImplementation: indicating the implementation to use
%                   1 : c/mex implementation (fast, needs to be compiled)
%                   2 : Matlab implementation (slow)
%                   3 : Goertzel algorithm via Matlab's spectrogram 
%               
%
% Output:
%       tempogram : the complex valued fourier tempogram
%       T : vector of time positions (in sec) for the frames of the tempogram
%       BPM: vector of bpm values of the tempo axis of the tempogram
%       
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
%
% Reference:
%   Peter Grosche and Meinard Müller
%   Extracting Predominant Local Pulse Information from Music Recordings 
%   IEEE Transactions on Audio, Speech, and Language Processing, 19(6), 1688-1701, 2011.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin < 2
    parameter = [];
end
if isfield(parameter,'featureRate')==0
    warning('parameter.featureRate not set! Assuming 1!')
    parameter.featureRate = 1;
end
if isfield(parameter,'tempoWindow')==0
    parameter.tempoWindow = 6; % in sec
end
if isfield(parameter,'BPM')==0
    parameter.BPM = 30:1:600;
end

if isfield(parameter,'stepsize')==0
    parameter.stepsize = ceil(parameter.featureRate./5); % 5 Hz default
end
if isfield(parameter,'useImplementation')==0
    parameter.useImplementation = 1; % 1: c implementation, 2: MATLAB implementation, 3: spectrogram via goertzel algorithm
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

win_len = round(parameter.tempoWindow.* parameter.featureRate);
win_len = win_len + mod(win_len,2) - 1;
parameter.tempoRate = parameter.featureRate./parameter.stepsize;

myhann = @(n)  0.5-0.5*cos(2*pi*((0:n-1)'/(n-1)));

windowTempogram = myhann(win_len);

novelty = [zeros(1,round(win_len/2)), novelty, zeros(1,round(win_len/2))]';

switch parameter.useImplementation
    case 1, % c/mex implementation
        if exist('compute_fourierCoefficients','file')~=3
            error('noveltyCurve_to_tempogram_via_DFT: mex function compute_fourierCoefficients not found. Compile (mex compute_fourierCoefficients.c or COMPILE.m), or set parameter.useImplementation to use the Matlab implementation (slow)!')
        end
        tic
        [tempogram, BPM, T] = compute_fourierCoefficients(novelty,windowTempogram,win_len-parameter.stepsize, (parameter.BPM./60)', parameter.featureRate);
        % normalize window (parsevals theorem)
        tempogram = tempogram./sqrt(win_len) / sum(windowTempogram) * win_len;
        T = T(:)';
%         fprintf('C runtime: \t%f\n',toc);
    case 2, % matlab implementation
        tic
        [tempogram, BPM, T] = compute_fourierCoefficients_matlab(novelty,windowTempogram,win_len-parameter.stepsize, parameter.BPM./60, parameter.featureRate);
        tempogram = tempogram./sqrt(win_len) / sum(windowTempogram) * win_len;
%         fprintf('Matlab runtime: \t%f\n',toc);
    case 3, % goertzel via matlabs spectrogram
        tic
        [tempogram, BPM, T] = spectrogram(novelty,windowTempogram,win_len-parameter.stepsize, parameter.BPM./60, parameter.featureRate );
        tempogram = tempogram./sqrt(win_len) / sum(windowTempogram) * win_len;
%         fprintf('Goertzel runtime: \t%f\n',toc);
end

BPM = BPM.*60;
T = T - T(1);



