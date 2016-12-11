function [PLP,featureRate] = tempogram_to_PLPcurve(tempogram, T, BPM, parameter)
%TEMPOGRAM_TO_PLPCURVE Computes a PLP curve from a tempogram.
%   [PLP] = tempogram_to_PLPcurve(tempogram, T, BPM) returns the 
%   PLP curve derived from the complex valued fourier tempogram tempogram 
%   with time and tempo axis T and BPM,m respectively.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: noveltyCurve_to_tempogram_via_DFT
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
%
% Description:
% computes a PLP curve from a complex tempogram representation
% uses maximum values for each frame (predominant local periodicity)
% or a given tempocurve 
% Input:
%        tempogram: (complex valued)
%        BPM: frequency axis of tempogram (in BPM)
%        T: time axis of tempogram (in sec)
%        parameter
%           .featureRate: feature rate of novelty curve, same is used for
%                         PLP curve
%           .tempoWindow: window size in sec (same as used for tempogram computation)
%           .stepsize: stepsize used in the tempogram computation
%           .useTempocurve: if set to 1, tempocurve is used instead of max values
%           .tempocurve: tempocurve (in BPM), one entry for each tempogram frame,
%               used instead of predominant periodicity values if useTempocurve == 1
%           .PLPrange: range of BPM values searched for predominant
%                     periodicities
%           
%
% Output:
%        PLP: PLP curve
%        featureRate: feature rate of the PLP curve
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


if nargin < 4
    parameter = [];
end

if nargin < 3
    error('Not enough arguments!');
end

if isfield(parameter,'featureRate')==0
    warning('featureRate unset! Assuming 100.');
    parameter.featureRate = 100;
end
if isfield(parameter,'tempoWindow')==0
    warning('tempo window length unset! Assuming 6 sec.');
    parameter.tempoWindow = 6; % sec
end

if ~isfield(parameter,'useTempocurve')
    parameter.useTempocurve = 0;
end

if ~isfield(parameter,'tempocurve')
    parameter.tempocurve = 0;
end

if ~isfield(parameter,'PLPrange') | isempty(parameter.PLPrange) | parameter.PLPrange == 0
    parameter.PLPrange = [BPM(1) BPM(end)];
end

if isfield(parameter,'stepsize')==0
    parameter.stepsize = ceil(parameter.featureRate./5); % 5 Hz default
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myhann = @(n)  0.5-0.5*cos(2*pi*((0:n-1)'/(n-1)));

if isreal(tempogram)
   error('Complex valued fourier tempogram needed for computing PLP curves!') 
end

tempogramAbs = abs(tempogram);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine BPM range
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[tmp, range(1)] = min(abs(BPM-parameter.PLPrange(1)));
[tmp, range(2)] = min(abs(BPM-parameter.PLPrange(2)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine predominant local periodicity or use tempocurve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

local_max = zeros(size(tempogramAbs,2),1);
if ~parameter.useTempocurve
    for frame = 1:size(tempogramAbs,2)
        [tmp,local_max(frame)] = max(tempogramAbs(range(1):range(2),frame));
        local_max(frame) = local_max(frame) + range(1)-1;
    end
else
    for frame = 1:size(tempogramAbs,2)
        [tmp,idx] = min(abs(BPM - parameter.tempocurve(frame)));
        local_max(frame) = idx;
    end
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cumulate periodiciy kernels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

win_len = round(parameter.tempoWindow.* parameter.featureRate);
win_len = win_len + mod(win_len,2) -1;

t = (T.*parameter.featureRate);
% if novelty curve is zero padded with half a window on both sides, PLP is
% always larger than novelty
PLP = zeros(1,(size(tempogram,2)-1+1).*parameter.stepsize);  

window = myhann(win_len)';
 % normalize window so sum(window) = length(window), like it is for box
 % window
window = window./(sum(window)./win_len); 

% normalize window according to overlap, this guarantees, that max(PLP)<=1
window = window./(win_len./parameter.stepsize); 


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% overlap add
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for frame = 1:size(tempogram,2)
    
    t0 = ceil(t(frame) - win_len/2 );
    t1 = floor(t(frame) + win_len/2 );
    
    phase = angle(tempogram(local_max(frame), frame));
    Tperiod = parameter.featureRate.*60./BPM(local_max(frame)); % period length
    len = (t1 - t0 + 1)/Tperiod;  % how many periods?
    
    cosine = window.*cos( (0:1/Tperiod:len-1/Tperiod)* 2* pi + phase ); % create cosine
    
    if t0 < 1
        cosine = cosine(-t0+2:end);
        t0 = 1;
    end
    
    if t1 > size(PLP,2)
        cosine = cosine(1:end + size(PLP,2)-t1);
        t1 = size(PLP,2);
    end
    
    PLP(t0:t1) = PLP(t0:t1) + cosine;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% half wave rectification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PLP = PLP.*(PLP>0);
featureRate = parameter.featureRate;






