function [cyclicTempogram, cyclicAxis] = tempogram_to_cyclicTempogram(tempogram, BPM, parameter)
%TEMPOGRAM_TO_CYCLICTEMPOGRAM Computes a cyclic tempogram representation
%   of a tempogram.
%   [cyclicTempogram] = tempogram_to_cyclicTempogram(tempogram, BPM) returns the 
%   cyclic tempogram cyclicTempogram of the tempogram tempogram with tempo axis BPM.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: tempogram_to_cyclicTempogram
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Description:
% Computes a cyclic tempogram representation of a tempogram by identifying 
% octave equivalences, simnilar as for chroma features.
%
% Input:
%       tempogram : a tempogram representation
%       BPM : tempo axis of the tempogram (in bpm)
%       parameter (optional): parameter struct with fields
%           .octave_divider : number of tempo classes used for representing
%                             a tempo octave. This parameter controls the
%                             dimensionality of cyclicTempogram
%           .refTempo : reference tempo defining the partition of BPM into
%                             tempo octaves
%               
%
% Output:
%       cyclicTempogram : the cyclic representation of the tempogram
%       cyclicAxis : the tempo axis of the tempogram, relative to the 
%                    reference tempo parameter.refTempo.
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
%   Peter Grosche, Meinard Müller, and Frank Kurth
%   Cyclic Tempogram - A Mid-level Tempo Representation For Music Signals 
%   Proceedings of IEEE International Conference on Acoustics, Speech, and Signal Processing (ICASSP), Dallas, Texas, USA, 2010.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






if nargin<3
    parameter = [];
end

if ~isfield(parameter,'refTempo')
    parameter.refTempo = 60; % BPM
end
if ~isfield(parameter,'octave_divider')
    parameter.octave_divider = 30;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cyclic tempogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isreal(tempogram)
   tempogram = abs(tempogram); 
end

refTempo = parameter.refTempo;
refOctave = refTempo./min(BPM);
% min(BPM)
minOctave = round(log2(min(BPM)/refTempo));
maxOctave = round(log2(max(BPM)/refTempo))+1;



% rescale to log tempo axis tempogram. Each octave is represented by
% parameter.octave_divider tempi

logBPM = refTempo*2.^(minOctave:1/parameter.octave_divider:(maxOctave-1/parameter.octave_divider));
logAxis_tempogram = rescaleTempoAxis(tempogram,BPM,logBPM);


% cyclic projection of log axis tempogram to the reference octave

endPos = find(logBPM<max(BPM),1,'last');
cyclicTempogram = zeros(parameter.octave_divider,size(logAxis_tempogram,2));
for idx=1:parameter.octave_divider
    cyclicTempogram(idx,:) = mean(logAxis_tempogram(idx:parameter.octave_divider:endPos,:));
end

cyclicAxis = refOctave.*logBPM(1:parameter.octave_divider)./refTempo;








