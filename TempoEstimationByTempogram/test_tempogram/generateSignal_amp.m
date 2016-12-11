function [ signal ] = generateSignal_amp(y, fs, onsetTime, gausswinSize)
%GENERATESIGNAL Summary of this function goes here
%   Detailed explanation goes here


[row, col] = size(y);
if (col > 1)
    y = mean(y, 2);
end
%startingPoint = onsetTime(1)*fs;
%y = y (startingPoint:end);
signal(1:length(y)) = 0;
signal = signal.';

%gaussian curve
w = gausswin(gausswinSize);

%amp
onsets = ceil(onsetTime * fs);
amp = abs(y(onsets));

for n = 1:length(onsetTime)
   %conver time to sample point
   %curveStartingPoint = onsetTime(n)*fs - gausswinSize/2;
   curveStartingPoint = onsetTime(n)*fs+1;
   curveEndPoint = curveStartingPoint + gausswinSize - 1;
   signal(curveStartingPoint:curveEndPoint) = w*amp(n);
end

end



%{
signal/norm(signal)
%}
