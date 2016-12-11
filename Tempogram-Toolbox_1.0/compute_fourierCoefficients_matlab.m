function [x,f,t] = compute_fourierCoefficients_matlab(s, win, noverlap, f, fs)
%COMPUTE_FOURIERCOEFFICIENTS_MATLAB is a helper function that calculates a
%   fourier coefficient with frequency f.
%   [x] = compute_fourierCoefficients_matlab(s, win, noverlap, f, fs) returns the 
%   complex fourier coefficients of frequency f of the signal s with sampling rate fs,
%   windowed using win and noverlap. 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: audio_to_noveltyCurve
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Input:
%       s: time domain signal
%       win: vector containing window function
%       f: vector of frequencies values of fourier coefficients, in Hz
%       fs: sampling rate of signal s in Hz
%       noverlap: overlap given in samples
%           
%
% Output:
%       x: complex fourier coefficients
%       f: frequencies of fourier coefficients, same as input f
%       t: time in sec of window positions
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 5
    fs = 1;
end

if nargin < 4
    error('Missing input arguments!');
end

s = s(:);
f = f(:);

win_len = length(win);
hopsize = win_len - noverlap;

T = ((0:1:(win_len-1))./fs)';
win_num = fix((length(s)-noverlap)/(win_len-noverlap));
x = zeros(win_num,length(f));
t = (win_len/2 : hopsize : length(s)-win_len/2)/fs;

twoPiT = 2*pi*T;


% for each frequency given in f
for f0 = 1:length(f)


    twoPiFt = f(f0)*twoPiT;
    cosine = cos(twoPiFt);
    sine = sin(twoPiFt);

    for w = 1:win_num
        start = (w-1)*hopsize+1;
        stop =  start + win_len -1;
        
        sig = s(start:stop) .*win;
        co = sum(sig .* cosine);
        si = sum(sig .* sine);
        x(w,f0) = (co + 1i*si);
    end
end
x = x';
