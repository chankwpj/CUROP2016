function [tempogram, T, Lag] = noveltyCurve_to_tempogram_via_ACF(novelty,parameter)
%NOVELTYCURVE_TO_TEMPOGRAM_VIA_ACF Computes a tempogram using autocorrelation.
%   tempogram = noveltyCurve_to_tempogram_via_ACF(novelty) returns the 
%   tempogram tempogram of a novelty curve novelty using a windowed 
%   autocorrelation variant. 
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: noveltyCurve_to_tempogram_via_ACF
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Computes tempogram with time lag axis (rhythmogram) according to:
% 
%
%
% Input: 
%       novelty: a novelty curve indicating note onsets
%       
%        featureRate: frames per second of novelty Curve
%        parameter (optional) : parameter struct with fields
%               .featureRate : feature rate of the novelty curve (Hz).
%                       This needs to be set to allow for setting other
%                       parameters in seconds!
%               .tempoWindow: Analysis window length in seconds
%               .stepsize: window stepsize in frames (of novelty curve)
%               .maxLag: maximum lag of analysis (in sec)
%               .minLag: minimum lag of analysis (in sec)
%               .normalization: all normalizations supported by xcorr plus  
%                   'unbiasedcoeff', a combination if xcorr's 'unbiased'
%                   and 'coeff'
%
% Output:
%       tempogram : tempogram representation 
%       T : vector of time positions (in sec) for each frame
%       Lag: time lag (in sec) of the time lag axis   

%   See also XCORR.
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
%   K. Jensen
%   Multiple scale music segmentation using rhythm, timbre and harmony
%   Eurasip Journal on Advances in Signal Processing, Vol. 2007, 2007.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if nargin < 2
    parameter = [];
end

if ~isfield(parameter, 'tempoWindow')
    parameter.tempoWindow = 6; % sec
end   

if ~isfield(parameter, 'featureRate')
    warning('parameter.featureRate not set, assuming 100!');
    parameter.featureRate = 100;
end  

if ~isfield(parameter, 'stepsize')
    parameter.stepsize = ceil(parameter.featureRate./5); % in frames (featureRate)
end   
if ~isfield(parameter, 'maxLag')
    parameter.maxLag = 60/30; % 2 sec, corresponding to 30 bpm
end
if ~isfield(parameter, 'minLag')
    parameter.minLag = 60/600; % 0.1 sec, corresponding to 600 bpm
end

if isfield(parameter,'normalization')==0
   parameter.normalization = 'unbiasedcoeff';
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


win_len = round(parameter.tempoWindow.*parameter.featureRate);
win_len = win_len + mod(win_len,2) -1;
stepsize = parameter.stepsize;
maxLag  = ceil(parameter.maxLag.*parameter.featureRate);
minLag = floor(parameter.minLag.*parameter.featureRate)+1;


noveltyPadded = [zeros(1,round(win_len/2)) novelty zeros(1,round(win_len/2))];
num_win = fix((length(noveltyPadded)-win_len+stepsize)/(stepsize));

noveltyNorm = zeros(1,num_win);
N = zeros(1,num_win);
tempogram = zeros(maxLag,num_win);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% windowed analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for win = 1:num_win

    start = max(1,floor( (win-1).*stepsize+1));
    stop  = min(length(noveltyPadded),ceil( start + win_len - 1));
    maxL  = min(maxLag,stop - start);
    window = ones(stop - start +1,1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % autocorrelation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    nov = noveltyPadded(start:stop);
    if strcmp(parameter.normalization,'unbiasedcoeff')
        [xcr, lags] = xcorr(window'.*nov,window'.*nov,maxL,'unbiased');
        xcr = xcr./(xcr(maxL+1)); % normalize by zero lag coefficient -> energy
    else
        [xcr, lags] = xcorr(window'.*nov,window'.*nov,maxL,parameter.normalization);
    end

    xcr = xcr(maxL+1+[1:maxL]); % keep only positive lags
    tempogram(:,win) = [xcr, zeros(1,maxLag-maxL)];
    
    noveltyNorm(win) = sum((window'.*nov.^2));
    N(win) = stop-start+1;
    
end

tempogram = flipud(tempogram(minLag:end,:));

T = (0:num_win-1)./(parameter.featureRate/parameter.stepsize);
Lag = flipud((minLag:1:maxLag)'./parameter.featureRate);




