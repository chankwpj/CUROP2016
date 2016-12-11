function visualize_tempogram(tempogram,T,tempo,parameter)
%VISUALIZE_TEMPOGRAM Visualizes tempograms.
%   visualize_tempogram(tempogram) visualizes the 
%   tempogram tempogram with time axis specified by vector T and tempo axis
%   specified by tempo
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: visualize_tempogram
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Description:
% Visualization of tempograms 
%
%
% Input:
%       tempogram : a cyclic tempogram
%       T : vector of time positions (in sec) for each frame of tempogram 
%       tempo : vector of tempo values for each row of tempogram
%       parameter (optional): parameter struct with fields
%               .imageRange : range of values to display 
%               .colormap : colormap to use
%               .plotMeanTempo : plot additional summary tempo vector
%               .yAxisLabel : Tempo (bpm) or Time-lag (sec)
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


if nargin < 4
    parameter = [];
end
if nargin < 3
    tempo = 1:size(tempogram,1);
end
if nargin < 2
    T = 1:size(tempogram,2);
end


if ~isfield(parameter,'yAxisLabel')
    parameter.yAxisLabel = 'Tempo (BPM)';
end

if ~isfield(parameter,'imageRange')
    parameter.imageRange = 0;
end

if ~isfield(parameter,'plotMeanTempo')
    parameter.plotMeanTempo = 0;
end

if ~isfield(parameter,'colormap')
    figure
    parameter.colormap = hot;%flipud(gray);
    close
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isreal(tempogram)
    tempogram = abs(tempogram);
end



if parameter.plotMeanTempo
    meanTempo = mean(tempogram,2);
    subplot(1,5,1), plot(meanTempo,tempo); ylim([min(tempo) max(tempo)]); xlim([0 max(meanTempo).*1.1]); hold on
    ylabel(parameter.yAxisLabel);
    subplot(1,5,[2 5]);
end

figure
if ~all(parameter.imageRange==0)
    imagesc(T,tempo,tempogram,parameter.imageRange);
else
    imagesc(T,tempo,tempogram);
end



if ~parameter.plotMeanTempo
    ylabel(parameter.yAxisLabel); xlabel('Time (sec)');
else
    xlabel('Time (sec)');
end

colormap(parameter.colormap);
colorbar; axis xy;
%fail
%colorbar('Ticks',[0:0.03/4: 0.03]); axis xy;
set(gca,'yTick',unique([round(tempo(1)) get(gca,'YTick') round(tempo(end))]))


