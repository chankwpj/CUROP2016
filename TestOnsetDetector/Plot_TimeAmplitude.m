function Plot_TimeAmplitude( AudioPath, AlgorithmFile, onsetTime, index )
%PLOT_TIMEAMPLITUDE Summary of this function goes here
%   Detailed explanation goes here

%plot
figure(index)
[y, fs] = audioread(AudioPath);
dt = 1/fs;
t = 0:dt:(length(y)*dt)-dt;
plt = plot(t,y, 'black'); 
xlabel('Seconds'); 
ylabel('Amplitude');
title(AlgorithmFile)
hold on
ymax =get(gca,'ylim');
%plot([1 1],ymax)
plt = plot([onsetTime onsetTime],ymax, 'red');
set(plt,'linewidth',2);
hold off

end

