function visualize_cyclicTempogram(cyclicTempogram,T,parameter)
%VISUALIZE_CYCLICTEMPOGRAM Visualizes cyclic tempograms.
%   visualize_cyclicTempogram(cyclicTempogram,T) visualizes the cyclic
%   tempogram cyclicTempogram with time axis specified by vector T
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: visualize_cyclicTempogram
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Description:
% Visualization of the cyclic tempograms 
%
%
% Input:
%       cyclicTempogram : a cyclic tempogram
%       T : vector of time positions (in sec) for each frame of cyclicTempogram 
%       parameter (optional): parameter struct with fields
%               .imageRange : range of values to display 
%               .colormap : colormap to use
%               
%
% Output:
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    parameter = [];
end

if isfield(parameter,'imageRange')==0
    parameter.imageRange = 0;
end
if ~isfield(parameter,'colormap')
    figure
    parameter.colormap = hot;%flipud(gray);
    close
end

if ~all(parameter.imageRange==0)
    figure; imagesc(T,1:size(cyclicTempogram,1)+1,[cyclicTempogram; cyclicTempogram(1,:)],parameter.imageRange); axis xy
else
    figure; imagesc(T,1:size(cyclicTempogram,1)+1,[cyclicTempogram; cyclicTempogram(1,:)]); axis xy
end

octave_divider = size(cyclicTempogram,1);
labels = 1+[0, (octave_divider)/12*1.666 (octave_divider)/12*3.333,(octave_divider)/12*5,(octave_divider)/12*7, (octave_divider)/12*8.666 (octave_divider)/12*10.333 octave_divider ];
names = [1    1.1    1.21    1.33    1.5    1.66    1.81    2];
set(gca,'YTick', labels)
set(gca,'YTickLabel', round(names.*100)./100)
colorbar
colormap(parameter.colormap)
xlabel('Time (sec)')
ylabel('Relative tempo')
