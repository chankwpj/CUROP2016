function [tempogram_out,BPM_out] = rescaleTempoAxis(tempogram_in,BPM_in,BPM_out)
%RESCALETEMPOAXIS Allows for rescaling tempograms.
%   [tempogram_out,BPM_out] = rescaleTempoAxis(tempogram_in,BPM_in,BPM_out)
%   returns a rescaled version of the tempogram tempogram_in (with tempo axis BPM_in)
%   tempogram_out rescaled to the tempo axis BPM_out.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: rescaleTempoAxis
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Description:
%   Computes a rescaled version of the tempogram tempogram_in (with tempo axis BPM_in)
%   tempogram_out rescaled to the tempo axis BPM_out using nearest neighbor
%   interpolation.
%
%
% Input:
%       tempogram_in : the original tempogram
%       BPM_in : tempo axis of the original tempogram tempogram_in
%       BPM_out : desired output tempo axis of tempogram_out
%       
%
% Output:
%       tempogram_out: rescaled tempogram
%       BPM_out: tempo axis of tempogram_out
%               
%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




tempogram_out = interp1(BPM_in,tempogram_in,BPM_out,'nearest',0);