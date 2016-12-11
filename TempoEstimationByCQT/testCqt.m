close all;
clear;
%%Please Change the path%%
%audios that we use
%AudioPathAm1 = 'C:/Users/genius/Desktop/SourceCode/Audio/am_2.wav';
AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/In_the_hall_of_mountain_king.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Mozart_Fantasy.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Shake_It_Off.wav';
AlgorithmFile = ['OnsetDetector.py'];
AlgorithmPath = strcat('C:/Users/genius/Desktop/SourceCode/MIREX_2015/OnsetDectector/', char(AlgorithmFile));

%Gauss Curve Simple Size for pulse
gaussCurveSimpleSize = 4400;
 
[y, fs] = audioread(AudioPath);
[status, onsetTime] = MIREX_Machine(AudioPath, AlgorithmPath);


%% CQT of Gaussian Signal
x_gauss = generateSignal(y, fs, onsetTime, gaussCurveSimpleSize);
figure(3); clf;
plot_tempo_spectrogram(x_gauss, fs);
title('Spectrogram: CQT of Gaussian Signal, In The Hall of Mountain King');


%% CQT of Sinusoidal Signal'
x_sine = warped_sine(onsetTime, y, fs);
figure(4); clf;
plot_tempo_spectrogram(x_sine, fs);
title('Spectrogram: CQT of Sinusoidal Signal, In The Hall of Mountain King');

%%

% [tempo, pos] = tempo_by_quantisation(onsetTime, y, fs);
% hold on
% plot(pos, tempo, 'w', 'LineWidth', 4);
% hold off

