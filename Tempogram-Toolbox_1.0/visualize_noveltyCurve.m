function visualize_noveltyCurve(noveltyCurve,parameter)
%VISUALIZE_NOVELTYCURVE Visualizes a novelty curve.
%   visualize_noveltyCurve(noveltyCurve) visualizes the novelty curve
%   noveltyCurve
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: visualize_noveltyCurve
% Date of Revision: 2011-10
% Programmer: Peter Grosche
% http://www.mpi-inf.mpg.de/resources/MIR/tempogramtoolbox/
%
% Description:
% Visualization of a  novelty curve
%
%
% Input:
%       noveltyCurve : a novelty curve
%       T : vector of time positions (in sec) for each frame of cyclicTempogram 
%       parameter (optional): parameter struct with fields
%               .featureRate : feature rate, needed for labeling in seconds
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
if nargin<2
    parameter = [];
end

if isfield(parameter,'featureRate')==0
    warning('parameter.featureRate not set! Assuming 100!')
    parameter.featureRate = 100;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
featureRate = parameter.featureRate;

figure;
n = (0:length(noveltyCurve)-1)./featureRate; % time in sec
plot(n,noveltyCurve);

xlim([n(1) n(end) ])
box on
xlabel('Time (sec)')
